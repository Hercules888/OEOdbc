/*------------------------------------------------------------------------
This file is part of the OEOdbc library, an OpenEdge ABL wrapper
around the ODBC libraries.


Copyright (C) 2013-2015 hercules888@gmail.com

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

http://www.gnu.org/licenses/lgpl-2.1.txt
----------------------------------------------------------------------*/
            /* Here is the success code */
          end.
          else do:
            IF x__iRetVal__x  = {&SQL_NO_DATA} then LEAVE x__iteraterecords__mainloop__x.
            else
              OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, oPStmt:iStmtHandle, x__iRetVal__x, 
                                                                     "unable to fetch record in prepared statement [" + string(x__iRetVal__x) + "]").
          end.
        end. /* batchloop */
        assign x__iNrOfRecs__x = x__iNrOfRecs__x + x__iNrOfRecsThisBatch__x.
        /* message "iNrOfRecs: " x__iNrOfRecs__x. */
        if x__lValidResultsCallback__x then  do:
          oResultsCallback:onNewBatch(input table-handle hDefaultTempTable by-reference, output x__lClearTT__x).
          if x__lValidDefaultTT__x  and x__lClearTT__x then hDefaultTempTable:default-buffer-handle:empty-temp-table(). 
        end. 
        IF x__iRetVal__x  = {&SQL_NO_DATA} then LEAVE x__iteraterecords__mainloop__x.
      END. /* Mainloop */
   
      oPstmt:iNrOfRecs = x__iNrOfRecs__x - 1.
   
      /* Do we have multiple tables from the resultset  */
      x__iRetVal__x = OEOdbcApi:Instance:SQLMoreResults(oPStmt:iStmtHandle).
      if x__iRetVal__x = {&SQL_SUCCESS} or x__iRetVal__x = {&SQL_SUCCESS_WITH_INFO} then do:
        assign x__iRetVal__x = OEOdbcApi:Instance:SQLFreeStmt(oPStmt:iStmtHandle, {&SQL_UNBIND}). 
        OEOdbcUtil:Instance:throwExceptionIfRequired(x__iRetVal__x, "Unable to unbind variables from statement").
      END.
      else if x__iRetVal__x <> {&SQL_NO_DATA} then
        OEOdbcUtil:Instance:throwExceptionIfRequired(x__iRetVal__x, "Unable to fetch next result set").
   
      &IF DEFINED(NoReturn) &THEN &ELSE return x__iRetVal__x &ENDIF.
