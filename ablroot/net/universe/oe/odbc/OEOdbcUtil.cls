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

class net.universe.oe.odbc.OEOdbcUtil:
  
  def private var mState       as memptr no-undo.
  def private var mMessageText as memptr no-undo.
   
  /* Get the only instance of this class by this property */
  def public static property Instance as OEOdbcUtil no-undo
  public get():
    if Instance = ? then Instance = new OEOdbcUtil().
    return Instance.
  end.
  private set.

  /* Private constructor, no instantiation outside of this class */
  constructor private OEOdbcUtil():
    set-size(mState)       = {&STATE_LEN}.
    set-size(mMessageText) = {&MESSAGETEXT_LEN}.
  end constructor.
  
  destructor public OEOdbcUtil().
    Instance = ?.
    set-size(mState)       = 0.
    set-size(mMessageText) = 0.
  end destructor.
  
  method public static logical isSQLSuccess (input iRetVal as int):
    return iRetVal = {&SQL_SUCCESS} or iRetVal = {&SQL_SUCCESS_WITH_INFO}.
  end method.

  method public void throwExceptionIfRequired(input iRetVal  as {&DEF_SQLSMALLINT},
                                              input cMessage as char):
    throwExceptionIfRequiredWithExtras(?, ?, iRetVal, cMessage).
  end method.

  method public void throwException(input cMessage as char):
    throwExceptionIfRequiredWithExtras(?, ?, ?, cMessage).
  end.
  
  method public void throwExceptionIfRequiredWithExtras(input iHandleType as {&DEF_SQLSMALLINT},
                                                        input iHandle     as {&DEF_SQLHANDLE},
                                                        input iRetVal     as {&DEF_SQLSMALLINT},
                                                        input cMessage    as char):

    if isSQLSuccess(iRetVal) then return.

    def var iNativeError   as {&DEF_SQLINTEGER}  no-undo.
    def var cState         as char               no-undo.
    def var cMessageText   as char               no-undo.
    def var iStringLength  as {&DEF_SQLSMALLINT} no-undo.
    def var oOdbcException as OEOdbcException      no-undo.
    def var hOdbcApi       as handle             no-undo.
  
    if iHandleType <> ? and iHandle <> ? and iHandle <> 0 then do:
      assign cState       = "?????"
             cMessageText = "Unknown".
                    
      iRetVal = OEOdbcApi:Instance:SQLGetDiagRec(iHandleType, iHandle, 1, OUTPUT cState, output iNativeError, OUTPUT cMessageText).
  
      if isSQLSuccess(iRetVal) then do:
        assign  cMessage = cMessage + "~n-ErrNo: " + String(iNativeError) + "~n-State: " + cState + "~n-Msg: " + cMessageText.
      end.
    end.                                           
                                                     
    oOdbcException = new OEOdbcException(cMessage, -1).
    undo, throw oOdbcException.
  end method.
  
end class.
