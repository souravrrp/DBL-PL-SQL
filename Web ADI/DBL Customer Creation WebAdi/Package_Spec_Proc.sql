/* Formatted on 6/24/2021 2:49:27 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE apps.xxdbl_cust_creation_pkg
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
   p_login_id            NUMBER := apps.fnd_global.login_id;

   PROCEDURE upload_data_from_stg_tbl (errbuf    OUT VARCHAR2,
                                       retcode   OUT VARCHAR2);

   PROCEDURE import_data_from_web_adi (P_UNIT_NAME             VARCHAR2,
                                       P_CUSTOMER_NO           VARCHAR2,
                                       P_CUSTOMER_NAME         VARCHAR2,
                                       P_CUSTOMER_TYPE         VARCHAR2,
                                       P_CUSTOMER_CATEGORY     VARCHAR2,
                                       P_BIN_NUMBER            VARCHAR2,
                                       P_TIN_NUMBER            VARCHAR2,
                                       P_IRC_NUMBER            VARCHAR2,
                                       P_ERC_NUMBER            VARCHAR2,
                                       P_ADDRESS1              VARCHAR2,
                                       P_ADDRESS2              VARCHAR2,
                                       P_ADDRESS3              VARCHAR2,
                                       P_ADDRESS4              VARCHAR2,
                                       P_EMAIL_ADDRESS         VARCHAR2,
                                       P_GL_ACCOUNT            VARCHAR2,
                                       P_CREDIT_LIMIT          NUMBER,
                                       P_PAYMENT_TERM          VARCHAR2,
                                       P_POSTAL_CODE           VARCHAR2,
                                       P_CUST_SITE_CATEGORY    VARCHAR2,
                                       P_SITE_ADDRESS1         VARCHAR2,
                                       P_SITE_ADDRESS2         VARCHAR2,
                                       P_SITE_ADDRESS3         VARCHAR2,
                                       P_CONTACT_PERSON        VARCHAR2,
                                       P_CONTACT_NUMBER        VARCHAR2,
                                       P_COUNTRY               VARCHAR2,
                                       P_AREA                  VARCHAR2,
                                       P_ZONE                  VARCHAR2,
                                       P_DIVISION              VARCHAR2,
                                       P_SALESPERSON           VARCHAR2,
                                       P_SITE_POSTAL_CODE      VARCHAR2,
                                       P_DEMAND_CLASS          VARCHAR2);
END xxdbl_cust_creation_pkg;
/