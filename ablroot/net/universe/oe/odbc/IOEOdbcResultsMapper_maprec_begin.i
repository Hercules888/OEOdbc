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

    &IF DEFINED(OnlyIterate) &THEN
    &ELSE
    &GLOBAL-DEFINE InOdbcCol IF GET-LONG(mColStrLen_or_ind[
      &GLOBAL-DEFINE NullOrVal ], 1) = -1 THEN ? ELSE 
      
      DEF VAR x__hCallSQLFetch__x AS HANDLE NO-UNDO.
      DEF VAR x__iNrOfRecs__x     AS INT    NO-UNDO.
      def var x__iNrOfRecsThisBatch__x    as int    no-undo.
      def var x__iMaxNrOfRecsPerBatch__x  as int    no-undo.
      def var x__lValidResultsCallback__x as log    no-undo.
      def var x__lValidDefaultTT__x       as log    no-undo.
      def var x__iNrOfBatches__x          as int    no-undo.
      def var x__iMaxNrOfBatches__x       as int    no-undo.
      DEF VAR x__iNrOfCols__x     AS INT    NO-UNDO.
      DEF VAR x__iBatchSize__x    AS INT    NO-UNDO INIT 0.
      DEF VAR x__iRetVal__x       AS INT    NO-UNDO.
      DEF VAR x__q__x             AS INT    NO-UNDO.
      DEF VAR x__hProc__x         AS HANDLE NO-UNDO.
      DEF VAR x__cBatchRoutine__x AS CHAR   NO-UNDO.
      def var x__lClearTT__x              as log    no-undo.
      def var mDBTableCols        as memptr no-undo extent {&MAX_COLS_IN_TABLE}.
      def var mColStrLen_or_ind   as memptr no-undo extent {&MAX_COLS_IN_TABLE}.

      
      assign /* x__iNrOfRecs__x = oPstmt:iNrOfRecs */
             x__iNrOfCols__x = oPstmt:iNrOfCols
             x__lValidDefaultTT__x = valid-handle(hDefaultTempTable)
             x__lValidResultsCallback__x = valid-object(oResultsCallback) and x__lValidDefaultTT__x.

      if not x__lValidResultsCallback__x then
        assign x__iMaxNrOfRecsPerBatch__x = 2147483647
               x__iMaxNrOfBatches__x = 1.
      else 
        assign x__iMaxNrOfRecsPerBatch__x = iNrOfRecsPerBatch
               x__iMaxNrOfBatches__x = 2147483647 / x__iMaxNrOfRecsPerBatch__x.
    
      /* message "MaxNrOfRecsPerBatch: " x__iMaxNrOfRecsPerBatch__x. */
     
      DO x__q__x = 1 TO x__iNrOfCols__x:
          SET-POINTER-VALUE(mDBTableCols[x__q__x])      = GET-POINTER-VALUE(oPStmt:mDBTableCols[x__q__x]).
          SET-POINTER-VALUE(mColStrLen_or_ind[x__q__x]) = GET-POINTER-VALUE(oPStmt:mColStrLen_or_ind[x__q__x]).
      END.
      
      x__hCallSQLFetch__x = OEOdbcApi:Instance:getCallHdlSQLFetch().
      x__hCallSQLFetch__x:set-parameter(1, "{&SQLHSTMT}", "input", oPStmt:iStmtHandle).
      
    &ENDIF

    &IF DEFINED(OnlyVars) &THEN 
    &ELSE
      if x__lValidResultsCallback__x then
        oResultsCallback:onBeforeBatch().

      x__iteraterecords__mainloop__x:
      do x__iNrOfBatches__x = 0 to x__iMaxNrOfBatches__x on stop  undo, leave
                                                         on error undo, leave
                                                         on quit  undo, leave:

        x__iteraterecords__batchloop__x:
        do x__iNrOfRecsThisBatch__x = 0 TO x__iMaxNrOfRecsPerBatch__x - 1 on stop  undo, leave
                                                                          on error undo, leave
                                                                          on quit  undo, leave:
          x__hCallSQLFetch__x:invoke().
          x__iRetVal__x = x__hCallSQLFetch__x:return-value.
          if x__iRetVal__x = {&SQL_SUCCESS} or x__iRetVal__x = {&SQL_SUCCESS_WITH_INFO} then do:
    &ENDIF

