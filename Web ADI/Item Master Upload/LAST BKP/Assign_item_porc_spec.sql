/* Formatted on 6/28/2020 2:02:54 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE apps.cust_webadi_item_assign_pkg
IS
   PROCEDURE assign_item_org_and_category (
      errbuf                  OUT VARCHAR2,
      retcode                 OUT VARCHAR2,
      cp_organization_id   IN     NUMBER,
      LCM_FLAG             IN     VARCHAR2);

   PROCEDURE assign_item_into_org (l_item_code          VARCHAR2,
                                   l_organization_id    NUMBER);

   PROCEDURE assign_item_category (vl_item_code          VARCHAR2,
                                   vl_organization_id    NUMBER);

   PROCEDURE create_lcm_item_category (Lcm_ITEM_CODE          VARCHAR2,
                                       Lcm_organization_id    NUMBER);
END cust_webadi_item_assign_pkg;
/