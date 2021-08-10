SELECT *
--MAX(CUSTOMER_TRX_ID)
FROM
APPS.RA_CUSTOMER_TRX_ALL
order by 
--creation_date 
--,
LAST_UPDATE_DATE
desc
;

SELECT
*
FROM
RA_CUSTOMER_TRX_LINES_ALL
order by 
--creation_date 
--,
LAST_UPDATE_DATE
desc;


SELECT
*
FROM
RA_CUST_TRX_LINE_GL_DIST_ALL
;



SELECT 'Hi' XX 
  --,CT.*
  ,CL.*
  --,DST.*
  --,TT.*
  FROM APPS.RA_CUSTOMER_TRX_ALL CT,
       APPS.RA_CUSTOMER_TRX_LINES_ALL CL,
       APPS.RA_CUST_TRX_LINE_GL_DIST_ALL DST,
       APPS.RA_CUST_TRX_TYPES_ALL TT
 WHERE     1 = 1
       AND ((:P_ORG_ID IS NULL)  OR (CT.ORG_ID=:P_ORG_ID))
       AND (:P_VOUCHER_NUM IS NULL OR (CT.DOC_SEQUENCE_VALUE=:P_VOUCHER_NUM))
       AND (:P_TRX_NUM IS NULL OR (CT.TRX_NUMBER=:P_TRX_NUM))
       AND CT.CUSTOMER_TRX_ID = CL.CUSTOMER_TRX_ID
       AND CT.CUSTOMER_TRX_ID = DST.CUSTOMER_TRX_ID
       AND DST.CUSTOMER_TRX_LINE_ID = CL.CUSTOMER_TRX_LINE_ID
       AND CT.CUST_TRX_TYPE_ID = TT.CUST_TRX_TYPE_ID
       ;
       
       
       select
       *
       from
       ra_interface_errors_all;
       
       
       select
       *
       from
       ra_interface_lines_all
       WHERE 1=1
       AND ORG_ID=126