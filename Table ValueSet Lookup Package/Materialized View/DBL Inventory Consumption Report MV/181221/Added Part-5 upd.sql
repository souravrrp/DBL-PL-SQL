/* Formatted on 12/18/2021 12:43:49 PM (QP5 v5.374) */
SELECT '5.eAM Work Order'
           AS "TR_SOURCE",
       'eAM Move Order' || '_' || "WOD"."WIP_ENTITY_NAME"
           "TR_TYPE",
       "A"."TRANSACTION_ID",
       "C"."SEGMENT1"
           "ITEM_CODE",
       "C"."DESCRIPTION"
           "ITEM_DESCRIPTION",
       "C"."PRIMARY_UOM_CODE"
           "UOM",
       "MIC"."SEGMENT2"
           "ITEM_CATEGORY",
       "MIC"."SEGMENT3"
           "ITEM_TYPE",
       ("A"."PRIMARY_QUANTITY")
           "TRX_QUANTITY",
       CASE
           WHEN "MP"."PROCESS_ENABLED_FLAG" = 'N'
           THEN
               "APPS"."XX_INV_TRAN_VAL_T" ("A"."TRANSACTION_ID")
           ELSE
               "APPS"."XX_OINV_TRAN_VAL" ("A"."TRANSACTION_ID")
       END
           AS "TOTAL_COST",
       "CC"."SEGMENT5"
           "NATURAL_ACC",
       "CC"."SEGMENT1"
           "COMPANY",
       "CC"."SEGMENT2"
           "LOCATION_DESC",
       "CC"."SEGMENT3"
           "PRODUCT_LINE_DESC",
       "CC"."SEGMENT4"
           "COST_CENTER_DESC",
       "CC"."SEGMENT5"
           "NATURAL_ACCOUNT_DESC",
       "CC"."SEGMENT6"
           "SUB_ACCCOUNT_DESC",
       "CC"."SEGMENT7"
           "INTER_COMPANY",
       "CC"."SEGMENT8"
           "EXP_CATEGORY_DESC",
       "OOD"."OPERATING_UNIT"
           "ORG_ID",
       "OOD"."ORGANIZATION_NAME",
       "OOD"."SET_OF_BOOKS_ID",
       "OOD"."ORGANIZATION_ID",
       "B"."REQUEST_NUMBER"
           "MO_NO",
       TRUNC ("A"."TRANSACTION_DATE")
           "TRANSACTION_DATE",
       "PRD"."PERIOD_NAME",
       "WOD"."AREA"
           "USE_AREA",
          "CC"."SEGMENT1"
       || '.'
       || "CC"."SEGMENT2"
       || '.'
       || "CC"."SEGMENT3"
       || '.'
       || "CC"."SEGMENT4"
       || '.'
       || "CC"."SEGMENT5"
       || '.'
       || "CC"."SEGMENT6"
       || '.'
       || "CC"."SEGMENT7"
       || '.'
       || "CC"."SEGMENT8"
       || '.'
       || "CC"."SEGMENT9"
           "CODE_COMBINATION",
       NULL
           "BUYER_NAME",
       NULL
           "CUSTOMER_NAME",
       "B"."CREATED_BY"
           "CREATED_BY",
       "WOD"."ASSET_NUMBER"
           "ASSET",
       "WOD"."ASSET_GROUP_DESCRIPTION"
           "ASSET_CATEGORY"
  FROM "APPS"."MTL_MATERIAL_TRANSACTIONS"     "A",
       "APPS"."MTL_TXN_REQUEST_HEADERS"       "B",
       "INV"."MTL_TXN_REQUEST_LINES"          "MTL",
       "APPS"."MTL_SYSTEM_ITEMS_B_KFV"        "C",
       "APPS"."MTL_ITEM_CATEGORIES_V"         "MIC",
       "APPS"."GL_CODE_COMBINATIONS"          "CC",
       "INV"."MTL_PARAMETERS"                 "MP",
       "APPS"."ORG_ORGANIZATION_DEFINITIONS"  "OOD",
       "APPS"."HR_OPERATING_UNITS"            "HOU",
       "INV"."ORG_ACCT_PERIODS"               "PRD",
       "APPLSYS"."FND_USER"                   "FNU",
       "APPS"."EAM_CFR_WORK_ORDER_V"          "WOD"
 WHERE     "A"."ORGANIZATION_ID" = "MP"."ORGANIZATION_ID"
       AND "MP"."ORGANIZATION_ID" = "OOD"."ORGANIZATION_ID"
       AND "OOD"."OPERATING_UNIT" = "HOU"."ORGANIZATION_ID"
       AND "A"."INVENTORY_ITEM_ID" = "C"."INVENTORY_ITEM_ID"
       AND "A"."ORGANIZATION_ID" = "C"."ORGANIZATION_ID"
       AND "A"."INVENTORY_ITEM_ID" = "MIC"."INVENTORY_ITEM_ID"
       AND "A"."ORGANIZATION_ID" = "MIC"."ORGANIZATION_ID"
       AND "A"."TRANSACTION_TYPE_ID" IN (35, 43)
       AND "A"."TRANSACTION_SOURCE_ID" = "MTL"."TXN_SOURCE_ID"
       AND "B"."HEADER_ID" = "MTL"."HEADER_ID"
       AND "B"."CREATED_BY" = "FNU"."USER_ID"
       AND "WOD"."MATERIAL_ACCOUNT" = "CC"."CODE_COMBINATION_ID"(+)
       AND "A"."ACCT_PERIOD_ID" = "PRD"."ACCT_PERIOD_ID"
       AND "A"."TRANSACTION_QUANTITY" < 0
       AND "A"."ORGANIZATION_ID" = "PRD"."ORGANIZATION_ID"
       AND "MTL"."TXN_SOURCE_ID" = "WOD"."WIP_ENTITY_ID"
       AND "A"."ORGANIZATION_ID" = "WOD"."ORGANIZATION_ID"
       AND "A"."MOVE_ORDER_LINE_ID" = "MTL"."LINE_ID"
       AND "A"."TRANSACTION_SOURCE_ID" = "WOD"."WIP_ENTITY_ID"
       AND "MIC"."CATEGORY_SET_NAME" = 'Inventory'