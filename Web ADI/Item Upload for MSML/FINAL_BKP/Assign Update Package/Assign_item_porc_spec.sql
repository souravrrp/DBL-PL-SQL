/* Formatted on 7/15/2020 3:17:17 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE apps.XXDBL_ITEM_ASSIGN_WEBADI_PKG
IS
   PROCEDURE assign_item_org_and_category (errbuf    OUT VARCHAR2,
                                           retcode   OUT VARCHAR2);

   PROCEDURE assign_item_into_org (l_item_code          VARCHAR2,
                                   l_organization_id    NUMBER);

   PROCEDURE assign_item_category (vl_item_code          VARCHAR2,
                                   vl_organization_id    NUMBER,
                                   vlu_category_id       NUMBER);

   PROCEDURE create_lcm_item_category (Lcm_ITEM_CODE          VARCHAR2,
                                       Lcm_organization_id    NUMBER);

   PROCEDURE item_assign_uom_conv (um_item_code IN VARCHAR2);

   PROCEDURE item_assign_template (tm_item_code       IN VARCHAR2,
                                   tm_org_id          IN NUMBER,
                                   tm_template_name   IN VARCHAR2);
END XXDBL_ITEM_ASSIGN_WEBADI_PKG;
/