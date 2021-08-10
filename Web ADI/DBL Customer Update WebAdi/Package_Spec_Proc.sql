/* Formatted on 4/11/2021 9:34:19 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE apps.xxdbl_cust_upd_webadi_pkg
IS
   PROCEDURE import_data_from_web_adi (P_UNIT_NAME           VARCHAR2,
                                       P_CUSTOMER_NO         VARCHAR2,
                                       P_EXISTING_ADDRESS    VARCHAR2,
                                       P_NEW_ADDRESS         VARCHAR2,
                                       P_POSTAL_CODE         VARCHAR2,
                                       P_SALESPERSON         VARCHAR2,
                                       P_TERRITORRY          VARCHAR2,
                                       P_DEMAND_CLASS        VARCHAR2);

   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
END xxdbl_cust_upd_webadi_pkg;
/