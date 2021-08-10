/* Formatted on 9/15/2020 11:29:59 AM (QP5 v5.287) */
DECLARE
   v_squence   NUMBER;
BEGIN
   SELECT MAX (NVL (fucn1, 365)) + 1
     INTO v_squence
     FROM xx_dbl_po_recv_adjust;

   UPDATE xx_dbl_po_recv_adjust
      SET fucn1 = v_squence
    WHERE po_no = '10323011434';

   DBMS_OUTPUT.put_line ('Update sequence is  : ' || v_squence);
END;