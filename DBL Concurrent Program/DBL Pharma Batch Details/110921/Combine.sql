/* Formatted on 9/11/2021 9:50:41 AM (QP5 v5.287) */
WITH FG
     AS (SELECT batch_no,
                LOT_NUMBER,
                product,
                PROD_DESCRIPTION,
                Plan_Products,
                Actual_Products,
                actual_start_date,
                ACTUAL_CMPLT_DATE,
                Product_type,
                LOT_NUMBER2,
                Item_type,
                Item_code,
                DESCRIPTION,
                PRIMARY_UNIT_OF_MEASURE,
                Actual_Ingredients
           FROM (  SELECT gbh.batch_no,
                          mtlot.LOT_NUMBER,
                          DECODE (gmd.line_type, 1, itm.segment1) AS Product,
                          itm.DESCRIPTION PROD_DESCRIPTION,
                          ROUND (
                             NVL ( (DECODE (gmd.line_type, 1, gmd.PLAN_QTY)),
                                  0),
                             5)
                             AS Plan_Products,
                          ROUND (
                             NVL ( (DECODE (gmd.line_type, 1, gmd.actual_qty)),
                                  0),
                             5)
                             AS Actual_Products,
                          gbh.actual_start_date,
                          gbh.ACTUAL_CMPLT_DATE,
                          F.FORMULA_CLASS Product_type,
                          mtlot.LOT_NUMBER LOT_NUMBER2,
                          cat.SEGMENT3 Item_type,
                          itm.segment1 Item_code,
                          itm.DESCRIPTION,
                          itm.PRIMARY_UNIT_OF_MEASURE,
                          ROUND (
                             NVL (
                                (DECODE (gmd.line_type, -1, gmd.actual_qty)),
                                0),
                             5)
                             AS Actual_Ingredients
                     --gmd.material_detail_id, gmd.line_type,mmt.*
                     FROM mtl_material_transactions mmt,
                          gme_material_details gmd,
                          gme_batch_header gbh,
                          org_organization_definitions ood,
                          apps.MTL_SYSTEM_ITEMS_FVL itm,
                          apps.mtl_item_categories_v cat,
                          mtl_transaction_lot_numbers mtlot,
                          APPS.fm_form_mst F
                    WHERE     mmt.transaction_source_type_id = 5
                          AND ood.organization_id = 158
                          AND gbh.organization_id = ood.organization_id
                          AND gbh.organization_id = itm.organization_id
                          AND gbh.organization_id = cat.organization_id
                          AND gmd.INVENTORY_ITEM_ID = itm.INVENTORY_ITEM_ID
                          AND itm.INVENTORY_ITEM_ID = cat.INVENTORY_ITEM_ID
                          AND gmd.INVENTORY_ITEM_ID = cat.INVENTORY_ITEM_ID
                          AND cat.CATEGORY_SET_NAME = 'Inventory'
                          AND mmt.trx_source_line_id = gmd.material_detail_id
                          AND mmt.transaction_source_id = gbh.batch_id
                          AND gbh.Formula_ID = F.Formula_ID
                          AND F.FORMULA_CLASS = 'SFG'
                          AND mtlot.transaction_id = mmt.TRANSACTION_ID
                          AND gmd.batch_id = gbh.batch_id
                 --and gbh.batch_no = '60'
                 ORDER BY gbh.batch_id,
                          gmd.line_type,
                          gmd.material_detail_id,
                          mmt.transaction_id)),
     SFG
     AS (SELECT batch_no,
                LOT_NUMBER,
                product,
                PROD_DESCRIPTION,
                Plan_Products,
                Actual_Products,
                actual_start_date,
                ACTUAL_CMPLT_DATE,
                Product_type,
                LOT_NUMBER2,
                Item_type,
                Item_code,
                DESCRIPTION,
                PRIMARY_UNIT_OF_MEASURE,
                Actual_Ingredients
           FROM (  SELECT gbh.batch_no,
                          mtlot.LOT_NUMBER,
                          DECODE (gmd.line_type, 1, itm.segment1) AS Product,
                          itm.DESCRIPTION PROD_DESCRIPTION,
                          ROUND (
                             NVL ( (DECODE (gmd.line_type, 1, gmd.PLAN_QTY)),
                                  0),
                             5)
                             AS Plan_Products,
                          ROUND (
                             NVL ( (DECODE (gmd.line_type, 1, gmd.actual_qty)),
                                  0),
                             5)
                             AS Actual_Products,
                          gbh.actual_start_date,
                          gbh.ACTUAL_CMPLT_DATE,
                          F.FORMULA_CLASS Product_type,
                          mtlot.LOT_NUMBER LOT_NUMBER2,
                          cat.SEGMENT3 Item_type,
                          itm.segment1 Item_code,
                          itm.DESCRIPTION,
                          itm.PRIMARY_UNIT_OF_MEASURE,
                          ROUND (
                             NVL (
                                (DECODE (gmd.line_type, -1, gmd.actual_qty)),
                                0),
                             5)
                             AS Actual_Ingredients
                     --gmd.material_detail_id, gmd.line_type,mmt.*
                     FROM mtl_material_transactions mmt,
                          gme_material_details gmd,
                          gme_batch_header gbh,
                          org_organization_definitions ood,
                          apps.MTL_SYSTEM_ITEMS_FVL itm,
                          apps.mtl_item_categories_v cat,
                          mtl_transaction_lot_numbers mtlot,
                          APPS.fm_form_mst F
                    WHERE     mmt.transaction_source_type_id = 5
                          AND ood.organization_id = 158
                          AND gbh.organization_id = ood.organization_id
                          AND gbh.organization_id = itm.organization_id
                          AND gbh.organization_id = cat.organization_id
                          AND gmd.INVENTORY_ITEM_ID = itm.INVENTORY_ITEM_ID
                          AND itm.INVENTORY_ITEM_ID = cat.INVENTORY_ITEM_ID
                          AND gmd.INVENTORY_ITEM_ID = cat.INVENTORY_ITEM_ID
                          AND cat.CATEGORY_SET_NAME = 'Inventory'
                          AND mmt.trx_source_line_id = gmd.material_detail_id
                          AND mmt.transaction_source_id = gbh.batch_id
                          AND gbh.Formula_ID = F.Formula_ID
                          AND F.FORMULA_CLASS = 'FG'
                          AND mtlot.transaction_id = mmt.TRANSACTION_ID
                          AND gmd.batch_id = gbh.batch_id
                 --and gbh.batch_no = '60'
                 ORDER BY gbh.batch_id,
                          gmd.line_type,
                          gmd.material_detail_id,
                          mmt.transaction_id))
SELECT FG.*
  FROM FG, SFG
 WHERE FG.LOT_NUMBER = SFG.LOT_NUMBER(+);