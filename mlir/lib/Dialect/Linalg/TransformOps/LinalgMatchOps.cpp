//===- LinalgTransformOps.cpp - Implementation of Linalg match ops --------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/TransformOps/LinalgMatchOps.h"
#include "mlir/Analysis/SliceAnalysis.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Linalg/IR/LinalgInterfaces.h"
#include "mlir/Dialect/Linalg/TransformOps/Syntax.h"
#include "mlir/Dialect/Linalg/Utils/Utils.h"
#include "mlir/Dialect/Transform/IR/TransformTypes.h"
#include "mlir/Dialect/Transform/Interfaces/MatchInterfaces.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "llvm/Support/DebugLog.h"
#include "llvm/Support/FormatVariadic.h"
#include "llvm/Support/InterleavedRange.h"

using namespace mlir;

#define DEBUG_TYPE "linalg-transforms"

//===----------------------------------------------------------------------===//
// StructuredMatchOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::MatchStructuredOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  // First, check if the payload operation is a structured Linalg operation.
  if (!isa<linalg::LinalgOp>(current)) {
    if (getFailurePropagationMode().value_or(
            FailurePropagationMode::Propagate) ==
        FailurePropagationMode::Propagate) {
      return emitSilenceableError() << "expected a Linalg op";
    }
    // If errors are suppressed, succeed and set all results to empty lists.
    LDBG() << "optional nested matcher expected a Linalg op";
    results.setRemainingToEmpty(cast<TransformOpInterface>(getOperation()));
    return DiagnosedSilenceableFailure::success();
  }

  // Bind `current` to the block argument.
  auto scope = state.make_region_scope(getBodyRegion());
  if (failed(state.mapBlockArgument(getBody()->getArgument(0),
                                    MappedValue(current)))) {
    return DiagnosedSilenceableFailure::definiteFailure();
  }

  for (Operation &nested : getBody()->without_terminator()) {
    DiagnosedSilenceableFailure diag =
        state.applyTransform(cast<TransformOpInterface>(nested));
    if (diag.isDefiniteFailure())
      return diag;
    if (diag.succeeded())
      continue;

    // If propagating errors, do this immediately.
    assert(diag.isSilenceableFailure());
    if (getFailurePropagationMode().value_or(
            FailurePropagationMode::Propagate) ==
        FailurePropagationMode::Propagate) {
      return diag;
    }

    // If suppressing errors, print the message into the debug stream before
    // silencing it. Then set all results value that are already known.
    // Results come from the terminator operands, which may be defined in the
    // (single) block of this operation or above it. When they are defined
    // above, they are known to be mapped at this point per SSA dominance.
    // When they are defined in this block, we additionally check if we have
    // already applied the operation that defines them. If not, the
    // corresponding results will be set to empty lists.
    LDBG() << "optional nested matcher failed: " << diag.getMessage();
    (void)diag.silence();
    SmallVector<OpOperand *> undefinedOperands;
    for (OpOperand &terminatorOperand :
         getBody()->getTerminator()->getOpOperands()) {
      Operation *definingOp = terminatorOperand.get().getDefiningOp();
      if (!definingOp)
        continue;
      if (definingOp->getBlock() != getBody())
        continue;
      if (definingOp->isBeforeInBlock(&nested))
        continue;

      undefinedOperands.push_back(&terminatorOperand);
    }

    SmallVector<SmallVector<transform::MappedValue>> mappings;
    auto filtered = llvm::make_filter_range(
        getBody()->getTerminator()->getOpOperands(), [&](OpOperand &opOperand) {
          return !llvm::is_contained(undefinedOperands, &opOperand);
        });
    SmallVector<Value> definedOperands = llvm::to_vector(llvm::map_range(
        filtered, [](OpOperand &opOperand) { return opOperand.get(); }));
    detail::prepareValueMappings(mappings, definedOperands, state);
    for (auto &&[operand, mapping] : llvm::zip_equal(filtered, mappings)) {
      results.setMappedValues(getResults()[operand.getOperandNumber()],
                              mapping);
    }
    results.setRemainingToEmpty(cast<TransformOpInterface>(getOperation()));
    return DiagnosedSilenceableFailure::success();
  }

  // Set the results.
  detail::forwardTerminatorOperands(getBody(), state, results);
  return DiagnosedSilenceableFailure::success();
}

void transform::MatchStructuredOp::getEffects(
    SmallVectorImpl<MemoryEffects::EffectInstance> &effects) {
  onlyReadsHandle(getCurrentMutable(), effects);
  onlyReadsPayload(effects);
  producesHandle(getOperation()->getOpResults(), effects);
}

LogicalResult transform::MatchStructuredOp::verify() {
  if (getBody()->getNumArguments() != 1)
    return emitOpError() << "expected one body argument";
  if (!isa<TransformHandleTypeInterface>(getBody()->getArgument(0).getType())) {
    return emitOpError() << "expected body argument to implement "
                            "TransformHandleTypeInterface";
  }
  for (Operation &nested : getBody()->without_terminator()) {
    if (isa<MatchOpInterface>(nested))
      continue;
    InFlightDiagnostic diag =
        emitOpError()
        << "expects nested operations to implement MatchOpInterface";
    diag.attachNote(nested.getLoc()) << "offending operation";
    return diag;
  }
  return success();
}

//===----------------------------------------------------------------------===//
// StructuredOpPredicateOpTrait
//===----------------------------------------------------------------------===//

LogicalResult transform::detail::verifyStructuredOpPredicateOpTrait(
    Operation *op, Value structuredOpHandle) {
  if (!isa_and_nonnull<MatchStructuredOp>(op->getParentOp())) {
    return op->emitOpError() << "expects parent op to be '"
                             << MatchStructuredOp::getOperationName() << "'";
  }

  // Bail out here, let the verifier of the parent complain.
  Operation *parent = op->getParentOp();
  if (parent->getNumRegions() < 1 || parent->getRegion(0).empty() ||
      parent->getRegion(0).front().getNumArguments() < 1)
    return success();

  if (structuredOpHandle != parent->getRegion(0).front().getArgument(0)) {
    return op->emitOpError()
           << "expected predicate to apply to the surrounding structured op";
  }
  return success();
}

//===----------------------------------------------------------------------===//
// MatchStructuredBodyOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::MatchStructuredBodyOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  auto linalgOp = cast<linalg::LinalgOp>(current);
  if (std::optional<uint64_t> position = getReductionPosition()) {
    SmallVector<Operation *> combinerOps;
    if (!matchReduction(linalgOp.getRegionOutputArgs(), *position,
                        combinerOps)) {
      return emitSilenceableError() << "could not match reduction";
    }
    if (combinerOps.size() != 1) {
      return emitSilenceableError() << "reduction combiner is not a single op";
    }
    return DiagnosedSilenceableFailure::success();
  }
  if (getPassthrough()) {
    Block &body = linalgOp->getRegion(0).front();
    if (body.getTerminator()->getOperands() != linalgOp.getRegionInputArgs()) {
      return emitSilenceableError() << "not a passthrough";
    }
    return DiagnosedSilenceableFailure::success();
  }
  if (getElementwise()) {
    if (!isElementwise(linalgOp))
      return emitSilenceableError() << "not elementwise";
    return DiagnosedSilenceableFailure::success();
  }
  if (std::optional<ArrayAttr> contractionOps = getContraction()) {
    Block &body = linalgOp->getRegion(0).front();
    std::string message;
    llvm::raw_string_ostream os(message);
    bool result = linalg::detail::isContractionBody(
        body,
        [&](Operation *elem, Operation *red) {
          return elem->getName().getStringRef() ==
                     cast<StringAttr>((*contractionOps)[0]).getValue() &&
                 red->getName().getStringRef() ==
                     cast<StringAttr>((*contractionOps)[1]).getValue();
        },
        os);
    if (result)
      return DiagnosedSilenceableFailure::success();
    return emitSilenceableError() << "contraction: " << message;
  }
  return emitDefiniteFailure() << "unknown body condition";
}

LogicalResult transform::MatchStructuredBodyOp::verify() {
  int64_t numOptions = getReductionPosition().has_value() + getPassthrough() +
                       getElementwise() + getContraction().has_value();

  if (numOptions > 1) {
    StringAttr attributeNames[] = {
        getReductionPositionAttrName(), getPassthroughAttrName(),
        getElementwiseAttrName(), getContractionAttrName()};
    return emitOpError() << "only one of {" << llvm::interleaved(attributeNames)
                         << "} is allowed";
  }

  if (std::optional<ArrayAttr> contractionAttr = getContraction()) {
    if (contractionAttr->size() != 2) {
      return emitOpError() << "expects " << getContractionAttrName()
                           << " to contain two elements";
    }
  }
  return success();
}

//===----------------------------------------------------------------------===//
// MatchStructuredClassifyContractionDimsOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::MatchStructuredClassifyContractionDimsOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  FailureOr<linalg::ContractionDimensions> contractionDims =
      linalg::inferContractionDims(cast<linalg::LinalgOp>(current));
  if (failed(contractionDims))
    return emitSilenceableError() << "could not infer contraction dimensions";

  MLIRContext *context = current->getContext();
  Builder builder(context);
  auto makeI64Attrs = [&](ArrayRef<unsigned> values) {
    return llvm::to_vector(
        llvm::map_range(values, [&](unsigned value) -> Attribute {
          return builder.getI64IntegerAttr(value);
        }));
  };
  results.setParams(cast<OpResult>(getBatch()),
                    makeI64Attrs(contractionDims->batch));
  results.setParams(cast<OpResult>(getM()), makeI64Attrs(contractionDims->m));
  results.setParams(cast<OpResult>(getN()), makeI64Attrs(contractionDims->n));
  results.setParams(cast<OpResult>(getK()), makeI64Attrs(contractionDims->k));
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// MatchStructuredClassifyConvolutionDimsOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::MatchStructuredClassifyConvolutionDimsOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  FailureOr<linalg::ConvolutionDimensions> convolutionDims =
      linalg::inferConvolutionDims(cast<linalg::LinalgOp>(current));
  if (failed(convolutionDims))
    return emitSilenceableError() << "could not infer convolution dimensions";

  MLIRContext *context = current->getContext();
  Builder builder(context);
  auto makeI64Attrs = [&](ArrayRef<unsigned> values) {
    return llvm::to_vector(
        llvm::map_range(values, [&](unsigned value) -> Attribute {
          return builder.getI64IntegerAttr(value);
        }));
  };
  results.setParams(cast<OpResult>(getBatch()),
                    makeI64Attrs(convolutionDims->batch));
  results.setParams(cast<OpResult>(getOutputImage()),
                    makeI64Attrs(convolutionDims->outputImage));
  results.setParams(cast<OpResult>(getOutputChannel()),
                    makeI64Attrs(convolutionDims->outputChannel));
  results.setParams(cast<OpResult>(getFilterLoop()),
                    makeI64Attrs(convolutionDims->filterLoop));
  results.setParams(cast<OpResult>(getInputChannel()),
                    makeI64Attrs(convolutionDims->inputChannel));
  results.setParams(cast<OpResult>(getDepth()),
                    makeI64Attrs(convolutionDims->depth));

  auto makeI64AttrsFromI64 = [&](ArrayRef<int64_t> values) {
    return llvm::to_vector(
        llvm::map_range(values, [&](int64_t value) -> Attribute {
          return builder.getI64IntegerAttr(value);
        }));
  };
  results.setParams(cast<OpResult>(getStrides()),
                    makeI64AttrsFromI64(convolutionDims->strides));
  results.setParams(cast<OpResult>(getDilations()),
                    makeI64AttrsFromI64(convolutionDims->dilations));
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// Utilities for structured match predicates.
//===----------------------------------------------------------------------===//

/// Checks if all values from `list` are also contained in `reference`. Returns
/// a silenceable error with the given message at the given location when it is
/// not the case. The error message must contain the "{0}" placeholder that
/// will be substituted with the value from `list` that is not contained in
/// `reference`.
static DiagnosedSilenceableFailure containsAll(ArrayRef<unsigned> reference,
                                               ArrayRef<int64_t> list,
                                               Location loc,
                                               const char *message) {
  for (int64_t value : list) {
    if (llvm::any_of(reference, [&](unsigned ref) {
          return static_cast<int64_t>(ref) == value;
        })) {
      continue;
    }
    return emitSilenceableFailure(loc) << llvm::formatv(message, value);
  }
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// MatchStructuredDimOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::MatchStructuredDimOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  auto linalgOp = cast<linalg::LinalgOp>(current);
  SmallVector<int64_t> dimensions;
  DiagnosedSilenceableFailure diag = getDimensionsFor(linalgOp, dimensions);
  if (!diag.succeeded())
    return diag;

  // If asked to check for the kind of dimension, perform the check.
  if (getParallel() || getReduction()) {
    SmallVector<unsigned> reference;
    if (getParallel())
      linalgOp.getParallelDims(reference);
    else if (getReduction())
      linalgOp.getReductionDims(reference);

    DiagnosedSilenceableFailure diag =
        containsAll(reference, dimensions, getLoc(),
                    getParallel() ? "expects dimension #{0} to be parallel"
                                  : "expects dimension #{0} to be reduction");
    if (!diag.succeeded())
      return diag;
  }

  // If not capturing, we are done here.
  if (!getResult())
    return diag;

  SmallVector<int64_t, 4> ranges = linalgOp.getStaticLoopRanges();
  Builder builder(current);
  SmallVector<Attribute> captured = llvm::to_vector(
      llvm::map_range(dimensions, [&](int64_t dim) -> Attribute {
        return builder.getI64IntegerAttr(ranges[dim]);
      }));
  results.setParams(cast<OpResult>(getResult()), captured);
  return DiagnosedSilenceableFailure::success();
}

DiagnosedSilenceableFailure transform::MatchStructuredDimOp::getDimensionsFor(
    linalg::LinalgOp op, SmallVectorImpl<int64_t> &dims) {
  DiagnosedSilenceableFailure diag =
      expandTargetSpecification(getLoc(), getIsAll(), getIsInverted(),
                                getRawDimList(), op.getNumLoops(), dims);
  if (diag.isSilenceableFailure()) {
    diag.attachNote(op->getLoc())
        << "while considering dimensions of this payload operation";
  }
  return diag;
}

LogicalResult transform::MatchStructuredDimOp::verify() {
  if (getParallel() && getReduction()) {
    return emitOpError() << "cannot request the same dimension to be both "
                            "parallel and reduction";
  }
  return verifyTransformMatchDimsOp(getOperation(), getRawDimList(),
                                    getIsInverted(), getIsAll());
}

//===----------------------------------------------------------------------===//
// MatchStructuredElementalBitwidthOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::MatchStructuredElementalBitwidthOp::matchValue(
    Value current, transform::TransformResults &results,
    transform::TransformState &state) {
  auto setupResult = [&](int64_t bitwidth) {
    Attribute attr = Builder(current.getContext()).getI64IntegerAttr(bitwidth);
    results.setParams(cast<OpResult>(getResult()), {attr});
    return DiagnosedSilenceableFailure::success();
  };

  Type type = current.getType();
  if (type.isIntOrFloat())
    return setupResult(type.getIntOrFloatBitWidth());

  if (auto shapedType = dyn_cast<ShapedType>(type)) {
    if (shapedType.getElementType().isIntOrFloat())
      return setupResult(shapedType.getElementTypeBitWidth());
  }
  return emitSilenceableError()
         << "unsupported type for bitwidth extraction: " << type;
}

//===----------------------------------------------------------------------===//
// MatchStructuredInputOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::MatchStructuredInputOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  auto linalgOp = cast<linalg::LinalgOp>(current);
  SmallVector<int64_t> positions;
  DiagnosedSilenceableFailure diag = getPositionsFor(linalgOp, positions);
  if (!diag.succeeded())
    return diag;

  SmallVector<MappedValue> operandMapping;
  operandMapping.reserve(positions.size());
  for (int64_t position : positions) {
    AffineMap indexingMap =
        linalgOp.getMatchingIndexingMap(linalgOp.getDpsInputOperand(position));
    if (getPermutation() && !indexingMap.isPermutation()) {
      return emitSilenceableError() << "the indexing map for input #"
                                    << position << " is not a permutation";
    }
    if (getProjectedPermutation() && !indexingMap.isProjectedPermutation()) {
      return emitSilenceableError()
             << "the indexing map for input #" << position
             << " is not a projected permutation";
    }

    // If capture not requested, skip it.
    if (!getResult())
      continue;

    if (isa<AffineMapParamType>(getResult().getType())) {
      operandMapping.emplace_back(AffineMapAttr::get(indexingMap));
      continue;
    }

    Value operand = linalgOp.getDpsInputOperand(position)->get();
    if (isa<TransformValueHandleTypeInterface>(getResult().getType())) {
      operandMapping.emplace_back(operand);
      continue;
    }

    Operation *operandProducer = operand.getDefiningOp();
    if (!operandProducer) {
      return emitSilenceableError()
             << "input #" << position << " is not produced by an operation";
    }
    operandMapping.emplace_back(operandProducer);
  }
  if (getResult())
    results.setMappedValues(cast<OpResult>(getResult()), operandMapping);
  return DiagnosedSilenceableFailure::success();
}

DiagnosedSilenceableFailure transform::MatchStructuredInputOp::getPositionsFor(
    linalg::LinalgOp op, SmallVectorImpl<int64_t> &positions) {
  DiagnosedSilenceableFailure diag = expandTargetSpecification(
      getLoc(), getIsAll(), getIsInverted(), getRawPositionList(),
      op.getNumDpsInputs(), positions);
  if (diag.isSilenceableFailure()) {
    diag.attachNote(op->getLoc())
        << "while considering DPS inputs of this payload operation";
  }
  return diag;
}

/// Verifies a matcher op for structured input or output, specifically the
/// attributes specifying the operand positions.
template <typename OpTy>
LogicalResult verifyStructuredOperandOp(OpTy op) {
  if (op.getPermutation() && op.getProjectedPermutation()) {
    return op.emitOpError()
           << op.getPermutationAttrName() << " and "
           << op.getProjectedPermutationAttrName() << " are mutually exclusive";
  }
  if (op.getRawPositionList().size() > 1 && op.getResult()) {
    return op.emitOpError()
           << "cannot bind multiple inputs/inits to the same value";
  }

  return success();
}

LogicalResult transform::MatchStructuredInputOp::verify() {
  if (failed(verifyStructuredOperandOp(*this)))
    return failure();
  return verifyTransformMatchDimsOp(getOperation(), getRawPositionList(),
                                    getIsInverted(), getIsAll());
}

//===----------------------------------------------------------------------===//
// MatchStructuredInitOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::MatchStructuredInitOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  auto linalgOp = cast<linalg::LinalgOp>(current);
  SmallVector<int64_t> positions;
  DiagnosedSilenceableFailure diag = getPositionsFor(linalgOp, positions);
  if (!diag.succeeded())
    return diag;

  SmallVector<MappedValue> operandMapping;
  operandMapping.reserve(positions.size());
  for (int64_t position : positions) {
    AffineMap indexingMap =
        linalgOp.getMatchingIndexingMap(linalgOp.getDpsInitOperand(position));
    if (getPermutation() && !indexingMap.isPermutation()) {
      return emitSilenceableError() << "the indexing map for output(init) #"
                                    << position << " is not a permutation";
    }
    if (getProjectedPermutation() && !indexingMap.isProjectedPermutation()) {
      return emitSilenceableError() << "the indexing map for output(init) #"
                                    << position << " is not a permutation";
    }

    // If capture not requested, skip it.
    if (!getResult())
      continue;

    if (isa<AffineMapParamType>(getResult().getType())) {
      operandMapping.emplace_back(AffineMapAttr::get(indexingMap));
      continue;
    }

    Value operand = linalgOp.getDpsInitOperand(position)->get();
    if (isa<TransformValueHandleTypeInterface>(getResult().getType())) {
      operandMapping.emplace_back(operand);
      continue;
    }

    Operation *operandProducer = operand.getDefiningOp();
    if (!operandProducer) {
      return emitSilenceableError() << "output(init) #" << position
                                    << " is not produced by an operation";
    }
    operandMapping.emplace_back(operandProducer);
  }
  if (getResult())
    results.setMappedValues(cast<OpResult>(getResult()), operandMapping);
  return DiagnosedSilenceableFailure::success();
}

DiagnosedSilenceableFailure transform::MatchStructuredInitOp::getPositionsFor(
    linalg::LinalgOp op, SmallVectorImpl<int64_t> &positions) {
  DiagnosedSilenceableFailure diag = expandTargetSpecification(
      getLoc(), getIsAll(), getIsInverted(), getRawPositionList(),
      op.getNumDpsInits(), positions);
  if (diag.isSilenceableFailure()) {
    diag.attachNote(op->getLoc())
        << "while considering DPS inits (outputs) of this payload operation";
  }
  return diag;
}

LogicalResult transform::MatchStructuredInitOp::verify() {
  if (failed(verifyStructuredOperandOp(*this)))
    return failure();
  return verifyTransformMatchDimsOp(getOperation(), getRawPositionList(),
                                    getIsInverted(), getIsAll());
}

//===----------------------------------------------------------------------===//
// MatchStructuredNumInputsOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::MatchStructuredNumInputsOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  auto linalgOp = cast<linalg::LinalgOp>(current);
  Attribute attr =
      Builder(current).getI64IntegerAttr(linalgOp.getNumDpsInputs());
  results.setParams(cast<OpResult>(getResult()), {attr});
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// MatchStructuredNumInitsOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::MatchStructuredNumInitsOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  auto linalgOp = cast<linalg::LinalgOp>(current);
  Attribute attr =
      Builder(current).getI64IntegerAttr(linalgOp.getNumDpsInits());
  results.setParams(cast<OpResult>(getResult()), {attr});
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// MatchStructuredRankOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::MatchStructuredRankOp::matchOperation(
    Operation *current, transform::TransformResults &results,
    transform::TransformState &state) {
  auto linalgOp = cast<linalg::LinalgOp>(current);
  int64_t numLoops = linalgOp.getNumLoops();
  Attribute attr = Builder(linalgOp->getContext()).getI64IntegerAttr(numLoops);
  results.setParams(cast<OpResult>(getRank()), {attr});
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// MatchStructuredResultOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::MatchStructuredResultOp::matchOperation(
    Operation *op, transform::TransformResults &results,
    transform::TransformState &state) {
  auto linalgOp = cast<linalg::LinalgOp>(op);
  int64_t position;
  DiagnosedSilenceableFailure diag = getPositionFor(linalgOp, position);
  if (!diag.succeeded())
    return diag;

  Value result = linalgOp.getTiedOpResult(linalgOp.getDpsInitOperand(position));
  if (isa<TransformValueHandleTypeInterface>(getResult().getType())) {
    results.setValues(cast<OpResult>(getResult()), {result});
    return DiagnosedSilenceableFailure::success();
  }

  if (result.getUsers().empty()) {
    return emitSilenceableError()
           << "no users of the result #" << getPosition();
  }
  Operation *firstUser = *result.getUsers().begin();
  if (getAny()) {
    results.set(cast<OpResult>(getResult()), {firstUser});
    return DiagnosedSilenceableFailure::success();
  }
  if (getSingle()) {
    if (!llvm::hasSingleElement(result.getUsers())) {
      return emitSilenceableError()
             << "more than one result user with single user requested";
    }
    results.set(cast<OpResult>(getResult()), {firstUser});
    return DiagnosedSilenceableFailure::success();
  }

  return emitDefiniteFailure() << "unknown sub-predicate";
}

DiagnosedSilenceableFailure
transform::MatchStructuredResultOp::getPositionFor(linalg::LinalgOp op,
                                                   int64_t &position) {
  auto rawPosition = static_cast<int64_t>(getPosition());
  position = rawPosition < 0 ? op.getNumDpsInits() + rawPosition : rawPosition;
  if (position >= op.getNumDpsInits() || position < 0) {
    return emitSilenceableError()
           << "position " << rawPosition
           << " overflows the number of results(ints) of the payload operation";
  }
  return DiagnosedSilenceableFailure::success();
}

LogicalResult transform::MatchStructuredResultOp::verify() {
  if ((getAny() || getSingle()) ^
      isa<TransformHandleTypeInterface>(getResult().getType())) {
    return emitOpError() << "expects either the any/single keyword or the type "
                            "value handle result type";
  }
  if (getAny() && getSingle()) {
    return emitOpError() << "'any' and 'single' are mutually exclusive";
  }
  return success();
}

//===----------------------------------------------------------------------===//
// MatchStructuredYieldOp
//===----------------------------------------------------------------------===//

void transform::MatchStructuredYieldOp::getEffects(
    SmallVectorImpl<MemoryEffects::EffectInstance> &effects) {
  onlyReadsHandle(getHandlesMutable(), effects);
  onlyReadsPayload(effects);
}

void transform::MatchStructuredYieldOp::build(OpBuilder &builder,
                                              OperationState &state) {
  build(builder, state, ValueRange());
}

#define GET_OP_CLASSES
#include "mlir/Dialect/Linalg/TransformOps/LinalgMatchOps.cpp.inc"
