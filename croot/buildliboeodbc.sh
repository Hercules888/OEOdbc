#!/bin/bash
#Use --export-dynamic parameter on ld to export functions into the dynsym section for dynamic linking
# Use -Wall to display all warnings

gcc -fPIC -c liboeodbchelper.c -O3 -masm=intel -std=c99
gcc -shared -o liboeodbchelper.dll liboeodbchelper.o 
#ld -shared -soname liboeodbchelper.so.1.0 -o liboeodbchelper.so -lc liboeodbchelper.o 

