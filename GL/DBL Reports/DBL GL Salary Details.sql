/* Formatted on 12/1/2021 9:20:45 AM (QP5 v5.365) */
SELECT JE_SOURCE,
       JE_CATEGORY,
          COMPANY
       || ' - '
       || (SELECT DESCRIPTION
             FROM FND_FLEX_VALUES_VL A
            WHERE A.FLEX_VALUE_SET_ID = 1017028 AND A.FLEX_VALUE = COMPANY)
           COMPANY_NAME,
          LOCATION
       || ' - '
       || (SELECT DESCRIPTION
             FROM FND_FLEX_VALUES_VL A
            WHERE A.FLEX_VALUE_SET_ID = 1017029 AND A.FLEX_VALUE = LOCATION)
           LOCATION_DESC,
          PRODUCT_LINE
       || ' - '
       || (SELECT DESCRIPTION
             FROM FND_FLEX_VALUES_VL A
            WHERE     A.FLEX_VALUE_SET_ID = 1017031
                  AND A.FLEX_VALUE = PRODUCT_LINE)
           PRODUCT_LINE,
          COST_CENTER
       || ' - '
       || (SELECT DESCRIPTION
             FROM FND_FLEX_VALUES_VL
            WHERE FLEX_VALUE_SET_ID = 1017032 AND FLEX_VALUE = COST_CENTER)
           COST_CENTER,
       ACCOUNT || ' - ' || ACCTDESC
           ACCOUNT_DESC,
       SUB_ACCOUNT || ' - ' || SUBACCDESC
           SUB_ACC_DESC,
          EXPENSE_CATEGORY
       || ' - '
       || (SELECT DESCRIPTION
             FROM FND_FLEX_VALUES_VL A
            WHERE     A.FLEX_VALUE_SET_ID = 1017038
                  AND A.FLEX_VALUE = EXPENSE_CATEGORY)
           EXP_CAT_DESC,
       VOUCHER_NUMBER,
       VOUCHER_DATE,
       DESCRIPTION,
       DEBITS,
       CREDITS,
       CREATED_BY
  FROM XX_GL_DETAILS_STATEMENT_V
 WHERE     1 = 1
       AND ACCOUNT IN ('512101',
                       '512102',
                       '512108',
                       '512113',
                       '512132')
       AND VOUCHER_DATE BETWEEN '01-OCT-2021' AND '31-OCT-2021'
       AND LEDGER_ID IN (2119,
                         2075,
                         2057,
                         2067,
                         2063,
                         2087,
                         2079,
                         2267,
                         2349,
                         2111,
                         2071,
                         2225,
                         2247,
                         2287,
                         2269,
                         2083,
                         2099,
                         2107,
                         2347,
                         2221,
                         2023,
                         2031,
                         2051,
                         2027,
                         2035,
                         2039,
                         2103,
                         2327,
                         2095,
                         2043,
                         2047,
                         2201,
                         2091,
                         2115,
                         2055);