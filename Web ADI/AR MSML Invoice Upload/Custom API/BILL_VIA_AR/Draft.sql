/* Formatted on 6/16/2020 6:19:24 PM (QP5 v5.287) */
  SELECT SL_NO,
         BILL_HEADER_ID,
         BILL_LINE_ID,
         CHALLAN_NUMBER,
         OPERATING_UNIT,
         ORG_ID,
         CUSTOMER_NUMBER,
         CUSTOMER_ID,
         CUSTOMER_NAME,
         CUSTOMER_TYPE,
         BILL_DATE,
         BILL_CURRENCY,
         BILL_CATEGORY,
         EXCHANCE_RATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATED_BY,
         CREATION_DATE,
         BILL_TYPE,
         CHALLAN_QTY,
         CHALLAN_DATE,
         ITEM_CODE,
         ITEM_NAME,
         UOM,
         FINISHING_WEIGHT,
         UNIT_SELLING_PRICE,
         STATUS,
         flag
    --  ,STG.*
    FROM APPS.ar_bill_upload_adi_stg STG
   WHERE 1 = 1
--AND BILL_HEADER_ID='26982'
--AND FLAG IS NULL
ORDER BY CHALLAN_NUMBER DESC;

UPDATE APPS.ar_bill_upload_adi_stg
   SET CHALLAN_NUMBER = NULL,
       BILL_HEADER_ID = NULL,
       BILL_LINE_ID = NULL,
       flag = NULL
 --,EXCHANCE_RATE='87'
 --,CHALLAN_DATE='13-JUN-2020'
 --,SL_NO=2
 --,BILL_DATE='11-JUN-2020'
 --,CHALLAN_QTY=14
 --,LAST_UPDATE_DATE='17-JUN-2020'
 --,CREATION_DATE='16-JUN-2020'
 WHERE 1 = 1 AND BILL_HEADER_ID IN ('26988')
--AND flag IS NULL
--AND CHALLAN_DATE='13-JUN-2020'
--AND EXCHANCE_RATE='87'
--AND ITEM_CODE='YRN34S100CVC53820513'
--AND FINISHING_WEIGHT='2'
--AND BILL_DATE='11-JUN-2020'
--AND SL_NO=1
;


DELETE FROM APPS.ar_bill_upload_adi_stg
      WHERE 1 = 1 --and BILL_DATE='12-JUN-2020'
            AND flag IS NULL --AND CHALLAN_DATE='13-JUN-2020'
            AND EXCHANCE_RATE = '87';

COMMIT;


SELECT '1' SL_NO,
       BHA.BILL_HEADER_ID,
       OPERATING_UNIT,
       ORG_ID,
       CUSTOMER_NUMBER,
       CUSTOMER_ID,
       CUSTOMER_NAME,
       CUSTOMER_TYPE,
       BILL_DATE,
       BILL_CURRENCY,
       BILL_CATEGORY,
       EXCHANCE_RATE,
       BHA.LAST_UPDATE_DATE,
       BHA.LAST_UPDATED_BY,
       BHA.LAST_UPDATE_LOGIN,
       BHA.CREATED_BY,
       BHA.CREATION_DATE,
       BILL_TYPE,
       BLA.BILL_LINE_ID,
       CHALLAN_NUMBER,
       CHALLAN_QTY,
       CHALLAN_DATE,
       --ITEM_CODE,
       --ITEM_DESCRIPTION ITEM_NAME,
       --UOM,
       --FINISHING_WEIGHT,
       --UNIT_SELLING_PRICE,
       BILL_STATUS
       --,BHA.*
       --,BLA.*
       ,BDA.*
  FROM XX_AR_BILLS_HEADERS_ALL BHA,
       XX_AR_BILLS_LINES_ALL BLA,
       XX_AR_BILLS_LINE_DETAILS_ALL BDA
 WHERE     BHA.ORG_ID = 131
       AND BHA.BILL_HEADER_ID = BLA.BILL_HEADER_ID
       AND BLA.BILL_LINE_ID = BDA.BILL_LINE_ID
       --AND BILL_NUMBER = 'MSML/2000'
       AND BHA.BILL_HEADER_ID = '26995'
--AND CHALLAN_NUMBER='MSML/11970'
;

SELECT DISTINCT SL_NO,
                BILL_HEADER_ID,
                OPERATING_UNIT,
                ORG_ID,
                CUSTOMER_NUMBER,
                CUSTOMER_ID,
                CUSTOMER_NAME,
                CUSTOMER_TYPE,
                BILL_CURRENCY,
                BILL_CATEGORY,
                BILL_DATE,
                EXCHANCE_RATE,
                BILL_TYPE,
                MAX(last_update_date),
                last_updated_by,
                last_update_login,
                created_by,
                MAX(creation_date),
                status
  FROM ar_bill_upload_adi_stg
 WHERE 1 = 1 AND flag IS NULL
--and sl_no=1
GROUP BY
SL_NO,
                BILL_HEADER_ID,
                OPERATING_UNIT,
                ORG_ID,
                CUSTOMER_NUMBER,
                CUSTOMER_ID,
                CUSTOMER_NAME,
                CUSTOMER_TYPE,
                BILL_CURRENCY,
                BILL_CATEGORY,
                BILL_DATE,
                EXCHANCE_RATE,
                BILL_TYPE,
                last_updated_by,
                last_update_login,
                created_by,
                status
;


UPDATE apps.ar_bill_upload_adi_stg
   SET BILL_HEADER_ID = '26895'
 WHERE 1 = 1 AND flag IS NULL;


SELECT DISTINCT SL_NO,
                BILL_HEADER_ID,
                BILL_LINE_ID,
                CHALLAN_QTY,
                CHALLAN_DATE,
                OPERATING_UNIT
  FROM ar_bill_upload_adi_stg
 WHERE 1 = 1 
 --AND BILL_HEADER_ID = v_bill_header_id_seq 
 AND flag IS NULL;
 
 
UPDATE apps.ar_bill_upload_adi_stg
   SET BILL_LINE_ID =
          xx_com_pkg.get_sequence_value ('XX_AR_BILLS_LINES_ALL',
                                         'BILL_LINE_ID'),
       CHALLAN_NUMBER = 'MSML/12087'
 WHERE BILL_HEADER_ID = '26895' AND CHALLAN_NUMBER IS NULL
 AND ROWNUM=1;


SELECT *
  FROM apps.ar_bill_upload_adi_stg
 --   SET BILL_LINE_ID =
 --          xx_com_pkg.get_sequence_value ('XX_AR_BILLS_LINES_ALL',
 --                                         'BILL_LINE_ID'),
 --       CHALLAN_NUMBER = 'MSML/12087'
 WHERE BILL_HEADER_ID = '26895' AND CHALLAN_NUMBER IS NULL AND ROWNUM = 1;


SELECT BILL_HEADER_ID,
       last_update_date,
       last_updated_by,
       last_update_login,
       created_by,
       creation_date,
       CHALLAN_NUMBER,
       CHALLAN_QTY,
       CHALLAN_DATE,
       BILL_CATEGORY,
       BILL_LINE_ID
  FROM ar_bill_upload_adi_stg
 WHERE BILL_HEADER_ID = 26889
--                   AND flag is null
;


SELECT DISTINCT BILL_LINE_ID,
                last_update_date,
                last_updated_by,
                last_update_login,
                created_by,
                creation_date,
                ITEM_CODE,
                FINISHING_WEIGHT,
                UNIT_SELLING_PRICE,
                ITEM_NAME,
                UOM
  FROM ar_bill_upload_adi_stg
 WHERE BILL_LINE_ID = '27328';

EXECUTE APPS.ar_bill_upload_adi_pkg.upload_data_to_staging(16,'MSML','2027','USD','Yarn Export',84,'16-JUN-20','Sample','09-JUN-20',25,'YRN40S100CTN52199944',8,'10423001696',' ');

EXECUTE apps.ar_bill_upload_adi_pkg.import_data_to_ar_tbl;