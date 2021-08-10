/* Formatted on 10/29/2020 9:50:20 AM (QP5 v5.354) */
SELECT *
  FROM xxdbl_kiln_headers
 WHERE 1 = 1 AND batch_no = '2010';

SELECT *
  FROM xxdbl_kiln_line1
 WHERE     1 = 1
       AND tiles_from_tf_loading = '3990'
       AND kiln_header_id = '828'
       AND kiln_line1_id = '7866';


SELECT *
  FROM xxdbl_kiln_line2
 WHERE     1 = 1
       AND locator_code = 'WPallet-142'
       AND kiln_header_id = '828'
       AND kiln_line1_id = '7866';
       
       
-----------------------------UPDATE---------------------------------------------

/*
UPDATE xxdbl_kiln_line1
   SET KILN_GAP_TIME = 0
 WHERE 1 = 1 AND tiles_from_tf_loading = '226710' AND kiln_header_id = '1667';
*/