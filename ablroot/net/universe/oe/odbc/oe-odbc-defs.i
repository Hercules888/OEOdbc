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

/* These settings are configured for a 64-bit OpenEdge installation on a 64-bit Linux operating system
   By redefining the global-defines, this should also be usable on 32-bit

   This is not structured correctly and only serves as a proof of concept.
   The final version should be wrapped in openedge class objects

   short = 16-bit
   long  = 32-bit
   int64 = 64-bit     
*/

&if opsys = 'win32' &then
  &global-define DECLTYPE stdcall
&else 
  &global-define DECLTYPE cdecl
&endif 

&global-define GNU_DECLTYPE cdecl

&global-define SQL_NULL_HANDLE 0
&global-define SQL_HANDLE_ENV  1
&global-define SQL_HANDLE_DBC  2
&global-define SQL_HANDLE_STMT 3
&global-define SQL_HANDLE_DESC 4

&global-define SQL_NTS -3

&global-define SQL_SUCCESS 0
&global-define SQL_SUCCESS_WITH_INFO 1
&global-define SQL_ERROR -1
&global-define SQL_INVALID_HANDLE -2
&global-define SQL_STILL_EXECUTING 2
&global-define SQL_NEED_DATA 99

&global-define SQLRETURN  short
&if opsys = 'win32' &then
  &global-define SQLHANDLE  long
  &global-define SQLHANDLE_PTR long
  &global-define SQLHENV long
  &global-define SQLHDBC long
  &global-define SQLHSTMT long
  &global-define POINTER long
  &global-define POINTER-SIZE 4
&else
  &global-define SQLHANDLE  int64
  &global-define SQLHANDLE_PTR int64
  &global-define SQLHENV int64
  &global-define SQLHDBC int64
  &global-define SQLHSTMT int64
  &global-define POINTER int64
  &global-define POINTER-SIZE 8
&endif
&global-define SQLSMALLINT short
&global-define SQLUSMALLINT short

&global-define SQLCHAR char
&global-define SQLCHAR_OUT memptr
&global-define SQLINTEGER long
&global-define SQLPOINTER memptr

&global-define SQLLEN long
&global-define SQLULEN long

&global-define DEF_SQLINTEGER int
&global-define DEF_SQLSMALLINT int
&global-define DEF_SQLRETURN int

&if opsys = 'win32' &then
  &global-define DEF_SQLHANDLE int
  &global-define DEF_SQLHENV int
  &global-define DEF_SQLHDBC int
  &global-define DEF_SQLHSTMT int
  &global-define DEF_POINTER int
&else
  &global-define DEF_SQLHANDLE int64
  &global-define DEF_SQLHENV int64
  &global-define DEF_SQLHDBC int64
  &global-define DEF_SQLHSTMT int64
  &global-define DEF_POINTER int64
&endif
&global-define DEF_SQLPOINTER memptr
&global-define DEF_SQLULEN int
&global-define DEF_SQLUSMALLINT int
&global-define DEF_SQLCHAR char
&global-define DEF_SQLCHAR_OUT memptr
&global-define DEF_SQLLEN int

&global-define SQL_ATTR_ODBC_VERSION 200
&global-define SQL_ATTR_LOGIN_TIMEOUT 103

&global-define SQL_OV_ODBC3 3
&global-define SQL_NO_DATA 100

&global-define HENV_MAGIC 19281

&if opsys = 'WIN32' &then
  /* &global-define LIBODBC_SO C:/Windows/SysWOW64/odbc32.dll */
  &global-define LIBODBC_SO odbc32
  &global-define liboeodbchelper_so liboeodbchelper

&else
  &global-define LIBODBC_SO libodbc.so
  &global-define liboeodbchelper_so liboeodbchelper.so

&endif



&global-define MESSAGETEXT_LEN 200
&global-define STATE_LEN 10

&global-define SQL_PARAM_TYPE_DEFAULT           2
&global define SQL_PARAM_TYPE_UNKNOWN           0
&global-define SQL_PARAM_INPUT                  1
&global-define SQL_PARAM_INPUT_OUTPUT           2
&global-define SQL_RESULT_COL                   3
&global-define SQL_PARAM_OUTPUT                 4
&global-define SQL_RETURN_VALUE                 5

/* SQL Data Types from database */

&global-define SQL_GUID -11
&global-define SQL_WLONGVARCHAR -10
&global-define SQL_WVARCHAR -9
&global-define SQL_WCHAR -8
&global-define SQL_BIT -7
&global-define SQL_TINYINT -6
&global-define SQL_BIGINT -5
&global-define SQL_LONGVARBINARY -4
&global-define SQL_VARBINARY -3
&global-define SQL_BINARY -2
&global-define SQL_LONGVARCHAR -1
&global-define SQL_UNKNOWN_TYPE 0
&global-define SQL_CHAR 1
&global-define SQL_NUMERIC 2
&global-define SQL_DECIMAL 3
&global-define SQL_INTEGER 4
&global-define SQL_SMALLINT 5
&global-define SQL_FLOAT 6
&global-define SQL_REAL 7
&global-define SQL_DOUBLE 8
&global-define SQL_DATETIME 9
&global-define SQL_DATE 9
&global-define SQL_TIME 10
&global-define SQL_TIMESTAMP 11
&global-define SQL_VARCHAR 12
&global-define SQL_TYPE_DATE 91
&global-define SQL_TYPE_TIME 92
&global-define SQL_TYPE_TIMESTAMP 93
&global-define SQL_INTERVAL_YEAR 101
&global-define SQL_INTERVAL_MONTH 102
&global-define SQL_INTERVAL_DAY 103
&global-define SQL_INTERVAL_HOUR 104
&global-define SQL_INTERVAL_MINUTE 105
&global-define SQL_INTERVAL_SECOND 106
&global-define SQL_INTERVAL_YEAR_TO_MONTH 107
&global-define SQL_INTERVAL_DAY_TO_HOUR 108
&global-define SQL_INTERVAL_DAY_TO_MINUTE 109
&global-define SQL_INTERVAL_HOUR_TO_MINUTE 111
&global-define SQL_INTERVAL_HOUR_TO_SECOND 112
&global-define SQL_INTERVAL_MINUTE_TO_SECOND 113

/* SQL Data Types from code */
&global-define SQL_C_CHAR 1
&global-define SQL_C_NUMERIC 2
&global-define SQL_C_LONG 4
&global-define SQL_C_SHORT 5
&global-define SQL_C_FLOAT 7
&global-define SQL_C_DOUBLE 8
&global-define SQL_C_DEFAULT 99
&global-define SQL_C_TYPE_DATE 91
&global-define SQL_C_TYPE_TIME 92
&global-define SQL_C_TIMESTAMP 93
&global-define SQL_C_TYPE_TIMESTAMP 93

&global-define SQL_C_UBIGINT -27
&global-define SQL_C_SBIGINT -25

&global-define SQL_C_DATE 9
&global-define SQL_C_BIT -7

/* Number of bytes for fixed-length types */
&global-define SQL_C_LONG_LEN 4
&global-define SQL_C_CHAR_LEN 0

/*
def var iCDataType as int no-undo extent 125.
iCDataType[{&SQL_VARCHAR}] = {&SQL_C_CHAR}.
iCDataType[{&SQL_INTEGER}] = {&SQL_C_LONG}.
*/
&global-define SQL_TYPE_SHIFT 12
&global-define MAX_COLS_IN_TABLE 50
&global-define MAX_COL_NAME_LEN 1024
&global-define MAX_MSG_TEXT_LEN 8192
&global-define RESBUF_SIZE_VARCHAR 32768


&global-define SQL_CURSOR_TYPE 6
&global-define SQL_CURSOR_FORWARD_ONLY 0

&global-define SQL_CONCURRENCY 7
&global-define SQL_CONCUR_READ_ONLY 1



&global-define SQL_ATTR_ANSI_APP 115

&global-define SQL_UNBIND 2

&global-define SQL_NULL_DATA -1
&global-define SQL_DATA_AT_EXEC -2

&global-define SQL_DATE_LEN 10
&global-define SQL_TIME_LEN 8
&global-define SQL_TIMESTAMP_LEN 19
