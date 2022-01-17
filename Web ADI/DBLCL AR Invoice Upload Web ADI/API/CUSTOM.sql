/* Formatted on 4/25/2021 12:43:13 PM (QP5 v5.287) */
--xxdbl_cer_ar_inv_upld_pkg

CREATE OR REPLACE PACKAGE APPS.xxdbl_cer_ar_inv_upld_pkg
IS
   PROCEDURE import_data_to_ar_invoice;

   PROCEDURE import_data_to_ar_cust_trx (ERRBUF    OUT VARCHAR2,
                                         RETCODE   OUT VARCHAR2);


   PROCEDURE ar_cust_trx_stg_upload (P_SL_NO                 NUMBER,
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
                                     P_UNIT_SELLING_PRICE    NUMBER,
                                     P_LINE_DESCRIPTION      VARCHAR2);
END xxdbl_cer_ar_inv_upld_pkg;
/