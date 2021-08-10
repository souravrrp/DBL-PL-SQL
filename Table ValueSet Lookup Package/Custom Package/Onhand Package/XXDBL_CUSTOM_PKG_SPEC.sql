/* Formatted on 7/15/2020 2:07:53 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.XXDBL_CUSTOM_PKG
AS
   FUNCTION xx_onhand_qty (p_inv_item_id   IN VARCHAR2,
                           p_org_id           NUMBER,
                           p_qty_type      IN VARCHAR2)
      RETURN NUMBER;
END;
/