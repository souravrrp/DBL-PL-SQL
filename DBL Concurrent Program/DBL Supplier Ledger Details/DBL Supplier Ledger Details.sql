/* Formatted on 9/2/2021 10:02:41 AM (QP5 v5.354) */
  SELECT 1
             SL,
         XX_AP_SUPPLIER_LEDGER_V.LEGAL_ENTITY_ID,
         XX_AP_SUPPLIER_LEDGER_V.ORG_ID
             ORG_ID,
         AB.LEGAL_ENTITY_NAME,
         HOU.NAME
             ORGANIZATION_NAME,
         NULL
             INV_TYPE,
         NULL
             COMPANY,
         NULL
             ACCOUNTING_DATE,
         APPS.XX_AP_PKG.GET_VENDOR_NUMBER_FROM_ID ( :P_VENDOR_ID)
             PARTY_NUM,
         APPS.XX_AP_PKG.GET_VENDOR_NAME ( :P_VENDOR_ID)
             PARTY_NAME,
         NULL
             INVOICE_NUM,
         NULL
             VOUCHER,
         'Opening Balance'
             DESCRIPTION,
         NULL
             GL_CODE_AND_DESC,
         NULL
             DR_AMOUNT,
         NULL
             CR_AMOUNT,
         (NVL (SUM (CR_AMOUNT), 0) - NVL (SUM (DR_AMOUNT), 0))
             BALANCE
    FROM APPS.XX_AP_SUPPLIER_LEDGER_V,
         APPS.HR_OPERATING_UNITS        HOU,
         apps.xxdbl_company_le_mapping_v AB
   WHERE     XX_AP_SUPPLIER_LEDGER_V.ORG_ID = HOU.ORGANIZATION_ID
         AND XX_AP_SUPPLIER_LEDGER_V.ORG_ID = AB.ORG_ID
         AND ( :P_ORG_ID IS NULL OR XX_AP_SUPPLIER_LEDGER_V.ORG_ID = :P_ORG_ID)
         AND VENDOR_ID = :P_VENDOR_ID
         AND XX_AP_SUPPLIER_LEDGER_V.LEGAL_ENTITY_ID = :P_LEGAL
         AND ACCOUNTING_DATE < :P_DATE_FROM
GROUP BY XX_AP_SUPPLIER_LEDGER_V.ORG_ID,
         HOU.NAME,
         XX_AP_SUPPLIER_LEDGER_V.LEGAL_ENTITY_ID,
         AB.LEGAL_ENTITY_NAME
UNION ALL
SELECT 2                                                  SL,
       XX_AP_SUPPLIER_LEDGER_V.LEGAL_ENTITY_ID,
       XX_AP_SUPPLIER_LEDGER_V.ORG_ID                     ORG_ID,
       AB.LEGAL_ENTITY_NAME,
       HOU.NAME                                           ORGANIZATION_NAME,
       INV_TYPE                                           INV_TYPE,
       BAL_SEG || '-' || BAL_SEG_NAME                     COMPANY,
       ACCOUNTING_DATE,
       PARTY_NUM,
       APPS.XX_AP_PKG.GET_VENDOR_NAME ( :P_VENDOR_ID)     PARTY_NAME,
       INVOICE_NUM,
       VOUCHER,
       DESCRIPTION,
       GL_CODE_AND_DESC,
       DR_AMOUNT,
       CR_AMOUNT,
       (NVL (CR_AMOUNT, 0) - NVL (DR_AMOUNT, 0))
  FROM XX_AP_SUPPLIER_LEDGER_V,
       HR_OPERATING_UNITS               HOU,
       apps.xxdbl_company_le_mapping_v  AB
 WHERE     XX_AP_SUPPLIER_LEDGER_V.ORG_ID = HOU.ORGANIZATION_ID
       AND XX_AP_SUPPLIER_LEDGER_V.ORG_ID = AB.ORG_ID
       AND ( :P_ORG_ID IS NULL OR XX_AP_SUPPLIER_LEDGER_V.ORG_ID = :P_ORG_ID)
       AND VENDOR_ID = :P_VENDOR_ID
       AND XX_AP_SUPPLIER_LEDGER_V.LEGAL_ENTITY_ID = :P_LEGAL
       AND ACCOUNTING_DATE BETWEEN :P_DATE_FROM AND :P_DATE_TO
ORDER BY SL, ACCOUNTING_DATE, VOUCHER