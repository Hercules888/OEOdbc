export DLC=/usr/dlc102b

export OEODBCROOT=/home/user/dev/OEOdbc

PATH=$OEODBCROOT/croot:$PATH
$DLC/bin/_progres -cpstream utf-8 -cpinternal utf-8 -b -p $OEODBCROOT/ablroot/net/universe/oe/odbc/examples/runexample-application1.p | cat
