/* Formatted on 3/4/2021 11:09:31 AM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION apps.get_mod_val_from_itm_grade (
   p_list_header_id   IN NUMBER,
   p_item_id          IN NUMBER,
   p_item_grade       IN VARCHAR2)
   RETURN NUMBER
IS
   ln_val   NUMBER;
-- CREATED BY : SOURAV PAUL
-- CREATION DATE : 04-MAR-2021
-- LAST UPDATE DATE :04-MAR-2021
-- PURPOSE : GET MODIFIER LINE VALUE FROM MODIFIER HEADER ID, ITEM ID, GRADE
BEGIN
   SELECT NVL (qll.operand, 0)
     INTO ln_val
     FROM apps.qp_list_headers_vl qlh,
          apps.qp_list_lines qll,
          apps.qp_pricing_attributes qpa
    WHERE     1 = 1
          AND qlh.list_header_id = qll.list_header_id
          AND qll.list_header_id = qpa.list_header_id
          AND qll.list_line_id = qpa.list_line_id
          AND TRUNC (SYSDATE) BETWEEN TRUNC (qll.start_date_active)
                                  AND TRUNC (qll.end_date_active)
          AND qpa.pricing_attribute = 'PRICING_ATTRIBUTE19'
          AND qlh.list_header_id = p_list_header_id
          AND TO_CHAR (qpa.product_attr_value) = p_item_id
          AND qpa.pricing_attr_value_from = p_item_grade;

   RETURN ln_val;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN '0';
--DBMS_OUTPUT.put_line ('ERROR: ' || SQLERRM);
END;
/