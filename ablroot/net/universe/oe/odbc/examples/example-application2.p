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

using net.universe.oe.odbc.OEOdbcException.
using net.universe.oe.odbc.IOEOdbcResultsCallback.
using net.universe.oe.odbc.examples.ExampleAppContext.
using net.universe.oe.odbc.examples.customer.CustomerDao.
using net.universe.oe.odbc.examples.customer.CustomerActionLogResultsCallbackDemo.


/* routine-level on error undo, throw. */

{net/universe/oe/odbc/examples/customer/ttCustomerActionLog.i}

do on error undo, throw:
  def var oXmplAppCtx    as ExampleAppContext no-undo.
  def var oCallback      as IOEOdbcResultsCallback no-undo.
  def var iStart         as int no-undo.
  def var i              as int no-undo.
  def var iNrOfLoops     as int no-undo init 10.

  oXmplAppCtx = new ExampleAppContext("testdbdsn","postgres","pgadmin").
  oCallback = new CustomerActionLogResultsCallbackDemo().
  oXmplAppCtx :oCustomerActionLogDao:GetAllCustomerActionLogsByCallback(output table ttCustomerActionLog by-reference, oCallback, 15).
end.
catch oOeOdbcEx as OEOdbcException:
  message "Application Error: " oOeOdbcEx:GetMessage(1) view-as alert-box.
end catch.
finally:
  if valid-object(oXmplAppCtx) then delete object oXmplAppCtx no-error.
  if valid-object(oCallback) then delete object oCallback no-error.
end finally.

