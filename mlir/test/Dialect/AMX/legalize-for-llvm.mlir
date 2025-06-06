// RUN: mlir-opt %s -convert-vector-to-llvm="enable-amx" | mlir-opt | FileCheck %s

// CHECK-LABEL: muli(
// CHECK: llvm.call_intrinsic "llvm.x86.tilezero.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tileloadd64.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tileloadd64.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tdpbuud.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tilestored64.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tdpbssd.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tilestored64.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tdpbusd.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tilestored64.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tdpbsud.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tilestored64.internal"
func.func @muli(%arg0: memref<?x?xi8>, %arg1: memref<?x?xi32>) {
  %0 = arith.constant 0 : index
  %1 = amx.tile_zero : !amx.tile<16x64xi8>
  %2 = amx.tile_load %arg0[%0, %0] : memref<?x?xi8> into !amx.tile<16x64xi8>
  %3 = amx.tile_load %arg1[%0, %0] : memref<?x?xi32> into !amx.tile<16x16xi32>
  %4 = amx.tile_muli %1 zext, %2 zext, %3 : !amx.tile<16x64xi8>, !amx.tile<16x64xi8>, !amx.tile<16x16xi32>
  amx.tile_store %arg1[%0, %0], %4 : memref<?x?xi32>, !amx.tile<16x16xi32>
  %5 = amx.tile_muli %1, %2, %3 : !amx.tile<16x64xi8>, !amx.tile<16x64xi8>, !amx.tile<16x16xi32>
  amx.tile_store %arg1[%0, %0], %5 : memref<?x?xi32>, !amx.tile<16x16xi32>
  %6 = amx.tile_muli %1 zext, %2, %3 : !amx.tile<16x64xi8>, !amx.tile<16x64xi8>, !amx.tile<16x16xi32>
  amx.tile_store %arg1[%0, %0], %6 : memref<?x?xi32>, !amx.tile<16x16xi32>
  %7 = amx.tile_muli %1, %2 zext, %3 : !amx.tile<16x64xi8>, !amx.tile<16x64xi8>, !amx.tile<16x16xi32>
  amx.tile_store %arg1[%0, %0], %7  : memref<?x?xi32>, !amx.tile<16x16xi32>
  return
}

// CHECK-LABEL: mulbf16(
// CHECK: llvm.call_intrinsic "llvm.x86.tilezero.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tileloadd64.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tileloadd64.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tdpbf16ps.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tilestored64.internal"
func.func @mulbf16(%arg0: memref<?x?xbf16>, %arg1: memref<?x?xf32>) {
  %0 = arith.constant 0 : index
  %1 = amx.tile_zero : !amx.tile<16x32xbf16>
  %2 = amx.tile_load %arg0[%0, %0] : memref<?x?xbf16> into !amx.tile<16x32xbf16>
  %3 = amx.tile_load %arg1[%0, %0] : memref<?x?xf32> into !amx.tile<16x16xf32>
  %4 = amx.tile_mulf %1, %2, %3 : !amx.tile<16x32xbf16>, !amx.tile<16x32xbf16>, !amx.tile<16x16xf32>
  amx.tile_store %arg1[%0, %0], %4 : memref<?x?xf32>, !amx.tile<16x16xf32>
  return
}

// CHECK-LABEL: mulfp16(
// CHECK: llvm.call_intrinsic "llvm.x86.tilezero.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tileloadd64.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tileloadd64.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tdpfp16ps.internal"
// CHECK: llvm.call_intrinsic "llvm.x86.tilestored64.internal"
func.func @mulfp16(%arg0: memref<?x?xf16>, %arg1: memref<?x?xf32>) {
  %0 = arith.constant 0 : index
  %1 = amx.tile_zero : !amx.tile<16x32xf16>
  %2 = amx.tile_load %arg0[%0, %0] : memref<?x?xf16> into !amx.tile<16x32xf16>
  %3 = amx.tile_load %arg1[%0, %0] : memref<?x?xf32> into !amx.tile<16x16xf32>
  %4 = amx.tile_mulf %1, %2, %3 : !amx.tile<16x32xf16>, !amx.tile<16x32xf16>, !amx.tile<16x16xf32>
  amx.tile_store %arg1[%0, %0], %4 : memref<?x?xf32>, !amx.tile<16x16xf32>
  return
}

// CHECK-LABEL: strides(
// CHECK: %[[CST_64_1:.+]] = llvm.mlir.constant(64 : i64) : i64
// CHECK: llvm.call_intrinsic "llvm.x86.tileloadd64.internal"(%{{.+}}, %{{.+}}, %{{.+}}, %[[CST_64_1]]
// CHECK: %[[CST_128_1:.+]] = llvm.mlir.constant(128 : i64) : i64
// CHECK: llvm.call_intrinsic "llvm.x86.tileloadd64.internal"(%{{.+}}, %{{.+}}, %{{.+}}, %[[CST_128_1]]
// CHECK: llvm.mlir.constant(2 : i64) : i64
// CHECK: llvm.extractvalue %{{.+}}[4, 0]
// CHECK: %[[STRIDE_1:.+]] = llvm.mul
// CHECK: llvm.call_intrinsic "llvm.x86.tileloadd64.internal"(%{{.+}}, %{{.+}}, %{{.+}}, %[[STRIDE_1]]
// CHECK: %[[CST_64_2:.+]] = llvm.mlir.constant(64 : i64) : i64
// CHECK: llvm.call_intrinsic "llvm.x86.tilestored64.internal"(%{{.+}}, %{{.+}}, %{{.+}}, %[[CST_64_2]]
// CHECK: %[[CST_128_2:.+]] = llvm.mlir.constant(128 : i64) : i64
// CHECK: llvm.call_intrinsic "llvm.x86.tilestored64.internal"(%{{.+}}, %{{.+}}, %{{.+}}, %[[CST_128_2]]
// CHECK: llvm.mlir.constant(2 : i64) : i64
// CHECK: llvm.extractvalue %{{.+}}[4, 0]
// CHECK: %[[STRIDE_2:.+]] = llvm.mul
// CHECK: llvm.call_intrinsic "llvm.x86.tilestored64.internal"(%{{.+}}, %{{.+}}, %{{.+}}, %[[STRIDE_2]]
func.func @strides(%arg0: memref<16x32xbf16>, %arg1: memref<16x32xbf16, strided<[64, 1]>>, %arg2: memref<16x32xbf16, strided<[?, 1]>>) {
  %0 = arith.constant 0 : index
  %1 = amx.tile_load %arg0[%0, %0] : memref<16x32xbf16> into !amx.tile<16x32xbf16>
  %2 = amx.tile_load %arg1[%0, %0] : memref<16x32xbf16, strided<[64, 1]>> into !amx.tile<16x32xbf16>
  %3 = amx.tile_load %arg2[%0, %0] : memref<16x32xbf16, strided<[?, 1]>> into !amx.tile<16x32xbf16>
  amx.tile_store %arg0[%0, %0], %3 : memref<16x32xbf16>, !amx.tile<16x32xbf16>
  amx.tile_store %arg1[%0, %0], %1 : memref<16x32xbf16, strided<[64, 1]>>, !amx.tile<16x32xbf16>
  amx.tile_store %arg2[%0, %0], %2 : memref<16x32xbf16, strided<[?, 1]>>, !amx.tile<16x32xbf16>
  return
}
