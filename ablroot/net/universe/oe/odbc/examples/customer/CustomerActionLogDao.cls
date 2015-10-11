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

using net.universe.oe.odbc.examples.customer.*.
using net.universe.oe.odbc.*.


ROUTINE-LEVEL ON ERROR UNDO, THROW.
CLASS net.universe.oe.odbc.examples.customer.CustomerActionLogDao:
  {net/universe/oe/odbc/examples/customer/ttCustomerActionLog.i &REFERENCE-ONLY=REFERENCE-ONLY &SCOPE=PRIVATE}

  def PRIVATE var oOdbcCon as OEOdbcConnection no-undo.

  Constructor public CustomerActionLogDao(input oOdbcCon as OEOdbcConnection):
     assign this-object:oOdbcCon = oOdbcCon.
  end constructor.

  &global-define CUSTOMERACTIONLOG_DB_FIELDS "customerId", "logEntryId", "logEntry"
  &global-define CUSTOMERACTIONLOG_DB_TABLE "CustomerActionLog"

  METHOD PUBLIC INT GetAllCustomerActionLogsByCallback(output table ttCustomerActionLog, 
                                                       input oResultsCallback as IOEOdbcResultsCallback,
                                                       input iNrOfRecsPerBatch as int):

    DEF VAR iNrOfRecs AS INT  NO-UNDO.
    def var cSQL      as char no-undo.
   
    DEF VAR oOdbcPStmt                  AS OEOdbcPreparedStatement   NO-UNDO.
    DEF VAR oCustActionLogResultsMapper AS CustomerActionLogResultsMapperGen     NO-UNDO. 

    ASSIGN cSQL = 'select {&CUSTOMERACTIONLOG_DB_FIELDS} from {&CUSTOMERACTIONLOG_DB_TABLE}'.
    
    oOdbcPStmt = oOdbcCon:prepareStatement(cSQL).

    oCustActionLogResultsMapper = NEW CustomerActionLogResultsMapperGen (INPUT TABLE ttCustomerActionLog BIND, oResultsCallback, iNrOfRecsPerBatch).

    iNrOfrecs = oOdbcPStmt:executeQuery(?, oCustActionLogResultsMapper).
    RETURN iNrOfRecs.

    FINALLY:
      IF VALID-OBJECT(oOdbcPstmt) THEN DELETE OBJECT oOdbcPstmt NO-ERROR.
      IF valid-object(oCustActionLogResultsMapper) then delete object oCustActionLogResultsMapper no-error.
    END FINALLY.

  END METHOD.  

END CLASS.  

