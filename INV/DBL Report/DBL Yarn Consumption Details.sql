/* Formatted on 3/27/2021 3:07:04 PM (QP5 v5.354) */
  SELECT APPS.XX_COM_PKG.GET_COMPANY_NAME ( :P_COMPANY)     COMPANY,
         --ORGANIZATION_NAME,
         ITEM_CODE,
         ITEM_DESCRIPTION,
         UOM,
         ITEM_CATEGORY,
         ITEM_TYPE,
         SUM (TRX_QUANTITY)                                 AS QTY,
         PERIOD_NAME,
         PERIOD_YEAR
    FROM (SELECT C.SEGMENT1
                     ITEM_CODE,
                 C.DESCRIPTION
                     "ITEM_DESCRIPTION",
                 C.PRIMARY_UOM_CODE
                     "UOM",
                 MIC.SEGMENT2
                     ITEM_CATEGORY,
                 MIC.SEGMENT3
                     ITEM_TYPE,
                 PP.NAME
                     AS DEPARTMENT,
                 (A.PRIMARY_QUANTITY)
                     TRX_QUANTITY,
                 CC.SEGMENT5
                     "NATURAL_ACC",
                 (SELECT DESCRIPTION
                    FROM FND_FLEX_VALUES_VL
                   WHERE     FLEX_VALUE_SET_ID = 1017028
                         AND FLEX_VALUE = CC.SEGMENT1)
                     COMPANY,
                    CC.SEGMENT2
                 || ' - '
                 || (SELECT DESCRIPTION
                       FROM FND_FLEX_VALUES_VL
                      WHERE     FLEX_VALUE_SET_ID = 1017029
                            AND FLEX_VALUE = CC.SEGMENT2)
                     LOCATION_DESC,
                    CC.SEGMENT3
                 || ' - '
                 || (SELECT DESCRIPTION
                       FROM FND_FLEX_VALUES_VL
                      WHERE     FLEX_VALUE_SET_ID = 1017031
                            AND FLEX_VALUE = CC.SEGMENT3)
                     PRODUCT_LINE_DESC,
                    CC.SEGMENT4
                 || ' - '
                 || (SELECT DESCRIPTION
                       FROM FND_FLEX_VALUES_VL
                      WHERE     FLEX_VALUE_SET_ID = 1017032
                            AND FLEX_VALUE = CC.SEGMENT4)
                     COST_CENTER_DESC,
                    CC.SEGMENT5
                 || ' - '
                 || (SELECT DESCRIPTION
                       FROM FND_FLEX_VALUES_VL
                      WHERE     FLEX_VALUE_SET_ID = 1017040
                            AND FLEX_VALUE = CC.SEGMENT5)
                     NATURAL_ACCOUNT_DESC,
                    CC.SEGMENT6
                 || ' - '
                 || (SELECT DESCRIPTION
                       FROM APPS.FND_FLEX_VALUES_TL
                      WHERE FLEX_VALUE_ID =
                            (SELECT FLEX_VALUE_ID
                               FROM APPS.FND_FLEX_VALUES
                              WHERE     FLEX_VALUE_SET_ID =
                                        (SELECT FLEX_VALUE_SET_ID
                                           FROM APPS.FND_FLEX_VALUE_SETS
                                          WHERE FLEX_VALUE_SET_NAME =
                                                'XXDBL_SUB_ACCOUNT_COA')
                                    AND FLEX_VALUE = CC.SEGMENT6
                                    AND PARENT_FLEX_VALUE_LOW =
                                        (SELECT FLEX_VALUE
                                           FROM FND_FLEX_VALUES_VL B
                                          WHERE     FLEX_VALUE_SET_ID = 1017040
                                                AND B.FLEX_VALUE = CC.SEGMENT5)))
                     SUB_ACCCOUNT_DESC,
                    CC.SEGMENT7
                 || ' - '
                 || (SELECT DESCRIPTION
                       FROM FND_FLEX_VALUES_VL
                      WHERE     FLEX_VALUE_SET_ID = 1017036
                            AND FLEX_VALUE = CC.SEGMENT7)
                     INTER_COMPANY,
                    CC.SEGMENT8
                 || ' - '
                 || (SELECT DESCRIPTION
                       FROM FND_FLEX_VALUES_VL
                      WHERE     FLEX_VALUE_SET_ID = 1017038
                            AND FLEX_VALUE = CC.SEGMENT8)
                     EXP_CATEGORY_DESC,
                 OOD.OPERATING_UNIT
                     ORG_ID,
                 -- HOU.NAME "OPERATING_UNIT_NAME",
                 OOD.ORGANIZATION_NAME,
                 TO_CHAR (A.TRANSACTION_DATE, 'MON-RR')
                     PERIOD_NAME,
                 TO_CHAR (A.TRANSACTION_DATE, 'RRRR')
                     PERIOD_YEAR,
                 'Production_Use'
                     AS "USE_AREA",
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
                     CODE_COMBINATION
            FROM APPS.MTL_MATERIAL_TRANSACTIONS   A,
                 APPS.MTL_GENERIC_DISPOSITIONS    B,
                 APPS.MTL_SYSTEM_ITEMS_B_KFV      C,
                 APPS.MTL_ITEM_CATEGORIES_V       MIC,
                 APPS.GL_CODE_COMBINATIONS        CC,
                 INV.MTL_PARAMETERS               MP,
                 APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                 APPS.HR_OPERATING_UNITS          HOU,
                 APPLSYS.FND_USER                 FNU,
                 -- mtl_transaction_accounts MTA,
                  (SELECT Q1.*, HAOU.NAME
                     FROM HR.PER_ALL_PEOPLE_F         Q1,
                          HR.PER_ALL_ASSIGNMENTS_F    PAAF,
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
                 --  AND OOD.ORGANIZATION_CODE = '181'
                 AND (   :P_SET_OF_BOOKS_ID IS NULL
                      OR HOU.SET_OF_BOOKS_ID = :P_SET_OF_BOOKS_ID)
                 AND CC.SEGMENT1 >=
                     (SELECT FROM_VALUE
                        FROM XX_VAL_SET_HIERARCHY_V
                       WHERE     FLEX_VALUE_SET_ID = :P_VALUE_SET_ID
                             AND FLEX_VALUE = :P_COMPANY)
                 AND CC.SEGMENT1 <=
                     (SELECT TO_VALUE
                        FROM XX_VAL_SET_HIERARCHY_V
                       WHERE     FLEX_VALUE_SET_ID = :P_VALUE_SET_ID
                             AND FLEX_VALUE = :P_COMPANY)
                 AND ( :P_ORG_ID IS NULL OR A.ORGANIZATION_ID = :P_ORG_ID)
                 AND :P_REPORT_TYPE = 'Rawdata'
                 AND ( :P_ACCOUNT IS NULL OR CC.SEGMENT5 = :P_ACCOUNT)
                 AND TRUNC (A.TRANSACTION_DATE) BETWEEN :P_DATE_FROM
                                                    AND :P_DATE_TO
                 -- AND C.SEGMENT1 = 'CHEMICAL000000000125'
                 AND MIC.SEGMENT2 = 'RAW MATERIAL'
                 AND MIC.SEGMENT3 = 'YARN')
GROUP BY                                                  --ORGANIZATION_NAME,
         ITEM_CODE,
         ITEM_DESCRIPTION,
         UOM,
         ITEM_CATEGORY,
         ITEM_TYPE,
         PERIOD_NAME,
         PERIOD_YEAR
ORDER BY ITEM_CODE,PERIOD_YEAR,PERIOD_NAME