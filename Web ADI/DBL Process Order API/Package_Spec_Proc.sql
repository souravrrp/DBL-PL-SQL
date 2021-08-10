/* Formatted on 5/23/2021 11:09:12 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE apps.xxdbl_om_order_upld_pkg
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;

   PROCEDURE process_data_from_stg_tbl (ERRBUF    OUT VARCHAR2,
                                        RETCODE   OUT VARCHAR2);

   PROCEDURE import_data_from_web_adi (p_customer_number    VARCHAR2,
                                       p_order_type         VARCHAR2,
                                       p_item_code          VARCHAR2,
                                       p_quantity           NUMBER,
                                       p_cust_po_number     VARCHAR2);
END xxdbl_om_order_upld_pkg;
/