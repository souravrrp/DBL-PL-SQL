/* Formatted on 12/7/2021 11:21:13 AM (QP5 v5.365) */
SELECT * FROM XXDBL.XXDBL_SHIPMENT_UPLOAD_STG;

--------------------------------------------------------------------------------
EXECUTE APPS.XXDBL_SHIPMENT_UPLOAD;


  SELECT *
    FROM xxdbl.xxdbl_shipment_upload_stg
   WHERE status IS NULL
ORDER BY inv_no;


--------------------------------------------------------------------------------

SELECT SHIPMENT_ID,
       ORG_ID,
       CUSTOMER_ID,
       EXPLC_MASTER_ID,
       CONTRACT_LC_NO,
       BL_NO,
       BL_DATE,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       SHIPMENT_DATE,
       SHIPMENT_NUMBER,
       FILE_NO,
       cust_trx_type_name,
       invoice_description,
       REC_CCID,
       REV_CCID,
       cust_trx_type_id,
       INSERT_STATUS
  FROM XXDBL.XX_EXPLC_SHIPMENT_MST
 WHERE 1 = 1 AND TO_CHAR (BL_DATE, 'MON-RRRR') = 'NOV-2021';

SELECT SHIPMENT_ID,
       COMM_INVOICE_NO,
       COMM_INVOICE_DATE,
       EXP_NO,
       EXP_DATE,
       COMM_INVOICE_ID,
       SHIPMENT_MODE,
       SHIP_TO_ORG_ID
  FROM XXDBL.XX_EXPLC_SHIPMENT_COMM
 WHERE 1 = 1 AND SHIPMENT_ID IN (195467, 195468);

SELECT SHIPMENT_ID,
       PRODUCT_UOM,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       PRODUCT_NO,
       PRODUCT_QTY,
       COMM_INVOICE_ID,
       UNIT_PRICE,
       EXPLC_ORDER_STYLE,
       CURRENCY_UNIT_PRICE
  FROM XXDBL.XX_EXPLC_SHIPMENT_DTL
 WHERE 1 = 1 AND SHIPMENT_ID IN (195467, 195468);

--------------------------------------------------------------------------------

DELETE FROM XXDBL.XXDBL_SHIPMENT_UPLOAD_STG;

DELETE FROM XXDBL.XX_EXPLC_SHIPMENT_MST
      WHERE SHIPMENT_ID IN (195467, 195468);

DELETE FROM XXDBL.XX_EXPLC_SHIPMENT_COMM
      WHERE SHIPMENT_ID IN (195467, 195468);

DELETE FROM XXDBL.XX_EXPLC_SHIPMENT_DTL
      WHERE SHIPMENT_ID IN (195467, 195468);

--------------------------------------------------------------------------------

--DBL Create Export Bill Receivable Invoice Program
--XX_AR_PKG.CREATE_EXP_AR_INVOICE2

  SELECT sm.org_id,
         sm.shipment_id
             invoice_id,
         sm.shipment_number
             bill_number,
         shipment_date
             trx_date,
         shipment_date
             gl_date,
         'USD'
             invoice_currency_code,
         conversion_rate
             exchance_rate,
         'Export'
             attribute_category,
         sm.shipment_id
             attribute1,
         sc.comm_invoice_no
             attribute3,
         (TO_CHAR (comm_invoice_date, 'YYYY/MM/DD') || ' 00:00:00')
             attribute5,
         sm.customer_id,
         sm.shipment_number
             comments,
         CUST_TRX_TYPE_ID,
         rec_ccid,
         rev_ccid
    FROM xx_explc_shipment_mst sm,
         xx_explc_shipment_comm sc,
         (SELECT conversion_rate, conversion_date
            FROM gl_daily_rates_v
           WHERE     user_conversion_type = 'Corporate'
                 AND from_currency = 'USD'
                 AND to_currency = 'BDT') conv
   WHERE     sm.shipment_id = sc.shipment_id
         AND sm.shipment_date = conv.conversion_date
         AND shipment_date IS NOT NULL
         AND comm_invoice_no IS NOT NULL
         AND sm.org_id = :p_org_id
         AND sm.ar_invoice_id IS NULL
         AND TRUNC (sm.shipment_date) >= '01-JAN-2015'
         AND TO_CHAR (sm.shipment_date, 'MON-YY') = :p_period_name
         AND NOT EXISTS
                 (SELECT 1
                    FROM ra_customer_trx_all ra
                   WHERE     ra.attribute1 = TO_CHAR (sm.shipment_id)
                         AND ra.org_id = sm.org_id)
ORDER BY invoice_id;