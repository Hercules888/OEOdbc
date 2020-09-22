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
class net.universe.oe.odbc.OEOdbcEnvironment:
  def public property iEnvHandle as {&DEF_SQLHENV} no-undo init 0
  public get.
  private set.
  
  constructor public OEOdbcEnvironment():
    def var iRetVal as {&DEF_SQLSMALLINT} no-undo.

    iRetVal = OEOdbcApi:Instance:SQLAllocHandle({&SQL_HANDLE_ENV}, {&SQL_NULL_HANDLE}, output iEnvHandle).
    OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_ENV}, iEnvHandle, iRetVal, "Unable to allocate Environment").

    setOdbcVersion(3).
  end constructor.
  
  destructor public OEOdbcEnvironment():
    def var iRetVal as int no-undo.
    
    if iEnvHandle <> 0 and iEnvHandle <> ? then do:
      ASSIGN iRetVal = OEOdbcApi:Instance:SQLFreeHandle({&SQL_HANDLE_ENV}, iEnvHandle).
      /*
      OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_ENV}, iEnvHandle, iRetVal, "Unable to free Environment").
      */
    end.
  end destructor.
  
  method PUBLIC OEOdbcConnection getConnection(input cServerName     as char,
                                               input cUserName       as char,
                                               input cAuthentication as char):
     
    def var iDbcHandle as {&DEF_SQLHDBC} no-undo init 0.
    def var oCon as OEOdbcConnection no-undo.
    
    assign oCon = new OEOdbcConnection(this-object, cServerName, cUserName, cAuthentication). 
    return oCon.
  end method.

  /* - windows : The components of the connection string can be found in the register when an ODBC datasource is created :
       HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\ODBC\ODBC.INI
     - linux :
       /etc/odbcinst.ini
           
     Connection string formats :
     - PostgreSQL windows   : "DRIVER=~{PostgreSQL Unicode~};Servername=<server>;Port=<port>;Database=<dbname>;UID=<username>;Password=<password>"
     - PostgreSQL linux     : "DRIVER=PostgreSQL;Servername=<server>;Port=<port>;Database=<dbname>;UID=<username>;Password=<password>"
     - SAP HANA windows     : "DRIVER=~{HDBODBC32~};CHAR_AS_UTF8=1;ServerNode=<server>:<port>;UID=<userame>;PWD=<password>"
     - SAP HANA linux       : "DRIVER=HANA;CHAR_AS_UTF8=1;ServerNode=<server>:<port>;UID=<userame>;PWD=<password>"
      
  */
  method PUBLIC OEOdbcConnection getConnection(input cConnectionString as char):
     
    def var iDbcHandle as {&DEF_SQLHDBC} no-undo init 0.
    def var oCon as OEOdbcConnection no-undo.
        
    assign oCon = new OEOdbcConnection(this-object, cConnectionString). 
    
    return oCon.
  end method.

  /* This needs to be fixed more structurally */
  method public void setOdbcVersion(input iOdbcVersion as int):
 
    def var iRetVal  as int    no-undo.
    def var mAttrVal as memptr no-undo.
   
    set-pointer-value(mAttrVal) = iOdbcVersion.
    iRetVal = OEOdbcApi:Instance:SQLSetEnvAttr(iEnvHandle, {&SQL_ATTR_ODBC_VERSION}, mAttrVal, 0).
    OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_ENV}, iEnvHandle, iRetVal, "Unable to set OdbcVersion attribute on Environment").           
  
  end method.

end class.
