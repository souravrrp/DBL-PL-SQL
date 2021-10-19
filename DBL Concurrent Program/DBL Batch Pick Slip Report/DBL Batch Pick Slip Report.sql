/* Formatted on 10/17/2021 10:21:02 AM (QP5 v5.365) */
WITH
    PRODUCT
    AS
        (SELECT ORGANIZATION_ID,
                INVENTORY_ITEM_ID,
                BATCH_ID,
                batch_no,
                LOT_Number,
                product,
                DESCRIPTION,
                PUOM,
                Plan_Products
           FROM (  SELECT DISTINCT
                          a.ORGANIZATION_ID,
                          itm.INVENTORY_ITEM_ID,
                          a.BATCH_ID,
                          a.batch_no,
                          a.ATTRIBUTE22           LOT_Number,
                          itm.SEGMENT1            product,
                          itm.DESCRIPTION,
                          itm.PRIMARY_UOM_CODE    PUOM,
                          --round(nvl((DECODE (b.line_type, -1, b.PLAN_QTY)),0),5) AS Plan_Ingredients,
                          ROUND (
                              NVL ((DECODE (b.line_type, 1, b.PLAN_QTY)), 0),
                              5)                  AS Plan_Products
                     FROM apps.gme_batch_header            a,
                          apps.gme_material_details        b,
                          apps.MTL_SYSTEM_ITEMS_FVL        itm,
                          apps.mtl_item_categories_v       cat,
                          apps.org_organization_definitions ood,
                          apps.gmd_routings_b              rt,
                          (SELECT batch_id, gba.GROUP_ID, GROUP_DESC
                             FROM gme.gme_batch_groups_association gba,
                                  gme.gme_batch_groups_tl         gbt
                            WHERE gba.GROUP_ID = gbt.GROUP_ID) bg
                    WHERE     a.organization_id = 158 --IN (145,159,153,152,158)
                          AND a.batch_id = bg.batch_id(+)
                          AND a.batch_id = b.batch_id
                          AND a.organization_id = b.organization_id
                          AND b.organization_id = itm.organization_id
                          AND a.organization_id = ood.organization_id
                          AND b.organization_id = cat.organization_id
                          AND itm.organization_id = cat.organization_id
                          AND b.INVENTORY_ITEM_ID = itm.INVENTORY_ITEM_ID
                          AND b.INVENTORY_ITEM_ID = cat.INVENTORY_ITEM_ID
                          AND cat.CATEGORY_SET_NAME = 'Inventory'
                          AND a.routing_id = rt.routing_id
                          AND a.batch_status NOT IN (-1)
                 ORDER BY a.batch_no)
          WHERE Plan_Products != 0),
    ING
    AS
        (SELECT DISTINCT
                ORGANIZATION_ID,
                FORMULA_ID,
                ROUTING_ID,
                RECIPE_VALIDITY_RULE_ID,
                MOVE_ORDER_HEADER_ID,
                FORMULA_NO,
                FORMULA_DESC1,
                FORMULA_VERS,
                FORMULA_CLASS,
                Expected_Yield,
                Expected_Yield_qty,
                DECODE (ATTRIBUTE_CATEGORY,
                        'API Adjustment', API_ADJUSTMENT,
                        'Excipient Adjustment', EXCIPIENT_ADJUSTMENT)
                    ATTRIBUTE1,
                ATTRIBUTE_CATEGORY,
                BATCH_ID,
                batch_no,
                Batch_LOT_Number,
                INVENTORY_ITEM_ID,
                ITEM_TYPE,
                Code_No,
                Ingredients,
                UOM,
                Ing_qty,
                Act_qty,
                INV_LOT_NUMBER
           FROM (  SELECT DISTINCT ORGANIZATION_ID,
                                   FORMULA_ID,
                                   ROUTING_ID,
                                   RECIPE_VALIDITY_RULE_ID,
                                   MOVE_ORDER_HEADER_ID,
                                   FORMULA_NO,
                                   FORMULA_DESC1,
                                   MAX (FORMULA_VERS)     FORMULA_VERS,
                                   FORMULA_CLASS,
                                   Expected_Yield,
                                   Expected_Yield_qty,
                                   ATTRIBUTE_CATEGORY,
                                   API_Adjustment,
                                   Excipient_Adjustment,
                                   BATCH_ID,
                                   batch_no,
                                   Batch_LOT_Number,
                                   INVENTORY_ITEM_ID,
                                   ITEM_TYPE,
                                   Code_No,
                                   Ingredients,
                                   UOM,
                                   Ing_qty,
                                   Act_qty,
                                   INV_LOT_NUMBER
                     FROM (  SELECT ORGANIZATION_ID,
                                    FORMULA_ID,
                                    ROUTING_ID,
                                    RECIPE_VALIDITY_RULE_ID,
                                    MOVE_ORDER_HEADER_ID,
                                    FORMULA_NO,
                                    FORMULA_DESC1,
                                    FORMULA_VERS,
                                    FORMULA_CLASS,
                                    Expected_Yield,
                                    Expected_Yield_qty,
                                    ATTRIBUTE_CATEGORY,
                                    API_Adjustment,
                                    Excipient_Adjustment,
                                    BATCH_ID,
                                    batch_no,
                                    Batch_LOT_Number,
                                    INVENTORY_ITEM_ID,
                                    ITEM_TYPE,
                                    Code_No,
                                    Ingredients,
                                    UOM,
                                    Ing_qty,
                                    Act_qty,
                                    MAX (INV_LOT_NUMBER)     INV_LOT_NUMBER
                               FROM (SELECT DISTINCT
                                            a.ORGANIZATION_ID,
                                            a.FORMULA_ID,
                                            a.ROUTING_ID,
                                            a.RECIPE_VALIDITY_RULE_ID,
                                            a.MOVE_ORDER_HEADER_ID,
                                            fm.FORMULA_NO,
                                            fm.FORMULA_DESC1,
                                            fm.FORMULA_VERS,
                                            fm.FORMULA_CLASS,
                                            fm.ATTRIBUTE10
                                                Expected_Yield,
                                            fm.ATTRIBUTE11
                                                Expected_Yield_qty,
                                            fml.ATTRIBUTE_CATEGORY,
                                            fml.ATTRIBUTE10
                                                API_Adjustment,
                                            fml.ATTRIBUTE20
                                                Excipient_Adjustment,
                                            a.BATCH_ID,
                                            a.batch_no,
                                            a.ATTRIBUTE22
                                                Batch_LOT_Number,
                                            itm.INVENTORY_ITEM_ID,
                                            cat.SEGMENT3
                                                ITEM_TYPE,
                                            itm.SEGMENT1
                                                Code_No,
                                            itm.DESCRIPTION
                                                Ingredients,
                                            itm.PRIMARY_UOM_CODE
                                                UOM,
                                            ROUND (
                                                NVL (
                                                    (DECODE (b.line_type,
                                                             -1, b.PLAN_QTY)),
                                                    0),
                                                5)
                                                AS Ing_qty,
                                            ROUND (
                                                NVL (
                                                    (DECODE (b.line_type,
                                                             -1, b.ACTUAL_QTY)),
                                                    0),
                                                5)
                                                AS Act_qty,
                                            lot.LOT_NUMBER,
                                            (DECODE (lot.STATUS_CODE,
                                                     'PASSED', lot.LOT_NUMBER))
                                                INV_LOT_NUMBER
                                       --ROUND (NVL ((DECODE (b.line_type, 1, b.PLAN_QTY)), 0), 5)    AS Plan_Products
                                       FROM apps.gme_batch_header   a,
                                            apps.FM_FORM_MST        fm,
                                            GMD.FM_MATL_DTL         fml,
                                            apps.gme_material_details b,
                                            apps.MTL_SYSTEM_ITEMS_FVL itm,
                                            apps.MTL_LOT_NUMBERS_ALL_V lot,
                                            apps.mtl_item_categories_v cat,
                                            apps.org_organization_definitions ood,
                                            apps.gmd_routings_b     rt,
                                            (SELECT batch_id,
                                                    gba.GROUP_ID,
                                                    GROUP_DESC
                                               FROM gme.gme_batch_groups_association
                                                    gba,
                                                    gme.gme_batch_groups_tl gbt
                                              WHERE gba.GROUP_ID = gbt.GROUP_ID)
                                            bg
                                      WHERE     a.organization_id = 158 --IN (145,159,153,152,158)
                                            AND a.batch_id = bg.batch_id(+)
                                            AND a.batch_id = b.batch_id
                                            AND a.organization_id =
                                                b.organization_id
                                            AND a.organization_id =
                                                fm.OWNER_ORGANIZATION_ID
                                            AND fm.OWNER_ORGANIZATION_ID =
                                                fml.ORGANIZATION_ID
                                            AND a.organization_id =
                                                lot.ORGANIZATION_ID
                                            AND b.organization_id =
                                                itm.organization_id
                                            AND a.organization_id =
                                                ood.organization_id
                                            AND b.organization_id =
                                                cat.organization_id
                                            AND itm.organization_id =
                                                cat.organization_id
                                            AND b.INVENTORY_ITEM_ID =
                                                itm.INVENTORY_ITEM_ID
                                            AND b.INVENTORY_ITEM_ID =
                                                cat.INVENTORY_ITEM_ID
                                            AND b.INVENTORY_ITEM_ID =
                                                lot.INVENTORY_ITEM_ID
                                            AND cat.CATEGORY_SET_NAME =
                                                'Inventory'
                                            AND a.FORMULA_ID = fm.FORMULA_ID
                                            AND fm.FORMULA_ID = fml.FORMULA_ID
                                            AND fml.FORMULALINE_ID =
                                                b.FORMULALINE_ID(+)
                                            AND a.routing_id = rt.routing_id
                                            AND a.batch_status NOT IN (-1) --and a.batch_no=43
                                                                          )
                              WHERE Ing_qty != 0
                           GROUP BY ORGANIZATION_ID,
                                    FORMULA_ID,
                                    ROUTING_ID,
                                    RECIPE_VALIDITY_RULE_ID,
                                    MOVE_ORDER_HEADER_ID,
                                    FORMULA_NO,
                                    FORMULA_DESC1,
                                    FORMULA_VERS,
                                    FORMULA_DESC1,
                                    FORMULA_CLASS,
                                    Expected_Yield,
                                    Expected_Yield_qty,
                                    ATTRIBUTE_CATEGORY,
                                    API_Adjustment,
                                    Excipient_Adjustment,
                                    BATCH_ID,
                                    batch_no,
                                    Batch_LOT_Number,
                                    INVENTORY_ITEM_ID,
                                    ITEM_TYPE,
                                    Code_No,
                                    Ingredients,
                                    UOM,
                                    Ing_qty,
                                    Act_qty)
                 GROUP BY ORGANIZATION_ID,
                          FORMULA_ID,
                          ROUTING_ID,
                          RECIPE_VALIDITY_RULE_ID,
                          MOVE_ORDER_HEADER_ID,
                          FORMULA_NO,
                          FORMULA_DESC1,
                          FORMULA_CLASS,
                          Expected_Yield,
                          Expected_Yield_qty,
                          ATTRIBUTE_CATEGORY,
                          API_Adjustment,
                          Excipient_Adjustment,
                          BATCH_ID,
                          batch_no,
                          Batch_LOT_Number,
                          INVENTORY_ITEM_ID,
                          ITEM_TYPE,
                          Code_No,
                          Ingredients,
                          UOM,
                          Ing_qty,
                          Act_qty,
                          INV_LOT_NUMBER))
  SELECT DISTINCT PRODUCT.*,
                  ING.*,
                  :P_BATCH_ID,
                  :P_LOT_NUMBER
    FROM PRODUCT, ING
   WHERE     PRODUCT.ORGANIZATION_ID = ING.ORGANIZATION_ID
         AND PRODUCT.BATCH_ID = ING.BATCH_ID
         AND PRODUCT.BATCH_ID = NVL ( :P_BATCH_ID, PRODUCT.BATCH_ID)
         AND PRODUCT.LOT_NUMBER = NVL ( :P_LOT_NUMBER, PRODUCT.LOT_NUMBER)
ORDER BY ING.batch_no