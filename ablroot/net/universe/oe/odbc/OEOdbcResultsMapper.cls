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

USING net.universe.oe.odbc.*.
{net/universe/oe/odbc/oe-odbc-defs.i}

ROUTINE-LEVEL ON ERROR UNDO, THROW.
CLASS net.universe.oe.odbc.OEOdbcResultsMapper abstract IMPLEMENTS IOEOdbcResultsMapper:
  
  def protected var oResultsCallback  as IOEOdbcResultsCallback no-undo.
  def protected var iNrOfRecsPerBatch as int no-undo init 100.
  def protected var hDefaultTempTable as handle no-undo.
  
  constructor public OEOdbcResultsMapper(input hDefaultTempTable as handle,
                                         input oResultsCallback as IOEOdbcResultsCallback,
                                         input iNrOfRecsPerBatch as int):

    if iNrOfRecsPerBatch <> ? and iNrOfRecsPerBatch > -1 then 
      assign this-object:iNrOfRecsPerBatch = iNrOfRecsPerBatch.
    
    assign this-object:oResultsCallback  = oResultsCallback
           this-object:hDefaultTempTable = hDefaultTempTable.

  end constructor.
 
  METHOD PUBLIC abstract int iterateAndMapResults(oPStmt AS OEOdbcPreparedStatement).  
 
END CLASS.
