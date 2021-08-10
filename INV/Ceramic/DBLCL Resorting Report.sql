/* Formatted on 9/29/2020 2:25:26 PM (QP5 v5.354) */
WITH
    TmpData
    AS
        (  SELECT       --SUM (mmt.TRANSACTION_QUANTITY) TRANSACTION_QUANTITY,
                  --mtt.TRANSACTION_TYPE_NAME AS INGRED_TRANSACTION_TYPE,
                  --mtln.LOT_NUMBER As INGREDIENT_LOT_NUMBER,
                  --h.FORMULA_ID,
                  fm.FORMULA_NO,
                  msi.concatenated_segments    AS item_code,
                  msi.description              AS item_description,
                  CASE
                      WHEN mtt.TRANSACTION_TYPE_NAME = 'WIP Issue'
                      THEN
                          SUM (mmt.TRANSACTION_QUANTITY)
                      ELSE
                          0
                  END                          WIP_Issue_TRA_QUANTITY,
                  CASE
                      WHEN mtt.TRANSACTION_TYPE_NAME = 'WIP Completion'
                      THEN
                          SUM (mmt.TRANSACTION_QUANTITY)
                      ELSE
                          0
                  END                          WIP_Completion_TRA_QUANTITY --,
             --          CASE
             --            WHEN mtt.TRANSACTION_TYPE_NAME = 'WIP Completion'
             --            THEN
             --               SUM (mmt.TRANSACTION_QUANTITY)
             --            ELSE
             --               SUM (mmt.TRANSACTION_QUANTITY)
             --         END
             --            RESORTING_QUANTITY
             FROM apps.MTL_MATERIAL_TRANSACTIONS mmt,
                  inv.MTL_TRANSACTION_TYPES      mtt,
                  inv.MTL_TRANSACTION_LOT_NUMBERS mtln,
                  gme.GME_BATCH_HEADER           h,
                  FM_FORM_MST_B                  fm,
                  apps.MTL_SYSTEM_ITEMS_B_KFV    msi
                  --,gmd_recipes                    r
            WHERE     mmt.TRANSACTION_TYPE_ID = mtt.TRANSACTION_TYPE_ID
                  AND mmt.TRANSACTION_ID = mtln.TRANSACTION_ID
                  AND mtln.ORGANIZATION_ID = mmt.ORGANIZATION_ID
                  AND mtln.TRANSACTION_SOURCE_ID = h.BATCH_ID
                  AND h.ORGANIZATION_ID = mmt.ORGANIZATION_ID
                  AND fm.FORMULA_ID = h.FORMULA_ID
                  AND mmt.inventory_item_id = msi.inventory_item_id
                  AND mmt.organization_id = msi.organization_id
                  -- AND msi.inventory_item_id = mic.inventory_item_id
                  --  AND msi.organization_id = mic.organization_id
                  AND mmt.INVENTORY_ITEM_ID = 188993
                  AND TRUNC (mmt.TRANSACTION_DATE) BETWEEN '08-Aug-20'
                                                       AND '08-Aug-20'
                  AND mmt.ORGANIZATION_ID = 152
                  AND mmt.TRANSACTION_UOM = 'CTN'
                  AND FORMULA_NO = 'DBLCL-RESORTING'
         GROUP BY mtt.TRANSACTION_TYPE_NAME,                --mtln.LOT_NUMBER,
                  --h.FORMULA_ID,
                  fm.FORMULA_NO,
                  msi.concatenated_segments,
                  msi.description)
  SELECT FORMULA_NO,
         ITEM_CODE,
         ITEM_DESCRIPTION,
         SUM (WIP_ISSUE_TRA_QUANTITY)                                          WIP_ISSUE_TRA_QUANTITY,
         SUM (WIP_COMPLETION_TRA_QUANTITY)                                     WIP_COMPLETION_TRA_QUANTITY,
         (SUM (WIP_COMPLETION_TRA_QUANTITY) * 1.44)                            SQM,
         (SUM (WIP_ISSUE_TRA_QUANTITY) + SUM (WIP_COMPLETION_TRA_QUANTITY))    Rejection
    FROM TmpData
GROUP BY FORMULA_NO, ITEM_CODE, ITEM_DESCRIPTION;