def var cOEOdbcRoot as char no-undo init 'c:/java/oe-odbc/OEOdbc'.



assign propath = cOEOdbcRoot + '/abltest,' + cOEOdbcRoot + '/ablroot,' + propath.

run net/universe/oe/odbc/test/basebufvartests.p.
