/* Formatted on 1/14/2020 5:16:34 PM (QP5 v5.287) */
  SELECT (CASE WHEN COUNT (fucn1) = 0 THEN 1 ELSE MAX (fucn1) + 1 END) 
    --  into
    --  v_max
    FROM xx_dbl_po_recv_adjust
   WHERE FUCDN1 = 2020