//===-- AVRMCCodeEmitter.cpp - Convert AVR Code to Machine Code -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the AVRMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "AVRMCCodeEmitter.h"

#include "MCTargetDesc/AVRMCAsmInfo.h"
#include "MCTargetDesc/AVRMCTargetDesc.h"

#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/EndianStream.h"

#define DEBUG_TYPE "mccodeemitter"

#define GET_INSTRMAP_INFO
#include "AVRGenInstrInfo.inc"
#undef GET_INSTRMAP_INFO

namespace llvm {

static void addFixup(SmallVectorImpl<MCFixup> &Fixups, uint32_t Offset,
                     const MCExpr *Value, uint16_t Kind) {
  bool PCRel = false;
  switch (Kind) {
  case AVR::fixup_7_pcrel:
  case AVR::fixup_13_pcrel:
    PCRel = true;
  }
  Fixups.push_back(MCFixup::create(Offset, Value, Kind, PCRel));
}

/// Performs a post-encoding step on a `LD` or `ST` instruction.
///
/// The encoding of the LD/ST family of instructions is inconsistent w.r.t
/// the pointer register and the addressing mode.
///
/// The permutations of the format are as followed:
/// ld Rd, X    `1001 000d dddd 1100`
/// ld Rd, X+   `1001 000d dddd 1101`
/// ld Rd, -X   `1001 000d dddd 1110`
///
/// ld Rd, Y    `1000 000d dddd 1000`
/// ld Rd, Y+   `1001 000d dddd 1001`
/// ld Rd, -Y   `1001 000d dddd 1010`
///
/// ld Rd, Z    `1000 000d dddd 0000`
/// ld Rd, Z+   `1001 000d dddd 0001`
/// ld Rd, -Z   `1001 000d dddd 0010`
///                 ^
///                 |
/// Note this one inconsistent bit - it is 1 sometimes and 0 at other times.
/// There is no logical pattern. Looking at a truth table, the following
/// formula can be derived to fit the pattern:
//
/// ```
/// inconsistent_bit = is_predec OR is_postinc OR is_reg_x
/// ```
//
/// We manually set this bit in this post encoder method.
unsigned
AVRMCCodeEmitter::loadStorePostEncoder(const MCInst &MI, unsigned EncodedValue,
                                       const MCSubtargetInfo &STI) const {

  assert(MI.getOperand(0).isReg() && MI.getOperand(1).isReg() &&
         "the load/store operands must be registers");

  unsigned Opcode = MI.getOpcode();

  // Get the index of the pointer register operand.
  unsigned Idx = 0;
  if (Opcode == AVR::LDRdPtrPd || Opcode == AVR::LDRdPtrPi ||
      Opcode == AVR::LDRdPtr)
    Idx = 1;

  // Check if we need to set the inconsistent bit
  bool IsPredec = Opcode == AVR::LDRdPtrPd || Opcode == AVR::STPtrPdRr;
  bool IsPostinc = Opcode == AVR::LDRdPtrPi || Opcode == AVR::STPtrPiRr;
  if (MI.getOperand(Idx).getReg() == AVR::R27R26 || IsPredec || IsPostinc)
    EncodedValue |= (1 << 12);

  // Encode the pointer register.
  switch (MI.getOperand(Idx).getReg()) {
  case AVR::R27R26:
    EncodedValue |= 0xc;
    break;
  case AVR::R29R28:
    EncodedValue |= 0x8;
    break;
  case AVR::R31R30:
    break;
  default:
    llvm_unreachable("invalid pointer register");
    break;
  }

  return EncodedValue;
}

template <AVR::Fixups Fixup>
unsigned
AVRMCCodeEmitter::encodeRelCondBrTarget(const MCInst &MI, unsigned OpNo,
                                        SmallVectorImpl<MCFixup> &Fixups,
                                        const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);

  if (MO.isExpr()) {
    addFixup(Fixups, 0, MO.getExpr(), MCFixupKind(Fixup));
    return 0;
  }

  assert(MO.isImm());

  // Take the size of the current instruction away.
  // With labels, this is implicitly done.
  auto target = MO.getImm();
  AVR::fixups::adjustBranchTarget(target);
  return target;
}

/// Encodes a `memri` operand.
/// The operand is 7-bits.
/// * The lower 6 bits is the immediate
/// * The upper bit is the pointer register bit (Z=0,Y=1)
unsigned AVRMCCodeEmitter::encodeMemri(const MCInst &MI, unsigned OpNo,
                                       SmallVectorImpl<MCFixup> &Fixups,
                                       const MCSubtargetInfo &STI) const {
  auto RegOp = MI.getOperand(OpNo);
  auto OffsetOp = MI.getOperand(OpNo + 1);

  assert(RegOp.isReg() && "Expected register operand");

  uint8_t RegBit = 0;

  switch (RegOp.getReg().id()) {
  default:
    Ctx.reportError(MI.getLoc(), "Expected either Y or Z register");
    return 0;
  case AVR::R31R30:
    RegBit = 0;
    break; // Z register
  case AVR::R29R28:
    RegBit = 1;
    break; // Y register
  }

  int8_t OffsetBits;

  if (OffsetOp.isImm()) {
    OffsetBits = OffsetOp.getImm();
  } else if (OffsetOp.isExpr()) {
    OffsetBits = 0;
    addFixup(Fixups, 0, OffsetOp.getExpr(), AVR::fixup_6);
  } else {
    llvm_unreachable("Invalid value for offset");
  }

  return (RegBit << 6) | OffsetBits;
}

unsigned AVRMCCodeEmitter::encodeComplement(const MCInst &MI, unsigned OpNo,
                                            SmallVectorImpl<MCFixup> &Fixups,
                                            const MCSubtargetInfo &STI) const {
  // The operand should be an immediate.
  assert(MI.getOperand(OpNo).isImm());

  auto Imm = MI.getOperand(OpNo).getImm();
  return (~0) - Imm;
}

template <AVR::Fixups Fixup, unsigned Offset>
unsigned AVRMCCodeEmitter::encodeImm(const MCInst &MI, unsigned OpNo,
                                     SmallVectorImpl<MCFixup> &Fixups,
                                     const MCSubtargetInfo &STI) const {
  auto MO = MI.getOperand(OpNo);

  if (MO.isExpr()) {
    if (isa<AVRMCExpr>(MO.getExpr())) {
      // If the expression is already an AVRMCExpr (i.e. a lo8(symbol),
      // we shouldn't perform any more fixups. Without this check, we would
      // instead create a fixup to the symbol named 'lo8(symbol)' which
      // is not correct.
      return getExprOpValue(MO.getExpr(), Fixups, STI);
    }

    MCFixupKind FixupKind = static_cast<MCFixupKind>(Fixup);
    addFixup(Fixups, Offset, MO.getExpr(), FixupKind);

    return 0;
  }

  assert(MO.isImm());
  return MO.getImm();
}

unsigned AVRMCCodeEmitter::encodeCallTarget(const MCInst &MI, unsigned OpNo,
                                            SmallVectorImpl<MCFixup> &Fixups,
                                            const MCSubtargetInfo &STI) const {
  auto MO = MI.getOperand(OpNo);

  if (MO.isExpr()) {
    MCFixupKind FixupKind = AVR::fixup_call;
    addFixup(Fixups, 0, MO.getExpr(), FixupKind);
    return 0;
  }

  assert(MO.isImm());

  auto Target = MO.getImm();
  AVR::fixups::adjustBranchTarget(Target);
  return Target;
}

unsigned AVRMCCodeEmitter::getExprOpValue(const MCExpr *Expr,
                                          SmallVectorImpl<MCFixup> &Fixups,
                                          const MCSubtargetInfo &STI) const {

  MCExpr::ExprKind Kind = Expr->getKind();

  if (Kind == MCExpr::Binary) {
    Expr = static_cast<const MCBinaryExpr *>(Expr)->getLHS();
    Kind = Expr->getKind();
  }

  if (Kind == MCExpr::Specifier) {
    AVRMCExpr const *AVRExpr = cast<AVRMCExpr>(Expr);
    int64_t Result;
    if (AVRExpr->evaluateAsConstant(Result)) {
      return Result;
    }

    MCFixupKind FixupKind = static_cast<MCFixupKind>(AVRExpr->getFixupKind());
    addFixup(Fixups, 0, AVRExpr, FixupKind);
    return 0;
  }

  assert(Kind == MCExpr::SymbolRef);
  return 0;
}

unsigned AVRMCCodeEmitter::getMachineOpValue(const MCInst &MI,
                                             const MCOperand &MO,
                                             SmallVectorImpl<MCFixup> &Fixups,
                                             const MCSubtargetInfo &STI) const {
  if (MO.isReg())
    return Ctx.getRegisterInfo()->getEncodingValue(MO.getReg());
  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  if (MO.isDFPImm())
    return static_cast<unsigned>(bit_cast<double>(MO.getDFPImm()));

  // MO must be an Expr.
  assert(MO.isExpr());

  return getExprOpValue(MO.getExpr(), Fixups, STI);
}

void AVRMCCodeEmitter::encodeInstruction(const MCInst &MI,
                                         SmallVectorImpl<char> &CB,
                                         SmallVectorImpl<MCFixup> &Fixups,
                                         const MCSubtargetInfo &STI) const {
  const MCInstrDesc &Desc = MCII.get(MI.getOpcode());

  // Get byte count of instruction
  unsigned Size = Desc.getSize();

  assert(Size > 0 && "Instruction size cannot be zero");

  uint64_t BinaryOpCode = getBinaryCodeForInstr(MI, Fixups, STI);

  for (int64_t i = Size / 2 - 1; i >= 0; --i) {
    uint16_t Word = (BinaryOpCode >> (i * 16)) & 0xFFFF;
    support::endian::write(CB, Word, llvm::endianness::little);
  }
}

MCCodeEmitter *createAVRMCCodeEmitter(const MCInstrInfo &MCII, MCContext &Ctx) {
  return new AVRMCCodeEmitter(MCII, Ctx);
}

#include "AVRGenMCCodeEmitter.inc"

} // end of namespace llvm
