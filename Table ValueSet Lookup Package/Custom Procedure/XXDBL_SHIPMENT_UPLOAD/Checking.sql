/* Formatted on 11/16/2021 4:13:53 PM (QP5 v5.365) */
SELECT * FROM XXDBL.XXDBL_SHIPMENT_UPLOAD_STG;

SELECT *
  FROM XXDBL.XX_EXPLC_SHIPMENT_MST
 WHERE 1 = 1 AND ORG_ID = 109 AND TO_CHAR (BL_DATE, 'MON-RRRR') = 'JUL-2021';

SELECT *
  FROM XXDBL.XX_EXPLC_SHIPMENT_DTL
 WHERE 1 = 1 AND SHIPMENT_ID = '194807';

--------------------------------------------------------------------------------

 EXECUTE APPS.XXDBL_SHIPMENT_UPLOAD;