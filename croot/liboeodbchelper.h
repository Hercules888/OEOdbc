#ifndef __LIB_OEODBCHELPER_H__
#define __LIB_OEODBCHELPER_H__

#ifdef __WINNT__
#include <windows.h>
#endif
#include <sql.h>
#include <sqltypes.h>
#include <sqlext.h>


typedef SQLRETURN (
 #ifdef __WINNT__ 
 __stdcall 
 #endif 
 *SQLBindParameterPtr) (
                   SQLHSTMT StatementHandle,
				   SQLUSMALLINT ParameterNumber,
				   SQLSMALLINT InputOutputType,
				   SQLSMALLINT ValueType,
				   SQLSMALLINT ParameterType,
				   SQLULEN ColumnSize,
				   SQLSMALLINT DecimalDigits,
				   SQLPOINTER ParameterValuePtr,
				   SQLLEN BufferLength,
				   SQLLEN * StrLen_or_IndPtr);

typedef SQLRETURN (
#ifdef __WINNT__
__stdcall
#endif
*SQLExecutePtr) (
                   SQLHSTMT StatementHandle);


extern SQLBindParameterPtr SQLBindParameterXX;
extern SQLExecutePtr SQLExecuteXX;


#endif /* ! __LIB_OEODBCHELPER_H__ */
