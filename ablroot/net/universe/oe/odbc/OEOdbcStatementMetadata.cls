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
class net.universe.oe.odbc.OEOdbcStatementMetadata:
  {net/universe/oe/odbc/ttOEOdbcColumnMetadata.i &SCOPE=PRIVATE}
  def public property iNrOfCols as int no-undo init 0
  public get.
  set.
  
  def public property iNrOfIntCols as int no-undo init 0
  public get.
  set.
 
  def public property iNrOfCharCols as int no-undo init 0
  public get.
  set.
  
  def public property iNrOfDecCols as int no-undo init 0
  public get.
  set.
   
  def public property iNrOfLogCols as int no-undo init 0
  public get.
  set.
  
  def public property iNrOfTimestampCols as int no-undo init 0
  public get.
  set.

 
  /* We keep metrics per type as a helper for generic results mappers */
  method public void setNrOfColsPerType(iNrOfCharCols as int, iNrOfIntCols as int, iNrOfDecCols as int, iNrOfLogCols as int, iNrOfTimestampCols as int):
    assign this-object:iNrOfCharCols      = iNrOfCharCols
	       this-object:iNrOfIntCols       = iNrOfIntCols
	       this-object:iNrOfDecCols       = iNrOfDecCols.
	       this-object:iNrOfLogCols       = iNrOfLogCols.
	       this-object:iNrOfTimestampCols = iNrOfTimestampCols.
  end method.
  
  destructor OEOdbcStatementMetadata():
    empty temp-table ttOEOdbcColumnMetadata.
  end destructor.
  
  method public void bindColumnMetadata(output table ttOEOdbcColumnMetadata bind):
  end method.
  
  method public int getColumnIndex(input cColumnName as char):
    find first ttOEOdbcColumnMetadata where ttOEOdbcColumnMetadata.ColumnName = cColumnName no-lock no-error.
    return (if avail ttOEOdbcColumnMetadata then ttOEOdbcColumnMetadata.ColumnIndex else ?).
  end method.
  
  method public int getColumnDataType(input cColumnName as char):
    find first ttOEOdbcColumnMetadata where ttOEOdbcColumnMetadata.ColumnName = cColumnName no-lock no-error.
    return (if avail ttOEOdbcColumnMetadata then ttOEOdbcColumnMetadata.DataType else ?).  
  end method.
  
  method public int getColumnDataType(input iColumnIndex as int):
    find first ttOEOdbcColumnMetadata where ttOEOdbcColumnMetadata.ColumnIndex = iColumnIndex no-lock no-error.
    return (if avail ttOEOdbcColumnMetadata then ttOEOdbcColumnMetadata.DataType else ?).  
  end method.
  
  
end class.
