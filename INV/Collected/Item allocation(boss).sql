/* Formatted on 12/12/2019 1:16:19 PM (QP5 v5.287) */
SELECT ALLOC_CODE, CONCATENATED_SEGMENTS
  FROM GL_ALOC_BAS a, apps.mtl_system_items_kfv b, GL_ALOC_MST C
 WHERE     a.INVENTORY_ITEM_ID = b.INVENTORY_ITEM_ID
       AND a.ORGANIZATION_ID = b.organization_id
       AND a.ORGANIZATION_ID = 150
       AND A.ALLOC_ID = C.ALLOC_ID
--       AND ALLOC_CODE=:ALLOC_CODE
--       AND ALLOC_CODE NOT LIKE '%SILO'
       AND a.DELETE_MARK = 0
--       AND CONCATENATED_SEGMENTS LIKE 'FT%'
       ;
       
       
----------------------------Alloc Code wise count-------------------------------
SELECT 
ALLOC_CODE, 
--a.DELETE_MARK,
--substr(ALLOC_CODE,0,2) item_type, 
COUNT(CONCATENATED_SEGMENTS) NO_OF_SEGMENTS
  FROM GL_ALOC_BAS a, apps.mtl_system_items_kfv b, GL_ALOC_MST C
 WHERE     a.INVENTORY_ITEM_ID = b.INVENTORY_ITEM_ID
       AND a.ORGANIZATION_ID = b.organization_id
       AND a.ORGANIZATION_ID = 150
       AND A.ALLOC_ID = C.ALLOC_ID
--       AND ALLOC_CODE NOT LIKE '%SILO'
       AND a.DELETE_MARK = 0
--       AND CONCATENATED_SEGMENTS not LIKE 'FT%'
       GROUP BY ALLOC_CODE
       --,a.DELETE_MARK