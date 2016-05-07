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
using net.universe.oe.odbc.examples.customer.CustomerDao.
using net.universe.oe.odbc.examples.customer.NumerictableDao.
using net.universe.oe.odbc.examples.customer.CustomerActionLogDao.

routine-level on error undo, throw.
class net.universe.oe.odbc.examples.ExampleAppContext:
   def private var cServerName     as char no-undo.
   def private var cUserName       as char no-undo.
   def private var cAuthentication as char no-undo.

   def private var lOdbcEnvInitialized              as log no-undo init false.
   def private var lOdbcConInitialized              as log no-undo init false.
   def private var lCustomerDaoInitialized          as log no-undo init false.
   def private var lNumerictableDaoInitialized      as log no-undo init false.
   def private var lCustomerActionLogDaoInitialized as log no-undo init false.

   def private property oOdbcEnv as OEOdbcEnvironment no-undo
   private get:
     if not valid-object(oOdbcEnv) then do:
        assign oOdbcEnv = new OeOdbcEnvironment()
               lOdbcEnvInitialized = true.
     end.
     return oOdbcEnv.
   end.
   private set.
 
   def private property oOdbcCon as OEOdbcConnection no-undo
   private get:
     if not valid-object(oOdbcCon) then do:
       assign oOdbcCon = oOdbcEnv:GetConnection(cServerName, cUserName, cAuthentication)
              lOdbcConInitialized = true.
     end.
     return oOdbcCon.
   end.
   private set.

   def public property oCustomerDao as CustomerDao no-undo
   public get:
     if not valid-object(oCustomerDao) then do: 
       assign oCustomerDao = new CustomerDao(oOdbcCon)
              lCustomerDaoInitialized = true.
     end.
     return oCustomerDao.
   end get.
   private set.

   def public property oNumerictableDao as NumerictableDao no-undo
   public get:
     if not valid-object(oNumerictableDao) then do: 
       assign oNumerictableDao = new NumerictableDao(oOdbcCon)
              lNumerictableDaoInitialized = true.
     end.
     return oNumerictableDao.
   end get.
   private set.


   
   def public property oCustomerActionLogDao as CustomerActionLogDao no-undo
   public get:
     if not valid-object(oCustomerActionLogDao) then do: 
       assign oCustomerActionLogDao = new CustomerActionLogDao(oOdbcCon)
              lCustomerActionLogDaoInitialized = true.
     end.
     return oCustomerActionLogDao.
   end get.
   private set.

   constructor public ExampleAppContext(input cServerName as char, input cUserName as char, input cAuthentication as char):
     this-object:cServerName     = cServerName.
     this-object:cUserName       = cUserName.
     this-object:cAuthentication = cAuthentication.
   end constructor. 

   destructor public ExampleAppContext():
     if lCustomerDaoInitialized then do on error undo, leave:
        if valid-object(oCustomerDao) then delete object oCustomerDao.
     end.
     if lNumerictableDaoInitialized then do on error undo, leave:
        if valid-object(oNumerictableDao) then delete object oNumerictableDao.
     end.

     if lOdbcConInitialized then do on error undo, leave:
       if valid-object(oOdbcCon) then delete object oOdbcCon.
     end.
     
     if lOdbcEnvInitialized then do on error undo, leave:
       if valid-object(oOdbcEnv) then delete object oOdbcEnv. 
     end.
   end destructor.


end class.
