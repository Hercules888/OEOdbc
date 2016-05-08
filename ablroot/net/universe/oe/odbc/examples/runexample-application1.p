&if opsys = 'win32' &then
assign propath='c:\java\oe-odbc\oeodbc\ablroot,' + propath.
&endif
&if '{&opsys}' = 'unix' &then
assign propath='/home/user/dev/OEOdbc/ablroot,' + propath.
&endif
run net/universe/oe/odbc/examples/example-application1.p.
