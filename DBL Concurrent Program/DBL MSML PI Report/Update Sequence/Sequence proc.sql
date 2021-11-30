/* Formatted on 11/30/2021 11:20:11 AM (QP5 v5.365) */
DECLARE
    v_squence   NUMBER;
BEGIN
    SELECT MAX (NVL (fucn1, 365)) + 1
      INTO v_squence
      FROM xx_dbl_po_recv_adjust
     WHERE FUCDN1 = '2021';

    UPDATE xx_dbl_po_recv_adjust
       SET fucn1 = v_squence
     WHERE po_no = '10423005167';

    DBMS_OUTPUT.put_line ('Update sequence is  : ' || v_squence);
END;