SELECT &P_ITEM_SEG IC_ITEM_NUMBER
,      &P_CAT_SEG IC_CATEGORY
,      MSI.description IC_DESCRIPTION
,      MSI.primary_uom_code IC_UOM
,      MSI.inventory_item_status_code IC_ITEM_STATUS
,      LU3.meaning IC_INV_ASSET
,      LU1.meaning IC_MAKE_BUY
,      DECODE(MSI.inventory_planning_code
,           6, LU5.meaning, LU2.meaning) IC_PLANNING_METHOD
,      CIQT.subinventory_code IC_SUBINV
,      decode(CIQT.subinventory_code,NULL,'Intransit','On-hand') IC_TYPE
,      DECODE(:P_ITEM_REVISION, 1, CIQT.revision, NULL) IC_REVISION
,      SEC.description IC_SUBINV_DESC
,      SEC.asset_inventory IC_ASSET_SUBINV
,      NVL(LU4.meaning,'Yes') IC_ASSET_SUBINV_DSP
,      ROUND(NVL(CIQT.rollback_qty,0),:P_qty_precision) IC_QTY
--BUG#5768615
,      ROUND((NVL(CICT.item_cost,0)*:P_EXCHANGE_RATE), :P_EXT_PREC) IC_UNIT_COST
,      DECODE(CICT.cost_type_id, :P_COST_TYPE_ID, ' ', '*') IC_DEFAULTED
,      NVL(CIQT.rollback_qty,0) *
--BUG#5768615
            DECODE(NVL(SEC.asset_inventory,1), 1, NVL(CICT.item_cost,0), 0) *
            :P_EXCHANGE_RATE  IC_TOTAL_COST
FROM    mfg_lookups LU5
,       mfg_lookups LU4
,       mfg_lookups LU3
,       mfg_lookups LU2
,       mfg_lookups LU1
,       mtl_categories_b MC
,       mtl_system_items_vl MSI
,       mtl_secondary_inventories SEC
,       cst_inv_qty_temp CIQT
,       cst_inv_cost_temp  CICT
,       mtl_parameters MP
,       cst_item_costs CIC
WHERE   MSI.organization_id = CIQT.organization_id
AND     MSI.inventory_item_id = CIQT.inventory_item_id
AND     MP.organization_id = CIQT.organization_id
AND     CICT.organization_id = CIQT.organization_id 
and     CICT.inventory_item_id = CIQT.inventory_item_id 
and     (CICT.cost_group_id = CIQT.cost_group_id 
      OR MP.primary_cost_method = 1)
AND     &P_SUBINV_WHERE
AND     &P_SUB_INV_SEC
AND     MC.category_id = CIQT.category_id
AND     LU1.lookup_type(+) = 'MTL_PLANNING_MAKE_BUY'
AND     LU1.lookup_code(+) = MSI.planning_make_buy_code
AND     LU2.lookup_type = 'MTL_MATERIAL_PLANNING'
AND     LU2.lookup_code = NVL(MSI.inventory_planning_code,6)
AND     LU3.lookup_type = 'SYS_YES_NO'
AND     LU3.lookup_code = CICT.inventory_asset_flag
AND     LU4.lookup_type(+) = 'SYS_YES_NO'
AND     LU4.lookup_code(+) = SEC.asset_inventory
AND     LU5.lookup_type = 'MRP_PLANNING_CODE'
AND     LU5.lookup_code = NVL(MSI.mrp_planning_code,6)
AND     CIC.organization_id = MP.cost_organization_id
AND     CIC.inventory_item_id = CIQT.inventory_item_id
AND      CIC.cost_type_id = CICT.cost_type_id