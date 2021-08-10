/* Formatted on 6/29/2020 11:04:55 AM (QP5 v5.287) */
SELECT *
  FROM per_org_structure_elements_v oh
 --apps.xxdbl_company_le_mapping_v ou
 WHERE     1 = 1
       --AND D_CHILD_NAME IN ('RMG-PROCESS','HTL-KNITTING','SPINING-PROCESS')
       --AND d_parent_name = 'Item Master Organization'
       --AND ORG_STRUCTURE_VERSION_ID=80
       --AND ORGANIZATION_ID_CHILD IN (193,196)
--       AND EXISTS
--              (SELECT 1
--                 FROM ORG_ORGANIZATION_DEFINITIONS OOD
--                WHERE     ORGANIZATION_ID_CHILD = OOD.ORGANIZATION_ID
--                      AND OOD.ORGANIZATION_CODE IN (
--                                                    '101',
--                                                    '103',
--                                                    '113',
--                                                    '114'
--                                                    ))
;


SELECT   organization_structure_id, NAME
    FROM per_organization_structures_v
   WHERE attribute1 = 'Y'
   AND NAME IN ('RMG-PROCESS','HTL-KNITTING','SPINING-PROCESS')
ORDER BY primary_structure_flag DESC, NAME