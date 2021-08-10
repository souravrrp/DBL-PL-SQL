/* Formatted on 10/28/2020 12:32:21 PM (QP5 v5.354) */
SELECT ln1.press_no
  FROM xxdbl.xxdbl_formtfl_header hdr, xxdbl.xxdbl_formtfl_line1 ln1
 WHERE     1 = 1
       AND hdr.batch_no = '3802'
       --AND ln1.press_no = '2'
       AND ln1.attribute1 = '3802-A-0005'
       AND hdr.FORMTFL_HEADER_ID = ln1.FORMTFL_HEADER_ID;


--------------------------------------------------------------------------------

SELECT *
  FROM xxdbl.xxdbl_formtfl_header
 WHERE 1 = 1 AND batch_no = '3802';


SELECT *
  FROM xxdbl.xxdbl_formtfl_line1 ln1
 WHERE     1 = 1
       AND ln1.FORMTFL_HEADER_ID = 1431
       ---AND ln1.press_no = '2'
       --AND ln1.glaze_line_no='Glaze Line2'
       AND ln1.attribute1 = '3802-A-0005';


UPDATE xxdbl.xxdbl_formtfl_line1 ln1
   SET ln1.glaze_line_no='Glaze Line3'
 WHERE     1 = 1
       AND ln1.FORMTFL_HEADER_ID = 1431
       --AND ln1.line_no = 'Phase1'
       --AND ln1.press_no = '2'
       AND ln1.glaze_line_no='Glaze Line2'
       AND ln1.attribute1 = '3802-A-0005';

--------------------------------------------------------------------------------

SELECT ln1.press_no
  FROM xxdbl.xxdbl_formtfl_header hdr, xxdbl.xxdbl_formtfl_line1 ln1
 WHERE     1 = 1
       AND hdr.batch_no = '3890'
       AND ln1.press_no = '2'
       AND ln1.attribute1 = '3802-A-0005'
       AND hdr.FORMTFL_HEADER_ID = ln1.FORMTFL_HEADER_ID;