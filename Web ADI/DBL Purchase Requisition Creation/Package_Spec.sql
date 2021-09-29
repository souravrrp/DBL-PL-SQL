/* Formatted on 9/29/2021 9:28:45 AM (QP5 v5.354) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_pr_creation_pkg
IS
    p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
    p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
    p_user_id             NUMBER := apps.fnd_global.user_id;
    p_org_id              NUMBER := apps.fnd_global.org_id;
    p_login_id            NUMBER := apps.fnd_global.login_id;

    PROCEDURE cust_upload_data_to_staging (
        P_ITEM_CODE                VARCHAR2,
        P_ITEM_DESCRIPTION         VARCHAR2,
        P_PRIMARY_UOM              VARCHAR2,
        P_SECONDARY_UOM            VARCHAR2,
        P_ITEM_CONVERSION_FACTOR   NUMBER,
        P_ORGANIZATION_CODE        VARCHAR2,
        P_LOT_CONTROLLED           VARCHAR2,
        P_LOT_DIVISIBLE            VARCHAR2,
        P_DUAL_SINGLE_UOM          VARCHAR2,
        P_DISCRETE_OR_PROCESS      VARCHAR2,
        P_ORG_HIERARCHY            VARCHAR2,
        P_TEMPLATE                 VARCHAR2,
        P_ITEM_TYPE                VARCHAR2,
        P_ITEM_CATEGORY_SEGMENT1   VARCHAR2,
        P_ITEM_CATEGORY_SEGMENT2   VARCHAR2,
        P_ITEM_CATEGORY_SEGMENT3   VARCHAR2,
        P_ITEM_CATEGORY_SEGMENT4   VARCHAR2,
        P_LCM_ENABLED              VARCHAR2,
        P_LIST_PRICE               NUMBER,
        P_EXPENSE_ACCOUNT          VARCHAR2,
        P_COGS_ACCOUNT             VARCHAR2,
        P_SALES_ACCOUNT            VARCHAR2,
        P_SERIAL_CONTROLLED        VARCHAR2,
        P_SHELF_LIFE               VARCHAR2,
        P_SHELF_LIFE_DAY           VARCHAR2,
        P_MIN_MAX_PLANNING         VARCHAR2,
        P_PLANNER                  VARCHAR2,
        P_MIN_ORDER_QTY            VARCHAR2,
        P_MAX_ORDER_QTY            VARCHAR2,
        P_SAFETY_STOCK             VARCHAR2,
        P_LEAD_TIME                NUMBER,
        P_STATUS                   VARCHAR2,
        P_STATUS_MESSAGE           VARCHAR2,
        P_LEGACY_ITEM_CODE         VARCHAR2,
        P_INVENTORY_ITEM_ID        NUMBER,
        P_ORGANIZATION_ID          NUMBER);

    PROCEDURE create_pr_from_interface (ERRBUF    OUT VARCHAR2,
                                        RETCODE   OUT VARCHAR2);
END xxdbl_pr_creation_pkg;
/