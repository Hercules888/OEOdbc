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

using net.universe.oe.odbc.*.
{net/universe/oe/odbc/oe-odbc-defs.i}

class net.universe.oe.odbc.OEOdbcApi:
  def private var hCallSQLAllocHandle    as handle no-undo.
  def private var hCallSQLFreeHandle     as handle no-undo.
  def private var hCallSQLSetEnvAttr     as handle no-undo.
  def private var hCallSQLSetConnectAttr as handle no-undo.
  def private var hCallSQLDisconnect     as handle no-undo.
  def private var hCallSQLConnect        as handle no-undo.
  def private var hCallSQLDriverConnect  as handle no-undo.
  def private var hCallSQLPrepare        as handle no-undo.
  def private var hCallSQLNumResultCols  as handle no-undo.
  def private var hCallSQLDescribeCol    as handle no-undo.
  def private var hCallSQLBindCol        as handle no-undo.
  def private var hCallSQLBindColV2      as handle no-undo.
  def private var hCallSQLExecute        as handle no-undo.
  def private var hCallSQLFetch          as handle no-undo.
  def private var hCallSQLCloseCursor    as handle no-undo.
  def private var hCallSQLSetStmtOption  as handle no-undo.
  def private var hCallSQLGetDiagRec     as handle no-undo.
  def private var hCallSQLBindParameter  as handle no-undo.
  def private var hCallSQLBindParamInt   as handle no-undo.     /* Specific sqlbindparameter for integer   - for performance */
  def private var hCallSQLBindParamChar  as handle no-undo.     /* Specific sqlbindparameter for character - for performance */
  def private var hCallSQLBindParamBit   as handle no-undo.     /* Specific sqlbindparameter for bit       - for performance */
  def private var hCallSQLBindParamLong  as handle no-undo.     /* Specific sqlbindparameter for int64     - for performance */
  def private var hCallSQLBindParamDate  as handle no-undo.     /* Specific sqlbindparameter for date      - for performance */
  def private var hCallSQLBindParamTimestamp as handle no-undo. /* Specific sqlbindparameter for timestamp - for performance */
  def private var hCallSQLMoreResults    as handle no-undo. 
  def private var hCallSQLFreeStmt       as handle no-undo.
  
  def private var mColumnName  as memptr no-undo.
  DEF PRIVATE VAR mSQLState    AS MEMPTR NO-UNDO.
  DEF PRIVATE VAR mMessageText AS MEMPTR NO-UNDO.
  
  /* Get the only instance of this class by this property */
  def public static property Instance as OEOdbcApi no-undo
  public get():
    if Instance = ? then Instance = new OEOdbcApi().
    return Instance.
  end.
  private set.


  method public handle getCallHdlSQLFetch():
    return hCallSQLFetch.
  end method.

  method public handle getCallHdlSQLBindParamInt():
    return hCallSQLBindParamInt.
  end method.

  method public handle getCallHdlSQLBindParamChar():
    return hCallSQLBindParamChar.
  end method.

  method public handle getCallHdlSQLBindParamBit():
    return hCallSQLBindParamBit.
  end method.
  
  method public handle getCallHdlSQLBindParamLong():
    return hCallSQLBindParamLong.
  end method.

  method public handle getCallHdlSQLBindParamDate():
    return hCallSQLBindParamDate.
  end method.

  method public handle getCallHdlSQLBindParamTimestamp():
    return hCallSQLBindParamTimestamp.
  end method.


  destructor public OEOdbcApi():
    delete object hCallSQLAllocHandle    no-error.
    delete object hCallSQLFreeHandle     no-error.
    delete object hCallSQLSetEnvAttr     no-error.
    delete object hCallSQLSetConnectAttr no-error.
    delete object hCallSQLDisconnect     no-error.
    delete object hCallSQLConnect        no-error.
    delete object hCallSQLDriverConnect  no-error.
    delete object hCallSQLPrepare        no-error.
    delete object hCallSQLNumResultCols  no-error.
    delete object hCallSQLDescribeCol    no-error.
    delete object hCallSQLBindCol        no-error.
    delete object hCallSQLBindColV2      no-error.
    delete object hCallSQLExecute        no-error.
    delete object hCallSQLFetch          no-error.
    delete object hCallSQLCloseCursor    no-error.
    delete object hCallSQLSetStmtOption  no-error.
    delete object hCallSQLGetDiagRec     no-error.
    delete object hCallSQLBindParameter  no-error.
    delete object hCallSQLBindParamInt   no-error.
    delete object hCallSQLBindParamChar  no-error.
    delete object hCallSQLBindParamBit   no-error.
    delete object hCallSQLBindParamLong  no-error.
    delete object hCallSQLBindParamDate  no-error.
    delete object hCallSQLBindParamTimestamp  no-error.
    delete object hCallSQLMoreResults    no-error.
    delete object hCallSQLFreeStmt       no-error.



    set-size(mColumnName) = 0.
    SET-SIZE(mSQLState) = 0.
    SET-SIZE(mMessageText) = 0.
  end destructor.
  
  constructor private OEOdbcApi():
    set-size(mColumnName)  = {&MAX_COL_NAME_LEN}.
    set-size(mMessageText) = {&MAX_MSG_TEXT_LEN}.
    SET-SIZE(mSQLState)     = 6.

    create call hCallSQLAllocHandle.
    assign hCallSQLAllocHandle:call-name                  = 'SQLAllocHandle'
           hCallSQLAllocHandle:library                    = '{&LIBODBC_SO}'
           hCallSQLAllocHandle:call-type                  = dll-call-type
           hCallSQLAllocHandle:persistent                 = true
           hCallSQLAllocHandle:num-parameters             = 3
           hCallSQLAllocHandle:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLAllocHandle:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLFreeHandle.
    assign hCallSQLFreeHandle:call-name                  = 'SQLFreeHandle'
           hCallSQLFreeHandle:library                    = '{&LIBODBC_SO}'
           hCallSQLFreeHandle:call-type                  = dll-call-type
           hCallSQLFreeHandle:persistent                 = true
           hCallSQLFreeHandle:num-parameters             = 2
           hCallSQLFreeHandle:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLFreeHandle:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLSetEnvAttr.
    assign hCallSQLSetEnvAttr:call-name                  = 'SQLSetEnvAttr'
           hCallSQLSetEnvAttr:library                    = '{&LIBODBC_SO}'
           hCallSQLSetEnvAttr:call-type                  = dll-call-type
           hCallSQLSetEnvAttr:persistent                 = true
           hCallSQLSetEnvAttr:num-parameters             = 4
           hCallSQLSetEnvAttr:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLSetEnvAttr:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLSetConnectAttr.
    assign hCallSQLSetConnectAttr:call-name                  = 'SQLSetConnectAttr'
           hCallSQLSetConnectAttr:library                    = '{&LIBODBC_SO}'
           hCallSQLSetConnectAttr:call-type                  = dll-call-type
           hCallSQLSetConnectAttr:persistent                 = true
           hCallSQLSetConnectAttr:num-parameters             = 4
           hCallSQLSetConnectAttr:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLSetConnectAttr:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLDisconnect.
    assign hCallSQLDisconnect:call-name                  = 'SQLDisconnect'
           hCallSQLDisconnect:library                    = '{&LIBODBC_SO}'
           hCallSQLDisconnect:call-type                  = dll-call-type
           hCallSQLDisconnect:persistent                 = true
           hCallSQLDisconnect:num-parameters             = 1
           hCallSQLDisconnect:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLDisconnect:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLConnect.
    assign hCallSQLConnect:call-name                  = 'SQLConnect'
           hCallSQLConnect:library                    = '{&LIBODBC_SO}'
           hCallSQLConnect:call-type                  = dll-call-type
           hCallSQLConnect:persistent                 = true
           hCallSQLConnect:num-parameters             = 7
           hCallSQLConnect:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLConnect:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLDriverConnect.
    assign hCallSQLDriverConnect:call-name                  = 'SQLDriverConnect'
           hCallSQLDriverConnect:library                    = '{&LIBODBC_SO}'
           hCallSQLDriverConnect:call-type                  = dll-call-type
           hCallSQLDriverConnect:persistent                 = true
           hCallSQLDriverConnect:num-parameters             = 8
           hCallSQLDriverConnect:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLDriverConnect:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLPrepare.
    assign hCallSQLPrepare:call-name                  = 'SQLPrepare'
           hCallSQLPrepare:library                    = '{&LIBODBC_SO}'
           hCallSQLPrepare:call-type                  = dll-call-type
           hCallSQLPrepare:persistent                 = true
           hCallSQLPrepare:num-parameters             = 3
           hCallSQLPrepare:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLPrepare:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLNumResultCols.
    assign hCallSQLNumResultCols:call-name                  = 'SQLNumResultCols'
           hCallSQLNumResultCols:library                    = '{&LIBODBC_SO}'
           hCallSQLNumResultCols:call-type                  = dll-call-type
           hCallSQLNumResultCols:persistent                 = true
           hCallSQLNumResultCols:num-parameters             = 2
           hCallSQLNumResultCols:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLNumResultCols:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLDescribeCol.
    assign hCallSQLDescribeCol:call-name                  = 'SQLDescribeCol'
           hCallSQLDescribeCol:library                    = '{&LIBODBC_SO}'
           hCallSQLDescribeCol:call-type                  = dll-call-type
           hCallSQLDescribeCol:persistent                 = true
           hCallSQLDescribeCol:num-parameters             = 9
           hCallSQLDescribeCol:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLDescribeCol:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLBindCol.
    assign hCallSQLBindCol:call-name                  = 'SQLBindCol'
           hCallSQLBindCol:library                    = '{&LIBODBC_SO}'
           hCallSQLBindCol:call-type                  = dll-call-type
           hCallSQLBindCol:persistent                 = true
           hCallSQLBindCol:num-parameters             = 6
           hCallSQLBindCol:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLBindCol:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLBindColV2.
    assign hCallSQLBindColV2:call-name                  = 'SQLBindCol'
           hCallSQLBindColV2:library                    = '{&LIBODBC_SO}'
           hCallSQLBindColV2:call-type                  = dll-call-type
           hCallSQLBindColV2:persistent                 = true
           hCallSQLBindColV2:num-parameters             = 6
           hCallSQLBindColV2:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLBindColV2:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLBindParameter.
    assign hCallSQLBindParameter:call-name                  = 'SQLBindParameter'
           hCallSQLBindParameter:library                    = '{&LIBODBC_SO}'
           hCallSQLBindParameter:call-type                  = dll-call-type
           hCallSQLBindParameter:persistent                 = true
           hCallSQLBindParameter:num-parameters             = 10
           hCallSQLBindParameter:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLBindParameter:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLBindParamInt.
    assign hCallSQLBindParamInt:call-name                  = 'SQLBindParameter'
           hCallSQLBindParamInt:library                    = '{&LIBODBC_SO}'
           hCallSQLBindParamInt:call-type                  = dll-call-type
           hCallSQLBindParamInt:persistent                 = true
           hCallSQLBindParamInt:num-parameters             = 10
           hCallSQLBindParamInt:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLBindParamInt:library-calling-convention = "{&DECLTYPE}".


    /* Pre-initialized values for binding integer parameter */
    hCallSQLBindParamInt:set-parameter(3,  "{&SQLSMALLINT}",  "input",   {&SQL_PARAM_INPUT}).
    hCallSQLBindParamInt:set-parameter(4,  "{&SQLSMALLINT}",  "input",   {&SQL_C_LONG}). /* The C value type */
    hCallSQLBindParamInt:set-parameter(5,  "{&SQLSMALLINT}",  "input",   {&SQL_INTEGER}). /* The SQL parameter type */
    hCallSQLBindParamInt:set-parameter(6,  "{&SQLULEN}",      "input",   0).
    hCallSQLBindParamInt:set-parameter(7,  "{&SQLSMALLINT}",  "input",   0).
    hCallSQLBindParamInt:set-parameter(9,  "{&SQLLEN}",       "input",   4). /* The length of the buffer containing the data */.

    create call hCallSQLBindParamChar.
    assign hCallSQLBindParamChar:call-name                  = 'SQLBindParameter'
           hCallSQLBindParamChar:library                    = '{&LIBODBC_SO}'
           hCallSQLBindParamChar:call-type                  = dll-call-type
           hCallSQLBindParamChar:persistent                 = true
           hCallSQLBindParamChar:num-parameters             = 10
           hCallSQLBindParamChar:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLBindParamChar:library-calling-convention = "{&DECLTYPE}".

    /* Pre-initialized values for binding integer parameter */
    hCallSQLBindParamChar:set-parameter(3,  "{&SQLSMALLINT}",  "input",   {&SQL_PARAM_INPUT}).
    hCallSQLBindParamChar:set-parameter(4,  "{&SQLSMALLINT}",  "input",   {&SQL_C_CHAR}). /* The C value type */
    hCallSQLBindParamChar:set-parameter(5,  "{&SQLSMALLINT}",  "input",   {&SQL_VARCHAR}). /* The SQL parameter type */
    hCallSQLBindParamChar:set-parameter(7,  "{&SQLSMALLINT}",  "input",   0).

    create call hCallSQLBindParamBit.
    assign hCallSQLBindParamBit:call-name                  = 'SQLBindParameter'
           hCallSQLBindParamBit:library                    = '{&LIBODBC_SO}'
           hCallSQLBindParamBit:call-type                  = dll-call-type
           hCallSQLBindParamBit:persistent                 = true
           hCallSQLBindParamBit:num-parameters             = 10
           hCallSQLBindParamBit:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLBindParamBit:library-calling-convention = "{&DECLTYPE}".


    /* Pre-initialized values for binding integer parameter */
    hCallSQLBindParamBit:set-parameter(3,  "{&SQLSMALLINT}",  "input",   {&SQL_PARAM_INPUT}).
    hCallSQLBindParamBit:set-parameter(4,  "{&SQLSMALLINT}",  "input",   {&SQL_C_BIT}). /* The C value type */
    hCallSQLBindParamBit:set-parameter(5,  "{&SQLSMALLINT}",  "input",   {&SQL_BIT}). /* The SQL parameter type */
    hCallSQLBindParamBit:set-parameter(6,  "{&SQLULEN}",      "input",   0).
    hCallSQLBindParamBit:set-parameter(7,  "{&SQLSMALLINT}",  "input",   0).
    hCallSQLBindParamBit:set-parameter(9,  "{&SQLLEN}",       "input",   1). /* The length of the buffer containing the data */.

    create call hCallSQLBindParamLong.
    assign hCallSQLBindParamLong:call-name                  = 'SQLBindParameter'
           hCallSQLBindParamLong:library                    = '{&LIBODBC_SO}'
           hCallSQLBindParamLong:call-type                  = dll-call-type
           hCallSQLBindParamLong:persistent                 = true
           hCallSQLBindParamLong:num-parameters             = 10
           hCallSQLBindParamLong:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLBindParamLong:library-calling-convention = "{&DECLTYPE}".


    /* Pre-initialized values for binding long parameter */
    hCallSQLBindParamLong:set-parameter(3,  "{&SQLSMALLINT}",  "input",   {&SQL_PARAM_INPUT}).
    hCallSQLBindParamLong:set-parameter(4,  "{&SQLSMALLINT}",  "input",   {&SQL_C_SBIGINT}). /* The C value type */
    hCallSQLBindParamLong:set-parameter(5,  "{&SQLSMALLINT}",  "input",   {&SQL_BIGINT}).    /* The SQL parameter type */
    hCallSQLBindParamLong:set-parameter(6,  "{&SQLULEN}",      "input",   0).
    hCallSQLBindParamLong:set-parameter(7,  "{&SQLSMALLINT}",  "input",   0).
    hCallSQLBindParamLong:set-parameter(9,  "{&SQLLEN}",       "input",   8). /* The length of the buffer containing the data */.

    create call hCallSQLBindParamDate.
    assign hCallSQLBindParamDate:call-name                  = 'SQLBindParameter'
           hCallSQLBindParamDate:library                    = '{&LIBODBC_SO}'
           hCallSQLBindParamDate:call-type                  = dll-call-type
           hCallSQLBindParamDate:persistent                 = true
           hCallSQLBindParamDate:num-parameters             = 10
           hCallSQLBindParamDate:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLBindParamDate:library-calling-convention = "{&DECLTYPE}".

    /* Todo: Add possibilty to lazy-init */

    /* Pre-initialized values for binding date parameter */
    hCallSQLBindParamDate:set-parameter(3,  "{&SQLSMALLINT}",  "input",   {&SQL_PARAM_INPUT}).
    hCallSQLBindParamDate:set-parameter(4,  "{&SQLSMALLINT}",  "input",   {&SQL_C_TYPE_DATE}). /* The C value type */
    hCallSQLBindParamDate:set-parameter(5,  "{&SQLSMALLINT}",  "input",   {&SQL_TIMESTAMP}).    /* The SQL parameter type */
    hCallSQLBindParamDate:set-parameter(6,  "{&SQLULEN}",      "input",   {&SQL_DATE_LEN}).
    hCallSQLBindParamDate:set-parameter(7,  "{&SQLSMALLINT}",  "input",   0).
    hCallSQLBindParamDate:set-parameter(9,  "{&SQLLEN}",       "input",   6). /* The length of the buffer containing the data */.


    create call hCallSQLBindParamTimestamp.
    assign hCallSQLBindParamTimestamp:call-name                  = 'SQLBindParameter'
           hCallSQLBindParamTimestamp:library                    = '{&LIBODBC_SO}'
           hCallSQLBindParamTimestamp:call-type                  = dll-call-type
           hCallSQLBindParamTimestamp:persistent                 = true
           hCallSQLBindParamTimestamp:num-parameters             = 10
           hCallSQLBindParamTimestamp:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLBindParamTimestamp:library-calling-convention = "{&DECLTYPE}".


    /* Pre-initialized values for binding timestamp parameter */
    hCallSQLBindParamTimestamp:set-parameter(3,  "{&SQLSMALLINT}",  "input",   {&SQL_PARAM_INPUT}).
    hCallSQLBindParamTimestamp:set-parameter(4,  "{&SQLSMALLINT}",  "input",   {&SQL_C_TYPE_TIMESTAMP}). /* The C value type */
    hCallSQLBindParamTimestamp:set-parameter(5,  "{&SQLSMALLINT}",  "input",   {&SQL_TIMESTAMP}).    /* The SQL parameter type */
    hCallSQLBindParamTimestamp:set-parameter(6,  "{&SQLULEN}",      "input",   {&SQL_TIMESTAMP_LEN}).
    hCallSQLBindParamTimestamp:set-parameter(7,  "{&SQLSMALLINT}",  "input",   0).
    hCallSQLBindParamTimestamp:set-parameter(9,  "{&SQLLEN}",       "input",   16). /* The length of the buffer containing the data */.



    create call hCallSQLExecute.
    assign hCallSQLExecute:call-name                  = 'SQLExecute'
           hCallSQLExecute:library                    = '{&LIBODBC_SO}'
           hCallSQLExecute:call-type                  = dll-call-type
           hCallSQLExecute:persistent                 = true
           hCallSQLExecute:num-parameters             = 1
           hCallSQLExecute:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLExecute:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLFetch.
    assign hCallSQLFetch:call-name                  = 'SQLFetch'
           hCallSQLFetch:library                    = '{&LIBODBC_SO}'
           hCallSQLFetch:call-type                  = dll-call-type
           hCallSQLFetch:persistent                 = true
           hCallSQLFetch:num-parameters             = 1
           hCallSQLFetch:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLFetch:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLCloseCursor.
    assign hCallSQLCloseCursor:call-name                  = 'SQLCloseCursor'
           hCallSQLCloseCursor:library                    = '{&LIBODBC_SO}'
           hCallSQLCloseCursor:call-type                  = dll-call-type
           hCallSQLCloseCursor:persistent                 = true
           hCallSQLCloseCursor:num-parameters             = 1
           hCallSQLCloseCursor:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLCloseCursor:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLSetStmtOption.
    assign hCallSQLSetStmtOption:call-name                  = 'SQLSetStmtOption'
           hCallSQLSetStmtOption:library                    = '{&LIBODBC_SO}'
           hCallSQLSetStmtOption:call-type                  = dll-call-type
           hCallSQLSetStmtOption:persistent                 = true
           hCallSQLSetStmtOption:num-parameters             = 3
           hCallSQLSetStmtOption:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLSetStmtOption:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLGetDiagRec.
    assign hCallSQLGetDiagRec:call-name                  = 'SQLGetDiagRec'
           hCallSQLGetDiagRec:library                    = '{&LIBODBC_SO}'
           hCallSQLGetDiagRec:call-type                  = dll-call-type
           hCallSQLGetDiagRec:persistent                 = true
           hCallSQLGetDiagRec:num-parameters             = 8
           hCallSQLGetDiagRec:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLGetDiagRec:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLMoreResults.
    assign hCallSQLMoreResults:call-name                  = 'SQLMoreResults'
           hCallSQLMoreResults:library                    = '{&LIBODBC_SO}'
           hCallSQLMoreResults:call-type                  = dll-call-type
           hCallSQLMoreResults:persistent                 = true
           hCallSQLMoreResults:num-parameters             = 1
           hCallSQLMoreResults:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLMoreResults:library-calling-convention = "{&DECLTYPE}".

    create call hCallSQLFreeStmt.
    assign hCallSQLFreeStmt:call-name                  = 'SQLFreeStmt'
           hCallSQLFreeStmt:library                    = '{&LIBODBC_SO}'
           hCallSQLFreeStmt:call-type                  = dll-call-type
           hCallSQLFreeStmt:persistent                 = true
           hCallSQLFreeStmt:num-parameters             = 2
           hCallSQLFreeStmt:return-value-dll-type      = "{&SQLRETURN}"
           hCallSQLFreeStmt:library-calling-convention = "{&DECLTYPE}".

  end constructor.

  method public {&DEF_SQLRETURN} SQLFreeHandle (input HandleType  as {&DEF_SQLSMALLINT},
                                                input InputHandle as {&DEF_SQLHANDLE}):

    hCallSQLFreeHandle:set-parameter(1, "{&SQLSMALLINT}",   "input", HandleType).
    hCallSQLFreeHandle:set-parameter(2, "{&SQLHANDLE}",     "input", InputHandle).
    hCallSQLFreeHandle:invoke().
    return hCallSQLFreeHandle:return-value.
  
  end method.

  method public {&DEF_SQLRETURN} SQLAllocHandle (input  HandleType   as {&DEF_SQLSMALLINT},
                                                 input  InputHandle  as {&DEF_SQLHANDLE},
                                                 output OutputHandle as {&DEF_SQLHANDLE}):

    hCallSQLAllocHandle:set-parameter(1, "{&SQLSMALLINT}", "input",  HandleType).
    hCallSQLAllocHandle:set-parameter(2, "{&SQLHANDLE}",   "input",  InputHandle).
    hCallSQLAllocHandle:set-parameter(3, "{&SQLHANDLE}",   "output", OutputHandle).
    hCallSQLAllocHandle:invoke().
    return hCallSQLAllocHandle:return-value.
  
  end method.
  
  method public {&DEF_SQLRETURN} SQLSetEnvAttr (input EnvironmentHandle as {&DEF_SQLHENV},
                                                input Attribute         as {&DEF_SQLINTEGER},
                                                input aValue            as {&DEF_SQLPOINTER},
                                                input StringLength      as {&DEF_SQLINTEGER}):

    hCallSQLSetEnvAttr:set-parameter(1, "{&SQLHENV}",    "input", EnvironmentHandle).
    hCallSQLSetEnvAttr:set-parameter(2, "{&SQLINTEGER}", "input", Attribute).
    hCallSQLSetEnvAttr:set-parameter(3, "{&SQLPOINTER}", "input", aValue).
    hCallSQLSetEnvAttr:set-parameter(4, "{&SQLINTEGER}", "input", StringLength).
    hCallSQLSetEnvAttr:invoke().
    return hCallSQLSetEnvAttr:return-value.
  
  end method.
  
  method public {&DEF_SQLRETURN} SQLSetConnectAttr (input ConnectionHandle as {&DEF_SQLHDBC},
                                                    input Attribute        as {&DEF_SQLINTEGER},
                                                    input ValuePtr         as {&DEF_SQLPOINTER},
                                                    input StringLength     as {&DEF_SQLINTEGER}):

    hCallSQLSetConnectAttr:set-parameter(1, "{&SQLHDBC}",    "input", ConnectionHandle).
    hCallSQLSetConnectAttr:set-parameter(2, "{&SQLINTEGER}", "input", Attribute).
    hCallSQLSetConnectAttr:set-parameter(3, "{&SQLPOINTER}", "input", ValuePtr).
    hCallSQLSetConnectAttr:set-parameter(4, "{&SQLINTEGER}", "input", StringLength).
    hCallSQLSetConnectAttr:invoke().
    return hCallSQLSetConnectAttr:return-value.
  
  end method.
  
  method public {&DEF_SQLRETURN} SQLDisconnect (input ConnectionHandle as {&DEF_SQLHDBC}):
 
    hCallSQLDisconnect:set-parameter(1, "{&SQLHDBC}",   "input", ConnectionHandle).
    hCallSQLDisconnect:invoke().
    return hCallSQLDisconnect:return-value.
  
  end method.
 
 method public {&DEF_SQLRETURN} SQLConnect (input ConnectionHandle as {&DEF_SQLHDBC},
                                            input ServerName       as {&DEF_SQLCHAR},
                                            input UserName         as {&DEF_SQLCHAR},
                                            input Authentication   as {&DEF_SQLCHAR}):
 
    hCallSQLConnect:set-parameter(1, "{&SQLHDBC}",     "input", ConnectionHandle).
    hCallSQLConnect:set-parameter(2, "{&SQLCHAR}",     "input", ServerName).
    hCallSQLConnect:set-parameter(3, "{&SQLSMALLINT}", "input", {&SQL_NTS}).
    hCallSQLConnect:set-parameter(4, "{&SQLCHAR}",     "input", UserName).
    hCallSQLConnect:set-parameter(5, "{&SQLSMALLINT}", "input", {&SQL_NTS}).
    hCallSQLConnect:set-parameter(6, "{&SQLCHAR}",     "input", Authentication).
    hCallSQLConnect:set-parameter(7, "{&SQLSMALLINT}", "input", {&SQL_NTS}).
    hCallSQLConnect:invoke().
    return hCallSQLConnect:return-value.
  
  end method.
  
  /* https://msdn.microsoft.com/en-us/library/ms715433%28v=vs.85%29.aspx */
  method public {&DEF_SQLRETURN} SQLDriverConnect (input ConnectionHandle        as {&DEF_SQLHDBC},
                                                   input Windowhandle            as {&DEF_SQLHWND},
                                                   input InConnectionString      as {&DEF_SQLCHAR},
                                                   input OutConnectionString     as {&DEF_SQLCHAR_OUT},
                                                   input BufferLength            as {&DEF_SQLSMALLINT},
                                                   input-output StringLength2Ptr as {&DEF_SQLSMALLINT},
                                                   input DriverCompletion        as {&DEF_SQLUSMALLINT}):
 
    hCallSQLDriverConnect:set-parameter(1, "{&SQLHDBC}",     "input", ConnectionHandle).
    hCallSQLDriverConnect:set-parameter(2, "{&SQLHWND}",     "input", Windowhandle).
    hCallSQLDriverConnect:set-parameter(3, "{&SQLCHAR}",     "input", InConnectionString).
    hCallSQLDriverConnect:set-parameter(4, "{&SQLSMALLINT}", "input", {&SQL_NTS}).
    hCallSQLDriverConnect:set-parameter(5, "{&SQLCHAR}",     "input", OutConnectionString).
    hCallSQLDriverConnect:set-parameter(6, "{&SQLSMALLINT}", "input", BufferLength).
    hCallSQLDriverConnect:set-parameter(7, "{&SQLSMALLINT}", "input-output", StringLength2Ptr).
    hCallSQLDriverConnect:set-parameter(8, "{&SQLSMALLINT}", "input", DriverCompletion).
    hCallSQLDriverConnect:invoke().
    return hCallSQLDriverConnect:return-value.
  
  end method.
  
  method public {&DEF_SQLRETURN} SQLPrepare (input StatementHandle as {&DEF_SQLHSTMT},
                                             input StatementText   as {&DEF_SQLCHAR}):
 
    hCallSQLPrepare:set-parameter(1, "{&SQLHSTMT}",   "input", StatementHandle).
    hCallSQLPrepare:set-parameter(2, "{&SQLCHAR}",    "input", StatementText).
    hCallSQLPrepare:set-parameter(3, "{&SQLINTEGER}", "input", {&SQL_NTS}).
    hCallSQLPrepare:invoke().
    return hCallSQLPrepare:return-value.
  
  end method.

  method public {&DEF_SQLRETURN} SQLNumResultCols (input  StatementHandle as {&DEF_SQLHSTMT},
                                                   output pnColumnCount   as {&DEF_SQLSMALLINT}):
 
    hCallSQLNumResultCols:set-parameter(1, "{&SQLHSTMT}",    "input",  StatementHandle).
    hCallSQLNumResultCols:set-parameter(2, "{&SQLSMALLINT}", "output", pnColumnCount).    
    hCallSQLNumResultCols:invoke().
    return hCallSQLNumResultCols:return-value.
  
  end method.
  
  method public {&DEF_SQLRETURN} SQLDescribeCol (input  StatementHandle as {&DEF_SQLHSTMT},
                                                 input  ColumnNumber    as {&DEF_SQLSMALLINT},
                                                 output ColumnName      as {&DEF_SQLCHAR},
                                                 output DataType        as {&DEF_SQLSMALLINT},
                                                 output ColumnSize      as {&DEF_SQLULEN},
                                                 output DecimalDigits   as {&DEF_SQLSMALLINT},
                                                 output Nullable        as {&DEF_SQLSMALLINT}):
    def var NameLength  as {&DEF_SQLSMALLINT} no-undo.

    put-string(mColumnName, 1) = "".

    hCallSQLDescribeCol:set-parameter(1, "{&SQLHSTMT}",    "input",  StatementHandle).
    hCallSQLDescribeCol:set-parameter(2, "{&SQLSMALLINT}", "input",  ColumnNumber).    
    hCallSQLDescribeCol:set-parameter(3, "{&SQLCHAR_OUT}", "output", mColumnName).    
    hCallSQLDescribeCol:set-parameter(4, "{&SQLSMALLINT}", "input",  255).    
    hCallSQLDescribeCol:set-parameter(5, "{&SQLSMALLINT}", "output", NameLength).    
    hCallSQLDescribeCol:set-parameter(6, "{&SQLSMALLINT}", "output", DataType).    
    hCallSQLDescribeCol:set-parameter(7, "{&SQLULEN}",     "output", ColumnSize).    
    hCallSQLDescribeCol:set-parameter(8, "{&SQLSMALLINT}", "output", DecimalDigits).    
    hCallSQLDescribeCol:set-parameter(9, "{&SQLSMALLINT}", "output", Nullable).    
    hCallSQLDescribeCol:invoke().

    assign ColumnName = get-string(mColumnName, 1, NameLength).
    return hCallSQLDescribeCol:return-value.
  
  end method.

  method public {&DEF_SQLRETURN} SQLBindCol (input  StatementHandle     as {&DEF_SQLHSTMT},
                                             input  ColumnNumber        as {&DEF_SQLUSMALLINT},
                                             input  nTargetType         as {&DEF_SQLSMALLINT},
                                             input  pTargetValue        as {&DEF_SQLPOINTER},
                                             input  nTargetValueMax     as {&DEF_SQLLEN},
                                             output pnLengthOrIndicator as {&DEF_SQLLEN}):

    hCallSQLBindCol:set-parameter(1, "{&SQLHSTMT}",     "input",  StatementHandle).
    hCallSQLBindCol:set-parameter(2, "{&SQLUSMALLINT}", "input",  ColumnNumber).    
    hCallSQLBindCol:set-parameter(3, "{&SQLSMALLINT}",  "input",  nTargetType).    
    hCallSQLBindCol:set-parameter(4, "{&SQLPOINTER}",   "input",  pTargetValue).    
    hCallSQLBindCol:set-parameter(5, "{&SQLLEN}",       "input",  nTargetValueMax).    
    hCallSQLBindCol:set-parameter(6, "{&SQLLEN}",       "output", pnLengthOrIndicator).    
    hCallSQLBindCol:invoke().
    return hCallSQLBindCol:return-value.
  
  end method.

  method public {&DEF_SQLRETURN} SQLBindColV2 (input  StatementHandle     as {&DEF_SQLHSTMT},
                                               input  ColumnNumber        as {&DEF_SQLUSMALLINT},
                                               input  nTargetType         as {&DEF_SQLSMALLINT},
                                               input  pTargetValue        as {&DEF_SQLPOINTER},
                                               input  nTargetValueMax     as {&DEF_SQLLEN},
                                               INPUT  pnLengthOrIndicator AS MEMPTR ):
 
    hCallSQLBindColV2:set-parameter(1, "{&SQLHSTMT}",     "input",  StatementHandle).
    hCallSQLBindColV2:set-parameter(2, "{&SQLUSMALLINT}", "input",  ColumnNumber).    
    hCallSQLBindColV2:set-parameter(3, "{&SQLSMALLINT}",  "input",  nTargetType).    
    hCallSQLBindColV2:set-parameter(4, "{&SQLPOINTER}",   "input",  pTargetValue).    
    hCallSQLBindColV2:set-parameter(5, "{&SQLLEN}",       "input",  nTargetValueMax).    
    hCallSQLBindColV2:set-parameter(6, "memptr",          "input", pnLengthOrIndicator).    
    hCallSQLBindColV2:invoke().
    return hCallSQLBindColV2:return-value.
  
  end method.


  method public {&DEF_SQLRETURN} SQLBindParameter (input StatementHandle      as {&DEF_SQLHSTMT},
                                                   input ParameterNumber      as {&DEF_SQLUSMALLINT},
                                                   input IOType               as {&DEF_SQLSMALLINT},
                                                   input ValueType            as {&DEF_SQLSMALLINT},
                                                   input ParameterType        as {&DEF_SQLSMALLINT},
                                                   input ColumnSize           as {&DEF_SQLULEN},
                                                   input DecimalDigits        as {&DEF_SQLSMALLINT},
                                                   input pData                as {&DEF_SQLPOINTER},
                                                   input nBufferLength        as {&DEF_SQLLEN},
                                                   output pnLengthOrIndicator as {&DEF_SQLLEN}):

    hCallSQLBindParameter:set-parameter(1,  "{&SQLHSTMT}",     "input",   StatementHandle).
    hCallSQLBindParameter:set-parameter(2,  "{&SQLUSMALLINT}", "input",   ParameterNumber).
    hCallSQLBindParameter:set-parameter(3,  "{&SQLSMALLINT}",  "input",   IOType).
    hCallSQLBindParameter:set-parameter(4,  "{&SQLSMALLINT}",  "input",   ValueType). /* The C value type */
    hCallSQLBindParameter:set-parameter(5,  "{&SQLSMALLINT}",  "input",   ParameterType). /* The SQL parameter type */
    hCallSQLBindParameter:set-parameter(6,  "{&SQLULEN}",      "input",   ColumnSize).
    hCallSQLBindParameter:set-parameter(7,  "{&SQLSMALLINT}",  "input",   DecimalDigits).
    hCallSQLBindParameter:set-parameter(8,  "{&SQLPOINTER}",   "input",   pData). /* The actual data to use */
    hCallSQLBindParameter:set-parameter(9,  "{&SQLLEN}",       "input",   nBufferLength). /* The length of the buffer containing the data */
    hCallSQLBindParameter:set-parameter(10, "{&SQLLEN}",       "output",  pnLengthOrIndicator).

    hCallSQLBindParameter:invoke().
    return hCallSQLBindParameter:return-value.
  
  end method.
/*
  method public {&DEF_SQLRETURN} SQLBindParamInt (input StatementHandle      as {&DEF_SQLHSTMT},
                                                  input ParameterNumber      as {&DEF_SQLUSMALLINT},
                                                  INPUT pData                AS MEMPTR,
                                                  output pnLengthOrIndicator as {&DEF_SQLLEN}):

    hCallSQLBindParamInt:set-parameter(1,  "{&SQLHSTMT}",     "input",   StatementHandle).
    hCallSQLBindParamInt:set-parameter(2,  "{&SQLUSMALLINT}", "input",   ParameterNumber).
    hCallSQLBindParamInt:set-parameter(8,  "{&SQLPOINTER}",   "input",   pData). /* The actual data to use */
    hCallSQLBindParamInt:set-parameter(10, "{&SQLLEN}",       "output",  pnLengthOrIndicator).

    hCallSQLBindParameter:invoke().
    return hCallSQLBindParameter:return-value.

  end method.


*/

 
  method public {&DEF_SQLRETURN} SQLExecute (input  StatementHandle as {&DEF_SQLHSTMT}):

    hCallSQLExecute:set-parameter(1, "{&SQLHSTMT}",     "input",  StatementHandle).
    hCallSQLExecute:invoke().
    return hCallSQLExecute:return-value.
  
  end method.
  
  method public {&DEF_SQLRETURN} SQLFetch (input  StatementHandle as {&DEF_SQLHSTMT}):

    hCallSQLFetch:set-parameter(1, "{&SQLHSTMT}",     "input",  StatementHandle).
    hCallSQLFetch:invoke().
    return hCallSQLFetch:return-value.
  
  end method.

  method public {&DEF_SQLRETURN} SQLCloseCursor (input  StatementHandle as {&DEF_SQLHSTMT}):

    hCallSQLCloseCursor:set-parameter(1, "{&SQLHSTMT}",     "input",  StatementHandle).
    hCallSQLCloseCursor:invoke().
    return hCallSQLCloseCursor:return-value.
  
  end method.
  
  method public {&DEF_SQLRETURN} SQLSetStmtOption (input  StatementHandle as {&DEF_SQLHSTMT},
                                                   INPUT  optionid        as {&DEF_SQLUSMALLINT},
                                                   INPUT  optionvalue     as {&DEF_SQLULEN}):

    hCallSQLSetStmtOption:set-parameter(1, "{&SQLHSTMT}",     "input",  StatementHandle).
    hCallSQLSetStmtOption:set-parameter(2, "{&SQLUSMALLINT}", "input",  optionid).
    hCallSQLSetStmtOption:set-parameter(3, "{&SQLULEN}",      "input",  optionvalue).
    hCallSQLSetStmtOption:invoke().
    return hCallSQLSetStmtOption:return-value.
  
  end method.

  method public {&DEF_SQLRETURN} SQLGetDiagRec (INPUT  HandleType   AS {&DEF_SQLSMALLINT},
                                                input  sqlHandle    as {&DEF_SQLHANDLE},
                                                INPUT  RecNumber    as {&DEF_SQLSMALLINT},
                                                OUTPUT SQLState     as {&DEF_SQLCHAR},
                                                OUTPUT NativeError  AS {&DEF_SQLINTEGER},
                                                OUTPUT MessageText  AS {&DEF_SQLCHAR}):

    DEF VAR iTextLength AS {&DEF_SQLSMALLINT} NO-UNDO.

    hCallSQLGetDiagRec:set-parameter(1, "{&SQLSMALLINT}",  "input",  HandleType).
    hCallSQLGetDiagRec:set-parameter(2, "{&SQLHANDLE}",    "input",  sqlHandle).
    hCallSQLGetDiagRec:set-parameter(3, "{&SQLSMALLINT}",  "input",  RecNumber).
    hCallSQLGetDiagRec:set-parameter(4, "{&SQLCHAR_OUT}",  "input",  mSQLState).
    hCallSQLGetDiagRec:set-parameter(5, "{&SQLINTEGER}",   "output", NativeError).
    hCallSQLGetDiagRec:set-parameter(6, "{&SQLCHAR_OUT}",  "input",  mMessageText).
    hCallSQLGetDiagRec:set-parameter(7, "{&SQLSMALLINT}",  "input",  {&MAX_MSG_TEXT_LEN}).
    hCallSQLGetDiagRec:set-parameter(8, "{&SQLSMALLINT}",  "output", iTextLength).
    
    hCallSQLGetDiagRec:invoke().
    ASSIGN SQLState    = GET-STRING(mSQLState, 1, 5).
           MessageText = GET-STRING(mMessageText, 1, iTextLength).

    return hCallSQLGetDiagRec:return-value.

  end method.
  
  method public {&DEF_SQLRETURN} SQLMoreResults (input  StatementHandle as {&DEF_SQLHSTMT}):

    hCallSQLMoreResults:set-parameter(1, "{&SQLHSTMT}",     "input",  StatementHandle).
    hCallSQLMoreResults:invoke().
    return hCallSQLMoreResults:return-value.
  
  end method.
  
  method public {&DEF_SQLRETURN} SQLFreeStmt (input StatementHandle as {&DEF_SQLHSTMT}, 
                                              input anOption as {&DEF_SQLUSMALLINT}):

    hCallSQLFreeStmt:set-parameter(1, "{&SQLHSTMT}",     "input",  StatementHandle).
    hCallSQLFreeStmt:set-parameter(2, "{&SQLUSMALLINT}", "input",  anOption).
    hCallSQLFreeStmt:invoke().
    return hCallSQLFreeStmt:return-value.
  
  end method.
  
  
end class.

