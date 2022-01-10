/* Formatted on 9/1/2020 11:49:33 AM (QP5 v5.354) */
SELECT *
  FROM qp_secu_list_headers_v slh, qp_list_lines_v ll
 WHERE     1 = 1
       AND slh.LIST_HEADER_ID = ll.LIST_HEADER_ID
       AND ll.PRODUCT_ATTR_VAL_DISP = 'CHEMICAL000000000885'
       AND slh.name = 'TPWL Inter Company Price List';

--------------------------------------------------------------------------------

SELECT *
  FROM qp_secu_list_headers_v slh
 WHERE 1 = 1 AND slh.name = 'TPWL Inter Company Price List';


SELECT *
  FROM qp_list_lines_v ll
 WHERE 1 = 1 AND PRODUCT_ATTR_VAL_DISP = 'CHEMICAL000000000885';