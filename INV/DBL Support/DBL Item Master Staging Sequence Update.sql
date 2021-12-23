/* Formatted on 12/19/2021 4:51:02 PM (QP5 v5.374) */
SELECT *
  FROM xxdbl.xxdbl_catalog_elem_serial xces
 WHERE     1 = 1
       --AND catalog_group = 'Fixed Asset'
       AND xces.catalog_group = NVL ( :p_catalog_group, xces.catalog_group);


--UPDATE xxdbl.xxdbl_catalog_elem_serial SET LAST_SERIAL = '3290' WHERE 1 = 1 AND CATALOG_GROUP = 'Fixed Asset';

--COMMIT;
