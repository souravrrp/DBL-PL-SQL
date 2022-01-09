CREATE OR REPLACE PACKAGE APPS.xxdbl_om_pkg
AS
   FUNCTION default_item_grade (p_inventory_item_id   IN NUMBER,
                                p_organization_id     IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION order_type_pl_match (p_order_type_id   IN NUMBER,
                                 p_org_id          IN NUMBER,
                                 p_pl_id           IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION GET_PARTY_SITE_ADDRESS (P_SITE_USE_ID NUMBER)
      RETURN VARCHAR2;

   FUNCTION GET_OM_PHONE_NUMBER (P_ID VARCHAR2, P_NAME VARCHAR2)
      RETURN VARCHAR2;
END xxdbl_om_pkg;
/