/* Formatted on 8/14/2021 1:29:36 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_item_upload_pkg
IS
   vl_set_process_id     NUMBER := TO_NUMBER (TO_CHAR (SYSDATE, 'ddmmyyyy'));

   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
   p_login_id            NUMBER := apps.fnd_global.login_id;

   PROCEDURE cust_upload_data_to_staging (
      P_COGS_ACCOUNT              VARCHAR2,
      P_DISCRETE_OR_PROCESS       VARCHAR2,
      P_DUAL_SINGLE_UOM           VARCHAR2,
      P_EXPENSE_ACCOUNT           VARCHAR2,
      P_INVENTORY_ITEM_ID         NUMBER,
      P_ITEM_CATEGORY_SEGMENT1    VARCHAR2,
      P_ITEM_CATEGORY_SEGMENT2    VARCHAR2,
      P_ITEM_CATEGORY_SEGMENT3    VARCHAR2,
      P_ITEM_CATEGORY_SEGMENT4    VARCHAR2,
      P_ITEM_CODE                 VARCHAR2,
      P_ITEM_CONVERSION_FACTOR    NUMBER,
      P_ITEM_DESCRIPTION          VARCHAR2,
      P_ITEM_TYPE                 VARCHAR2,
      P_LCM_ENABLED               VARCHAR2,
      P_LEAD_TIME                 NUMBER,
      P_LEGACY_ITEM_CODE          VARCHAR2,
      P_LIST_PRICE                NUMBER,
      P_LOT_CONTROLLED            VARCHAR2,
      P_LOT_DIVISIBLE             VARCHAR2,
      P_MAX_ORDER_QTY             VARCHAR2,
      P_MIN_MAX_PLANNING          VARCHAR2,
      P_MIN_ORDER_QTY             VARCHAR2,
      P_ORGANIZATION_CODE         VARCHAR2,
      P_ORGANIZATION_ID           NUMBER,
      P_ORG_HIERARCHY             VARCHAR2,
      P_PLANNER                   VARCHAR2,
      P_PRIMARY_UOM               VARCHAR2,
      P_SAFETY_STOCK              VARCHAR2,
      P_SALES_ACCOUNT             VARCHAR2,
      P_SECONDARY_UOM             VARCHAR2,
      P_SERIAL_CONTROLLED         VARCHAR2,
      P_SHELF_LIFE                VARCHAR2,
      P_SHELF_LIFE_DAY            VARCHAR2,
      P_STATUS                    VARCHAR2,
      P_STATUS_MESSAGE            VARCHAR2,
      P_TEMPLATE                  VARCHAR2);

   PROCEDURE assign_item_org_and_category (ERRBUF    OUT VARCHAR2,
                                           RETCODE   OUT VARCHAR2);

   --PROCEDURE cust_import_data_to_interface;

   PROCEDURE item_assign_uom_conv (um_item_code IN VARCHAR2);

   PROCEDURE item_assign_template (tm_item_code       IN VARCHAR2,
                                   tm_org_id          IN NUMBER,
                                   tm_template_name   IN VARCHAR2);

   PROCEDURE assign_item_category (vl_item_code          VARCHAR2,
                                   vl_organization_id    NUMBER,
                                   vlu_category_id       NUMBER);

   PROCEDURE create_lcm_item_category (Lcm_ITEM_CODE          VARCHAR2,
                                       Lcm_organization_id    NUMBER);
END xxdbl_item_upload_pkg;
/