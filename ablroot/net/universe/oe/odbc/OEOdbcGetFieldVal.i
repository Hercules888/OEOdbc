( &IF DEFINED(NoNull) &THEN &ELSE IF GET-LONG(mColStrLen_or_ind[{&Idx}], 1) = -1 THEN ? ELSE &ENDIF GET-{&AsType}(mDBTableCols[{&Idx}], 1) )
