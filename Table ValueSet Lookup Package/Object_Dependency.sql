/* Formatted on 10/26/2021 2:46:21 PM (QP5 v5.365) */
SELECT *
  FROM DBA_DEPENDENCIES
 WHERE     1 = 1
       --AND OWNER = 'APPS'
       --AND NAME = 'XX_BANK_LEDGER_V'
       --AND TYPE = 'VIEW'
       --AND TYPE IN ('TABLE','VIEW') 
       --AND TYPE IN ('PACKAGE','PACKAGE BODY') 
       --AND TYPE IN ('TRIGGER') 
       --AND TYPE IN ('FUNCTION') 
       --AND TYPE IN ('SEQUENCE')  
       --AND TYPE IN ('MATERIALIZED VIEW')
       AND (   :P_TYPE IS NULL OR (UPPER (TYPE) LIKE UPPER ('%' || :P_TYPE || '%')))
       AND (   :P_OBJECT_NAME IS NULL OR (UPPER (NAME) LIKE UPPER ('%' || :P_OBJECT_NAME || '%')))
       AND (   :P_OWNER_NAME IS NULL OR (UPPER (OWNER) = UPPER ( :P_OWNER_NAME)))
       ;