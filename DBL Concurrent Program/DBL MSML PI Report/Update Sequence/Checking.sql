/* Formatted on 9/15/2020 11:28:46 AM (QP5 v5.287) */
SELECT MAX (NVL (fucn1, 365)) + 1
  FROM xx_dbl_po_recv_adjust
  --WHERE FUCDN1='2020'
  ;


SELECT (CASE WHEN COUNT (fucn1) = 0 THEN 1 ELSE MAX (fucn1) + 1 END) SEQ
            --INTO v_max
            FROM xx_dbl_po_recv_adjust
         WHERE FUCDN1 = '2020';

SELECT COUNT (*) v_po_number
  FROM xx_dbl_po_recv_adjust
 WHERE po_no = :p_po_number;

SELECT MAX (NVL (fucn1, 365)) + 1
  FROM xx_dbl_po_recv_adjust;

SELECT *
  FROM xx_dbl_po_recv_adjust
 WHERE po_no IN ('10323011428', '10323011434');


SELECT *
  FROM xx_dbl_po_recv_adjust
 WHERE 1=1 
 --AND po_no = '10323011434'
 AND FUCDN1='2020'
 ORDER BY FUCN1 DESC, TRANSACTION_DATE DESC;

  SELECT *
    FROM xx_dbl_po_recv_adjust
    where po_no = '10323010815'
ORDER BY TRANSACTION_DATE DESC