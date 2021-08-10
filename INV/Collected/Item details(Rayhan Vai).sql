/* Formatted on 5/18/2020 11:09:42 AM (QP5 v5.287) */
  SELECT ood.organization_code,
         ood.organization_id,
         ORGANIZATION_NAME,
         a.inventory_item_id,
         a.segment1 AS Item_Code,
         description,
         --LOT_CONTROL_CODE,
         PRIMARY_UOM_CODE,
         SECONDARY_UOM_CODE,
         b.category_id,
         b.segment1,
         b.segment2 "Item_Category",
         b.segment3 "Item_Type",
         b.segment4,
         a.PROCESS_COSTING_ENABLED_FLAG,
         a.INVENTORY_ITEM_STATUS_CODE,
         a.PURCHASING_ITEM_FLAG,
         a.creation_date
    FROM apps.mtl_system_items_b_kfv a,
         apps.mtl_item_categories_v b,
         apps.org_organization_definitions ood
   WHERE     a.inventory_item_id = b.inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.organization_id = ood.organization_id
         -- and a.RECEIVING_ROUTING_ID=2
         AND CATEGORY_SET_ID = 1 -- 1100000041    -- 1100000061  sales category set ID
         AND b.segment2 NOT IN ('FINISH GOODS','RAW MATERIAL','PACKING MATERIAL')
         AND a.INVENTORY_ITEM_STATUS_CODE='Active'
         -- and b.segment2='IT'
         --   AND TO_dATE(A.CREATION_DATE) ='27-SEP-2017'                              --1100000041
         --   AND description like '%?%'
         --  and INVENTORY_ITEM_FLAG ='N'
         --  and   description  like '%%'
         --and  b.segment1 LIKE 'PACK%'
         AND ood.organization_code IN ('194')
-- AND ood.organization_code not IN ('113','133','143','152','163','183','101','103','251','211','231','221','171','191','181','185','193','IMO')
--  and b.segment3='YARN'
--and  a.segment1='YRN34S100CTN52199918'
ORDER BY 7