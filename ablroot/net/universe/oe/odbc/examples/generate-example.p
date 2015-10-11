/*------------------------------------------------------------------------
This file is part of the OEOdbc library, an OpenEdge ABL wrapper
around the ODBC libraries.


Copyright (C) 2013 hercules888@gmail.com

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

using net.universe.oe.odbc.*.

def var cServerName     as char no-undo init 'testdbdsn'.
def var cUserName       as char no-undo init 'postgres'.
def var cAuthentication as char no-undo init 'pgadmin'.

def var oEnv           as OEOdbcEnvironment              no-undo.
def var oCon           as OEOdbcConnection               no-undo.
def var oStmt          as OEOdbcPreparedStatement        no-undo.
def var oParamsMapper  as IOEOdbcParamsMapper            no-undo.
def var oResultsMapper as OEOdbcCodeWritingResultsMapper no-undo.

def var iNrOfRecs as int no-undo init -1.

/* A dummy temp-table is used to pass on for now */
def temp-table ttDummy no-undo
  field fldDummy as int.


def var cRootPath as char no-undo init 'C:/test/oeodbc/github/OEOdbc/ablroot/'. 



/* Initialize the ODBC environment */
oEnv = new OeOdbcEnvironment().

/* Get a connection to the database */
oCon = oEnv:GetConnection(cServerName, cUserName, cAuthentication).

/* Generate 1st table */

assign oParamsMapper = new OEOdbcGenericParamsMapper().
assign oResultsMapper = new OEOdbcCodeWritingResultsMapper(input table ttDummy).

oResultsMapper:cOEOdbcPackage   = "net.universe.oe.odbc.examples.customer".
oResultsMapper:cOEOdbcClass     = "CustomerResultsMapperGen".
oResultsMapper:cOEOdbcTemptable = "ttCustomer".
oResultsMapper:cOutputFilePath  = cRootPath + replace(oResultsMapper:cOEOdbcPackage, '.','/') + '/' + oResultsMapper:cOEOdbcClass + ".cls".

oStmt = new OEOdbcPreparedStatement(oCon, 'select "customerId", "customerName", "isActive", "AnnualIncome", "Sex", "State" /* , "birthDate", "createdOn" */ from  "Customer" offset 0 limit 1').

iNrOfrecs = oStmt:executeQuery(oParamsMapper, oResultsMapper).

oResultsMapper:cTemplateFilePath = 'net/universe/oe/odbc/temptable.template'.
oResultsMapper:cOutputFilePath   = cRootPath + replace(oResultsMapper:cOEOdbcPackage, '.','/') +  '/' + oResultsMapper:cOEOdbcTempTable + ".i".

iNrOfrecs = oStmt:executeQuery(oParamsMapper, oResultsMapper).

delete object oParamsMapper.
delete object oResultsMapper.
delete object oStmt.


/* Generate 2nd table */

assign oParamsMapper = new OEOdbcGenericParamsMapper().
assign oResultsMapper = new OEOdbcCodeWritingResultsMapper(input table ttDummy).

oResultsMapper:cOEOdbcPackage   = "net.universe.oe.odbc.examples.customer".
oResultsMapper:cOEOdbcClass     = "CustomerActionLogResultsMapperGen".
oResultsMapper:cOEOdbcTemptable = "ttCustomerActionLog".

oResultsMapper:cOutputFilePath  = cRootPath + replace(oResultsMapper:cOEOdbcPackage, '.','/') + '/' + oResultsMapper:cOEOdbcClass + ".cls".
oStmt = new OEOdbcPreparedStatement(oCon, 'select "customerId", "logEntryId", "logEntry" from "CustomerActionLog" offset 0 limit 1').

iNrOfrecs = oStmt:executeQuery(oParamsMapper, oResultsMapper).

oResultsMapper:cTemplateFilePath = 'net/universe/oe/odbc/temptable.template'.
oResultsMapper:cOutputFilePath   = cRootPath + replace(oResultsMapper:cOEOdbcPackage, '.','/') +  '/' + oResultsMapper:cOEOdbcTempTable + ".i".

iNrOfrecs = oStmt:executeQuery(oParamsMapper, oResultsMapper).


delete object oParamsMapper.
delete object oResultsMapper.
delete object oStmt.
delete object oCon.
delete object oEnv.




