&IF DEFINED({&PREFIX}ttCustomerActionLog-I) = 0 &THEN
&GLOBAL-DEFINE {&PREFIX}ttCustomerActionLog-I 1
DEF TEMP-TABLE {&PREFIX}ttCustomerActionLog NO-UNDO {&REFERENCE-ONLY} 
  FIELD SortOrder AS INTEGER     INIT ?
  
  FIELD customerId AS INTEGER init ?  
  FIELD logEntryId AS INTEGER init ?  
  FIELD logEntry AS CHARACTER init ?  
  index idxSortOrder is primary unique sortOrder
  .
  
&ENDIF
