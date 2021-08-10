/* Formatted on 6/27/2020 10:28:59 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_ar_interface_upload_pkg
IS
   PROCEDURE import_data_to_ar_interface (ERRBUF    OUT VARCHAR2,
                                          RETCODE   OUT VARCHAR2);

   PROCEDURE upload_data_to_ar_int_stg (P_SL_NO                 NUMBER,
                                        P_ORGANIZATION_CODE     VARCHAR2,
                                        P_BATCH_SOURCE_NAME     VARCHAR2,
                                        P_TRX_TYPE              VARCHAR2,
                                        P_CUST_TRX_TYPE         VARCHAR2,
                                        P_LINE_NUMBER           NUMBER,
                                        P_TRX_DATE              DATE,
                                        P_GL_DATE               DATE,
                                        P_CURRENCY_CODE         VARCHAR2,
                                        P_CUSTOMER_NUMBER       VARCHAR2,
                                        P_ITEM_CODE             VARCHAR2,
                                        P_QUANTITY              NUMBER,
                                        P_UNIT_SELLING_PRICE    NUMBER);
END xxdbl_ar_interface_upload_pkg;
/
