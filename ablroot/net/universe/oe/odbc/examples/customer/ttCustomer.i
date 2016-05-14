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

&IF DEFINED({&PREFIX}TTCustomer-I) = 0 &THEN
&GLOBAL-DEFINE {&PREFIX}TTCustomer-I 1
  
  
DEF {&SCOPE} TEMP-TABLE {&PREFIX}ttCustomer NO-UNDO {&REFERENCE-ONLY} 
  FIELD SortOrder      as int
  FIELD CustomerId     AS INT 
  FIELD CustomerName   AS CHAR  format "x(30)"
  FIELD IsActive       AS LOG
  field AnnualIncome   as dec format "->>,>>>,>>9.9999"
  /*
  field Sex            as char format "x"
  field State          as char format "x(2)"
  */
  field BirthDate      as date format "99/99/9999"
  field CreatedOn      as datetime
  index idxSortOrder is primary unique SortOrder
  INDEX idxPK is unique CustomerId.

&ENDIF
