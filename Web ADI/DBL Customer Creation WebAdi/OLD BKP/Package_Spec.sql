CREATE OR REPLACE PACKAGE APPS.xxdbl_cust_upld_webadi_pkg
IS
   PROCEDURE upload_data_from_stg_tbl (ERRBUF    OUT VARCHAR2,
                                       RETCODE   OUT VARCHAR2);

   PROCEDURE import_data_from_web_adi (P_UNIT_NAME        VARCHAR2,
                                       P_CUSTOMER_NAME     VARCHAR2,
                                       P_CUSTOMER_TYPE    VARCHAR2,
                                       P_ATTRIBUTE1       VARCHAR2,
                                       P_ATTRIBUTE2       VARCHAR2,
                                       P_ATTRIBUTE3       VARCHAR2,
                                       P_ATTRIBUTE4       VARCHAR2,
                                       P_ADDRESS1         VARCHAR2,
                                       P_ADDRESS2         VARCHAR2,
                                       P_ADDRESS3         VARCHAR2,
                                       P_ADDRESS4         VARCHAR2,
                                       P_POSTAL_CODE      VARCHAR2);

   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
END xxdbl_cust_upld_webadi_pkg;
/
