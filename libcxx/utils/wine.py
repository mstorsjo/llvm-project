#!/usr/bin/env python
#===----------------------------------------------------------------------===##
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===----------------------------------------------------------------------===##

"""wine.py is a utility for running a program wrapped in Wine.
"""

import argparse
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--execdir', type=str, required=True)
    parser.add_argument('--codesign_identity', type=str, required=False, default=None)
    parser.add_argument('--env', type=str, nargs='*', required=False, default=dict())
    parser.add_argument("command", nargs=argparse.ONE_OR_MORE)
    args = parser.parse_args()
    commandLine = args.command
    commandLine.insert(0, '/usr/bin/wine')

    # Extract environment variables into a dictionary
    env = {k : v  for (k, v) in map(lambda s: s.split('=', 1), args.env)}

    env['WINEPATH'] = env['PATH'].replace('/', '\\')

    # Run the command line with the given environment in the execution directory.
    return subprocess.call(subprocess.list2cmdline(commandLine), cwd=args.execdir, env=env, shell=True)


if __name__ == '__main__':
    exit(main())
