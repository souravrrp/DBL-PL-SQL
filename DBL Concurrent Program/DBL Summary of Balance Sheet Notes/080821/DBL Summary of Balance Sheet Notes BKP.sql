WITH XX_WITH_CLAUSE_TAB
     AS (  SELECT JE_SOURCE,
                  1 ORD,
                  ACCOUNT,
                  ACCTDESC,
                  PARTY_CODE,
                  PARTY_NAME VENDOR_NAME,
                  SUM (NVL (DEBITS, 0)) - SUM (NVL (CREDITS, 0))
                     OPENING_BALANCE,
                  0 DEBITS,
                  0 CREDITS
             FROM XX_GL_DETAILS_STATEMENT_V_2 GLST
            WHERE     GLST.LEDGER_ID = :P_LEDGER_ID
                  AND GLST.VOUCHER_DATE < :P_FROM_DATE
         --AND JE_SOURCE != 'OPM_INV'
         GROUP BY ACCOUNT,
                  ACCTDESC,
                  PARTY_CODE,
                  PARTY_NAME,
                  JE_SOURCE
         UNION ALL
           SELECT JE_SOURCE,
                  2 ORD,
                  ACCOUNT,
                  ACCTDESC,
                  PARTY_CODE,
                  PARTY_NAME VENDOR_NAME,
                  0 OPENING_BALANCE,
                  SUM (NVL (DEBITS, 0)) DEBITS,
                  SUM (NVL (CREDITS, 0)) CREDITS
             FROM XX_GL_DETAILS_STATEMENT_V_2 GLST
            WHERE     GLST.LEDGER_ID = :P_LEDGER_ID
                  AND GLST.VOUCHER_DATE BETWEEN :P_FROM_DATE AND :P_TO_DATE
         --AND JE_SOURCE != 'OPM_INV'
         GROUP BY ACCOUNT,
                  ACCTDESC,
                  PARTY_CODE,
                  PARTY_NAME,
                  JE_SOURCE)
  SELECT ACCOUNT,
         ACCTDESC,
         PARTY_CODE CUSTOMER_NUMBER,
         CASE
            WHEN JE_SOURCE = 'Carry Forward' AND VENDOR_NAME IS NULL
            THEN
               'Opening Balance'
            WHEN JE_SOURCE = 'CM' AND VENDOR_NAME IS NULL
            THEN
               'Cash Management'
            WHEN JE_SOURCE = 'FA' AND VENDOR_NAME IS NULL
            THEN
               'Fixed Asset'
            WHEN JE_SOURCE = 'INV' AND VENDOR_NAME IS NULL
            THEN
               'Inventory'
            WHEN JE_SOURCE = 'Manual' AND VENDOR_NAME IS NULL
            THEN
               'General Ledger'
            WHEN     JE_SOURCE NOT IN ('Carry Forward',
                                       'CM',
                                       'FA',
                                       'INV',
                                       'Manual')
                 AND VENDOR_NAME IS NULL
            THEN
               JE_SOURCE
            ELSE
               VENDOR_NAME
         END
            CUSTOMER_NAME,
         SUM (OPENING_BALANCE) OPENING_BALANCE,
         SUM (DEBITS) DR_AMOUNT,
         SUM (CREDITS) CR_AMOUNT
    FROM XX_WITH_CLAUSE_TAB T, RG_REPORT_AXIS_CONTENTS RAC, RG_REPORT_AXES RRA
   WHERE     RAC.AXIS_SET_ID = RRA.AXIS_SET_ID
         AND RAC.AXIS_SEQ = RRA.AXIS_SEQ
         AND RRA.AXIS_SET_ID = 4007
         AND RRA.AXIS_SEQ = :P_AXIS_SEQ
         AND T.ACCOUNT BETWEEN SEGMENT5_LOW AND SEGMENT5_HIGH
GROUP BY ACCOUNT,
         ACCTDESC,
         PARTY_CODE,
         VENDOR_NAME,
         CASE
            WHEN JE_SOURCE = 'Carry Forward' AND VENDOR_NAME IS NULL
            THEN
               'Opening Balance'
            WHEN JE_SOURCE = 'CM' AND VENDOR_NAME IS NULL
            THEN
               'Cash Management'
            WHEN JE_SOURCE = 'FA' AND VENDOR_NAME IS NULL
            THEN
               'Fixed Asset'
            WHEN JE_SOURCE = 'INV' AND VENDOR_NAME IS NULL
            THEN
               'Inventory'
            WHEN JE_SOURCE = 'Manual' AND VENDOR_NAME IS NULL
            THEN
               'General Ledger'
            WHEN     JE_SOURCE NOT IN ('Carry Forward',
                                       'CM',
                                       'FA',
                                       'INV',
                                       'Manual')
                 AND VENDOR_NAME IS NULL
            THEN
               JE_SOURCE
            ELSE
               VENDOR_NAME
         END
  --HAVING SUM (OPENING_BALANCE) + SUM (DEBITS) + SUM (CREDITS) <> 0
ORDER BY 1,
         2,
         3,
         5;