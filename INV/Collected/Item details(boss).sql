SELECT ood.organization_code,
       --RECEIVING_ROUTING_ID,
  -- ood.organization_id,
   --    ORGANIZATION_NAME,
    --   PROCESS_COSTING_ENABLED_FLAG,
      a.inventory_item_id,
       a.segment1 AS Item_Code,
   --    INVENTORY_ITEM_STATUS_CODE,
    --   PURCHASING_ENABLED_FLAG,
      -- PROCESS_COSTING_ENABLED_FLAG,
      -- PURCHASING_ITEM_FLAG,
      -- INVENTORY_ASSET_FLAG,
--       (SELECT DESCRIPTION
--          FROM APPS.FND_FLEX_VALUES_TL
--         WHERE FLEX_VALUE_ID =
--                  (SELECT FLEX_VALUE_ID
--                     FROM APPS.FND_FLEX_VALUES
--                    WHERE FLEX_VALUE_SET_ID =
--                             (SELECT FLEX_VALUE_SET_ID
--                                FROM APPS.FND_FLEX_VALUE_SETS
--                               WHERE FLEX_VALUE_SET_NAME =
--                                        'XXDBL_NATURAL_ACCOUNT_COA')
--                          AND FLEX_VALUE = CC.SEGMENT5))
--          NATURAL_ACCOUNT_DESC,
       a.description,
       T.LONG_DESCRIPTION,
    --   PROCESS_COSTING_ENABLED_FLAG ,
    --   PROCESS_YIELD_SUBINVENTORY,
    --   PROCESS_SUPPLY_SUBINVENTORY,
    --   PROCESS_SUPPLY_LOCATOR_ID,
    --   PROCESS_YIELD_LOCATOR_ID,
  --     LOT_CONTROL_CODE,
 --      LOT_DIVISIBLE_FLAG,
 --      PRIMARY_UOM_CODE,
  --     SECONDARY_UOM_CODE,
     --  b.segment1 "Item_Category_busi",
       b.segment1 "Product_Line",
        b.segment2 "Article",
          b.segment3 "Color_Group",
        b.segment4 "Item_Type",
        a.ATTRIBUTE5 h_s_code
   --   a.ATTRIBUTE3 item_type,
   --    b.segment4 "Catalog",
--       TRIM(PP.TITLE || ' ' || PP.FIRST_NAME || ' '
--            || DECODE (PP.MIDDLE_NAMES,
--                       NULL, PP.LAST_NAME,
--                       PP.MIDDLE_NAMES || ' ' || PP.LAST_NAME))
--          "REQUEST_BY",
--       a.SALES_ACCOUNT
  FROM apps.mtl_system_items_b_kfv a,
  inv.MTL_SYSTEM_ITEMS_TL  t,
       apps.mtl_item_categories_v b,
       apps.org_organization_definitions ood,
       apps.gl_code_combinations_kfv cc,
       apps.mtl_parameters mp,
       APPLSYS.FND_USER FNU,
       (SELECT q1.*, haou.name
          FROM HR.PER_ALL_PEOPLE_F Q1,
               hr.per_all_assignments_f paaf,
               hr.hr_all_organization_units haou
         WHERE SYSDATE BETWEEN q1.EFFECTIVE_START_DATE
                           AND  q1.EFFECTIVE_END_DATE
               AND SYSDATE BETWEEN paaf.EFFECTIVE_START_DATE
                               AND  paaf.EFFECTIVE_END_DATE
               AND q1.person_id = paaf.person_id
               AND paaf.organization_id = haou.organization_id) PP
 WHERE     a.inventory_item_id = b.inventory_item_id
       AND a.organization_id = b.organization_id
       AND a.organization_id = ood.organization_id
       AND a.EXPENSE_ACCOUNT = cc.code_combination_id
       AND mp.organization_id = a.organization_id
       AND a.CREATED_BY = FNU.USER_ID
       AND a.inventory_item_id = t.inventory_item_id
       AND a.organization_id = T.organization_id
       AND PP.PARTY_ID(+) = NVL (FNU.PERSON_PARTY_ID, 0)
       AND INVENTORY_ITEM_STATUS_CODE = 'Active'
       --   AND    b.segment1 || b.segment2 ||       b.segment3 ||     b.segment4='NANANANA'
       --- AND mp.PROCESS_ENABLED_FLAG = 'Y'
       AND CATEGORY_SET_ID= 1
      -- AND ITEM_TYPE =
       --   AND INVENTORY_ITEM_STATUS_CODE ='Active'
        -- AND SET_OF_BOOKS_ID = '2095'
   --   and mp.organization_code='193' -- in  ('172', '182', '186', '192', '202', '241')
       AND A.ORGANIZATION_ID = 150    
      AND  b.segment2 = 'FINISH GOODS'
  --     AND a.creation_date like '%10%OCT%'                 -- in (197,198)
   AND b.segment3='DYED YARN'-- not in ('DYED FIBER','SEWING THREAD','DYED YARN')  --DYED FIBER    --SEWING THREAD    --DYED YARN
--AND   a.segment1 LIKE 'RIBON000000000000079'
          --     AND PROCESS_YIELD_SUBINVENTORY IS NULL