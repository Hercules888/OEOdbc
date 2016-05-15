#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <time.h>
#include <stdlib.h>
#ifdef __linux__
#include <dlfcn.h>
#endif
#ifdef __WINNT__
#include <windows.h>
#endif
#include "liboeodbchelper.h"

#define FIELDTYPE_CHAR 1
#define FIELDTYPE_DATE 2
#define FIELDTYPE_LOG 3
#define FIELDTYPE_INT 4
#define FIELDTYPE_DEC 5
#define FIELDTYPE_DATETIME 34
#define FIELDTYPE_DATETIMETZ 40

#define MAX_STRFIELDLEN 8000
#define MAX_TIMESTAMPTZ_LEN 32
#define MAX_DECFIELDLEN 38
#define MAX_DECIMALS 12

#define __USE_FRACTION_OFF
#define __DEBUG_OFF

typedef struct  {
  int numFields;
  SQLLEN* strLen_or_IndBuffer;
  SQLPOINTER sqlbindBuffer;  
  SQLPOINTER* sqlbindBufferPtrs;
  int sqlbindBufferLen;
} SQLBindBufferContext; 

typedef struct  {
  SQLHSTMT statementHandle;
  unsigned char* openedgeBuffer;
  int openedgeBufferLen;
  char pad[4];
  SQLBindBufferContext* sqlbindBufferContext;
} IterateBufferParams;

void helloWorld() {
    
    
    printf("Hello Mundo!\n");
}
void dummy() {
    
}

const char* getFieldTypeDescr(int fieldtype) {
  switch(fieldtype) {
    case FIELDTYPE_CHAR: return "CHARACTER";
    case FIELDTYPE_INT: return "INTEGER";
    case FIELDTYPE_LOG: return "LOGICAL";	
    case FIELDTYPE_DEC: return "DECIMAL";
    case FIELDTYPE_DATE: return "DATE";
    case FIELDTYPE_DATETIME: return "DATETIME";
    case FIELDTYPE_DATETIMETZ: return "DATETIME-TZ";
	default: return "UNKNOWN";  
  }	
}

void printbuf(char* buffer, int length) {
  for(int j=0;j<length;j++) {
     printf("%x ", (255 & *(buffer + j))); 
      
  }
}

long long longlong_pow(int x, int n)
{
    long long r = 1;
    while (n--)
        r *= x;

    return r; 
}


double getdecfieldasdouble(int datasize, char* decdata) {
  double doublevalue = 0;
  if(!datasize) return doublevalue;

    //char pointnibbles=
  char signnibbles=(*(decdata)>>4) & 0xF;
  char pointnibbles=*(decdata) & 0xF;

  //printf("Pointnibbles: %ld - Signnibbles: %ld\n", pointnibbles, signnibbles);
  //printbuf(decdata, 10);

  double roundvalue=0, pointvalue=0;
  long long nibblesvalue=0;
  int bytepos=datasize-1;
  int nibblepos=1, exp=0, nibblecount=0, byte, nibble;
  
  for(int q=0;q<=1;q++) {
    nibblecount = pointnibbles;
    nibblesvalue = 0;
    exp=0;

    while ((!q)?nibblecount:bytepos) {
      byte = *(decdata + bytepos);
      if(nibblepos) byte>>=4;
      nibble = (byte & 0xf);
      //printf("\nNibble %c\n", nibble + '0');
      if(nibble >=0 && nibble <= 9) {
        nibblesvalue += (nibble * longlong_pow(10, exp++));
        //printf("Nibblesvalue %ld\n",nibblesvalue);
        //printf("Exp %ld\n", exp);
        nibblecount--;
      }
        
      if(nibblepos) {
        bytepos--;
        nibblepos=0;		
      }
      else nibblepos = 1;
    }
    if(!q) pointvalue=nibblesvalue;
    else   roundvalue=nibblesvalue;
  }
  //printf("signnibbles: %ld", signnibles);
  doublevalue=roundvalue + (pointvalue / longlong_pow(10, pointnibbles));
  
  if (!signnibbles) doublevalue = 0 - doublevalue;
  //printf("roundvalue: %lld pointvalue: %lld doublevalue: %f\n", roundvalue, pointvalue, doublevalue);
 
  //doublevalue = pointvalue / longlong_pow(pointvalue, pointnibbles);
  //doublevalue = roundvalue*1e-9;
  //printf("Infunc: %f\n", (double)pointvalue);
  return doublevalue;
}

void getcharfield(int datalen, char* buffer, char* outstr, int outstrlen) {
  *outstr=0;
  //printf("datalen: %ld\n", datalen);
  strncpy(outstr, buffer, datalen);
  if(datalen<outstrlen)
    *(outstr + datalen) = 0;
  else
    *(outstr + (outstrlen-1))=0;  
    
  //printf("predata-");
  printf(outstr);
  //printf("postdata-");
  //printf("String: %s\n", outstr);
}




int getintfield(int intsize, unsigned char* intdata) {
  //assert
  //if(datasize > 4) 	
    
  int buf=(*(intdata) & 0x80)?-1:0;
  unsigned char* bufptr = (char*)&buf;
  
  //printf("intsize: %ld\n", intsize);
  for(int i=0;i<intsize;i++) {
    // printf("byte => %ld\n", *(intdata + intsize - (i+1)));
    *(bufptr+i)=*(intdata + intsize - (i+1));  
    //printf("Intsize: %ld, Loop: %ld, Value: %ld\n", intsize, intsize - (i+1), *(intdata + intsize - (i+1)));
  }
  
  return buf;
}


void processnullfield(int index, SQLBindBufferContext* contextptr) {
	
	SQLLEN* thisStrLen_or_IndBuffer=(contextptr->strLen_or_IndBuffer + index);
	*thisStrLen_or_IndBuffer=SQL_NULL_DATA;
}

void getdatetimefield(int tssize, unsigned char* tsdata, time_t* datepart, int* timepart) {
  *datepart=0;
  *timepart=0;
  if(!tssize) return;

  int nrofintbytes=(tssize>4)?4:tssize;
  int nrofdatebytes=tssize-nrofintbytes;

  //printf("intbytes: %d\n", nrofintbytes);
  //printf("datebytes: %d\n", nrofdatebytes);
 
  if(nrofdatebytes) {
    *datepart=(*(tsdata) & 0x80)?-1:0;
    unsigned char* bufptr = (unsigned char*)datepart;
    for(int i=0;i<nrofdatebytes;i++) {
      *(bufptr+i)=*(tsdata + nrofdatebytes - (i+1));  
      //printf("Intsize: %ld, Loop: %ld, Value: %ld\n", intsize, intsize - (i+1), *(intdata + intsize - (i+1)));
    }
  }

  char* timebuf = (char*)timepart;
  char* srcbuf= tsdata +nrofdatebytes;
  for(int i=0;i<nrofintbytes;i++) {
    *(timebuf+i)=*(srcbuf + (nrofintbytes - (i+1)));  
  }
}

void processdatetimetzfield(int index, unsigned char* dataptr, int datalen, SQLBindBufferContext* contextptr) {
  // http://www.cplusplus.com/reference/ctime/strftime/	
	
  //printf("In process -> datalen = %d\n", datalen);
  char* thisSqlbindBuffer=*(contextptr->sqlbindBufferPtrs + index);
  //printf("timestamp data (process): %s\n", thisSqlbindBuffer);


  unsigned char* bufptr=NULL;
  struct tm* datetm=NULL;
  time_t timepart=0;
  int timezone=0;
  if(datalen > 8) {
    int nroftimebytes=datalen-8;
    //printf("Time bytes? %d\n", nroftimebytes);
  
    unsigned char *timeptr = dataptr + nroftimebytes - 1; 
    bufptr = (char*)&timepart;
    for(int i=0;i<nroftimebytes;i++) {
      //printf("timebyte[%x] - ", *(timeptr-i));
      *(bufptr+i)=*(timeptr-i);  
    }
    //printf("\n");
  
    unsigned char *dateptr = dataptr + datalen - 5; 
    time_t datepart=(*(dateptr-7) & 0x80)?-1:0;
    bufptr = (char*)&datepart;
    for(int i=0;i<4;i++) {
      *(bufptr+i)=*(dateptr-i);  
    }
 
    unsigned char *tzptr = dataptr + datalen - 1; 
    timezone=(*(tzptr-3) & 0x80)?-1:0;
    bufptr = (char*)&timezone;
    for(int i=0;i<4;i++) {
      *(bufptr+i)=*(tzptr-i);  
    }
 
    //printf("Time: %d - Date: %d - Timezone: %d\n", timepart, datepart, timezone);

    datepart-=7184; // difference between 2 may 1950 & 1 january 1970
    datepart *= 86400;
    datepart+=((timepart/1000) + (timezone*60));
    //printf("datepart: %d\n", datepart);
    datetm=gmtime(&datepart);
  }
  /*
  // fix this
  else {
	 // The null value
	datetm =
	datetm->tm_year=50;
    datetm->tm_mon=4;
	datetm->tm_mday=2;
	datetm->tm_hour=0,
	datetm->tm_min=0,
	datetm->tm_sec=0,
	timepart=0,
	timezone=0
  }
  */
  
  if(datetm==NULL) {
	SQLLEN* thisStrLen_or_IndBuffer=(contextptr->strLen_or_IndBuffer + index);
	*thisStrLen_or_IndBuffer=SQL_NULL_DATA;
  }
  else {
	//  printf("timezone: %d", timezone);
	
	int ret = snprintf (thisSqlbindBuffer, MAX_TIMESTAMPTZ_LEN,
				"%04d-%02d-%02d %02d:%02d:%02d.%03d %c%02d:%02d",
	            datetm->tm_year + 1900,
                datetm->tm_mon + 1,
				datetm->tm_mday,
				datetm->tm_hour,
				datetm->tm_min,
				datetm->tm_sec,
				timepart%1000,
				((timezone<0)?'-':'+'),
				timezone / 60,
				timezone % 60);
				
	assert(ret==30);
	/*
	int ret = snprintf (thisSqlbindBuffer, MAX_TIMESTAMPTZ_LEN,
				"%04d-%02d-%02d %02d:%02d:%02d %c%02d:%02d",
	            datetm->tm_year + 1900,
                datetm->tm_mon + 1,
				datetm->tm_mday,
				datetm->tm_hour,
				datetm->tm_min,
				datetm->tm_sec,
				((timezone<0)?'-':'+'),
				timezone / 60,
				timezone % 60);
    */
    //printf("buf: %s - ret: %d\n", thisSqlbindBuffer, ret);
  }
  
  //printf("datetm??? %ld\n", datetm);
  //exit(0);
  // Unable to parse the date, so let's return an empty date
	  /*
    printf("%d/%d/%d %d:%d:%d +%d",
	  datetm->tm_year + 1900,
      datetm->tm_mon + 1,
      datetm->tm_mday, 
  	  datetm->tm_hour,
 	  datetm->tm_min,
      datetm->tm_sec,
	  timezone);
*/	  
  
}

void processdatetimefield(int index, unsigned char* dataptr, int datalen, SQLBindBufferContext* contextptr) {
  SQL_TIMESTAMP_STRUCT* thisSqlbindBuffer=*(contextptr->sqlbindBufferPtrs + index);
  time_t datepart=0;
  int timepart=0;
  getdatetimefield(datalen, dataptr, &datepart, &timepart);
  
  //printf("datepart: %d - %x\n", datepart, datepart);
  //printf("timepart: %d - %x\n", timepart, timepart);
  
  #ifdef __USE_FRACTION
    int temp=timepart%1000;
  #else
	int temp=0;
  #endif
  thisSqlbindBuffer->fraction=temp;
  
  timepart/=1000;
  temp=timepart/3600;
  thisSqlbindBuffer->hour=temp;
  timepart-=(temp*3600);
  temp=timepart/60;
  thisSqlbindBuffer->minute=temp;
  timepart-=(temp*60);
  thisSqlbindBuffer->second=timepart;

  datepart-=7184; // difference between 2 may 1950 & 1 january 1970
  datepart *= 86400;
  //printf("datepart: %d\n", datepart);
  struct tm* datetm=gmtime(&datepart);
  
  //printf("datetm??? %ld\n", datetm);
  //exit(0);
  // Unable to parse the date, so let's return an empty date
  if(datetm==NULL) {
	thisSqlbindBuffer->year = 0;
	thisSqlbindBuffer->month = 0;
	thisSqlbindBuffer->day = 0;
    thisSqlbindBuffer->hour=0;
    thisSqlbindBuffer->minute=0;
    thisSqlbindBuffer->second=0;
    thisSqlbindBuffer->fraction= 0;
	SQLLEN* thisStrLen_or_IndBuffer=(contextptr->strLen_or_IndBuffer + index);
	*thisStrLen_or_IndBuffer=SQL_NULL_DATA;
  }
  else {
    thisSqlbindBuffer->year  = datetm->tm_year + 1900;
    thisSqlbindBuffer->month = datetm->tm_mon + 1;
    thisSqlbindBuffer->day   = datetm->tm_mday;
  }
  //printf("date:%d/%d/%d\n",thisSqlbindBuffer->day,thisSqlbindBuffer->month,thisSqlbindBuffer->year);
  //printf("Time: %d:%d:%d.%d\n",thisSqlbindBuffer->hour,thisSqlbindBuffer->minute,thisSqlbindBuffer->second,thisSqlbindBuffer->fraction );
}

void processdatefield(int index, unsigned char* dataptr, int datalen, SQLBindBufferContext* contextptr) {
  SQL_DATE_STRUCT* thisSqlbindBuffer=*(contextptr->sqlbindBufferPtrs + index);

  time_t dateval=getintfield(datalen, dataptr);
  
  dateval-=7184; // difference between 2 may 1950 & 1 january 1970
  dateval *= 86400;
  
  struct tm* datetm=gmtime(&dateval);
  //printf("Year: %d - Month: %d - Day: %d\n",datetm->tm_year + 1900, datetm->tm_mon + 1, datetm->tm_mday);

  // Unable to parse the date, so let's return an empty date
  if(datetm==NULL) {
	thisSqlbindBuffer->year = 0;
	thisSqlbindBuffer->month = 0;
	thisSqlbindBuffer->day = 0;
	SQLLEN* thisStrLen_or_IndBuffer=(contextptr->strLen_or_IndBuffer + index);
	*thisStrLen_or_IndBuffer=SQL_NULL_DATA;
  }
  else {
    thisSqlbindBuffer->year  = datetm->tm_year + 1900;
    thisSqlbindBuffer->month = datetm->tm_mon + 1;
    thisSqlbindBuffer->day   = datetm->tm_mday;
  }
  
  //printf("Date as integer: %d", dateval);


  /*
  SQL_DATE_STRUCT struct {
		Year  SQLSMALLINT
		Month SQLUSMALLINT
		Day   SQLUSMALLINT
	}
  */  
  
  
  //struct tm * gmtime (const time_t * timer);

   //Convert time_t to tm as UTC time
}

void processlogfield(int index, unsigned char* dataptr, SQLBindBufferContext* contextptr) {
	unsigned char* thisSqlbindBuffer=*(contextptr->sqlbindBufferPtrs + index);
	*thisSqlbindBuffer=*(dataptr);
}

void processdecfieldaschar(int index, unsigned char* dataptr, int datalen, SQLBindBufferContext* contextptr) {
  assert(dataptr!=NULL);

	unsigned char* thisSqlbindBuffer=*(contextptr->sqlbindBufferPtrs + index);
  SQLLEN* thisStrLen_or_IndBuffer=(contextptr->strLen_or_IndBuffer + index);

  if(!datalen) {
  	 *thisSqlbindBuffer='0';
  	 *(thisSqlbindBuffer+1)=0;
  	 return;
  }

    //char pointnibbles=
  char signnibbles=(*(dataptr)>>4) & 0xF;
  char pointnibbles=*(dataptr) & 0xF;

  int odd =  ((*(dataptr + datalen - 1) & 0x0f) == 0x0f);
  /*
  printf("signnibbles: %d - pointnibbles: %d\n", signnibbles, pointnibbles);
  printf("Isodd? %d\n", odd);
  printf("datalen: %d\n", datalen);
  */
  
  
  int outpos = 0;
  if(!signnibbles)*(thisSqlbindBuffer + outpos++)='-';
  
  int nibblecount = ((datalen - 1) * 2)-odd;
  //printf("nibblecount: %d\n", nibblecount);
  
  int dotpos = nibblecount - (pointnibbles + 1);
  
  char data=0, nibble=0;
  for(int i=0; i<nibblecount; i++) {
  	if(!(i&0x1)){
  	  data=*(dataptr + 1+ (i>>1));
  	  nibble = data >> 4;
  	  //printf("byte: %x for i: %d \n", data, i);
  	} 
  	else {
  		//printf("data odd: %x\n", data);
  		nibble = (data & 0xf);
  	}
  	//printf("nibble: %c\n", nibble + '0');
  	
  	*(thisSqlbindBuffer + outpos++)=(nibble + '0');
  	
  	
  	if(i==dotpos) *(thisSqlbindBuffer + outpos++)='.';
  	//printf("%c\n", (data>>(4 * (i & 0x1))) + '0');
  	//printf("shift: %d\n", (4 * (i & 0x1)));
  	//printf("data: %c\n", data);
    ///printf("%d\n", i >> 1);
    //printf("%d\n", i & 0x01);
  }
  
  *(thisSqlbindBuffer + outpos) = 0;
  //printf("Decimal data: %s\n", thisSqlbindBuffer);
  *thisStrLen_or_IndBuffer=/*strlen(thisSqlbindBuffer)*/ SQL_NTS;
 
}

void processstringfield(int index, unsigned char* dataptr, int datalen, SQLBindBufferContext* contextptr) {
  if (datalen >= MAX_STRFIELDLEN) datalen = MAX_STRFIELDLEN;
  //printf("String data: %s\n", dataptr);
  
  unsigned char* thisSqlbindBuffer=*(contextptr->sqlbindBufferPtrs + index);
  SQLLEN* thisStrLen_or_IndBuffer=(contextptr->strLen_or_IndBuffer + index);
  strncpy(thisSqlbindBuffer, dataptr, datalen);
    
    
    
    
  if(datalen>=MAX_STRFIELDLEN) datalen=MAX_STRFIELDLEN - 1;
  *(thisSqlbindBuffer + datalen) = 0;

  *thisStrLen_or_IndBuffer=datalen;

   //printf("ptrinfunc: %ld\n", thisSqlbindBuffer);  
   //printf("ptrinfunc: %s\n", thisSqlbindBuffer);
}


/* Callback method where all the action will happen */
void processfield(int datatype, int index, void* dataptr, SQLBindBufferContext* contextptr) {
  #ifdef __DEBUG
  printf("Field %ld of type %s > \n", index, getFieldTypeDescr(datatype));
  #endif
  
  SQLLEN* thisStrLen_or_IndBuffer=(contextptr->strLen_or_IndBuffer + index);
  
  //printf("sqlbindBufferPtrs: %ld *sqlbindBufferPtrs: %ld\n", contextptr->sqlbindBufferPtrs, *(contextptr->sqlbindBufferPtrs));
  SQLPOINTER thisSqlbindBuffer=*(contextptr->sqlbindBufferPtrs + index);
  
  //printf("index: %ld - thisStrLen_or_IndBuffer %ld\n", index, thisStrLen_or_IndBuffer);
  //printf("index: %ld - thisSqlbindBuffer %ld\n", index, thisSqlbindBuffer);

  if(dataptr==0) {
      #ifdef __DEBUG
      printf("[NULL]");
      #endif
  }
  else switch(datatype) {
    case FIELDTYPE_INT: {
      int data = *((int*)dataptr);
      *((int*)thisSqlbindBuffer)=data;
      #ifdef __DEBUG
      printf("%ld\n", data);
      #endif
      break;
    }
    case FIELDTYPE_CHAR: {


      //char* data = (char*) dataptr;
      //printf((char*)dataptr);
      #ifdef __DEBUG
      //printf(data);
      #endif
      break;  
    }
    case FIELDTYPE_DEC: {
      double data = *((double*) dataptr);
      #ifdef __DEBUG
      printf("%f", data);
      #endif
      break;  
    }
    case FIELDTYPE_LOG: {
      #ifdef __DEBUG
      //printf("%s", ?"true":"false");
      #endif
    }
  }  
  #ifdef __DEBUG
  printf("\n");
  #endif
}

void freeContext(SQLBindBufferContext* sqlbindBufferContext) {
    if(sqlbindBufferContext) {
        free(sqlbindBufferContext->strLen_or_IndBuffer);
        free(sqlbindBufferContext->sqlbindBuffer);
        free(sqlbindBufferContext->sqlbindBufferPtrs);
        free(sqlbindBufferContext);
    }
}
    
/* If there is no context passed to the iteratebuffer, then one is allocated 
*/
SQLRETURN iterateBuffer(IterateBufferParams* iterateBufferParams) {

  
  /*
  printf("iteratebuffer ptr struct (c): %ld\n", iterateBufferParams);
  printf("Struct size %ld:\n", sizeof(IterateBufferParams)); 
  printf("SQLHSTMT size %ld:\n", sizeof(SQLHSTMT)); 
  
  printf("sqlbindBufferContext (c) %d\n", iterateBufferParams->sqlbindBufferContext);
  */

  unsigned char* buffer = iterateBufferParams->openedgeBuffer;
  SQLHSTMT statementHandle = iterateBufferParams->statementHandle;
  SQLBindBufferContext* contextptr = iterateBufferParams->sqlbindBufferContext; 
  //int buflen = iterateBufferParamsPtr->statementHandle;
    
  
  char encoding[20];
  
  int numfields1            = *(short*)(buffer+4);
  int numfields2            = *(short*)(buffer+6);
  int numfields             = numfields1 - 1;
  int numfieldsplus2        = numfields + 2;
  int numfieldsdiv4         = numfields/4;
  int numfieldsplus2div16   = numfieldsplus2/16;
  
  char fieldtype = 0;
  int afterfielddefsvar1pos = 16 + (numfieldsdiv4 * 4);
  strncpy(encoding, buffer + afterfielddefsvar1pos + 2, 20);
  encoding[sizeof(encoding)]=0;
  int afterfielddefsvar2pos = afterfielddefsvar1pos + strlen(encoding) + ((numfieldsplus2 < 16)?3:6) + (numfieldsplus2div16 * 2);

  //printf("Received context? %ld\n", contextptr);
  
  int numfieldsplus2indata  = *(buffer + afterfielddefsvar2pos + 7);
  
  assert(numfields1==numfields2);
  #ifdef __DEBUG 
  printf("Encoding: %s\n", encoding);
  //printf("Buffer length: %ld\n", buflen);
  printf("NumFieldsPlus1 (1/2): %ld/%ld\n", numfields1, numfields2);
  printf("NumFields: %ld\n", numfields);
  #endif
  //printf("NumFields: %ld\n", numfields);
  // Count the size required for passing data to the buffer
  if (contextptr==NULL) {
    #ifdef __DEBUG 
	printf("Allocating environment (should be one-time)\n");
	#endif
    //printf("Size of SQLBindBufferContext: %ld\n", sizeof(SQLBindBufferContext));
    //printf("Size of IterateBufferParams: %ld\n", sizeof(IterateBufferParams));
    
    contextptr = malloc(sizeof(SQLBindBufferContext));
    contextptr->strLen_or_IndBuffer = NULL;
    contextptr->sqlbindBuffer=NULL;
    contextptr->sqlbindBufferPtrs=NULL;
    contextptr->sqlbindBufferLen=0;

    iterateBufferParams->sqlbindBufferContext = contextptr;
    int sqlbindBufferLen = 0;
    for(int i=0;i<numfields; i++) {
      fieldtype = *(buffer + 13 + i);
      switch(fieldtype) {	
          case FIELDTYPE_INT: {
            sqlbindBufferLen+=sizeof(int);
            break;
          }
          case FIELDTYPE_CHAR: {
            sqlbindBufferLen+=MAX_STRFIELDLEN;
            break;  
          }
          case FIELDTYPE_DEC: {
            sqlbindBufferLen+=MAX_DECFIELDLEN;
            break;			
          }
          case FIELDTYPE_LOG: {
            sqlbindBufferLen+=1;
            break;
          }
          case FIELDTYPE_DATE: {
            sqlbindBufferLen+=sizeof(SQL_DATE_STRUCT);
            break;
          }
          case FIELDTYPE_DATETIME: {
            sqlbindBufferLen+=sizeof(SQL_TIMESTAMP_STRUCT);
            break;
          }
          case FIELDTYPE_DATETIMETZ: { 
		  // ISO8601 
		  // http://infocenter.sybase.com/help/index.jsp?topic=/com.sybase.help.sqlanywhere.12.0.1/dbreference/dtsd.html
		  // http://www.postgresql.org/docs/8.4/static/datatype-datetime.html
		  // https://github.com/MariaDB/mariadb-connector-odbc/blob/master/test/datetime.c
		  // https://support.microsoft.com/en-us/kb/250286
		  // http://marc.info/?l=freetds&m=119972698418096
		  // https://www.ibm.com/support/knowledgecenter/SSEPEK_11.0.0/com.ibm.db2z11.doc.odbc/src/tpc/db2z_sqcex.dita
          // To deal with TimeTz and TimestampTz.
          // No standard native-SQL representation for these,
          // so we ask for them as strings and re-parse them.
		  // 2004-10-19 10:23:54+02 - 1970-01-01 00:00:00+00
		  
            sqlbindBufferLen+=MAX_TIMESTAMPTZ_LEN;
            break;
          }
      }
    
 

 
      #ifdef __DEBUG 
      printf("- Field %ld has type %s(%d)\n", i, getFieldTypeDescr(fieldtype), fieldtype); 
      #endif
    }
    
    void* thisSqlbindBuffer=NULL;
    SQLLEN* thisStrLen_or_IndBuffer=NULL;
    SQLLEN* strLen_or_IndBuffer = malloc(numfields * sizeof(SQLLEN));
    SQLPOINTER sqlbindBuffer = malloc(sqlbindBufferLen);
    SQLPOINTER* sqlbindBufferPtrs = malloc(numfields * sizeof(SQLPOINTER));
 
    #ifdef __DEBUG 
    //printf("Allocated strLen_or_IndBuffer zone %ld\n", strLen_or_IndBuffer);
    //printf("Sizeof strlenorind %ld\n",numfields * sizeof(SQLLEN));
    //printf("Allocated sqlbindBuffer zone %ld\n", sqlbindBuffer);
    //printf("Sizeof strlenorind %ld\n",sqlbindBufferLen);
    #endif
	
    contextptr->strLen_or_IndBuffer=strLen_or_IndBuffer;
    contextptr->sqlbindBuffer=sqlbindBuffer;
    contextptr->sqlbindBufferPtrs=sqlbindBufferPtrs;
    contextptr->sqlbindBufferLen=sqlbindBufferLen;

	#ifdef __DEBUG 
    printf("strLen_or_IndBuffer(c): %ld\n", contextptr->strLen_or_IndBuffer);
    printf("sqlbindBuffer(c): %ld\n",contextptr->sqlbindBuffer);
    printf("sqlbindBufferPtrs(c): %ld\n", contextptr->sqlbindBufferPtrs);
    printf("sqlbindBufferLen(c): %ld\n",contextptr->sqlbindBufferLen);
    #endif

	
	//return SQL_SUCCESS;
	
	
    #ifdef __DEBUG 
    printf("Allocated size for sqlbindBuffer: %ld\n", sqlbindBufferLen);
    #endif
    
    
    SQLSMALLINT  valueType=0, parameterType=0, decimalDigits=0; 
    SQLLEN       bufferLength=0;	
    SQLULEN      columnSize=0;  
    int bufferPos = 0;
    int skip=0;
    SQLRETURN ret = 0;
    for(SQLUSMALLINT i=0; i<numfields; i++) {
      thisStrLen_or_IndBuffer = strLen_or_IndBuffer + i;
      // printf("thisstrlen %ld - strlen %ld - added %ld\n", thisStrLen_or_IndBuffer, strLen_or_IndBuffer, sizeof(SQLLEN) * i);
      fieldtype = *(buffer + 13 + i);
      thisSqlbindBuffer = sqlbindBuffer + bufferPos;
      // printf("thisSqlbindBuffer: %ld\n",thisSqlbindBuffer);
      *(sqlbindBufferPtrs + i) = thisSqlbindBuffer;
      // printf("sqlbindbuffers: %ld\n", *(sqlbindBufferPtrs + i));
      switch(fieldtype) {
        case FIELDTYPE_INT: {
          valueType = SQL_C_LONG;
          parameterType = SQL_INTEGER;
          bufferLength=sizeof(int);
          columnSize=0;
          decimalDigits=0;
          skip=bufferLength;
          *((int*)thisSqlbindBuffer)=0;
          *thisStrLen_or_IndBuffer=columnSize;
          break;
        }
        case FIELDTYPE_CHAR: {
          valueType = SQL_C_CHAR;
          parameterType = SQL_VARCHAR /* SQL_CHAR */ /* SQL_LONG_VARCHAR */;
          bufferLength=0;
          columnSize=MAX_STRFIELDLEN;
          decimalDigits=0;
          skip=columnSize;
          *((char*)thisSqlbindBuffer) = 0;
          *thisStrLen_or_IndBuffer=0;
          break;
        }
        case FIELDTYPE_DEC: {
          //printf("allocating buffer for dec\n");
          valueType = SQL_C_CHAR;
          parameterType = SQL_NUMERIC /* SQL_CHAR */ /* SQL_LONG_VARCHAR */;
          bufferLength=0;
          columnSize= MAX_DECFIELDLEN;
          decimalDigits=/* 2 */ /*35*/ MAX_DECIMALS; /* This is max 35, and is by choice. By increasing this, the digits before the point get decreased */
          skip=columnSize;
          *((char*)thisSqlbindBuffer) = 0;
          *thisStrLen_or_IndBuffer= SQL_NTS /*0 */;
          break;
        }
        case FIELDTYPE_LOG: {
          valueType = SQL_C_BIT;
          parameterType = SQL_BIT;
          bufferLength=1;
          columnSize=bufferLength;
          decimalDigits=0;
          skip=columnSize;
          *((char*)thisSqlbindBuffer) = 0;
          *thisStrLen_or_IndBuffer=0;
          break;
        }
		case FIELDTYPE_DATE: {
          valueType = SQL_C_TYPE_DATE;
          parameterType = SQL_TYPE_DATE;
          bufferLength=sizeof(SQL_DATE_STRUCT);
          columnSize=0;
          decimalDigits=0;
          skip=bufferLength;
          //*((char*)thisSqlbindBuffer) = 0;
/*		  
		  SQL_DATE_STRUCT* test = thisSqlbindBuffer;
		  test->year=2002;
		  test->month=2;
		  test->day=22;
*/		  
          *thisStrLen_or_IndBuffer=0;
          break;
        }
		case FIELDTYPE_DATETIME: {
          valueType = SQL_C_TIMESTAMP;
          parameterType = SQL_TIMESTAMP;
          bufferLength=sizeof(SQL_TIMESTAMP_STRUCT);
          columnSize=23;
          decimalDigits=3;
          skip=bufferLength;
          //*((char*)thisSqlbindBuffer) = 0;
          /*
		  SQL_TIMESTAMP_STRUCT* test = thisSqlbindBuffer;
		  test->year=1999;
		  test->month=5;
		  test->day=13;
		  test->hour=14;
		  test->minute=15;
		  test->second=16;
		  test->fraction=1;
          */		  
		  *thisStrLen_or_IndBuffer=0;
          break;
        }
        case FIELDTYPE_DATETIMETZ: {
          valueType = SQL_C_CHAR;
          parameterType = SQL_TIMESTAMP /* SQL_CHAR */ /* SQL_LONG_VARCHAR */;
          bufferLength=MAX_TIMESTAMPTZ_LEN;
          columnSize=23;
          decimalDigits=3;
          skip=columnSize;
          *((char*)thisSqlbindBuffer) = 0;
          *thisStrLen_or_IndBuffer=SQL_NTS;
		  /*
		  const char test[] = "2015-04-03 12:34:56.123+01";
		  printf("Size of test? %d\n", sizeof(test));
		  strncpy(thisSqlbindBuffer,test, sizeof(test));
		  printf("Buffer: %s\n", thisSqlbindBuffer);
		  */
          break;
        }
      }
 
  
      /*
      FILE * fp;
      fp = fopen ("c:\\test\\testfile.bin", "w+");
      //fprintf(fp,sqlbindBuffer);
      fwrite(sqlbindBuffer , 1 , sqlbindBufferLen , fp );
      fclose(fp);
      */
    
    
      // thisStrLen_or_IndBuffer=0; 
         
      //printf("binding parameter\n");
      ret = SQLBindParameterXX(statementHandle, i+1, SQL_PARAM_INPUT, valueType, parameterType, columnSize, decimalDigits, sqlbindBuffer + bufferPos, bufferLength, thisStrLen_or_IndBuffer);
      #ifdef __DEBUG
	  printf("SQLBindParameterXX Return: %ld\n", ret);
      #endif 
	  if(ret!=SQL_SUCCESS) return ret; 
	  //printf("Check!\n");
      bufferPos+=skip;
      //printf("Returned strlen: %ld\n", thisStrLen_or_IndBuffer);
    } 
  }
  
  
	  


  //printf("numfieldsdiv4: %ld\n", numfieldsdiv4);
  //printf("nunfieldsplus2indata: %ld\n", numfieldsplus2indata);  
  

  int twobytes = (numfieldsplus2>127)?1:0;
  unsigned char* datalenptr = buffer + afterfielddefsvar2pos + 14 + twobytes;
  
  int datalen = 0;
  
  //printf("firstdatasize %ld\n", datalen);
  
  //char outbuf[32000];
  int isnull=0;
  
  for(int i=0;i<numfields; i++) {
    datalen= *(datalenptr);
    fieldtype = *(buffer + 13 + i);
    isnull=0;
    //printf("Fieldtype: %ld", fieldtype);
    
    //printf("datalen orig %ld\n", datalen);
    if (datalen>=253) {
       isnull = 1;
       datalen=0;	   
    }
    else {
      //printf("datalenone: %ld\n", datalen);
      if(datalen >= 230) {
          ++datalenptr;
          datalen = (*(datalenptr++)<<8) + *(datalenptr);
      } 
      //datalenptr++;
      //printf("After datalen: %ld\n", datalen);
    }
    datalenptr++;
    //printf("datalenptr: %ld\n",datalenptr);
    /*
    printf("Data length: %ld ", datalen);
    printf("> %s ", getFieldTypeDescr(fieldtype));
    printf(" @ pos %ld \n", i + 1);
    */
    int datatype = fieldtype;
    //int index = i  + 1;
    int index = i;
    
    if(isnull) {
        //processfield(datatype, index, 0, contextptr);
        processnullfield(index, contextptr);
    }
    else switch(fieldtype)  {
      
      case FIELDTYPE_INT: {
        int data = getintfield(datalen, datalenptr);
        processfield(datatype, index, &data, contextptr);
        break;
      }
      case FIELDTYPE_DEC: {
        //printbuf(datalenptr, 10);
        processdecfieldaschar(index, datalenptr, datalen, contextptr);
        //printf("Double: %f\n", data);
        //processfield(datatype, index, &data, contextptr);
        //printf("Data: %s\n", *(contextptr->sqlbindBufferPtrs + index));
        break;
      }
      case FIELDTYPE_CHAR: {
        //printf("Datalen: %ld\n", datalen);
        //getcharfield(datalen, datalenptr, outbuf, sizeof(outbuf));
        //processfield(datatype, index, outbuf, contextptr);
        processstringfield(index, datalenptr, datalen, contextptr);
        break;
      }
      case FIELDTYPE_LOG: {
		processlogfield(index, (unsigned char*)&datalen, contextptr);
		break;
      }
      case FIELDTYPE_DATE: {
		processdatefield(index, datalenptr, datalen, contextptr);
		break;
      }
      case FIELDTYPE_DATETIME: {
		processdatetimefield(index, datalenptr, datalen, contextptr);
		break;
      }
      case FIELDTYPE_DATETIMETZ: {
		processdatetimetzfield(index, datalenptr, datalen, contextptr);
		break;
      }
      default: {
         break;
      }
    }

    datalenptr+=datalen;
  }
 
  //printf("Executing\n");
  SQLRETURN ret = SQLExecuteXX(statementHandle);                 
  return ret;
}

SQLBindParameterPtr SQLBindParameterXX  = NULL;
SQLExecutePtr       SQLExecuteXX        = NULL;


// If libodbc is loaded from progress, that loaded library can be used from this dll 

void odbcInitialize() {
  /* SQLBindParameter = dlsym(NULL, "SQLBindParameter"); */
  /*

  */   
  #ifdef __DEBUG
  printf("In odbcInitialize\n");
  #endif
  
  #ifdef __WINNT__
  HMODULE odbcModule = GetModuleHandle("odbc32.dll");
  SQLBindParameterXX = (SQLBindParameterPtr) GetProcAddress(odbcModule, "SQLBindParameter");
  SQLExecuteXX = (SQLExecutePtr) GetProcAddress(odbcModule, "SQLExecute");
  #endif
  #ifdef __DEBUG
  printf("Module: %ld\n", odbcModule);
  #endif
  #ifdef __linux__
  SQLBindParameterXX = dlsym(NULL, "SQLBindParameter");
  SQLExecuteXX = dlsym(NULL, "SQLExecute");
  #endif
  #ifdef __DEBUG
  printf("Bind parameter: %ld \n", SQLBindParameterXX);
  printf("Execute parameter: %ld \n", SQLExecuteXX);
  #endif
}

/*
__attribute__((constructor)) void so_init (void)
{
      unixodbc_initialize();
}	
*/
    

