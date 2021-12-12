/* Formatted on 8/26/2021 10:39:51 AM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW APPS.XXDBLCL_SALES_ORDER_DTL_MV#
(
   ORG_ID,
   CUSTOMER_NUMBER,
   CUSTOMER_NAME,
   CUST_CATEGORY,
   C_TYPE,
   ADDRESS1,
   ORDER_NUMBER,
   ORDER_TYPE,
   ORDERED_DATE,
   INVOICE_DATE,
   PRIORITY,
   FREIGHT,
   FREIGHT_CHARGE,
   ORDER_FLOW_STATUS_CODE,
   LINE_FLOW_STATUS_CODE,
   ORDERED_ITEM,
   DESCRIPTION,
   ORDER_SHIPPING_INSTRUCTIONS,
   LINE_SHIPPING_INSTRUCTIONS,
   CUST_PO_NUMBER,
   PREFERRED_GRADE,
   ITEM_SIZE,
   PRODUCT_CATEGORY,
   PRODUCT_TYPE,
   ORDERED_QUANTITY,
   ORDER_QUANTITY_UOM,
   UNIT_LIST_PRICE,
   UNIT_SELLING_PRICE,
   ORDERED_QUANTITY2,
   ORDERED_QUANTITY_UOM2,
   SHIPPED_QUANTITY,
   SHIPPED_QUANTITY2,
   LINE_DISCOUNT,
   RESOURCE_NAME,
   SALESREP_ID,
   CUSTOMER_ID,
   CORRESPONDING_DEALER_CODE,
   CORRESPONDING_DEALER,
   ORDER_PACKING_INSTRUCTIONS,
   LINE_PACKING_INSTRUCTIONS
)
   BEQUEATH DEFINER
AS
   SELECT OH.ORG_ID,
       CUST.CUSTOMER_NUMBER,
       CUST.CUSTOMER_NAME,
       CUST.CUSTOMER_CATEGORY_CODE CUST_CATEGORY,
       CUST.CUSTOMER_TYPE C_TYPE,
       CUST.ADDRESS1,
       OH.ORDER_NUMBER,
       OTT.NAME ORDER_TYPE,
       TRUNC (OH.ORDERED_DATE) ORDERED_DATE,
       TRUNC (OL.ACTUAL_SHIPMENT_DATE) INVOICE_DATE,
       OH.SHIPMENT_PRIORITY_CODE PRIORITY,
       OL.FREIGHT_TERMS_CODE FREIGHT,
       CASE
          WHEN     OL.FREIGHT_TERMS_CODE = 'DEALER'
               AND OTT.TRANSACTION_TYPE_ID NOT IN (1006, 1014)
          THEN
             OL.ORDERED_QUANTITY * .8
          ELSE
             0
       END
          Freight_Charge,
       OH.FLOW_STATUS_CODE ORDER_FLOW_STATUS_CODE,
       OL.FLOW_STATUS_CODE LINE_FLOW_STATUS_CODE,
       OL.ORDERED_ITEM,
       MSI.DESCRIPTION,
       OH.SHIPPING_INSTRUCTIONS ORDER_SHIPPING_INSTRUCTIONS,
       OL.SHIPPING_INSTRUCTIONS LINE_SHIPPING_INSTRUCTIONS,
       OH.CUST_PO_NUMBER,
       OL.PREFERRED_GRADE,
       CAT.ITEM_SIZE ITEM_SIZE,
       CAT.PRODUCT_CATEGORY PRODUCT_CATEGORY,
       CAT.PRODUCT_TYPE PRODUCT_TYPE,
       OL.ORDERED_QUANTITY,
       OL.ORDER_QUANTITY_UOM,
       OL.UNIT_LIST_PRICE,
       OL.UNIT_SELLING_PRICE,
       OL.ORDERED_QUANTITY2,
       OL.ORDERED_QUANTITY_UOM2,
       OL.SHIPPED_QUANTITY,
       OL.SHIPPED_QUANTITY2,
       (OL.UNIT_LIST_PRICE - OL.UNIT_SELLING_PRICE) * OL.ORDERED_QUANTITY
          LINE_DISCOUNT,
       RSV.RESOURCE_NAME,
       OH.SALESREP_ID,
       CUST.CUSTOMER_ID,
       NVL (ACD.CUSTOMER_NUMBER, CUST.CUSTOMER_NUMBER)
          CORRESPONDING_DEALER_CODE,
       NVL (ACD.CUSTOMER_NAME, CUST.CUSTOMER_NAME) CORRESPONDING_DEALER,
       OH.PACKING_INSTRUCTIONS ORDER_PACKING_INSTRUCTIONS,
       OL.PACKING_INSTRUCTIONS LINE_PACKING_INSTRUCTIONS
  FROM OE_ORDER_HEADERS_ALL OH,
       OE_ORDER_LINES_ALL OL,
       APPS.OE_TRANSACTION_TYPES_TL OTT,
       INV.MTL_SYSTEM_ITEMS_B MSI,
       XX_AR_CUSTOMER_SITE_V CUST,
       APPS.AR_CUSTOMERS ACD,
       APPS.XXDBL_MTL_ITEM_CTG_INFO CAT,
       JTF_RS_SALESREPS SAL,
       JTF_RS_DEFRESOURCES_V RSV
 WHERE     OH.HEADER_ID = OL.HEADER_ID
       AND OH.ORDER_TYPE_ID = OTT.TRANSACTION_TYPE_ID
       AND OL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
       AND OL.SHIP_FROM_ORG_ID = MSI.ORGANIZATION_ID
       AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
       AND MSI.ORGANIZATION_ID = CAT.ORGANIZATION_ID
       AND OH.SALESREP_ID = SAL.SALESREP_ID
       AND OH.ORG_ID = SAL.ORG_ID
       AND SAL.RESOURCE_ID = RSV.RESOURCE_ID
       AND CUST.ACCT_USE_STATUS = 'A'
       AND CUST.SITE_USE_STATUS = 'A'
       AND OL.SOLD_TO_ORG_ID = CUST.CUSTOMER_ID
       AND OL.SHIP_TO_ORG_ID = CUST.SHIP_TO_ORG_ID
       AND OH.ATTRIBUTE3 = ACD.CUSTOMER_ID(+)
       AND OH.ORG_ID = 126;

GRANT SELECT ON APPS.XXDBLCL_SALES_ORDER_DTL_MV# TO APPSRO;

--------------------------------------------------------------------------------
EXEC ad_zd_mview.upgrade('APPS','XXDBLCL_SALES_ORDER_DTL_MV');

SELECT *
  FROM dba_objects
 WHERE object_name LIKE 'XXDBLCL_SALES_ORDER_DTL_MV%';


--------------------------------------------------------------------------------


EXECUTE dbms_mview.refresh('APPS.XXDBLCL_SALES_ORDER_DTL_MV',method =>'C',ATOMIC_REFRESH=>FALSE);

EXECUTE DBMS_MVIEW.REFRESH_ALL_MVIEWS(failures,'C','', TRUE, FALSE, FALSE);

BEGIN
   DBMS_MVIEW.refresh ('APPS.XXDBLCL_SALES_ORDER_DTL_MV',
                       method           => 'C',
                       atomic_refresh   => FALSE);
END;

EXECUTE dbms_mview.refresh('APPS.XXDBLCL_SALES_ORDER_DTL_MV','C', NULL, TRUE,FALSE,1,0,0,FALSE,FALSE,TRUE);


--------------------------------------------------------------------------------


BEGIN
   SYS.DBMS_SCHEDULER.create_job (
      job_name          => 'XXDBL_MVIEW_SCHEDULER',
      job_type          => 'PLSQL_BLOCK',
      job_action        => 'BEGIN EXECUTE dbms_mview.refresh(''APPS.XXDBLCL_SALES_ORDER_DTL_MV'',method => ''C'',ATOMIC_REFRESH=>FALSE) END;',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'freq=hourly; byminute=0',
      end_date          => NULL,
      enabled           => TRUE,
      comments          => 'Job defined entirely by the CREATE JOB procedure.');
END;
/


BEGIN
   SYS.DBMS_SCHEDULER.DROP_JOB (job_name => 'APPS.XXDBL_MVIEW_SCHEDULER');
END;
/


BEGIN
   SYS.DBMS_SCHEDULER.create_job (
      job_name          => 'XXDBL_MVIEW_SCHEDULER',
      job_type          => 'STORED_PROCEDURE',
      job_action        => 'APPS.XXDBL_MVIEW_DTLD_PKG.RUN_MVIEW_DATALOAD_PROC',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'freq=minutely; interval=15; bysecond=0;',
      end_date          => NULL,
      enabled           => TRUE,
      comments          => 'Job defined entirely by the CREATE JOB procedure.');
END;
/

BEGIN
   SYS.DBMS_SCHEDULER.create_job (
      job_name          => 'XXDBL_MVIEW_SCHEDULER',
      job_type          => 'PLSQL_BLOCK',
      job_action        => 'BEGIN APPS.XXDBL_MVIEW_DTLD_PKG.RUN_MVIEW_DATALOAD_PROC; END;',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'freq=daily; byhour=1; byminute=0; bysecond=0;',
      end_date          => NULL,
      enabled           => TRUE,
      comments          => 'Job Scheduled Created for Update Materialized View.');
END;
/

BEGIN
   DBMS_SCHEDULER.set_attribute (
      name        => 'APPS.XXDBL_MVIEW_SCHEDULER',
      attribute   => 'repeat_interval',
      VALUE       => 'freq=daily; byhour=1,13; byminute=30; bysecond=0;');
END;
/


 EXECUTE SYS.DBMS_SYNC_REFRESH.REGISTER_MVIEWS('XXDBLCL_SALES_ORDER_DTL_MV');



-- Display job run details.

  SELECT *
    FROM all_scheduler_job_run_details
   WHERE 1 = 1 AND job_name = 'XXDBL_MVIEW_SCHEDULER'
ORDER BY actual_start_date DESC;

--------------------------------------------------------------------------------


SELECT *
  FROM APPS.XXDBLCL_SALES_ORDER_DTL_MV
 WHERE 1 = 1
--AND PERIOD_DESC = 'FEB-21'
--AND ORGANIZATION_ID = 195
;
 --------------------------------------------------------------------------
      ----------XXDBLCL_SALES_ORDER_DTL_MV MVIEW DATALOAD--------------------------
      --------------------------------------------------------------------------

BEGIN
   ELSIF p_mview = 'XXDBLCL_SALES_ORDER_DTL_MV'
   THEN
      BEGIN
         x_mview_name := 'XXDBLCL_SALES_ORDER_DTL_MV';
         DBMS_MVIEW.REFRESH ('APPS.XXDBLCL_SALES_ORDER_DTL_MV',
                             METHOD           => 'C',
                             ATOMIC_REFRESH   => FALSE);
         COMMIT;
         fnd_file.put_line (
            fnd_file.LOG,
            'Successfully Refresh the Materialized View :' || x_mview_name);
      END;
   END IF;
END;