/* Formatted on 12/9/2021 3:23:53 PM (QP5 v5.374) */
SELECT *
  FROM xxdbl.xxdbl_items1 xi
 WHERE     1 = 1
       AND item_code = 'DYES0000300002000044'
       --AND done IS NULL
       AND inventory_item_id = 4406
       AND xi.organization_id = 150;

--------------------------------------------------------------------------------

SELECT * FROM APPS.XXDB_ITM_DESC_UPD_STG;