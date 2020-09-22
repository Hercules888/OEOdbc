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

insert into "Customer"("customerId", "customerName", "isActive", "AnnualIncome", "Sex", "State", "birthDate", "createdOn")
values(1, 'John Doe', true, 1234.567, 'M','MS', date '12/31/1980', current_timestamp);
insert into "Customer"("customerId", "customerName", "isActive", "AnnualIncome", "Sex", "State", "birthDate", "createdOn")
values(2, 'Jane Doe', false, 9876.54321, 'F','KS', date '12/31/1990', current_timestamp);
insert into "Customer"
select generate_series, 'User' || generate_series, false, 9876.54321, 'F','KS', date '31/12/1990', current_timestamp from generate_series(3, 1000000);

