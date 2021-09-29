DROP VIEW APPS.GME_BATCH_DETAILS_V;

/* Formatted on 9/20/2021 11:01:05 AM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW APPS.GME_BATCH_DETAILS_V
(
    BATCH_ID,
    BATCH_NO,
    LOT_NUMBER,
    PRODUCT,
    PROD_DESCRIPTION,
    PRIMARY_UOM_CODE,
    PLAN_PRODUCTS,
    ACTUAL_PRODUCTS,
    ACTUAL_START_DATE,
    ACTUAL_CMPLT_DATE,
    PRO_CLASS,
    BATCH_ID_1,
    BATCH_NO_1,
    LOT_NUMBER_1,
    ITEM_TYPE,
    PROD_CATE,
    ITEM_CODE,
    PROD_DESCRIPTION_1,
    PRIMARY_UOM_CODE_1,
    ACTUAL_PRODUCTS_1,
    ACTUAL_START_DATE_1,
    ACTUAL_CMPLT_DATE_1
)
BEQUEATH DEFINER
AS
    SELECT BATCH_ID,
           BATCH_NO,
           LOT_NUMBER,
           PRODUCT,
           PROD_DESCRIPTION,
           PRIMARY_UOM_CODE,
           PLAN_PRODUCTS,
           ACTUAL_PRODUCTS,
           ACTUAL_START_DATE,
           ACTUAL_CMPLT_DATE,
           PRO_CLASS,
           BATCH_ID_1,
           BATCH_NO_1,
           LOT_NUMBER_1,
           ITEM_TYPE,
           PROD_CATE,
           ITEM_CODE,
           PROD_DESCRIPTION_1,
           PRIMARY_UOM_CODE_1,
           ACTUAL_PRODUCTS_1,
           ACTUAL_START_DATE_1,
           ACTUAL_CMPLT_DATE_1
      FROM (WITH
                FGP
                AS
                    (SELECT BATCH_ID,
                            batch_no,
                            LOT_NUMBER,
                            product,
                            PROD_DESCRIPTION,
                            PRIMARY_UOM_CODE,
                            Plan_Products,
                            Actual_Products,
                            actual_start_date,
                            ACTUAL_CMPLT_DATE,
                            ITEM_TYPE     PRO_CLASS
                       FROM (SELECT gbh.BATCH_ID,
                                    gbh.batch_no,
                                    mtlot.LOT_NUMBER,
                                    DECODE (gmd.line_type, 1, itm.segment1)
                                        AS Product,
                                    itm.DESCRIPTION
                                        PROD_DESCRIPTION,
                                    itm.PRIMARY_UOM_CODE,
                                    ROUND (
                                        NVL (
                                            (DECODE (gmd.line_type,
                                                     1, gmd.PLAN_QTY)),
                                            0),
                                        5)
                                        AS Plan_Products,
                                    ROUND (
                                        NVL (
                                            (DECODE (gmd.line_type,
                                                     1, gmd.actual_qty)),
                                            0),
                                        5)
                                        AS Actual_Products,
                                    gbh.actual_start_date,
                                    gbh.ACTUAL_CMPLT_DATE,
                                    ITM.ITEM_TYPE
                               FROM inv.mtl_material_transactions      mmt,
                                    gme.gme_material_details           gmd,
                                    gme.gme_batch_header               gbh,
                                    apps.org_organization_definitions  ood,
                                    apps.MTL_SYSTEM_ITEMS_FVL          itm,
                                    apps.mtl_item_categories_v         cat,
                                    inv.mtl_transaction_lot_numbers    mtlot,
                                    APPS.fm_form_mst                   F
                              WHERE     mmt.transaction_source_type_id = 5
                                    AND ood.organization_id = 158
                                    AND gbh.organization_id =
                                        ood.organization_id
                                    AND gbh.organization_id =
                                        itm.organization_id
                                    AND gbh.organization_id =
                                        cat.organization_id
                                    AND gmd.INVENTORY_ITEM_ID =
                                        itm.INVENTORY_ITEM_ID
                                    AND itm.INVENTORY_ITEM_ID =
                                        cat.INVENTORY_ITEM_ID
                                    AND gmd.INVENTORY_ITEM_ID =
                                        cat.INVENTORY_ITEM_ID
                                    AND cat.CATEGORY_SET_NAME = 'Inventory'
                                    AND mmt.trx_source_line_id =
                                        gmd.material_detail_id
                                    AND mmt.transaction_source_id =
                                        gbh.batch_id
                                    AND gbh.Formula_ID = F.Formula_ID
                                    -- AND F.FORMULA_CLASS = 'FG'
                                    AND ITM.ITEM_TYPE = 'FG'
                                    AND cat.SEGMENT3 = 'FG COMMERCIAL'
                                    AND mtlot.transaction_id =
                                        mmt.TRANSACTION_ID
                                    AND gmd.batch_id = gbh.batch_id)
                      WHERE Plan_Products != 0),
                FGING
                AS
                    (  SELECT BATCH_ID              BATCH_ID_1,
                              batch_no              batch_no_1,
                              LOT_NUMBER            LOT_NUMBER_1,
                              ITEM_CODE,
                              PROD_DESCRIPTION      PROD_DESCRIPTION_1,
                              PROD_CATE,
                              PRIMARY_UOM_CODE      PRIMARY_UOM_CODE_1,
                              Actual_Products       Actual_Products_1,
                              actual_start_date     actual_start_date_1,
                              ACTUAL_CMPLT_DATE     ACTUAL_CMPLT_DATE_1,
                              ITEM_TYPE
                         FROM (SELECT gbh.BATCH_ID,
                                      gbh.batch_no,
                                      mtlot.LOT_NUMBER,
                                      itm.SEGMENT1       ITEM_CODE,
                                      itm.DESCRIPTION    PROD_DESCRIPTION,
                                      ITM.ITEM_TYPE,
                                      cat.SEGMENT3       PROD_CATE,
                                      itm.PRIMARY_UOM_CODE,
                                      ROUND (
                                          NVL (
                                              (DECODE (gmd.line_type,
                                                       -1, gmd.actual_qty)),
                                              0),
                                          5)             AS Actual_Products,
                                      gbh.actual_start_date,
                                      gbh.ACTUAL_CMPLT_DATE
                                 FROM inv.mtl_material_transactions    mmt,
                                      gme.gme_material_details         gmd,
                                      gme.gme_batch_header             gbh,
                                      apps.org_organization_definitions ood,
                                      apps.MTL_SYSTEM_ITEMS_FVL        itm,
                                      apps.mtl_item_categories_v       cat,
                                      inv.mtl_transaction_lot_numbers  mtlot,
                                      APPS.fm_form_mst                 F
                                WHERE     mmt.transaction_source_type_id = 5
                                      AND ood.organization_id = 158
                                      AND gbh.organization_id =
                                          ood.organization_id
                                      AND gbh.organization_id =
                                          itm.organization_id
                                      AND gbh.organization_id =
                                          cat.organization_id
                                      AND gmd.INVENTORY_ITEM_ID =
                                          itm.INVENTORY_ITEM_ID
                                      AND itm.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND gmd.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND cat.CATEGORY_SET_NAME = 'Inventory'
                                      AND mmt.trx_source_line_id =
                                          gmd.material_detail_id
                                      AND mmt.transaction_source_id =
                                          gbh.batch_id
                                      AND gbh.Formula_ID = F.Formula_ID
                                      --AND F.FORMULA_CLASS = 'FG'
                                      --AND cat.SEGMENT3='SPM'
                                      --AND ITM.ITEM_TYPE IN('SPM')
                                      AND mtlot.transaction_id =
                                          mmt.TRANSACTION_ID
                                      AND gmd.batch_id = gbh.batch_id)
                        WHERE Actual_Products != 0
                     --AND batch_no=60
                     ORDER BY batch_no)
            SELECT DISTINCT FGP.*, FGING.*
              FROM FGP, FGING
             WHERE FGP.BATCH_ID = FGING.BATCH_ID_1)
    UNION ALL
    SELECT BATCH_ID,
           BATCH_NO,
           LOT_NUMBER,
           PRODUCT,
           PROD_DESCRIPTION,
           PRIMARY_UOM_CODE,
           PLAN_PRODUCTS,
           ACTUAL_PRODUCTS,
           ACTUAL_START_DATE,
           ACTUAL_CMPLT_DATE,
           PRO_CLASS,
           BATCH_ID_1,
           BATCH_NO_1,
           LOT_NUMBER_1,
           ITEM_TYPE,
           PROD_CATE,
           ITEM_CODE,
           PROD_DESCRIPTION_1,
           PRIMARY_UOM_CODE_1,
           ACTUAL_PRODUCTS_1,
           ACTUAL_START_DATE_1,
           ACTUAL_CMPLT_DATE_1
      FROM (WITH
                FGP
                AS
                    (SELECT PRO_CLASS,
                            BATCH_ID,
                            batch_no,
                            LOT_NUMBER,
                            product,
                            PROD_DESCRIPTION,
                            PRIMARY_UOM_CODE,
                            Plan_Products,
                            Actual_Products,
                            actual_start_date,
                            ACTUAL_CMPLT_DATE
                       FROM (SELECT (SELECT 'SFG' FROM DUAL)
                                        PRO_CLASS,
                                    gbh.BATCH_ID,
                                    gbh.batch_no,
                                    mtlot.LOT_NUMBER,
                                    DECODE (gmd.line_type, 1, itm.segment1)
                                        AS Product,
                                    itm.DESCRIPTION
                                        PROD_DESCRIPTION,
                                    itm.PRIMARY_UOM_CODE,
                                    ROUND (
                                        NVL (
                                            (DECODE (gmd.line_type,
                                                     1, gmd.PLAN_QTY)),
                                            0),
                                        5)
                                        AS Plan_Products,
                                    ROUND (
                                        NVL (
                                            (DECODE (gmd.line_type,
                                                     1, gmd.actual_qty)),
                                            0),
                                        5)
                                        AS Actual_Products,
                                    gbh.actual_start_date,
                                    gbh.ACTUAL_CMPLT_DATE
                               FROM inv.mtl_material_transactions      mmt,
                                    gme.gme_material_details           gmd,
                                    gme.gme_batch_header               gbh,
                                    apps.org_organization_definitions  ood,
                                    apps.MTL_SYSTEM_ITEMS_FVL          itm,
                                    apps.mtl_item_categories_v         cat,
                                    inv.mtl_transaction_lot_numbers    mtlot,
                                    APPS.fm_form_mst                   F
                              WHERE     mmt.transaction_source_type_id = 5
                                    AND ood.organization_id = 158
                                    AND gbh.organization_id =
                                        ood.organization_id
                                    AND gbh.organization_id =
                                        itm.organization_id
                                    AND gbh.organization_id =
                                        cat.organization_id
                                    AND gmd.INVENTORY_ITEM_ID =
                                        itm.INVENTORY_ITEM_ID
                                    AND itm.INVENTORY_ITEM_ID =
                                        cat.INVENTORY_ITEM_ID
                                    AND gmd.INVENTORY_ITEM_ID =
                                        cat.INVENTORY_ITEM_ID
                                    AND cat.CATEGORY_SET_NAME = 'Inventory'
                                    AND mmt.trx_source_line_id =
                                        gmd.material_detail_id
                                    AND mmt.transaction_source_id =
                                        gbh.batch_id
                                    AND gbh.Formula_ID = F.Formula_ID
                                    --AND F.FORMULA_CLASS = 'FG'
                                    AND ITM.ITEM_TYPE = 'FG'
                                    AND cat.SEGMENT3 = 'FG COMMERCIAL'
                                    AND mtlot.transaction_id =
                                        mmt.TRANSACTION_ID
                                    AND gmd.batch_id = gbh.batch_id)
                      WHERE Plan_Products != 0),
                FGING
                AS
                    (  SELECT BATCH_ID,
                              batch_no,
                              LOT_NUMBER,
                              ITEM_CODE,
                              PROD_DESCRIPTION,
                              ITEM_TYPE,
                              PROD_CATE,
                              PRIMARY_UOM_CODE,
                              Actual_Products,
                              actual_start_date,
                              ACTUAL_CMPLT_DATE
                         FROM (SELECT gbh.BATCH_ID,
                                      gbh.batch_no,
                                      mtlot.LOT_NUMBER,
                                      itm.SEGMENT1       ITEM_CODE,
                                      itm.DESCRIPTION    PROD_DESCRIPTION,
                                      ITM.ITEM_TYPE,
                                      cat.SEGMENT3       PROD_CATE,
                                      itm.PRIMARY_UOM_CODE,
                                      ROUND (
                                          NVL (
                                              (DECODE (gmd.line_type,
                                                       -1, gmd.actual_qty)),
                                              0),
                                          5)             AS Actual_Products,
                                      gbh.actual_start_date,
                                      gbh.ACTUAL_CMPLT_DATE
                                 FROM inv.mtl_material_transactions    mmt,
                                      gme.gme_material_details         gmd,
                                      gme.gme_batch_header             gbh,
                                      apps.org_organization_definitions ood,
                                      apps.MTL_SYSTEM_ITEMS_FVL        itm,
                                      apps.mtl_item_categories_v       cat,
                                      inv.mtl_transaction_lot_numbers  mtlot,
                                      APPS.fm_form_mst                 F
                                WHERE     mmt.transaction_source_type_id = 5
                                      AND ood.organization_id = 158
                                      AND gbh.organization_id =
                                          ood.organization_id
                                      AND gbh.organization_id =
                                          itm.organization_id
                                      AND gbh.organization_id =
                                          cat.organization_id
                                      AND gmd.INVENTORY_ITEM_ID =
                                          itm.INVENTORY_ITEM_ID
                                      AND itm.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND gmd.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND cat.CATEGORY_SET_NAME = 'Inventory'
                                      AND mmt.trx_source_line_id =
                                          gmd.material_detail_id
                                      AND mmt.transaction_source_id =
                                          gbh.batch_id
                                      AND gbh.Formula_ID = F.Formula_ID
                                      --AND F.FORMULA_CLASS = 'FG'
                                      --AND cat.SEGMENT3='SPM'
                                      --AND ITM.ITEM_TYPE IN('SPM')
                                      AND mtlot.transaction_id =
                                          mmt.TRANSACTION_ID
                                      AND gmd.batch_id = gbh.batch_id)
                        WHERE Actual_Products != 0
                     --AND batch_no=60
                     ORDER BY batch_no),
                SFGING
                AS
                    (  SELECT BATCH_ID              BATCH_ID_1,
                              batch_no              BATCH_NO_1,
                              created_lot,
                              LOT_NUMBER            LOT_NUMBER_1,
                              ITEM_CODE,
                              PROD_DESCRIPTION      PROD_DESCRIPTION_1,
                              ITEM_TYPE,
                              PROD_CATE,
                              PRIMARY_UOM_CODE      PRIMARY_UOM_CODE_1,
                              Actual_Products       ACTUAL_PRODUCTS_1,
                              actual_start_date     actual_start_date_1,
                              ACTUAL_CMPLT_DATE     ACTUAL_CMPLT_DATE_1
                         FROM (SELECT gbh.BATCH_ID,
                                      gbh.batch_no,
                                      APPS.GET_SFG_PRO_LOT_IN_ING (
                                          gbh.BATCH_ID)    AS created_lot,
                                      mtlot.LOT_NUMBER,
                                      itm.SEGMENT1         ITEM_CODE,
                                      itm.DESCRIPTION      PROD_DESCRIPTION,
                                      ITM.ITEM_TYPE,
                                      cat.SEGMENT3         PROD_CATE,
                                      itm.PRIMARY_UOM_CODE,
                                      ROUND (
                                          NVL (
                                              (DECODE (gmd.line_type,
                                                       -1, gmd.actual_qty)),
                                              0),
                                          5)               AS Actual_Products,
                                      gbh.actual_start_date,
                                      gbh.ACTUAL_CMPLT_DATE
                                 FROM inv.mtl_material_transactions    mmt,
                                      gme.gme_material_details         gmd,
                                      gme.gme_batch_header             gbh,
                                      apps.org_organization_definitions ood,
                                      apps.MTL_SYSTEM_ITEMS_FVL        itm,
                                      apps.mtl_item_categories_v       cat,
                                      inv.mtl_transaction_lot_numbers  mtlot,
                                      APPS.fm_form_mst                 F
                                WHERE     mmt.transaction_source_type_id = 5
                                      AND ood.organization_id = 158
                                      AND gbh.organization_id =
                                          ood.organization_id
                                      AND gbh.organization_id =
                                          itm.organization_id
                                      AND gbh.organization_id =
                                          cat.organization_id
                                      AND gmd.INVENTORY_ITEM_ID =
                                          itm.INVENTORY_ITEM_ID
                                      AND itm.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND gmd.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND cat.CATEGORY_SET_NAME = 'Inventory'
                                      AND mmt.trx_source_line_id =
                                          gmd.material_detail_id
                                      AND mmt.transaction_source_id =
                                          gbh.batch_id
                                      AND gbh.Formula_ID = F.Formula_ID
                                      AND F.FORMULA_CLASS = 'SFG'
                                      --AND cat.SEGMENT3='PPM'
                                      --AND ITM.ITEM_TYPE IN('PPM')
                                      AND mtlot.transaction_id =
                                          mmt.TRANSACTION_ID
                                      AND gmd.batch_id = gbh.batch_id)
                        WHERE Actual_Products != 0
                     ORDER BY batch_no)
            SELECT DISTINCT FGP.*, SFGING.*
              FROM FGP, FGING, SFGING
             WHERE     FGP.BATCH_ID = FGING.BATCH_ID
                   AND FGING.LOT_NUMBER = SFGING.created_lot)
    --ORDER BY BATCH_NO,PRO_CLASS

    UNION ALL
    SELECT BATCH_ID,
           BATCH_NO,
           LOT_NUMBER,
           PRODUCT,
           PROD_DESCRIPTION,
           PRIMARY_UOM_CODE,
           PLAN_PRODUCTS,
           ACTUAL_PRODUCTS,
           ACTUAL_START_DATE,
           ACTUAL_CMPLT_DATE,
           PRO_CLASS,
           BATCH_ID_1,
           BATCH_NO_1,
           LOT_NUMBER_1,
           ITEM_TYPE,
           PROD_CATE,
           ITEM_CODE,
           PROD_DESCRIPTION_1,
           PRIMARY_UOM_CODE_1,
           ACTUAL_PRODUCTS_1,
           ACTUAL_START_DATE_1,
           ACTUAL_CMPLT_DATE_1
      FROM (WITH
                FGP
                AS
                    (SELECT PRO_CLASS,
                            BATCH_ID,
                            batch_no,
                            LOT_NUMBER,
                            product,
                            PROD_DESCRIPTION,
                            PRIMARY_UOM_CODE,
                            Plan_Products,
                            Actual_Products,
                            actual_start_date,
                            ACTUAL_CMPLT_DATE
                       FROM (SELECT (SELECT 'BULK' FROM DUAL)
                                        PRO_CLASS,
                                    gbh.BATCH_ID,
                                    gbh.batch_no,
                                    mtlot.LOT_NUMBER,
                                    DECODE (gmd.line_type, 1, itm.segment1)
                                        AS Product,
                                    itm.DESCRIPTION
                                        PROD_DESCRIPTION,
                                    itm.PRIMARY_UOM_CODE,
                                    ROUND (
                                        NVL (
                                            (DECODE (gmd.line_type,
                                                     1, gmd.PLAN_QTY)),
                                            0),
                                        5)
                                        AS Plan_Products,
                                    ROUND (
                                        NVL (
                                            (DECODE (gmd.line_type,
                                                     1, gmd.actual_qty)),
                                            0),
                                        5)
                                        AS Actual_Products,
                                    gbh.actual_start_date,
                                    gbh.ACTUAL_CMPLT_DATE
                               FROM inv.mtl_material_transactions      mmt,
                                    gme.gme_material_details           gmd,
                                    gme.gme_batch_header               gbh,
                                    apps.org_organization_definitions  ood,
                                    apps.MTL_SYSTEM_ITEMS_FVL          itm,
                                    apps.mtl_item_categories_v         cat,
                                    inv.mtl_transaction_lot_numbers    mtlot,
                                    APPS.fm_form_mst                   F
                              WHERE     mmt.transaction_source_type_id = 5
                                    AND ood.organization_id = 158
                                    AND gbh.organization_id =
                                        ood.organization_id
                                    AND gbh.organization_id =
                                        itm.organization_id
                                    AND gbh.organization_id =
                                        cat.organization_id
                                    AND gmd.INVENTORY_ITEM_ID =
                                        itm.INVENTORY_ITEM_ID
                                    AND itm.INVENTORY_ITEM_ID =
                                        cat.INVENTORY_ITEM_ID
                                    AND gmd.INVENTORY_ITEM_ID =
                                        cat.INVENTORY_ITEM_ID
                                    AND cat.CATEGORY_SET_NAME = 'Inventory'
                                    AND mmt.trx_source_line_id =
                                        gmd.material_detail_id
                                    AND mmt.transaction_source_id =
                                        gbh.batch_id
                                    AND gbh.Formula_ID = F.Formula_ID
                                    --AND F.FORMULA_CLASS = 'FG'
                                    AND ITM.ITEM_TYPE = 'FG'
                                    AND cat.SEGMENT3 = 'FG COMMERCIAL'
                                    AND mtlot.transaction_id =
                                        mmt.TRANSACTION_ID
                                    AND gmd.batch_id = gbh.batch_id)
                      WHERE Plan_Products != 0),
                FGING
                AS
                    (  SELECT BATCH_ID,
                              batch_no,
                              LOT_NUMBER,
                              ITEM_CODE,
                              PROD_DESCRIPTION,
                              ITEM_TYPE,
                              PROD_CATE,
                              PRIMARY_UOM_CODE,
                              Actual_Products,
                              actual_start_date,
                              ACTUAL_CMPLT_DATE
                         FROM (SELECT gbh.BATCH_ID,
                                      gbh.batch_no,
                                      mtlot.LOT_NUMBER,
                                      itm.SEGMENT1       ITEM_CODE,
                                      itm.DESCRIPTION    PROD_DESCRIPTION,
                                      ITM.ITEM_TYPE,
                                      cat.SEGMENT3       PROD_CATE,
                                      itm.PRIMARY_UOM_CODE,
                                      ROUND (
                                          NVL (
                                              (DECODE (gmd.line_type,
                                                       -1, gmd.actual_qty)),
                                              0),
                                          5)             AS Actual_Products,
                                      gbh.actual_start_date,
                                      gbh.ACTUAL_CMPLT_DATE
                                 FROM inv.mtl_material_transactions    mmt,
                                      gme.gme_material_details         gmd,
                                      gme.gme_batch_header             gbh,
                                      apps.org_organization_definitions ood,
                                      apps.MTL_SYSTEM_ITEMS_FVL        itm,
                                      apps.mtl_item_categories_v       cat,
                                      inv.mtl_transaction_lot_numbers  mtlot,
                                      APPS.fm_form_mst                 F
                                WHERE     mmt.transaction_source_type_id = 5
                                      AND ood.organization_id = 158
                                      AND gbh.organization_id =
                                          ood.organization_id
                                      AND gbh.organization_id =
                                          itm.organization_id
                                      AND gbh.organization_id =
                                          cat.organization_id
                                      AND gmd.INVENTORY_ITEM_ID =
                                          itm.INVENTORY_ITEM_ID
                                      AND itm.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND gmd.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND cat.CATEGORY_SET_NAME = 'Inventory'
                                      AND mmt.trx_source_line_id =
                                          gmd.material_detail_id
                                      AND mmt.transaction_source_id =
                                          gbh.batch_id
                                      AND gbh.Formula_ID = F.Formula_ID
                                      --AND F.FORMULA_CLASS = 'FG'
                                      --AND cat.SEGMENT3='SPM'
                                      --AND ITM.ITEM_TYPE IN('SPM')
                                      AND mtlot.transaction_id =
                                          mmt.TRANSACTION_ID
                                      AND gmd.batch_id = gbh.batch_id)
                        WHERE Actual_Products != 0
                     --AND batch_no=60
                     ORDER BY batch_no),
                SFGING
                AS
                    (  SELECT BATCH_ID              BATCH_ID_1,
                              batch_no              BATCH_NO_1,
                              created_lot,
                              LOT_NUMBER            LOT_NUMBER_1,
                              ITEM_CODE,
                              PROD_DESCRIPTION      PROD_DESCRIPTION_1,
                              ITEM_TYPE,
                              PROD_CATE,
                              PRIMARY_UOM_CODE      PRIMARY_UOM_CODE_1,
                              Actual_Products       ACTUAL_PRODUCTS_1,
                              actual_start_date     actual_start_date_1,
                              ACTUAL_CMPLT_DATE     ACTUAL_CMPLT_DATE_1
                         FROM (SELECT gbh.BATCH_ID,
                                      gbh.batch_no,
                                      APPS.GET_SFG_PRO_LOT_IN_ING (
                                          gbh.BATCH_ID)    AS created_lot,
                                      mtlot.LOT_NUMBER,
                                      itm.SEGMENT1         ITEM_CODE,
                                      itm.DESCRIPTION      PROD_DESCRIPTION,
                                      ITM.ITEM_TYPE,
                                      cat.SEGMENT3         PROD_CATE,
                                      itm.PRIMARY_UOM_CODE,
                                      ROUND (
                                          NVL (
                                              (DECODE (gmd.line_type,
                                                       -1, gmd.actual_qty)),
                                              0),
                                          5)               AS Actual_Products,
                                      gbh.actual_start_date,
                                      gbh.ACTUAL_CMPLT_DATE
                                 FROM inv.mtl_material_transactions    mmt,
                                      gme.gme_material_details         gmd,
                                      gme.gme_batch_header             gbh,
                                      apps.org_organization_definitions ood,
                                      apps.MTL_SYSTEM_ITEMS_FVL        itm,
                                      apps.mtl_item_categories_v       cat,
                                      inv.mtl_transaction_lot_numbers  mtlot,
                                      APPS.fm_form_mst                 F
                                WHERE     mmt.transaction_source_type_id = 5
                                      AND ood.organization_id = 158
                                      AND gbh.organization_id =
                                          ood.organization_id
                                      AND gbh.organization_id =
                                          itm.organization_id
                                      AND gbh.organization_id =
                                          cat.organization_id
                                      AND gmd.INVENTORY_ITEM_ID =
                                          itm.INVENTORY_ITEM_ID
                                      AND itm.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND gmd.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND cat.CATEGORY_SET_NAME = 'Inventory'
                                      AND mmt.trx_source_line_id =
                                          gmd.material_detail_id
                                      AND mmt.transaction_source_id =
                                          gbh.batch_id
                                      AND gbh.Formula_ID = F.Formula_ID
                                      AND F.FORMULA_CLASS = 'SFG'
                                      -- AND cat.SEGMENT3='PPM'
                                      --AND ITM.ITEM_TYPE IN('PPM')
                                      AND mtlot.transaction_id =
                                          mmt.TRANSACTION_ID
                                      AND gmd.batch_id = gbh.batch_id)
                        WHERE Actual_Products != 0
                     ORDER BY batch_no),
                BULKP
                AS
                    (  SELECT BATCH_ID,
                              batch_no,
                              LOT_NUMBER,
                              PROD_DESCRIPTION,
                              ITEM_TYPE,
                              PRIMARY_UOM_CODE,
                              Actual_Products,
                              actual_start_date,
                              ACTUAL_CMPLT_DATE
                         FROM (SELECT gbh.BATCH_ID,
                                      gbh.batch_no,
                                      mtlot.LOT_NUMBER,
                                      itm.DESCRIPTION    PROD_DESCRIPTION,
                                      ITM.ITEM_TYPE,
                                      itm.PRIMARY_UOM_CODE,
                                      ROUND (
                                          NVL (
                                              (DECODE (gmd.line_type,
                                                       1, gmd.actual_qty)),
                                              0),
                                          5)             AS Actual_Products,
                                      gbh.actual_start_date,
                                      gbh.ACTUAL_CMPLT_DATE
                                 FROM inv.mtl_material_transactions    mmt,
                                      gme.gme_material_details         gmd,
                                      gme.gme_batch_header             gbh,
                                      apps.org_organization_definitions ood,
                                      apps.MTL_SYSTEM_ITEMS_FVL        itm,
                                      apps.mtl_item_categories_v       cat,
                                      inv.mtl_transaction_lot_numbers  mtlot,
                                      APPS.fm_form_mst                 F
                                WHERE     mmt.transaction_source_type_id = 5
                                      AND ood.organization_id = 158
                                      AND gbh.organization_id =
                                          ood.organization_id
                                      AND gbh.organization_id =
                                          itm.organization_id
                                      AND gbh.organization_id =
                                          cat.organization_id
                                      AND gmd.INVENTORY_ITEM_ID =
                                          itm.INVENTORY_ITEM_ID
                                      AND itm.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND gmd.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND cat.CATEGORY_SET_NAME = 'Inventory'
                                      AND mmt.trx_source_line_id =
                                          gmd.material_detail_id
                                      AND mmt.transaction_source_id =
                                          gbh.batch_id
                                      AND gbh.Formula_ID = F.Formula_ID
                                      AND F.FORMULA_CLASS = 'BULK'
                                      --AND cat.SEGMENT3='BULK'
                                      -- AND ITM.ITEM_TYPE='BULK'
                                      AND mtlot.transaction_id =
                                          mmt.TRANSACTION_ID
                                      AND gmd.batch_id = gbh.batch_id)
                        WHERE Actual_Products != 0
                     ORDER BY batch_no),
                BULKING
                AS
                    (  SELECT BATCH_ID              BATCH_ID_1,
                              batch_no              batch_no_1,
                              created_lot,
                              LOT_NUMBER            LOT_NUMBER_1,
                              ITEM_CODE,
                              PROD_DESCRIPTION      PROD_DESCRIPTION_1,
                              ITEM_TYPE,
                              PROD_CATE,
                              PRIMARY_UOM_CODE      PRIMARY_UOM_CODE_1,
                              Actual_Products       ACTUAL_PRODUCTS_1,
                              actual_start_date     ACTUAL_START_DATE_1,
                              ACTUAL_CMPLT_DATE     ACTUAL_CMPLT_DATE_1
                         FROM (SELECT gbh.BATCH_ID,
                                      gbh.batch_no,
                                      APPS.GET_BULK_PRO_LOT_IN_ING (
                                          gbh.BATCH_ID)    AS created_lot,
                                      mtlot.LOT_NUMBER,
                                      itm.SEGMENT1         ITEM_CODE,
                                      itm.DESCRIPTION      PROD_DESCRIPTION,
                                      ITM.ITEM_TYPE,
                                      cat.SEGMENT3         PROD_CATE,
                                      itm.PRIMARY_UOM_CODE,
                                      ROUND (
                                          NVL (
                                              (DECODE (gmd.line_type,
                                                       -1, gmd.actual_qty)),
                                              0),
                                          5)               AS Actual_Products,
                                      gbh.actual_start_date,
                                      gbh.ACTUAL_CMPLT_DATE
                                 FROM inv.mtl_material_transactions    mmt,
                                      gme.gme_material_details         gmd,
                                      gme.gme_batch_header             gbh,
                                      apps.org_organization_definitions ood,
                                      apps.MTL_SYSTEM_ITEMS_FVL        itm,
                                      apps.mtl_item_categories_v       cat,
                                      inv.mtl_transaction_lot_numbers  mtlot,
                                      APPS.fm_form_mst                 F
                                WHERE     mmt.transaction_source_type_id = 5
                                      AND ood.organization_id = 158
                                      AND gbh.organization_id =
                                          ood.organization_id
                                      AND gbh.organization_id =
                                          itm.organization_id
                                      AND gbh.organization_id =
                                          cat.organization_id
                                      AND gmd.INVENTORY_ITEM_ID =
                                          itm.INVENTORY_ITEM_ID
                                      AND itm.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND gmd.INVENTORY_ITEM_ID =
                                          cat.INVENTORY_ITEM_ID
                                      AND cat.CATEGORY_SET_NAME = 'Inventory'
                                      AND mmt.trx_source_line_id =
                                          gmd.material_detail_id
                                      AND mmt.transaction_source_id =
                                          gbh.batch_id
                                      AND gbh.Formula_ID = F.Formula_ID
                                      AND F.FORMULA_CLASS = 'BULK'
                                      --AND cat.SEGMENT3='API'
                                      AND mtlot.transaction_id =
                                          mmt.TRANSACTION_ID
                                      --and gbh.batch_no=58
                                      AND gmd.batch_id = gbh.batch_id)
                        WHERE Actual_Products != 0
                     ORDER BY batch_no)
            SELECT DISTINCT FGP.*, BULKING.*
              FROM FGP,
                   FGING,
                   SFGING,
                   BULKP,
                   BULKING
             WHERE     FGP.BATCH_ID = FGING.BATCH_ID
                   AND FGING.LOT_NUMBER = SFGING.created_lot
                   AND SFGING.LOT_NUMBER_1 = BULKP.LOT_NUMBER
                   AND BULKP.BATCH_ID = BULKING.BATCH_ID_1
                   AND BULKP.LOT_NUMBER = BULKING.created_lot);


CREATE OR REPLACE SYNONYM APPSRO.GME_BATCH_DETAILS_V FOR APPS.GME_BATCH_DETAILS_V;


GRANT SELECT ON APPS.GME_BATCH_DETAILS_V TO APPSRO;
