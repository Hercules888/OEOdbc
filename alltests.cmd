@echo off
setlocal
set DLC=c:\progressx86\openedge
set OEODBCROOT=c:/java/oe-odbc/oeodbc
set PATH=%OEODBCROOT%\croot;%PATH%
%DLC%\bin\prowin32.exe -cpstream utf-8 -cpinternal utf-8 -b -p "%OEODBCROOT%/abltest/net/universe/oe/odbc/test/runtests.p" | cat
endlocal