@echo off
rem Use --export-dynamic parameter on ld to export functions into the dynsym section for dynamic linking

rem Use -Wall to display all warnings

set MINGW=C:\Program Files (x86)\mingw-w64\i686-5.3.0-win32-dwarf-rt_v4-rev0\mingw32\
"%MINGW%\bin\gcc.exe" -fPIC -c liboeodbchelper.c -O3 -masm=intel -std=c99
"%MINGW%\bin\gcc.exe" -shared -o liboeodbchelper.dll liboeodbchelper.o 
rem "%MINGW%\bin\ld.exe" -shared -soname liboeodbchelper.so.1.0 -o liboeodbchelper.dll -lc liboeodbchelper.o 

