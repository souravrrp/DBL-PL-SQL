/* Formatted on 2/8/2022 11:49:10 AM (QP5 v5.374) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_cer_ar_intrf_pkg
IS
    p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
    p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
    p_user_id             NUMBER := apps.fnd_global.user_id;
    p_org_id              NUMBER := apps.fnd_global.org_id;
    p_login_id            NUMBER := apps.fnd_global.login_id;

    PROCEDURE import_data_to_ar_interface (ERRBUF    OUT VARCHAR2,
                                           RETCODE   OUT VARCHAR2);

    PROCEDURE upload_data_to_ar_int_stg (P_SL_NO                NUMBER,
                                         P_BATCH_SOURCE_NAME    VARCHAR2,
                                         P_TRX_TYPE             VARCHAR2,
                                         P_CUST_TRX_TYPE        VARCHAR2,
                                         P_LINE_NUMBER          NUMBER,
                                         P_TRX_DATE             DATE,
                                         P_GL_DATE              DATE,
                                         P_CURRENCY_CODE        VARCHAR2,
                                         P_CUSTOMER_NUMBER      VARCHAR2,
                                         P_QUANTITY             NUMBER,
                                         P_UNIT_SELLING_PRICE   NUMBER,
                                         P_DESCRIPTION          VARCHAR2,
                                         P_GL_CODE              VARCHAR2);
END xxdbl_cer_ar_intrf_pkg;
/
