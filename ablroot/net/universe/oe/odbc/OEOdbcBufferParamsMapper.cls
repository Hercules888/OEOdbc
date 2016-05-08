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

USING net.universe.oe.odbc.*.
ROUTINE-LEVEL ON ERROR UNDO, THROW.
{net/universe/oe/odbc/oe-odbc-defs.i}

&global-define DEF_PTR int
&global-define PTR long

CLASS net.universe.oe.odbc.OEOdbcBufferParamsMapper IMPLEMENTS IOEOdbcParamsMapper:

  def private var mIterateBufferParams as memptr no-undo.
  def private var hTempTable as handle no-undo.
  
  def private temp-table ttRaw no-undo
    field data as raw.

  def private var hBuf    as handle no-undo.
  def private var hBufRaw as handle no-undo.
  def private var hFldRaw as handle no-undo.
  def private var hQry    as handle no-undo.
  
  CONSTRUCTOR PUBLIC OEOdbcBufferParamsMapper(input table-handle htemptable):
  
    OEOdbcHelperApi:Instance:SQLHOdbcInitialize().
	
	set-size(mIterateBufferParams) = {&POINTER-SIZE} + {&POINTER-SIZE} + 8 + {&POINTER-SIZE}.
	put-{&pointer}(mIterateBufferParams, 1)  = 0. /* statementHandle */
	put-{&pointer}(mIterateBufferParams, 1 + {&POINTER-SIZE}) = 0. /* openedgeBuffer */
	put-long      (mIterateBufferParams, 1 + {&POINTER-SIZE} + {&POINTER-SIZE}) = 0. /* openedgeBufferLen */
	/* We have 4bytes padding */
	put-{&pointer}(mIterateBufferParams, 1 + {&POINTER-SIZE} + {&POINTER-SIZE}  + 8) = 0. /* sqlbindBufferContext */
	
	message "iteratebufferparams struct size(openedge): " get-size(mIterateBufferParams).
	message "iteratebufferparams struct(openedge) :" get-pointer-value(mIterateBufferParams).
	
	assign hBufRaw = temp-table ttRaw:default-buffer-handle
           hFldRaw = hBufRaw:buffer-field('data')
		   hBuf    = hTempTable:default-buffer-handle.

    create ttRaw.
  END CONSTRUCTOR.

  DESTRUCTOR PUBLIC OEOdbcBufferParamsMapper():
    set-size(mIterateBufferParams) = 0.
  END DESTRUCTOR.

  METHOD PUBLIC VOID iterateAndMapParams(oPStmt AS OEOdbcPreparedStatement):
    oPStmt:lSkipExecute=true.
    
	message "StatementHandle (openedge): " oPStmt:iStmtHandle.
    put-{&pointer}(mIterateBufferParams, 1)  = oPStmt:iStmtHandle. /* statementHandle */
	put-{&pointer}(mIterateBufferParams, 1 + {&pointer-size} + {&pointer-size} + 8) = 0. /* sqlbindBufferContext */



    message "Iterating & mapping parameters".
	def var oOEOdbcHelperApi as net.universe.oe.odbc.OEOdbcHelperApi no-undo.
	def var hCallSQLHExecuteBuffer  as handle no-undo.
	def var mBufferData as memptr no-undo.
	def var iSize as int no-undo.
	def var ptrContext as {&DEF_POINTER} no-undo.
	
	oOEOdbcHelperApi = OEOdbcHelperApi:Instance.
	hCallSQLHExecuteBuffer=oOEOdbcHelperApi:getCallHdlSQLHExecuteBuffer().
    /*
	hCallSQLHExecuteBuffer=oOEOdbcHelperApi:getCallHdlSQLHDummy().
    */
    def var i as int no-undo.
	
     etime(true).	
	create query hQry.
	hQry:set-buffers(hBuf).
	hQry:query-prepare("for each " + hBuf:name + " no-lock").
	do i = 1 to 1:
	  hQry:query-open().
      hQry:get-first().
	  /* Currently we don't use the size, so let's leave it here */
        
      hCallSQLHExecuteBuffer:set-parameter(1,  "{&pointer}",   "input",  get-pointer-value(mIterateBufferParams)).
	  do while not hQry:query-off-end:
	    hBuf:raw-transfer(true, hFldRaw).
	    mBufferData = ttRaw.data.
   	    put-{&pointer}(mIterateBufferParams, 1 + {&pointer-size})  = get-pointer-value(mBufferData). /* openedgeBuffer */
	    put-long(mIterateBufferParams, 1 + {&pointer-size} + {&pointer-size})  = get-size(mBufferData).          /* openedgeBufferLen */
		/* message "invoking..." view-as alert-box. */
	    hCallSQLHExecuteBuffer:invoke().
	    /* message "Context (openedge)? " get-{&POINTER}(mIterateBufferParams, 1 + {&pointer-size} + {&pointer-size} + 8) view-as alert-box. */
	    set-size(mBufferData)=0.
		if(hCallSQLHExecuteBuffer:return-value <> {&SQL_SUCCESS}) then 
		          OEOdbcUtil:Instance:throwExceptionIfRequiredWithExtras({&SQL_HANDLE_STMT}, oPStmt:iStmtHandle, hCallSQLHExecuteBuffer:return-value, "Unable to execute buffer through helper").

	    hQry:get-next().
  	  end.
	end.
	finally:
	
	  if valid-handle(hQry) then do:
	    hQry:query-close() no-error.
	    delete object hQry.
	  end.
	  oOEOdbcHelperApi:SQLHFreeContext(ptrContext).
	  
	message etime(false) view-as alert-box.	
    end.
	
    END METHOD.

END CLASS.
