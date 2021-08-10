/* Formatted on 7/13/2020 1:16:29 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE apps.xxdbl_ar_invoice_upld_adi_pkg
IS
   PROCEDURE import_data_to_ar_tbl (ERRBUF    OUT VARCHAR2,
                                    RETCODE   OUT VARCHAR2);

   PROCEDURE XXDBL_MSML_CREATE_AR_INVOICE;

   PROCEDURE upload_data_to_staging (P_SL_NO               NUMBER,
                                     P_OPERATING_UNIT      VARCHAR2,
                                     P_CUSTOMER_NUMBER     VARCHAR2,
                                     P_BILL_CURRENCY       VARCHAR2,
                                     P_BILL_CATEGORY       VARCHAR2,
                                     P_EXCHANCE_RATE       NUMBER,
                                     P_BILL_DATE           DATE,
                                     P_BILL_TYPE           VARCHAR2,
                                     P_CHALLAN_DATE        DATE,
                                     P_CHALLAN_QTY         NUMBER,
                                     P_ITEM_CODE           VARCHAR2,
                                     P_FINISHING_WEIGHT    NUMBER,
                                     P_PO_NUMBER           VARCHAR2,
                                     P_PI_NUMBER           VARCHAR2);

   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
END xxdbl_ar_invoice_upld_adi_pkg;
/