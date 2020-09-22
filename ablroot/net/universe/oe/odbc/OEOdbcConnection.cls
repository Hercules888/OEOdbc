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

routine-level on error undo, throw.
class net.universe.oe.odbc.OEOdbcConnection:

  def property iDbcHandle as {&DEF_SQLHDBC} no-undo init 0
  get.
  private set.

  constructor public OEOdbcConnection(input oOdbcEnv as OEOdbcEnvironment, input cServerName as char,
                                      input cUserName as char, input cAuthentication as char):
     def var iRetVal    as {&DEF_SQLSMALLINT} no-undo.
     def var iEnvHandle as {&DEF_SQLHENV}     no-undo.
     
     if not valid-object(oOdbcEnv) then OEOdbcUtil:Instance:throwException("No environment specified to allocate Database Connection").
     iEnvHandle = oOdbcEnv:iEnvHandle.

     /* Allocate Database Connection Handle */
     iRetVal = OEOdbcApi:Instance:SQLAllocHandle({&SQL_HANDLE_DBC}, iEnvHandle, output iDbcHandle).
     OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_ENV}, iEnvHandle, iRetVal, "Unable to allocate Database Connection").
     
     setLoginTimeout(5).           
     
     iRetVal = OEOdbcApi:Instance:SQLConnect(iDbcHandle, cServerName,
                                   cUserName,
                                   cAuthentication).
     OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_DBC}, iDbcHandle, iRetVal, "Unable open Database Connection").

      
  end constructor.

  constructor public OEOdbcConnection(input oOdbcEnv as OEOdbcEnvironment, input cConnectionString as char):
    def var iRetVal               as {&DEF_SQLSMALLINT} no-undo.
    def var iEnvHandle            as {&DEF_SQLHENV}     no-undo.    
    def var mpOutConnectionString as {&DEF_SQLCHAR_OUT} no-undo.   
    def var iStringLength2Ptr     as {&DEF_SQLSMALLINT} no-undo.
         
    if not valid-object(oOdbcEnv) then OEOdbcUtil:Instance:throwException("No environment specified to allocate Database Connection").
    iEnvHandle = oOdbcEnv:iEnvHandle.

    /* Allocate Database Connection Handle */
    iRetVal = OEOdbcApi:Instance:SQLAllocHandle({&SQL_HANDLE_DBC}, iEnvHandle, output iDbcHandle).
    OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_ENV}, iEnvHandle, iRetVal, "Unable to allocate Database Connection").
    
    setLoginTimeout(5).           
             
    set-size(mpOutConnectionString) = 1024.    
    assign iStringLength2Ptr = 0.    
    
    iRetVal = OEOdbcApi:Instance:SQLDriverConnect(iDbcHandle,0,cConnectionString,mpOutConnectionString,
                                                  0,input-output iStringLength2Ptr,0).                                   
    OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_DBC}, iDbcHandle, iRetVal, "Unable open Database Connection").
        
    finally:
      set-size(mpOutConnectionString) = 0.
    end.
              
  end constructor.
  
  destructor public OEOdbcConnection():
    def var iRetVal as int no-undo.
        
    if iDbcHandle <> 0 and iDbcHandle <> ? then do:    
      iRetVal = OEOdbcApi:Instance:SQLDisconnect(iDbcHandle).
      OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_DBC}, iDbcHandle, iRetVal, "Unable to disconnect the Database Connection").

      iRetVal = OEOdbcApi:Instance:SQLFreeHandle({&SQL_HANDLE_DBC}, iDbcHandle).
      OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_DBC}, iDbcHandle, iRetVal, "Unable to free Database Connection").
    end.
  end destructor.  
 
  
  /* This needs to be built more generic, but we just leave it as-is for now */
  method public void setLoginTimeout(input iLoginTimeout as int):
    def var mAttrVal as {&SQLPOINTER}      no-undo.
    def var iRetVal  as {&DEF_SQLSMALLINT} no-undo.
    
    set-pointer-value(mAttrVal) = iLoginTimeout.
    iRetVal = OEOdbcApi:Instance:SQLSetConnectAttr(iDbcHandle, {&SQL_ATTR_LOGIN_TIMEOUT}, mAttrVal, 0).
    OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_DBC}, iDbcHandle, iRetVal, "Unable to set LoginTimeout attribute on Connection").
  end method.

  method public OEOdbcPreparedStatement prepareStatement(input cSQL as char):
    def var oOdbcPStmt as net.universe.oe.odbc.OEOdbcPreparedStatement no-undo.
    oOdbcPStmt = new OEOdbcPreparedStatement(this-object, cSQL).
    return oOdbcPStmt.
  end method.
end class.
