/* Formatted on 9/22/2021 3:35:39 PM (QP5 v5.354) */
SELECT LAST_SERIAL, ee.*
  FROM xxdbl.xxdbl_catalog_elem_serial ee
 WHERE 1 = 1 
 --AND CATALOG_GROUP = 'Distribution Trading Item';
 
 
 UPDATE xxdbl.xxdbl_catalog_elem_serial
   SET LAST_SERIAL = '638'
 WHERE 1 = 1 AND CATALOG_GROUP = 'Distribution Trading Item';

COMMIT;