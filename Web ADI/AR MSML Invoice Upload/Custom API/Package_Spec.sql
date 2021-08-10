CREATE OR REPLACE PACKAGE APPS.xxdbl_ar_invoice_upld_adi_pkg
IS
   PROCEDURE import_data_to_ar_cust_trx (ERRBUF    OUT VARCHAR2,
                                         RETCODE   OUT VARCHAR2);


   PROCEDURE ar_cust_trx_stg_upload (P_SL_NO                 NUMBER,
                                     P_LINE_NUMBER           NUMBER,
                                     P_BILL_DATE             DATE,
                                     P_CURRENCY_CODE         VARCHAR2,
                                     P_CUSTOMER_NUMBER       VARCHAR2,
                                     P_CUSTOMER_NAME         VARCHAR2,
                                     P_ITEM_CODE             VARCHAR2,
                                     P_QUANTITY              NUMBER,
                                     P_UNIT_SELLING_PRICE    NUMBER,
                                     P_BILL_CATEGORY         VARCHAR2,
                                     P_CHALLAN_DATE          DATE,
                                     P_PO_NUMBER             VARCHAR2,
                                     P_PI_NUMBER             VARCHAR2,
                                     P_EXCHANCE_RATE           NUMBER);

   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
END xxdbl_ar_invoice_upld_adi_pkg;
/