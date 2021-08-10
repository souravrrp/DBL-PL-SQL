/* Formatted on 2/13/2021 11:18:47 AM (QP5 v5.354) */
SELECT                                                                  --sh.*
       sl.*
  FROM xxdbl.xxdbl_sqrpol_headers sh, xxdbl.xxdbl_sqrpol_line sl
 WHERE     1 = 1
       AND sh.header_id = sl.header_id
       AND sl.stock_locator = 'Table-151'
       AND sl.line_no = 'Phase2'
       AND sh.batch_no = '3405';


--------------------------------------------------------------------------------

SELECT *
  FROM xxdbl.xxdbl_sqrpol_headers xsh
 WHERE 1 = 1 AND ( :p_batch_no IS NULL OR (xsh.batch_no = :p_batch_no));

SELECT *
  FROM xxdbl.xxdbl_sqrpol_operation xso
 WHERE 1 = 1 
 AND header_id = 1266 
 --AND xso.status != 'CONFIRMED'
 ;

SELECT *
  FROM xxdbl.xxdbl_sqrpol_line xsl
 WHERE 1 = 1 AND header_id = 1266;


--------------------------------------------------------------------------------

SELECT                                                                  --sh.*
       sl.line_no, sl.*
  FROM xxdbl.xxdbl_sqrpol_headers sh, xxdbl.xxdbl_sqrpol_line sl
 WHERE     1 = 1
       AND sh.header_id = sl.header_id
       AND sl.stock_locator = 'Table-151'
       AND sl.line_no = 'Phase2'
       AND sl.line_id = 39552
       AND sh.batch_no = '3405';

SELECT                                                                  --sh.*
       sl.line_no, sl.*
  FROM xxdbl.xxdbl_sqrpol_line sl
 WHERE     1 = 1
       AND sl.stock_locator = 'Table-151'
       AND sl.line_no = 'Phase2'
       AND sl.line_id = 39552;

UPDATE xxdbl.xxdbl_sqrpol_line sl
   SET sl.line_no = 'Phase1'
 WHERE     1 = 1
       AND sl.stock_locator = 'Table-151'
       AND sl.line_no = 'Phase2'
       AND sl.line_id = 39552;