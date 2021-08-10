/* Formatted on 12/10/2019 10:45:07 AM (QP5 v5.287) */
------------------------Customer Ledger Info------------------------------------

SELECT *
  FROM APPS.XXDBL_AR_CUSTOMER_DTL_LEDGER_V LDG, APPS.AR_CUSTOMERS AC
 WHERE     1 = 1
       AND LDG.CUSTOMER_ID = AC.CUSTOMER_ID
       AND (   :P_CUSTOMER_NUMBER IS NULL
            OR (A.CUSTOMER_NUMBER = :P_CUSTOMER_NUMBER))
       AND (   :P_CUST_NAME IS NULL
            OR (UPPER (A.CUSTOMER_NAME) LIKE
                   UPPER ('%' || :P_CUST_NAME || '%')))
       AND (   ( :P_ORG_ID IS NULL AND OOH.ORG_ID IN (125))
            OR (OOH.ORG_ID = :P_ORG_ID));

------------------------Customer Info-------------------------------------------

SELECT *
  FROM APPS.AR_CUSTOMERS
 WHERE  (:P_CUSTOMER_NUMBER IS NULL OR (A.CUSTOMER_NUMBER = :P_CUSTOMER_NUMBER))
 --AND CUSTOMER_NUMBER IN ('187056')
 AND     (:P_CUST_NAME IS NULL OR (UPPER(A.CUSTOMER_NAME) LIKE UPPER('%'||:P_CUST_NAME||'%') ))