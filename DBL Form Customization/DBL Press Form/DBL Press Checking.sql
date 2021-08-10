/* Formatted on 2/4/2021 3:19:13 PM (QP5 v5.354) */
SELECT 
    --hdr.*
    --ln1.*
    ln2.*
  FROM xxdbl.xxdbl_formpress_header  hdr,
       xxdbl.xxdbl_formpress_line1   ln1,
       xxdbl.xxdbl_formpress_line2   ln2
 WHERE     1 = 1
       AND hdr.batch_no = '4947'
       --AND ln1.press_no = '2'
       AND ln1.attribute1 = '4947-A-0001'
       AND hdr.formpress_header_id = ln1.formpress_header_id(+)
       AND hdr.formpress_header_id = ln2.formpress_header_id(+)
       AND ln1.formpress_line1_id = ln2.formpress_line1_id(+);


--------------------------------------------------------------------------------

SELECT *
  FROM xxdbl.xxdbl_formpress_header
 WHERE 1 = 1 AND batch_no = '4865';


SELECT *
  FROM xxdbl.xxdbl_formpress_line1 ln1
 WHERE     1 = 1
       AND ln1.formpress_header_id = 1818
       AND ln1.press_no = '3'
       AND ln1.attribute1 = '4865-B-0005'
;

UPDATE xxdbl.xxdbl_formpress_line1 ln1
   SET ln1.confirm_flag = 'N', ln1.confirm_date = NULL
 WHERE     1 = 1
       AND ln1.formpress_header_id = 1858
       AND ln1.press_no = '5'
       AND ln1.attribute1 = '4947-A-0001';

--------------------------------------------------------------------------------

SELECT ln1.press_no
  FROM xxdbl.xxdbl_formpress_header hdr, xxdbl.xxdbl_formpress_line1 ln1
 WHERE     1 = 1
       AND hdr.batch_no = '3890'
       AND ln1.press_no = '2'
       AND ln1.attribute1 = '3890-C-0004'
       AND hdr.formpress_header_id = ln1.formpress_header_id;