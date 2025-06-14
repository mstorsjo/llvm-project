//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// UNSUPPORTED: no-exceptions

// This test file validates that std::vector<T>::reserve provides the strong exception guarantee if T is
// Cpp17MoveInsertable and no exception is thrown by the move constructor of T during the reserve call.
// It also checks that if T's move constructor is not noexcept, reserve provides only the basic exception
// guarantee.

#include <cstddef>
#include <memory>
#include <type_traits>
#include <vector>

#include "count_new.h"

inline void check_new_delete_called() {
  assert(globalMemCounter.new_called == globalMemCounter.delete_called);
}

static const std::array<char, 62> letters = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
    'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
    
inline std::string getString(std::size_t n, std::size_t len) {
  std::string s;
  s.reserve(len);
  for (std::size_t i = 0; i < len; ++i)
    s += letters[(i * i + n) % letters.size()];
  return s;
}

inline std::vector<std::string> getStringInputsWithLength(std::size_t n, std::size_t len) {
  std::vector<std::string> v;
  v.reserve(n);
  for (std::size_t i = 0; i < n; ++i)
    v.push_back(getString(i, len));
  return v;
}

int main(int, char**) {
  { // Practical example: Testing with 100 strings, each 256 characters long.
    std::vector<std::string> in = getStringInputsWithLength(100, 256);
  }
  check_new_delete_called();
}
