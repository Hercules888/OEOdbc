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
/* using net.universe.oe.odbc.IOEOdbcResultsCallback. */
using net.universe.oe.odbc.examples.ExampleAppContext.
using net.universe.oe.odbc.examples.customer.CustomerDao.
/*
using net.universe.oe.odbc.examples.customer.CustomerResultsCallbackDemo.
*/

/* routine-level on error undo, throw. */

{net/universe/oe/odbc/examples/customer/ttCustomer.i}

do on error undo, throw:
  def var oXmplAppCtx    as ExampleAppContext no-undo.
  /* def var oCallback      as IOEOdbcResultsCallback no-undo. */
  def var iStart         as int no-undo.
  def var i              as int no-undo.
  def var iNrOfLoops     as int no-undo init 10.

  /*oXmplAppCtx = new ExampleAppContext("testdbdsn","postgres","pgmaster"). */
  
  /* oXmplAppCtx = new ExampleAppContext("sqldbdsn","sa","sqladmin"). */
  oXmplAppCtx = new ExampleAppContext("sqlodbdsn","sa","sqladmin"). 
  
  /*
  oXmplAppCtx :oCustomerDao:GetCustomerById(1, output table ttCustomer by-reference).
  for each ttCustomer no-lock:
    disp ttCustomer.
  end.
  */
  
  empty temp-table ttCustomer.
  do i = 1 to 2:
    create ttCustomer.
    assign ttCustomer.sortOrder=i
	       ttCustomer.customerid=i
           ttCustomer.customername='customer ' + string(customerId)
		   ttCustomer.annualincome=123.45
		   ttCustomer.isactive = ?
		   ttCustomer.birthdate= /* date(2,22,2002) */ today.
  end.
  
  message "running example" ttCustomer.annualincome view-as alert-box.
  
  oXmplAppCtx :oCustomerDao:insertCustomers(input table ttCustomer by-reference).
  

  
  /*
  oCallback = new CustomerResultsCallbackDemo().
  iStart = etime(false).
  */
  /*
  oXmplAppCtx:oCustomerDao:GetAllCustomersByCallback(output table ttCustomer by-reference, oCallback, 2).
  */
  /*
  oXmplAppCtx:oCustomerDao:GetAllCustomers(output table ttCustomer by-reference).
  */
  message "First run (with init) took " (etime(false) - iStart) " msec.".

  empty temp-table ttCustomer.
  /*
  iStart = etime(false).
  do i = 1 to iNrOfLoops:
    empty temp-table ttCustomer.
    oXmplAppCtx:oCustomerDao:GetAllCustomers(output table ttCustomer by-reference).
  end.
  message "Run (no init required) took on average " ((etime(false) - iStart) / iNrOfLoops) " msec per query for  "  iNrOfLoops " loops.".

  for each ttCustomer no-lock:
    disp ttCustomer.
  end.
  */
end.
catch oOeOdbcEx as OEOdbcException:
  message "Application Error: " oOeOdbcEx:GetMessage(1) view-as alert-box.
end catch.
finally:
  if valid-object(oXmplAppCtx) then delete object oXmplAppCtx no-error.
  /* if valid-object(oCallback) then delete object oCallback no-error. */
end finally.

