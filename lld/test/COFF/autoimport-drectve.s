# REQUIRES: x86

# RUN: echo -e ".global variable\n.global DllMainCRTStartup\n.text\nDllMainCRTStartup:\nret\n.data\nvariable:\n.long 42" > %t-lib.s
# RUN: llvm-mc -triple=x86_64-windows-gnu %t-lib.s -filetype=obj -o %t-lib.obj
# RUN: lld-link -out:%t-lib.dll -dll -entry:DllMainCRTStartup %t-lib.obj -lldmingw -implib:%t-lib.lib

# RUN: llvm-mc -triple=x86_64-windows-gnu %s -filetype=obj -o %t.obj
# RUN: not lld-link -lldmingw -out:%t.exe -entry:main %t.obj %t-lib.lib 2>&1 | FileCheck %s

## Check that we can disable runtime pseudo relocs via a .drectve in a
## linked object file:
##
# CHECK: error: automatic dllimport of variable in {{.*}}/autoimport-drectve.s.tmp.obj requires pseudo relocations

    .global main
    .text
main:
    movl variable(%rip), %eax
    ret
    .data
ptr:
    .quad variable

    .section .drectve
    .ascii "-runtime-pseudo-reloc:no"
