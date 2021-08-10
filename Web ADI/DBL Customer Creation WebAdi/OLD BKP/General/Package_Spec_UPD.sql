/* Formatted on 5/10/2021 11:29:58 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_cust_webadi_pkg
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;


   PROCEDURE import_data_from_web_adi (P_UNIT_NAME            VARCHAR2,
                                       P_CUSTOMER_NAME        VARCHAR2,
                                       P_CUSTOMER_TYPE        VARCHAR2,
                                       P_CUSTOMER_CATEGORY    VARCHAR2,
                                       P_ATTRIBUTE1           VARCHAR2,
                                       P_ATTRIBUTE2           VARCHAR2,
                                       P_ATTRIBUTE3           VARCHAR2,
                                       P_ATTRIBUTE4           VARCHAR2,
                                       P_ADDRESS1             VARCHAR2,
                                       P_ADDRESS2             VARCHAR2,
                                       P_ADDRESS3             VARCHAR2,
                                       P_ADDRESS4             VARCHAR2,
                                       P_POSTAL_CODE          VARCHAR2,
                                       P_TERRITORRY           VARCHAR2,
                                       P_DEMAND_CLASS         VARCHAR2,
                                       P_PAYMENT_TERM         VARCHAR2,
                                       P_SALESPERSON          VARCHAR2,
                                       P_GL_ACCOUNT           VARCHAR2);
END xxdbl_cust_webadi_pkg;
/