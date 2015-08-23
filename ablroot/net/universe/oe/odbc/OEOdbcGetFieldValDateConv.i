( &IF DEFINED(NoNull) &THEN &ELSE IF GET-LONG(mColStrLen_or_ind[{&Idx}], 1) < 2 THEN ? ELSE &ENDIF 
date(get-short(x__mDTMonthTmp{&Idx}__x, 1), get-short(x__mDTDayTmp{&Idx}__x, 1), GET-short(mDBTableCols[{&Idx}], 1) )  )
