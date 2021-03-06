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

class net.universe.oe.odbc.examples.customer.CustomerResultsCallbackDemo implements net.universe.oe.odbc.IOEOdbcResultsCallback:

  {net/universe/oe/odbc/examples/customer/ttCustomer.i &REFERENCE-ONLY=REFERENCE-ONLY}
  
  constructor public CustomerResultsCallbackDemo():
    /* message "CustomerCallback - constructor()". */
  end constructor.
  method public  void onBeforeBatch():
    message "CustomerCallback - onBeforeBatch()".
  end method.
  method public void onNewBatch(input table-handle httCustomer, output lClearTT as log):
    onNewBatchInt(table-handle httCustomer by-reference, output lClearTT).
  end method.
  method private void onNewBatchInt(input table ttCustomer, output lClearTT as log):
    message "CustomerCallback - onNewBatch()".
	find first ttCustomer no-lock no-error.
	if avail ttCustomer then 
      message "CustomerId:" customerId 
	       " / CustomerName:" customerName 
		   " / IsActive:" IsActive 
		   " / AnnualIncome:" AnnualIncome
		   " / Sex:" Sex
		   " / State:" State
		   " / BirthDate:" BirthDate
		   " / CreatedOn:" CreatedOn.
    for each ttCustomer no-lock:
	//  put unformatted '.'.
	/*
      message "CustomerId:" customerId 
	       " / CustomerName:" customerName 
		   " / IsActive:" IsActive 
		   " / AnnualIncome:" AnnualIncome
		   " / Sex:" Sex
		   " / State:" State
		   " / BirthDate:" BirthDate
		   " / CreatedOn:" CreatedOn.
    */
    end.
    lClearTT = true.
  end method.
  method public void onAfterBatch():
    message "CustomerCallback - onAfterBatch()".
  end method.
end class.