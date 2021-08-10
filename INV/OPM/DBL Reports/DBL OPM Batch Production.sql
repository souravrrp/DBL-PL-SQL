/* Formatted on 1/24/2021 2:05:28 PM (QP5 v5.354) */
SELECT r.ROUTING_NO                                    AS Process,
       h.attribute2                                    AS Shift,
       DECODE (h.batch_STATUS,
               1, 'Pending',
               2, 'WIP',
               3, 'Complete',
               4, 'Closed')                            Bat_statsus,
       --TO_DATE (h.attribute1, 'RRRR/MM/DD HH24:MI:SS') AS Production_Date,
       t.transaction_date,
       h.batch_no,
       DECODE (h.terminated_ind, 0, 'No', 'Yes')       AS Terminated_Ind, --t.transaction_source_id as trans_source_id,
       d.line_type,
       msi.concatenated_segments                       item,
       msi.description,
       (SELECT SEGMENT2
          FROM APPS.MTL_ITEM_CATEGORIES_V
         WHERE     INVENTORY_ITEM_ID = t.INVENTORY_ITEM_ID
               AND ORGANIZATION_ID = t.ORGANIZATION_ID
               AND CATEGORY_SET_NAME = 'Inventory')    ITEM_CATEGORY,
       (SELECT SEGMENT2
          FROM APPS.MTL_ITEM_CATEGORIES_V
         WHERE     INVENTORY_ITEM_ID = t.INVENTORY_ITEM_ID
               AND ORGANIZATION_ID = t.ORGANIZATION_ID
               AND CATEGORY_SET_NAME = 'Inventory')    ITEM_TYPE,
       MSI.PRIMARY_uom_CODE                            AS trans_uom,
       T.PRIMARY_QUANTITY,
       t.SECONDARY_TRANSACTION_QUANTITY,
       t.SECONDARY_UOM_CODE
  --   t.attribute1, t.attribute2, t.attribute3
  FROM inv.mtl_material_transactions  t,
       gme.gme_material_details       d,
       gme.gme_batch_header           h,
       gmd.gmd_routings_b             r,
       apps.mtl_system_items_kfv      msi
 WHERE     t.transaction_source_type_id = 5
       AND t.transaction_source_id = h.batch_id
       AND t.organization_id = h.organization_id
       AND d.batch_id = h.batch_id
       AND d.material_detail_id = t.trx_source_line_id
       AND r.routing_id = h.routing_id
       AND r.owner_organization_id = h.organization_id
       AND d.inventory_item_id = msi.inventory_item_id
       AND d.organization_id = msi.organization_id
       --AND T.SECONDARY_UOM_CODE = 'CTN'
       --AND msi.concatenated_segments LIKE '%6060%'
       AND t.organization_id = 150
       --AND TO_CHAR (t.transaction_date, 'MON-YY') = 'MAR-19'
       --AND r.ROUTING_NO LIKE 'SILO%'
       --AND TO_DATE (h.attribute1, 'RRRR/MM/DD HH24:MI:SS') >= ''
       --AND h.batch_NO IN (945, 664, 622)
       --AND r.ROUTING_NO IN ('RECYLE -1', 'RECYLE -2')
       --AND d.line_type = 2
       --AND h.batch_STATUS = 1
       AND TRUNC (t.TRANSACTION_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO
       AND LINE_TYPE = -1;