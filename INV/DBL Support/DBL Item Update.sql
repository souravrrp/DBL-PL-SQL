/* Formatted on 9/4/2021 12:45:05 PM (QP5 v5.354) */
SELECT *
  FROM xxdbl.xxdbl_items1 xi
 WHERE     1 = 1
       AND item_code = 'DYES0000300002000044'
       --AND done IS NULL
       AND inventory_item_id = 4406
       AND xi.organization_id = 150;
       
SELECT * FROM APPS.XXDB_ITM_DESC_UPD_STG;

SELECT *
  FROM xxdbl.xxdbl_catalog_elem_serial
 WHERE 1 = 1 
 --AND CATALOG_GROUP = 'Fixed Asset'
 ;



--UPDATE xxdbl.xxdbl_catalog_elem_serial SET LAST_SERIAL = '3290' WHERE 1 = 1 AND CATALOG_GROUP = 'Fixed Asset';

--COMMIT;