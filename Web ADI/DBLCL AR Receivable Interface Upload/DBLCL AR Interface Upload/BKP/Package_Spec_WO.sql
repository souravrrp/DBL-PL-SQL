/* Formatted on 8/20/2020 12:42:11 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_ar_interface_upload_pkg
IS
   PROCEDURE import_data_to_ar_interface (ERRBUF    OUT VARCHAR2,
                                          RETCODE   OUT VARCHAR2);

   PROCEDURE upload_data_to_ar_int_stg (P_CUST_TRX_TYPE         VARCHAR2,
                                        P_LINE_NUMBER           NUMBER,
                                        P_TRX_DATE              DATE,
                                        P_GL_DATE               DATE,
                                        P_CURRENCY_CODE         VARCHAR2,
                                        P_EXCHANGE_RATE         NUMBER,
                                        P_CUSTOMER_NUMBER       VARCHAR2,
                                        P_ITEM_CODE             VARCHAR2,
                                        P_QUANTITY              NUMBER,
                                        P_UNIT_SELLING_PRICE    NUMBER,
                                        P_PO_NUMBER             VARCHAR2,
                                        P_PI_NUMBER             VARCHAR2);

   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
END xxdbl_ar_interface_upload_pkg;
/