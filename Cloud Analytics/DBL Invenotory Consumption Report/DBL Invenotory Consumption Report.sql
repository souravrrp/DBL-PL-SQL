/* Formatted on 6/15/2021 11:55:33 AM (QP5 v5.354) */
SELECT SET_OF_BOOKS_ID,
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
       USE_AREA,
       NATURAL_ACC,
       COMPANY                                        COMPANY_CODE,
       APPS.XX_COM_PKG.GET_COMPANY_NAME (COMPANY)     COMPANY_NAME,
       LOCATION_DESC,
       PRODUCT_LINE_DESC,
       COST_CENTER_DESC,
       NATURAL_ACCOUNT_DESC,
       SUB_ACCCOUNT_DESC,
       INTER_COMPANY,
       EXP_CATEGORY_DESC,
       CODE_COMBINATION,
       TRX_QUANTITY                                   QTY,
       ABS (TOTAL_COST / TRX_QUANTITY)                UNIT_COST,
       TOTAL_COST,
       BUYER_NAME,
       CUSTOMER_NAME,
       CREATED_BY
  FROM (SELECT '1.MOVE_ORDER'                                              AS TR_SOURCE,
               'Move_Order'                                                TR_TYPE,
               A.TRANSACTION_ID,
               C.SEGMENT1                                                  ITEM_CODE,
               C.DESCRIPTION                                               ITEM_DESCRIPTION,
               C.PRIMARY_UOM_CODE                                          UOM,
               MIC.SEGMENT2                                                ITEM_CATEGORY,
               MIC.SEGMENT3                                                ITEM_TYPE,
               (A.PRIMARY_QUANTITY)                                        TRX_QUANTITY,
               CASE
                   WHEN MP.PROCESS_ENABLED_FLAG = 'N'
                   THEN
                       APPS.XX_INV_TRAN_VAL_T (A.TRANSACTION_ID)
                   ELSE
                       APPS.XX_OINV_TRAN_VAL (A.TRANSACTION_ID)
               END                                                         AS TOTAL_COST,
               CC.SEGMENT5                                                 NATURAL_ACC,
               CC.SEGMENT1                                                 COMPANY,
               CC.SEGMENT2                                                 LOCATION_DESC,
               CC.SEGMENT3                                                 PRODUCT_LINE_DESC,
               CC.SEGMENT4                                                 COST_CENTER_DESC,
               CC.SEGMENT5                                                 NATURAL_ACCOUNT_DESC,
               CC.SEGMENT6                                                 SUB_ACCCOUNT_DESC,
               CC.SEGMENT7                                                 INTER_COMPANY,
               CC.SEGMENT8                                                 EXP_CATEGORY_DESC,
               OOD.OPERATING_UNIT                                          ORG_ID,
               OOD.ORGANIZATION_NAME,
               OOD.SET_OF_BOOKS_ID,
               OOD.ORGANIZATION_ID,
               B.REQUEST_NUMBER                                            MO_NO,
               TRUNC (A.TRANSACTION_DATE)                                  TRANSACTION_DATE,
               PRD.PERIOD_NAME,
               NVL (MTRL.ATTRIBUTE7, MTRL.ATTRIBUTE13)                     USE_AREA,
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
               || CC.SEGMENT9                                              CODE_COMBINATION,
               NULL                                                        BUYER_NAME,
               NULL                                                        CUSTOMER_NAME,
               APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (B.CREATED_BY)    CREATED_BY
          FROM APPS.MTL_MATERIAL_TRANSACTIONS     A,
               APPS.MTL_TXN_REQUEST_HEADERS       B,
               MTL_TXN_REQUEST_LINES_V            MTRL,
               APPS.MTL_SYSTEM_ITEMS_B_KFV        C,
               APPS.MTL_ITEM_CATEGORIES_V         MIC,
               APPS.GL_CODE_COMBINATIONS          CC,
               INV.MTL_PARAMETERS                 MP,
               APPS.ORG_ORGANIZATION_DEFINITIONS  OOD,
               APPS.HR_OPERATING_UNITS            HOU,
               INV.ORG_ACCT_PERIODS               PRD,
               APPLSYS.FND_USER                   FNU
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
               AND A.DISTRIBUTION_ACCOUNT_ID = CC.CODE_COMBINATION_ID
               AND A.ACCT_PERIOD_ID = PRD.ACCT_PERIOD_ID
               AND A.TRANSACTION_QUANTITY < 0
               AND A.ORGANIZATION_ID = PRD.ORGANIZATION_ID
               AND MTRL.INVENTORY_ITEM_ID = A.INVENTORY_ITEM_ID
               AND MTRL.ORGANIZATION_ID = A.ORGANIZATION_ID
               AND MTRL.LINE_ID = A.TRX_SOURCE_LINE_ID
               AND A.TRANSACTION_SOURCE_ID = B.HEADER_ID
               AND MIC.CATEGORY_SET_NAME = 'Inventory'
        UNION ALL
        SELECT '2 . OPM_DIS_ACC_ALS'                                       AS TR_SOURCE,
               'Move_Order'                                                TR_TYPE,
               A.TRANSACTION_ID,
               C.SEGMENT1                                                  ITEM_CODE,
               C.DESCRIPTION                                               ITEM_DESCRIPTION,
               C.PRIMARY_UOM_CODE                                          UOM,
               MIC.SEGMENT2                                                ITEM_CATEGORY,
               MIC.SEGMENT3                                                ITEM_TYPE,
               (A.PRIMARY_QUANTITY)                                        TRX_QUANTITY,
               CASE
                   WHEN MP.PROCESS_ENABLED_FLAG = 'N'
                   THEN
                       APPS.XX_INV_TRAN_VAL_T (A.TRANSACTION_ID)
                   ELSE
                       APPS.XX_OINV_TRAN_VAL (A.TRANSACTION_ID)
               END                                                         AS TOTAL_COST,
               CC.SEGMENT5                                                 NATURAL_ACC,
               CC.SEGMENT1                                                 COMPANY,
               CC.SEGMENT2                                                 LOCATION_DESC,
               CC.SEGMENT3                                                 PRODUCT_LINE_DESC,
               CC.SEGMENT4                                                 COST_CENTER_DESC,
               CC.SEGMENT5                                                 NATURAL_ACCOUNT_DESC,
               CC.SEGMENT6                                                 SUB_ACCCOUNT_DESC,
               CC.SEGMENT7                                                 INTER_COMPANY,
               CC.SEGMENT8                                                 EXP_CATEGORY_DESC,
               OOD.OPERATING_UNIT                                          ORG_ID,
               OOD.ORGANIZATION_NAME,
               OOD.SET_OF_BOOKS_ID,
               OOD.ORGANIZATION_ID,
               NULL                                                        MO_NO,
               TRUNC (A.TRANSACTION_DATE)                                  TRANSACTION_DATE,
               TO_CHAR (A.TRANSACTION_DATE, 'MON-RR')                      PERIOD_NAME,
               'Production_Use'                                            AS Use_Area,
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
               || CC.SEGMENT9                                              CODE_COMBINATION,
               NULL                                                        BUYER_NAME,
               NULL                                                        CUSTOMER_NAME,
               APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (A.CREATED_BY)    CREATED_BY
          FROM APPS.MTL_MATERIAL_TRANSACTIONS     A,
               APPS.MTL_GENERIC_DISPOSITIONS      B,
               APPS.MTL_SYSTEM_ITEMS_B_KFV        C,
               APPS.MTL_ITEM_CATEGORIES_V         MIC,
               APPS.GL_CODE_COMBINATIONS          CC,
               INV.MTL_PARAMETERS                 MP,
               APPS.ORG_ORGANIZATION_DEFINITIONS  OOD,
               APPS.HR_OPERATING_UNITS            HOU,
               APPLSYS.FND_USER                   FNU
         WHERE     A.ORGANIZATION_ID = MP.ORGANIZATION_ID
               AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
               AND OOD.OPERATING_UNIT = HOU.ORGANIZATION_ID
               AND A.INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID
               AND A.ORGANIZATION_ID = C.ORGANIZATION_ID
               AND A.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
               AND A.ORGANIZATION_ID = MIC.ORGANIZATION_ID
               AND A.TRANSACTION_TYPE_ID IN (31, 41, 100)
               AND A.TRANSACTION_SOURCE_ID = B.DISPOSITION_ID
               AND A.CREATED_BY = FNU.USER_ID
               AND B.DISTRIBUTION_ACCOUNT = CC.CODE_COMBINATION_ID
               AND B.ORGANIZATION_ID = A.ORGANIZATION_ID
               AND CATEGORY_SET_NAME = 'Inventory'
        UNION ALL
        SELECT '3.EXP_PO'
                   AS TR_SOURCE,
               'Expense PO'
                   TR_TYPE,
               RT.TRANSACTION_ID,
               C.SEGMENT1
                   ITEM_CODE,
               PLL.ITEM_DESCRIPTION,
               PLL.UNIT_MEAS_LOOKUP_CODE
                   UOM,
               MIC.SEGMENT2
                   ITEM_CATEGORY,
               MIC.SEGMENT3
                   ITEM_TYPE,
               RRSL.SOURCE_DOC_QUANTITY
                   TRX_QUANTITY,
               NVL (RRSL.ACCOUNTED_CR, 0) - NVL (RRSL.ACCOUNTED_DR, 0)
                   TOTAL_COST,
               CC.SEGMENT5
                   NATURAL_ACC,
               CC.SEGMENT1
                   COMPANY,
               CC.SEGMENT2
                   LOCATION_DESC,
               CC.SEGMENT3
                   PRODUCT_LINE_DESC,
               CC.SEGMENT4
                   COST_CENTER_DESC,
               CC.SEGMENT5
                   NATURAL_ACCOUNT_DESC,
               CC.SEGMENT6
                   SUB_ACCCOUNT_DESC,
               CC.SEGMENT7
                   INTER_COMPANY,
               CC.SEGMENT8
                   EXP_CATEGORY_DESC,
               OOD.OPERATING_UNIT
                   ORG_ID,
               OOD.ORGANIZATION_NAME,
               OOD.SET_OF_BOOKS_ID,
               OOD.ORGANIZATION_ID,
               NULL
                   MO_NO,
               RT.TRANSACTION_DATE,
               RRSL.PERIOD_NAME,
               'EXPENSE_PO'
                   AS Use_Area,
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
               NULL
                   BUYER_NAME,
               NULL
                   CUSTOMER_NAME,
               APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (RT.CREATED_BY)
                   CREATED_BY
          FROM APPS.RCV_RECEIVING_SUB_LEDGER      RRSL,
               APPS.RCV_TRANSACTIONS              RT,
               APPS.PO_DISTRIBUTIONS_ALL          PD,
               APPS.PO_LINES_ALL                  PLL,
               APPS.GL_CODE_COMBINATIONS          CC,
               APPS.MTL_SYSTEM_ITEMS_B_KFV        C,
               APPS.MTL_ITEM_CATEGORIES_V         MIC,
               APPS.ORG_ORGANIZATION_DEFINITIONS  OOD
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
               AND ACCOUNTING_LINE_TYPE = 'Charge'
               AND RT.DESTINATION_TYPE_CODE = 'EXPENSE'
               AND MIC.CATEGORY_SET_ID = 1
        UNION ALL
        SELECT '4.INVENTORY'                                               AS TR_SOURCE,
               'Miscellaneous Receipt'                                     TR_TYPE,
               A.TRANSACTION_ID,
               C.SEGMENT1                                                  ITEM_CODE,
               C.DESCRIPTION                                               ITEM_DESCRIPTION,
               C.PRIMARY_UOM_CODE                                          UOM,
               MIC.SEGMENT2                                                ITEM_CATEGORY,
               MIC.SEGMENT3                                                ITEM_TYPE,
               (A.PRIMARY_QUANTITY)                                        TRX_QUANTITY,
               CASE
                   WHEN MP.PROCESS_ENABLED_FLAG = 'N'
                   THEN
                       APPS.XX_INV_TRAN_VAL_T (A.TRANSACTION_ID)
                   ELSE
                       APPS.XX_OINV_TRAN_VAL (A.TRANSACTION_ID)
               END                                                         AS TOTAL_COST,
               CC.SEGMENT5                                                 NATURAL_ACC,
               CC.SEGMENT1                                                 COMPANY,
               CC.SEGMENT2                                                 LOCATION_DESC,
               CC.SEGMENT3                                                 PRODUCT_LINE_DESC,
               CC.SEGMENT4                                                 COST_CENTER_DESC,
               CC.SEGMENT5                                                 NATURAL_ACCOUNT_DESC,
               CC.SEGMENT6                                                 SUB_ACCCOUNT_DESC,
               CC.SEGMENT7                                                 INTER_COMPANY,
               CC.SEGMENT8                                                 EXP_CATEGORY_DESC,
               OOD.OPERATING_UNIT                                          ORG_ID,
               OOD.ORGANIZATION_NAME,
               OOD.SET_OF_BOOKS_ID,
               OOD.ORGANIZATION_ID,
               NULL                                                        AS REQUEST_NUMBER,
               TRUNC (A.TRANSACTION_DATE)                                  TRANSACTION_DATE,
               PRD.PERIOD_NAME,
               NULL                                                        AS USE_AREA,
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
               || CC.SEGMENT9                                              CODE_COMBINATION,
               NULL                                                        BUYER_NAME,
               NULL                                                        CUSTOMER_NAME,
               APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (A.CREATED_BY)    CREATED_BY
          FROM APPS.MTL_MATERIAL_TRANSACTIONS     A,
               APPS.MTL_SYSTEM_ITEMS_B_KFV        C,
               APPS.MTL_ITEM_CATEGORIES_V         MIC,
               APPS.GL_CODE_COMBINATIONS          CC,
               INV.MTL_PARAMETERS                 MP,
               APPS.ORG_ORGANIZATION_DEFINITIONS  OOD,
               APPS.HR_OPERATING_UNITS            HOU,
               INV.ORG_ACCT_PERIODS               PRD,
               APPLSYS.FND_USER                   FNU
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
               AND MIC.CATEGORY_SET_NAME = 'Inventory');