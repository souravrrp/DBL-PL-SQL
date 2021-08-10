CREATE OR REPLACE PACKAGE APPS.xxdbl_cust_site_webadi_pkg
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
   p_login_id            NUMBER := apps.fnd_global.login_id;

   PROCEDURE import_data_from_web_adi (p_unit_name         VARCHAR2,
                                       p_customer_no       VARCHAR2,
                                       p_address1          VARCHAR2,
                                       p_address2          VARCHAR2,
                                       p_address3          VARCHAR2,
                                       p_contact_person    VARCHAR2,
                                       p_contact_number    VARCHAR2,
                                       p_country           VARCHAR2,
                                       p_area              VARCHAR2,
                                       p_zone              VARCHAR2,
                                       p_division          VARCHAR2,
                                       p_salesperson_id    VARCHAR2,
                                       p_postal_code       VARCHAR2,
                                       p_demand_class      VARCHAR2,
                                       p_customer_category VARCHAR2);
END xxdbl_cust_site_webadi_pkg;
/