/* Formatted on 6/6/2021 11:36:52 AM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW APPS.XXDBL_INV_CON_RPT
(
   REPORT_TYPE,
   SET_OF_BOOKS_ID,
   ORGANIZATION_ID,
   ORGANIZATION_NAME,
   TR_TYPE,
   TRANSACTION_ID,
   TRANSACTION_DATE,
   MO_NO,
   ITEM_CODE,
   ITEM_DESCRIPTION,
   UOM,
   ITEM_CATEGORY,
   ITEM_TYPE,
   DEPARTMENT,
   Use_Area,
   NATURAL_ACC,
   COMPANY_CODE,
   LOCATION_DESC,
   PRODUCT_LINE_DESC,
   COST_CENTER_DESC,
   NATURAL_ACCOUNT_DESC,
   SUB_ACCCOUNT_DESC,
   INTER_COMPANY,
   EXP_CATEGORY_DESC,
   CODE_COMBINATION,
   QTY,
   UNIT_COST,
   TOTAL_COST,
   BUYER_NAME,
   CUSTOMER_NAME,
   ASSET_DESCRIPTION,
   CREATED_BY
)
   BEQUEATH DEFINER
AS
   SELECT 'Rawdata' REPORT_TYPE,
          SET_OF_BOOKS_ID,
          ORGANIZATION_ID,
          ORGANIZATION_NAME,
          TR_TYPE,
          TRANSACTION_ID,
          TRANSACTION_DATE,
          MO_NO,
          ITEM_CODE,
          ITEM_DESCRIPTION,
          UOM,
          ITEM_CATEGORY,
          ITEM_TYPE,
          DEPARTMENT,
          Use_Area,
          NATURAL_ACC,
          COMPANY_CODE,
          LOCATION_DESC,
          PRODUCT_LINE_DESC,
          COST_CENTER_DESC,
          NATURAL_ACCOUNT_DESC,
          SUB_ACCCOUNT_DESC,
          INTER_COMPANY,
          EXP_CATEGORY_DESC,
          CODE_COMBINATION,
          TRX_QUANTITY QTY,
          ABS (TOTAL_COST / TRX_QUANTITY) UNIT_COST,
          TOTAL_COST,
          BUYER_NAME,
          CUSTOMER_NAME,
          ASSET_DESCRIPTION,
          CREATED_BY
     FROM (SELECT '1.MOVE_ORDER' AS TR_SOURCE,
                  'Move_Order' TR_TYPE,
                  A.TRANSACTION_ID,
                  C.SEGMENT1 ITEM_CODE,
                  C.DESCRIPTION "ITEM_DESCRIPTION",
                  C.PRIMARY_UOM_CODE "UOM",
                  MIC.SEGMENT2 ITEM_CATEGORY,
                  MIC.SEGMENT3 ITEM_TYPE,
                  PP.NAME AS DEPARTMENT,
                  --  A.NEW_COST UNIT_COST,
                  (A.PRIMARY_QUANTITY) TRX_QUANTITY,
                  CASE
                     WHEN MP.PROCESS_ENABLED_FLAG = 'N'
                     THEN
                        APPS.XX_INV_TRAN_VAL_T (A.TRANSACTION_ID)
                     ELSE
                        APPS.XX_OINV_TRAN_VAL (A.TRANSACTION_ID)
                  END
                     AS TOTAL_COST,
                  CC.SEGMENT5 "NATURAL_ACC",
                  CC.SEGMENT1 COMPANY_CODE,
                  gl_flexfields_pkg.get_description_sql (
                     CC.CHART_OF_ACCOUNTS_ID,
                     1,
                     CC.SEGMENT1)
                     COMPANY,
                     CC.SEGMENT2
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        2,
                        CC.SEGMENT2)
                     LOCATION_DESC,
                     CC.SEGMENT3
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        3,
                        CC.SEGMENT3)
                     PRODUCT_LINE_DESC,
                     CC.SEGMENT4
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        4,
                        CC.SEGMENT4)
                     COST_CENTER_DESC,
                     CC.SEGMENT5
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        5,
                        CC.SEGMENT5)
                     NATURAL_ACCOUNT_DESC,
                     CC.SEGMENT6
                  || ' - '
                  || (SELECT DESCRIPTION
                        FROM FND_FLEX_VALUES_VL FLV
                       WHERE     FLEX_VALUE = CC.SEGMENT6
                             AND PARENT_FLEX_VALUE_LOW = CC.SEGMENT5)
                     SUB_ACCCOUNT_DESC,
                     CC.SEGMENT7
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        7,
                        CC.SEGMENT7)
                     INTER_COMPANY,
                     CC.SEGMENT8
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        8,
                        CC.SEGMENT8)
                     EXP_CATEGORY_DESC,
                  OOD.OPERATING_UNIT ORG_ID,
                  --HOU.NAME "OPERATING_UNIT_NAME",
                  OOD.ORGANIZATION_NAME,
                  OOD.SET_OF_BOOKS_ID,
                  OOD.ORGANIZATION_ID,
                  B.REQUEST_NUMBER MO_NO,
                  TRUNC (A.TRANSACTION_DATE) TRANSACTION_DATE,
                  PRD.PERIOD_NAME,
                  NVL (MTRL.ATTRIBUTE7, MTRL.ATTRIBUTE13) USE_AREA,
                     CC.SEGMENT1
                  || '.'
                  || CC.SEGMENT2
                  || '.'
                  || CC.SEGMENT3
                  || '.'
                  || CC.SEGMENT4
                  || '.'
                  || CC.SEGMENT5
                  || '.'
                  || CC.SEGMENT6
                  || '.'
                  || CC.SEGMENT7
                  || '.'
                  || CC.SEGMENT8
                  || '.'
                  || CC.SEGMENT9
                     CODE_COMBINATION,
                  NULL BUYER_NAME,
                  NULL CUSTOMER_NAME,
                  (SELECT DESCRIPTION
                     FROM FA_ADDITIONS
                    WHERE     ASSET_NUMBER = MTRL.ATTRIBUTE1
                          AND MTRL.ATTRIBUTE_CATEGORY =
                                 'DBL Fixed Asset List')
                     ASSET_DESCRIPTION,
                  APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (B.CREATED_BY)
                     CREATED_BY
             FROM APPS.MTL_MATERIAL_TRANSACTIONS A,
                  APPS.MTL_TXN_REQUEST_HEADERS B,
                  MTL_TXN_REQUEST_LINES_V MTRL,
                  APPS.MTL_SYSTEM_ITEMS_B_KFV C,
                  APPS.MTL_ITEM_CATEGORIES_V MIC,
                  APPS.GL_CODE_COMBINATIONS CC,
                  INV.MTL_PARAMETERS MP,
                  APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                  APPS.HR_OPERATING_UNITS HOU,
                  INV.ORG_ACCT_PERIODS PRD,
                  APPLSYS.FND_USER FNU,
                  (SELECT Q1.*, HAOU.NAME
                     FROM HR.PER_ALL_PEOPLE_F Q1,
                          HR.PER_ALL_ASSIGNMENTS_F PAAF,
                          HR.HR_ALL_ORGANIZATION_UNITS HAOU
                    WHERE     SYSDATE BETWEEN Q1.EFFECTIVE_START_DATE
                                          AND Q1.EFFECTIVE_END_DATE
                          AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE
                                          AND PAAF.EFFECTIVE_END_DATE
                          AND Q1.PERSON_ID = PAAF.PERSON_ID
                          AND PAAF.ORGANIZATION_ID = HAOU.ORGANIZATION_ID) PP
            WHERE     A.ORGANIZATION_ID = MP.ORGANIZATION_ID
                  AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                  AND OOD.OPERATING_UNIT = HOU.ORGANIZATION_ID
                  AND A.INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID
                  AND A.ORGANIZATION_ID = C.ORGANIZATION_ID
                  AND A.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                  AND A.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                  AND A.TRANSACTION_TYPE_ID IN (63)
                  AND A.TRANSACTION_SOURCE_ID = B.HEADER_ID
                  AND B.HEADER_ID = MTRL.HEADER_ID
                  AND B.CREATED_BY = FNU.USER_ID
                  AND PP.PARTY_ID(+) = NVL (FNU.PERSON_PARTY_ID, 0)
                  AND A.DISTRIBUTION_ACCOUNT_ID = CC.CODE_COMBINATION_ID
                  AND A.ACCT_PERIOD_ID = PRD.ACCT_PERIOD_ID
                  AND A.TRANSACTION_QUANTITY < 0
                  AND A.ORGANIZATION_ID = PRD.ORGANIZATION_ID
                  AND MTRL.INVENTORY_ITEM_ID = A.INVENTORY_ITEM_ID
                  AND MTRL.ORGANIZATION_ID = A.ORGANIZATION_ID
                  AND MTRL.LINE_ID = A.TRX_SOURCE_LINE_ID
                  AND A.TRANSACTION_SOURCE_ID = B.HEADER_ID
                  AND CATEGORY_SET_NAME = 'Inventory'
           UNION ALL
           SELECT '2.OPM_DIS_ACC_ALS' AS TR_SOURCE,
                  'Move_Order' TR_TYPE,
                  A.TRANSACTION_ID,
                  C.SEGMENT1 ITEM_CODE,
                  C.DESCRIPTION "ITEM_DESCRIPTION",
                  C.PRIMARY_UOM_CODE "UOM",
                  MIC.SEGMENT2 ITEM_CATEGORY,
                  MIC.SEGMENT3 ITEM_TYPE,
                  PP.NAME AS DEPARTMENT,
                  (A.PRIMARY_QUANTITY) TRX_QUANTITY,
                  CASE
                     WHEN MP.PROCESS_ENABLED_FLAG = 'N'
                     THEN
                        APPS.XX_INV_TRAN_VAL_T (A.TRANSACTION_ID)
                     ELSE
                        APPS.XX_OINV_TRAN_VAL (A.TRANSACTION_ID)
                  END
                     AS TOTAL_COST,
                  CC.SEGMENT5 "NATURAL_ACC",
                  CC.SEGMENT1 COMPANY_CODE,
                  gl_flexfields_pkg.get_description_sql (
                     CC.CHART_OF_ACCOUNTS_ID,
                     1,
                     CC.SEGMENT1)
                     COMPANY,
                     CC.SEGMENT2
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        2,
                        CC.SEGMENT2)
                     LOCATION_DESC,
                     CC.SEGMENT3
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        3,
                        CC.SEGMENT3)
                     PRODUCT_LINE_DESC,
                     CC.SEGMENT4
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        4,
                        CC.SEGMENT4)
                     COST_CENTER_DESC,
                     CC.SEGMENT5
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        5,
                        CC.SEGMENT5)
                     NATURAL_ACCOUNT_DESC,
                     CC.SEGMENT6
                  || ' - '
                  || (SELECT DESCRIPTION
                        FROM FND_FLEX_VALUES_VL FLV
                       WHERE     FLEX_VALUE = CC.SEGMENT6
                             AND PARENT_FLEX_VALUE_LOW = CC.SEGMENT5)
                     SUB_ACCCOUNT_DESC,
                     CC.SEGMENT7
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        7,
                        CC.SEGMENT7)
                     INTER_COMPANY,
                     CC.SEGMENT8
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        8,
                        CC.SEGMENT8)
                     EXP_CATEGORY_DESC,
                  OOD.OPERATING_UNIT ORG_ID,
                  OOD.ORGANIZATION_NAME,
                  OOD.SET_OF_BOOKS_ID,
                  OOD.ORGANIZATION_ID,
                  NULL MO_NO,
                  TRUNC (A.TRANSACTION_DATE) TRANSACTION_DATE,
                  TO_CHAR (A.TRANSACTION_DATE, 'MON-RR') PERIOD_NAME,
                  'Production_Use' AS "Use_Area",
                     CC.SEGMENT1
                  || '.'
                  || CC.SEGMENT2
                  || '.'
                  || CC.SEGMENT3
                  || '.'
                  || CC.SEGMENT4
                  || '.'
                  || CC.SEGMENT5
                  || '.'
                  || CC.SEGMENT6
                  || '.'
                  || CC.SEGMENT7
                  || '.'
                  || CC.SEGMENT8
                  || '.'
                  || CC.SEGMENT9
                     CODE_COMBINATION,
                  NULL BUYER_NAME,
                  NULL CUSTOMER_NAME,
                  NULL ASSET_DESCRIPTION,
                  APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (A.CREATED_BY)
                     CREATED_BY
             --mic.SEGMENT3 ITEM_TYPE
             FROM APPS.MTL_MATERIAL_TRANSACTIONS A,
                  APPS.MTL_GENERIC_DISPOSITIONS B,
                  APPS.MTL_SYSTEM_ITEMS_B_KFV C,
                  APPS.MTL_ITEM_CATEGORIES_V MIC,
                  APPS.GL_CODE_COMBINATIONS CC,
                  INV.MTL_PARAMETERS MP,
                  APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                  APPS.HR_OPERATING_UNITS HOU,
                  APPLSYS.FND_USER FNU,
                  -- mtl_transaction_accounts MTA,
                  (SELECT Q1.*, HAOU.NAME
                     FROM HR.PER_ALL_PEOPLE_F Q1,
                          HR.PER_ALL_ASSIGNMENTS_F PAAF,
                          HR.HR_ALL_ORGANIZATION_UNITS HAOU
                    WHERE     SYSDATE BETWEEN Q1.EFFECTIVE_START_DATE
                                          AND Q1.EFFECTIVE_END_DATE
                          AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE
                                          AND PAAF.EFFECTIVE_END_DATE
                          AND Q1.PERSON_ID = PAAF.PERSON_ID
                          AND PAAF.ORGANIZATION_ID = HAOU.ORGANIZATION_ID) PP
            WHERE     A.ORGANIZATION_ID = MP.ORGANIZATION_ID
                  AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                  AND OOD.OPERATING_UNIT = HOU.ORGANIZATION_ID
                  AND A.INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID
                  AND A.ORGANIZATION_ID = C.ORGANIZATION_ID
                  AND A.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                  AND A.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                  --    AND MTA.TRANSACTION_ID(+) = A.TRANSACTION_ID
                  --      AND MTA.ACCOUNTING_LINE_TYPE = 2
                  AND A.TRANSACTION_TYPE_ID IN (31, 41, 100)
                  AND A.TRANSACTION_SOURCE_ID = B.DISPOSITION_ID
                  AND A.CREATED_BY = FNU.USER_ID
                  AND PP.PARTY_ID(+) = NVL (FNU.PERSON_PARTY_ID, 0)
                  AND B.DISTRIBUTION_ACCOUNT = CC.CODE_COMBINATION_ID
                  AND B.ORGANIZATION_ID = A.ORGANIZATION_ID
                  AND CATEGORY_SET_NAME = 'Inventory'
           UNION ALL
           SELECT '3.EXP_PO' AS TR_SOURCE,
                  'Expense PO' TR_TYPE,
                  RT.TRANSACTION_ID,
                  C.SEGMENT1 ITEM_CODE,
                  PLL.ITEM_DESCRIPTION,
                  PLL.UNIT_MEAS_LOOKUP_CODE UOM,
                  MIC.SEGMENT2 ITEM_CATEGORY,
                  MIC.SEGMENT3 ITEM_TYPE,
                  NULL DEPARTMENT,
                  RRSL.SOURCE_DOC_QUANTITY TRX_QUANTITY,
                  --PLL.UNIT_PRICE * rrsl.SOURCE_DOC_QUANTITY TOTAL_COST,
                  -- NVL (RRSL.ACCOUNTED_DR, 0) - NVL (RRSL.ACCOUNTED_CR, 0)
                  NVL (RRSL.ACCOUNTED_CR, 0) - NVL (RRSL.ACCOUNTED_DR, 0)
                     TOTAL_COST,
                  CC.SEGMENT5 "NATURAL_ACC",
                  CC.SEGMENT1 COMPANY_CODE,
                  gl_flexfields_pkg.get_description_sql (
                     CC.CHART_OF_ACCOUNTS_ID,
                     1,
                     CC.SEGMENT1)
                     COMPANY,
                     CC.SEGMENT2
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        2,
                        CC.SEGMENT2)
                     LOCATION_DESC,
                     CC.SEGMENT3
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        3,
                        CC.SEGMENT3)
                     PRODUCT_LINE_DESC,
                     CC.SEGMENT4
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        4,
                        CC.SEGMENT4)
                     COST_CENTER_DESC,
                     CC.SEGMENT5
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        5,
                        CC.SEGMENT5)
                     NATURAL_ACCOUNT_DESC,
                     CC.SEGMENT6
                  || ' - '
                  || (SELECT DESCRIPTION
                        FROM FND_FLEX_VALUES_VL FLV
                       WHERE     FLEX_VALUE = CC.SEGMENT6
                             AND PARENT_FLEX_VALUE_LOW = CC.SEGMENT5)
                     SUB_ACCCOUNT_DESC,
                     CC.SEGMENT7
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        7,
                        CC.SEGMENT7)
                     INTER_COMPANY,
                     CC.SEGMENT8
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        8,
                        CC.SEGMENT8)
                     EXP_CATEGORY_DESC,
                  OOD.OPERATING_UNIT ORG_ID,
                  OOD.ORGANIZATION_NAME,
                  OOD.SET_OF_BOOKS_ID,
                  OOD.ORGANIZATION_ID,
                  NULL MO_NO,
                  RT.TRANSACTION_DATE,
                  RRSL.PERIOD_NAME,
                  'EXPENSE_PO' AS "Use_Area",
                     CC.SEGMENT1
                  || '.'
                  || CC.SEGMENT2
                  || '.'
                  || CC.SEGMENT3
                  || '.'
                  || CC.SEGMENT4
                  || '.'
                  || CC.SEGMENT5
                  || '.'
                  || CC.SEGMENT6
                  || '.'
                  || CC.SEGMENT7
                  || '.'
                  || CC.SEGMENT8
                  || '.'
                  || CC.SEGMENT9
                     CODE_COMBINATION,
                  NULL BUYER_NAME,
                  NULL CUSTOMER_NAME,
                  NULL ASSET_DESCRIPTION,
                  APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (RT.CREATED_BY)
                     CREATED_BY
             FROM RCV_RECEIVING_SUB_LEDGER RRSL,
                  RCV_TRANSACTIONS RT,
                  PO_DISTRIBUTIONS_ALL PD,
                  PO_LINES_ALL PLL,
                  GL_CODE_COMBINATIONS CC,
                  MTL_SYSTEM_ITEMS_B_KFV C,
                  MTL_ITEM_CATEGORIES_V MIC,
                  ORG_ORGANIZATION_DEFINITIONS OOD
            WHERE     PD.PO_DISTRIBUTION_ID = RT.PO_DISTRIBUTION_ID
                  AND RT.TRANSACTION_ID = RRSL.RCV_TRANSACTION_ID
                  AND RT.PO_DISTRIBUTION_ID = RRSL.REFERENCE3
                  AND PD.PO_LINE_ID = PLL.PO_LINE_ID
                  AND PD.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
                  AND CC.CODE_COMBINATION_ID = RRSL.CODE_COMBINATION_ID
                  AND MIC.INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID
                  AND MIC.ORGANIZATION_ID = C.ORGANIZATION_ID
                  AND RRSL.SET_OF_BOOKS_ID = OOD.SET_OF_BOOKS_ID
                  AND OOD.ORGANIZATION_ID = RT.ORGANIZATION_ID
                  AND C.ORGANIZATION_ID = RT.ORGANIZATION_ID
                  AND C.INVENTORY_ITEM_ID = PLL.ITEM_ID
                  AND PD.DESTINATION_ORGANIZATION_ID = C.ORGANIZATION_ID
                  --AND RRSL.REFERENCE4 = '10633000205'
                  AND ACCOUNTING_LINE_TYPE = 'Charge'
                  AND RT.DESTINATION_TYPE_CODE = 'EXPENSE'
                  AND MIC.CATEGORY_SET_ID = 1
           UNION ALL
           SELECT '4.INVENTORY' AS TR_SOURCE,
                  'Miscellaneous Receipt' TR_TYPE,
                  A.TRANSACTION_ID,
                  C.SEGMENT1 ITEM_CODE,
                  C.DESCRIPTION "ITEM_DESCRIPTION",
                  C.PRIMARY_UOM_CODE "UOM",
                  MIC.SEGMENT2 ITEM_CATEGORY,
                  MIC.SEGMENT3 ITEM_TYPE,
                  PP.NAME AS DEPARTMENT,
                  (A.PRIMARY_QUANTITY) TRX_QUANTITY,
                  CASE
                     WHEN MP.PROCESS_ENABLED_FLAG = 'N'
                     THEN
                        APPS.XX_INV_TRAN_VAL_T (A.TRANSACTION_ID)
                     ELSE
                        APPS.XX_OINV_TRAN_VAL (A.TRANSACTION_ID)
                  END
                     AS TOTAL_COST,
                  CC.SEGMENT5 "NATURAL_ACC",
                  CC.SEGMENT1 COMPANY_CODE,
                  gl_flexfields_pkg.get_description_sql (
                     CC.CHART_OF_ACCOUNTS_ID,
                     1,
                     CC.SEGMENT1)
                     COMPANY,
                     CC.SEGMENT2
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        2,
                        CC.SEGMENT2)
                     LOCATION_DESC,
                     CC.SEGMENT3
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        3,
                        CC.SEGMENT3)
                     PRODUCT_LINE_DESC,
                     CC.SEGMENT4
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        4,
                        CC.SEGMENT4)
                     COST_CENTER_DESC,
                     CC.SEGMENT5
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        5,
                        CC.SEGMENT5)
                     NATURAL_ACCOUNT_DESC,
                     CC.SEGMENT6
                  || ' - '
                  || (SELECT DESCRIPTION
                        FROM FND_FLEX_VALUES_VL FLV
                       WHERE     FLEX_VALUE = CC.SEGMENT6
                             AND PARENT_FLEX_VALUE_LOW = CC.SEGMENT5)
                     SUB_ACCCOUNT_DESC,
                     CC.SEGMENT7
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        7,
                        CC.SEGMENT7)
                     INTER_COMPANY,
                     CC.SEGMENT8
                  || ' - '
                  || gl_flexfields_pkg.get_description_sql (
                        CC.CHART_OF_ACCOUNTS_ID,
                        8,
                        CC.SEGMENT8)
                     EXP_CATEGORY_DESC,
                  OOD.OPERATING_UNIT ORG_ID,
                  OOD.ORGANIZATION_NAME,
                  OOD.SET_OF_BOOKS_ID,
                  OOD.ORGANIZATION_ID,
                  NULL AS REQUEST_NUMBER,
                  TRUNC (A.TRANSACTION_DATE) TRANSACTION_DATE,
                  PRD.PERIOD_NAME,
                  NULL AS USE_AREA,
                     CC.SEGMENT1
                  || '.'
                  || CC.SEGMENT2
                  || '.'
                  || CC.SEGMENT3
                  || '.'
                  || CC.SEGMENT4
                  || '.'
                  || CC.SEGMENT5
                  || '.'
                  || CC.SEGMENT6
                  || '.'
                  || CC.SEGMENT7
                  || '.'
                  || CC.SEGMENT8
                  || '.'
                  || CC.SEGMENT9
                     CODE_COMBINATION,
                  NULL BUYER_NAME,
                  NULL CUSTOMER_NAME,
                  NULL AS ASSET_DESCRIPTION,
                  APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (A.CREATED_BY)
                     CREATED_BY
             FROM APPS.MTL_MATERIAL_TRANSACTIONS A,
                  APPS.MTL_SYSTEM_ITEMS_B_KFV C,
                  APPS.MTL_ITEM_CATEGORIES_V MIC,
                  APPS.GL_CODE_COMBINATIONS CC,
                  INV.MTL_PARAMETERS MP,
                  APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                  APPS.HR_OPERATING_UNITS HOU,
                  INV.ORG_ACCT_PERIODS PRD,
                  APPLSYS.FND_USER FNU,
                  (SELECT Q1.*, HAOU.NAME
                     FROM HR.PER_ALL_PEOPLE_F Q1,
                          HR.PER_ALL_ASSIGNMENTS_F PAAF,
                          HR.HR_ALL_ORGANIZATION_UNITS HAOU
                    WHERE     SYSDATE BETWEEN Q1.EFFECTIVE_START_DATE
                                          AND Q1.EFFECTIVE_END_DATE
                          AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE
                                          AND PAAF.EFFECTIVE_END_DATE
                          AND Q1.PERSON_ID = PAAF.PERSON_ID
                          AND PAAF.ORGANIZATION_ID = HAOU.ORGANIZATION_ID) PP
            WHERE     1 = 1
                  AND A.TRANSACTION_TYPE_ID = 42
                  AND A.INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID
                  AND A.ORGANIZATION_ID = C.ORGANIZATION_ID
                  AND A.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                  AND A.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                  AND A.DISTRIBUTION_ACCOUNT_ID = CC.CODE_COMBINATION_ID
                  AND A.ORGANIZATION_ID = MP.ORGANIZATION_ID
                  AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                  AND OOD.OPERATING_UNIT = HOU.ORGANIZATION_ID
                  AND A.ACCT_PERIOD_ID = PRD.ACCT_PERIOD_ID
                  AND A.ORGANIZATION_ID = PRD.ORGANIZATION_ID
                  AND A.CREATED_BY = FNU.USER_ID
                  AND PP.PARTY_ID(+) = NVL (FNU.PERSON_PARTY_ID, 0)
                  AND MIC.CATEGORY_SET_NAME = 'Inventory');