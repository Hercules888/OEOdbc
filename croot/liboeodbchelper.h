#ifndef __LIB_OEODBCHELPER_H__
#define __LIB_OEODBCHELPER_H__

#include <windows.h>
#include <sql.h>
#include <sqltypes.h>
#include <sqlext.h>


typedef SQLRETURN (__stdcall *SQLBindParameterPtr) (
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

typedef SQLRETURN (__stdcall *SQLExecutePtr) (
                   SQLHSTMT StatementHandle);


extern SQLBindParameterPtr SQLBindParameterXX;
extern SQLExecutePtr SQLExecuteXX;


#endif /* ! __LIB_OEODBCHELPER_H__ */
