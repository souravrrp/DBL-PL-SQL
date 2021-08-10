/* Formatted on 10/29/2020 9:50:47 AM (QP5 v5.354) */
SELECT *
  FROM xxdbl.xxdbl_formtb_headers fh, xxdbl.xxdbl_formtb_line1 fl1
 WHERE     1 = 1
       AND fh.formtb_header_id = fl1.formtb_header_id
       AND fh.batch_no = '3529'
       AND fl1.attribute7 IN ('3529-0026', '3529-0027');



--------------------------------------------------------------------------------

SELECT * FROM xxdbl.xxdbl_formtb_line1;


SELECT * FROM xxdbl.xxdbl_formtb_headers;