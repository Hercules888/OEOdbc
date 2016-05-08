/*------------------------------------------------------------------------
This file is part of the openedge-odbc library, an OpenEdge
ABL wrapper around ODBC Api, intended to invoke SQL calls
directly from OpenEdge ABL code.

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
{net/universe/oe/odbc/oe-odbc-defs.i}


class net.universe.oe.odbc.OEOdbcHelperApi:
  def private var hCallSQLHExecuteBuffer  as handle no-undo.
  def private var hCallSQLHDummy          as handle no-undo.
  def private var hCallSQLHOdbcInitialize as handle no-undo.
  def private var hCallSQLHFreeContext    as handle no-undo.
  
  
  /* Get the only instance of this class by this property */
  def public static property Instance as OEOdbcHelperApi no-undo
  public get():
    if Instance = ? then Instance = new OEOdbcHelperApi().
    return Instance.
  end.
  private set.

  method public handle getCallHdlSQLHExecuteBuffer():
    return hCallSQLHExecuteBuffer.
  end method.

  method public handle getCallHdlSQLHDummy():
    return hCallSQLHDummy.
  end method.

  destructor public OEOdbcHelperApi():
    delete object hCallSQLHExecuteBuffer    no-error.
	delete object hCallSQLHDummy            no-error.
	delete object hCallSQLHOdbcInitialize   no-error.
	delete object hCallSQLHFreeContext      no-error.
  end destructor.
  
  constructor private OEOdbcHelperApi():

 def var hCallIterateBuffer as handle no-undo.

	create call hCallSQLHExecuteBuffer.
	assign hCallSQLHExecuteBuffer:call-name                  = 'iterateBuffer'
		   hCallSQLHExecuteBuffer:library                    = '{&liboeodbchelper_so}'
		   hCallSQLHExecuteBuffer:call-type                  = dll-call-type
		   hCallSQLHExecuteBuffer:persistent                 = true
		   hCallSQLHExecuteBuffer:num-parameters             = 1
		   hCallSQLHExecuteBuffer:return-value-dll-type      = "long"
		   hCallSQLHExecuteBuffer:library-calling-convention = "{&GNU_DECLTYPE}".

	create call hCallSQLHDummy.
	assign hCallSQLHDummy:call-name                  = 'dummy'
		   hCallSQLHDummy:library                    = '{&liboeodbchelper_so}'
		   hCallSQLHDummy:call-type                  = dll-call-type
		   hCallSQLHDummy:persistent                 = true
		   hCallSQLHDummy:num-parameters             = 0
		   /* hCallSQLHDummy:return-value-dll-type      = "long" */
		   hCallSQLHDummy:library-calling-convention = "{&GNU_DECLTYPE}".

	create call hCallSQLHFreeContext.
	assign hCallSQLHFreeContext:call-name                  = 'freeContext'
		   hCallSQLHFreeContext:library                    = '{&liboeodbchelper_so}'
		   hCallSQLHFreeContext:call-type                  = dll-call-type
		   hCallSQLHFreeContext:persistent                 = true
		   hCallSQLHFreeContext:num-parameters             = 1
		   /* hCallSQLHFreeContext:return-value-dll-type      = "long" */
		   hCallSQLHFreeContext:library-calling-convention = "{&GNU_DECLTYPE}".
		   
		   
	create call hCallSQLHOdbcInitialize.
	assign hCallSQLHOdbcInitialize:call-name                  = 'odbcInitialize'
		   hCallSQLHOdbcInitialize:library                    = '{&liboeodbchelper_so}'
		   hCallSQLHOdbcInitialize:call-type                  = dll-call-type
		   hCallSQLHOdbcInitialize:persistent                 = true
		   hCallSQLHOdbcInitialize:num-parameters             = 0
		   /* hCallSQLHOdbcInitialize:return-value-dll-type      = "long" */
		   hCallSQLHOdbcInitialize:library-calling-convention = "{&GNU_DECLTYPE}".

		   
  end constructor.

  method public int SQLHExecuteBuffer (input ptrParams as {&DEF_POINTER}):

    hCallSQLHExecuteBuffer:set-parameter(1,  "{&POINTER}",     "input",  ptrParams).
    hCallSQLHExecuteBuffer:invoke().
    return hCallSQLHExecuteBuffer:return-value.
  
  end method.

  method public int SQLHFreeContext (input ptrContext as {&DEF_POINTER}):

	hCallSQLHFreeContext:set-parameter(1,  "{&POINTER}", "input",  ptrContext).
  
  end method.
  
  
  method public void SQLHDummy ():
    hCallSQLHdummy:invoke().
  end method.
  
  method public void SQLHOdbcInitialize ():
    hCallSQLHOdbcInitialize:invoke().
  end method.

  
end class.

