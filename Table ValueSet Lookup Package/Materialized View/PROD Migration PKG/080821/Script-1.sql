/* Formatted on 8/8/2021 5:39:49 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW APPS.XXDBL_GL_DTL_STAT_SUM_MV#
(
    SL,
    APPLICATION_ID,
    JE_SOURCE,
    JE_CATEGORY,
    COMPANY,
    ACCOUNT,
    ACCTDESC,
    VOUCHER_NUMBER,
    VOUCHER_DATE,
    DESCRIPTION,
    ENTERED_DEBITS,
    ENTERED_CREDITS,
    DEBITS,
    CREDITS,
    PARTY_CODE,
    PARTY_NAME,
    LEDGER_ID
)
BEQUEATH DEFINER
AS
    SELECT 1                              SL,
           101                            APPLICATION_ID,
           SRC.USER_JE_SOURCE_NAME        JE_SOURCE,
           CAT.NAME                       JE_CATEGORY,
           CC.SEGMENT1                    COMPANY,
           CC.SEGMENT5                    ACCOUNT,
           FLEX.DESCRIPTION               ACCTDESC,
           GJH.DOC_SEQUENCE_VALUE         VOUCHER_NUMBER,
           GJH.DEFAULT_EFFECTIVE_DATE     VOUCHER_DATE,
           GJL.DESCRIPTION,
           NVL (GJL.ENTERED_DR, 0)        ENTERED_DEBITS,
           NVL (GJL.ENTERED_CR, 0)        ENTERED_CREDITS,
           NVL (GJL.ACCOUNTED_DR, 0)      DEBITS,
           NVL (GJL.ACCOUNTED_CR, 0)      CREDITS,
           NULL                           PARTY_CODE,
           NULL                           PARTY_NAME,
           GJH.LEDGER_ID
      FROM GL_JE_HEADERS                GJH,
           APPS.GL_JE_LINES             GJL,
           FND_DOC_SEQUENCE_CATEGORIES  CAT,
           GL_JE_SOURCES_TL             SRC,
           APPS.GL_CODE_COMBINATIONS    CC,
           FND_FLEX_VALUES_VL           FLEX
     WHERE     GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
           AND GJH.JE_CATEGORY = CAT.CODE
           AND CAT.APPLICATION_ID = 101
           AND GJH.JE_SOURCE = SRC.JE_SOURCE_NAME
           AND (   NVL (GJL.ACCOUNTED_DR, 0) <> 0
                OR NVL (GJL.ACCOUNTED_CR, 0) <> 0)
           AND GJL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND NVL (GJH.JE_FROM_SLA_FLAG, 'N') <> 'Y'
           AND GJL.STATUS = 'P'
           AND GJH.ACTUAL_FLAG = 'A'
    UNION ALL
    SELECT 2
               SL,
           222
               APPLICATION_ID,
           'AR'
               JE_SOURCE,
           GJH.JE_CATEGORY,
           CC.SEGMENT1
               COMPANY,
           CC.SEGMENT5
               ACCOUNT,
           FLEX.DESCRIPTION
               ACCTDESC,
           XAH.DOC_SEQUENCE_VALUE
               VOUCHER_NUMBER,
           XAH.ACCOUNTING_DATE
               VOUCHER_DATE,
           ('Cust-' || CUST.CUSTOMER_NUMBER || ' Trx No-' || CT.TRX_NUMBER)
               PARTICULARS,
           NVL (XAL.ENTERED_DR, 0)
               ENTERED_DEBITS,
           NVL (XAL.ENTERED_CR, 0)
               ENTERED_CREDITS,
           XAL.ACCOUNTED_DR,
           XAL.ACCOUNTED_CR,
           CUST.CUSTOMER_NUMBER
               PARTY_CODE,
           CUST.CUSTOMER_NAME
               PARTY_NAME,
           GJH.LEDGER_ID
      FROM XX_AR_CUSTOMER_SITE_V         CUST,
           RA_CUSTOMER_TRX_ALL           CT,
           XLA.XLA_TRANSACTION_ENTITIES  XTE,
           XLA_AE_HEADERS                XAH,
           XLA_AE_LINES                  XAL,
           GL_IMPORT_REFERENCES          GIR,
           GL_JE_HEADERS                 GJH,
           GL_JE_LINES                   GJL,
           GL_CODE_COMBINATIONS          CC,
           FND_FLEX_VALUES_VL            FLEX
     WHERE     CUST.CUSTOMER_ID = CT.BILL_TO_CUSTOMER_ID
           AND CT.CUSTOMER_TRX_ID(+) = XTE.SOURCE_ID_INT_1
           AND CUST.ORG_ID = XTE.SECURITY_ID_INT_1
           AND XTE.ENTITY_CODE IN ('TRANSACTIONS')
           AND XTE.ENTITY_ID = XAH.ENTITY_ID
           AND XTE.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID = 222
           AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
           AND XAH.APPLICATION_ID = XAL.APPLICATION_ID
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND GIR.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND (   NVL (XAL.ACCOUNTED_DR, 0) <> 0
                OR NVL (XAL.ACCOUNTED_CR, 0) <> 0)
           AND GJL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJL.STATUS = 'P'
           AND CUST.SITE_USE_CODE = 'BILL_TO'
           AND CUST.PRIMARY_FLAG = 'Y'
    UNION ALL
    SELECT 3
               SL,
           222
               APPLICATION_ID,
           'AR'
               JE_SOURCE,
           GJH.JE_CATEGORY,
           CC.SEGMENT1
               COMPANY,
           CC.SEGMENT5
               ACCOUNT,
           FLEX.DESCRIPTION
               ACCTDESC,
           GJH.DOC_SEQUENCE_VALUE
               VOUCHER_NUMBER,
           XAH.ACCOUNTING_DATE
               VOUCHER_DATE,
           ('Cust-' || CUST.CUSTOMER_NUMBER || ' Trx No-' || CT.TRX_NUMBER)
               PARTICULARS,
           NVL (XAL.ENTERED_DR, 0)
               ENTERED_DEBITS,
           NVL (XAL.ENTERED_CR, 0)
               ENTERED_CREDITS,
           XAL.ACCOUNTED_DR,
           XAL.ACCOUNTED_CR,
           CUST.CUSTOMER_NUMBER
               PARTY_CODE,
           CUST.CUSTOMER_NAME
               PARTY_NAME,
           GJH.LEDGER_ID
      FROM XX_AR_CUSTOMER_SITE_V         CUST,
           RA_CUSTOMER_TRX_ALL           CT,
           XLA.XLA_TRANSACTION_ENTITIES  XTE,
           XLA_AE_HEADERS                XAH,
           XLA_AE_LINES                  XAL,
           GL_IMPORT_REFERENCES          GIR,
           GL_JE_HEADERS                 GJH,
           GL_JE_LINES                   GJL,
           GL_CODE_COMBINATIONS          CC,
           FND_FLEX_VALUES_VL            FLEX
     WHERE     CUST.CUSTOMER_ID = CT.DRAWEE_ID
           AND CT.CUSTOMER_TRX_ID(+) = XTE.SOURCE_ID_INT_1
           AND CUST.ORG_ID = XTE.SECURITY_ID_INT_1
           AND XTE.ENTITY_CODE IN ('BILLS_RECEIVABLE')
           AND XTE.ENTITY_ID = XAH.ENTITY_ID
           AND XTE.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID = 222
           AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
           AND XAH.APPLICATION_ID = XAL.APPLICATION_ID
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND GIR.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND (   NVL (XAL.ACCOUNTED_DR, 0) <> 0
                OR NVL (XAL.ACCOUNTED_CR, 0) <> 0)
           AND GJL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJL.STATUS = 'P'
           AND CUST.SITE_USE_CODE = 'BILL_TO'
           AND CUST.PRIMARY_FLAG = 'Y'
    UNION ALL
    SELECT 4
               SL,
           222
               APPLICATION_ID,
           'AR'
               JE_SOURCE,
           GJH.JE_CATEGORY,
           CC.SEGMENT1
               COMPANY,
           CC.SEGMENT5
               ACCOUNT,
           FLEX.DESCRIPTION
               ACCTDESC,
           XAH.DOC_SEQUENCE_VALUE
               VOUCHER_NUMBER,
           XAH.ACCOUNTING_DATE
               VOUCHER_DATE,
           ('Cust-' || CUST.CUSTOMER_NUMBER || ' Trx No-' || CT.TRX_NUMBER)
               PARTICULARS,
           NVL (XAL.ENTERED_DR, 0)
               ENTERED_DEBITS,
           NVL (XAL.ENTERED_CR, 0)
               ENTERED_CREDITS,
           XAL.ACCOUNTED_DR,
           XAL.ACCOUNTED_CR,
           CUST.CUSTOMER_NUMBER
               PARTY_CODE,
           CUST.CUSTOMER_NAME
               PARTY_NAME,
           GJH.LEDGER_ID
      FROM XX_AR_CUSTOMER_SITE_V         CUST,
           RA_CUSTOMER_TRX_ALL           CT,
           AR_ADJUSTMENTS_ALL            ADJ,
           XLA.XLA_TRANSACTION_ENTITIES  XTE,
           XLA_AE_HEADERS                XAH,
           XLA_AE_LINES                  XAL,
           GL_IMPORT_REFERENCES          GIR,
           GL_JE_HEADERS                 GJH,
           GL_JE_LINES                   GJL,
           GL_CODE_COMBINATIONS          CC,
           FND_FLEX_VALUES_VL            FLEX
     WHERE     CUST.CUSTOMER_ID = CT.BILL_TO_CUSTOMER_ID
           AND CT.CUSTOMER_TRX_ID = ADJ.CUSTOMER_TRX_ID
           AND ADJ.ADJUSTMENT_ID(+) = XTE.SOURCE_ID_INT_1
           AND CUST.ORG_ID = XTE.SECURITY_ID_INT_1
           AND XTE.ENTITY_CODE IN ('ADJUSTMENTS')
           AND XTE.ENTITY_ID = XAH.ENTITY_ID
           AND XTE.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID = 222
           AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
           AND XAH.APPLICATION_ID = XAL.APPLICATION_ID
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND GIR.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND (   NVL (XAL.ACCOUNTED_DR, 0) <> 0
                OR NVL (XAL.ACCOUNTED_CR, 0) <> 0)
           AND GJL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJL.STATUS = 'P'
           AND CUST.SITE_USE_CODE = 'BILL_TO'
           AND CUST.PRIMARY_FLAG = 'Y'
    UNION ALL
    SELECT 5                          SL,
           222                        APPLICATION_ID,
           'AR'                       JE_SOURCE,
           GJH.JE_CATEGORY,
           CC.SEGMENT1                COMPANY,
           CC.SEGMENT5                ACCOUNT,
           FLEX.DESCRIPTION           ACCTDESC,
           XAH.DOC_SEQUENCE_VALUE     VOUCHER_NUMBER,
           XAH.ACCOUNTING_DATE        VOUCHER_DATE,
           (   'Cust-'
            || CUST.CUSTOMER_NUMBER
            || ' Rcv No-'
            || CR.RECEIPT_NUMBER)     PARTICULARS,
           NVL (XAL.ENTERED_DR, 0)    ENTERED_DEBITS,
           NVL (XAL.ENTERED_CR, 0)    ENTERED_CREDITS,
           XAL.ACCOUNTED_DR,
           XAL.ACCOUNTED_CR,
           CUST.CUSTOMER_NUMBER       PARTY_CODE,
           CUST.CUSTOMER_NAME         PARTY_NAME,
           GJH.LEDGER_ID
      FROM XX_AR_CUSTOMER_SITE_V         CUST,
           AR_CASH_RECEIPTS_ALL          CR,
           XLA.XLA_TRANSACTION_ENTITIES  XTE,
           XLA_AE_HEADERS                XAH,
           XLA_AE_LINES                  XAL,
           GL_IMPORT_REFERENCES          GIR,
           GL_JE_HEADERS                 GJH,
           GL_JE_LINES                   GJL,
           GL_CODE_COMBINATIONS          CC,
           FND_FLEX_VALUES_VL            FLEX
     WHERE     CUST.CUSTOMER_ID(+) = CR.PAY_FROM_CUSTOMER
           AND CUST.ORG_ID(+) = CR.ORG_ID
           AND CR.CASH_RECEIPT_ID = XTE.SOURCE_ID_INT_1
           AND XTE.ENTITY_ID = XAH.ENTITY_ID
           AND XTE.ENTITY_CODE = 'RECEIPTS'
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XTE.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID = 222
           AND XAH.APPLICATION_ID = XAL.APPLICATION_ID
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND GIR.JE_HEADER_ID = GJH.JE_HEADER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND NVL (NVL (XAL.ACCOUNTED_DR, XAL.ACCOUNTED_CR), 0) <> 0
           AND GJL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJL.STATUS = 'P'
           AND CUST.SITE_USE_CODE(+) = 'BILL_TO'
           AND CUST.PRIMARY_FLAG(+) = 'Y'
    UNION ALL
    SELECT 6                           SL,
           200                         APPLICATION_ID,
           'AP'                        JE_SOURCE,
           GJH.JE_CATEGORY,
           CC.SEGMENT1                 COMPANY,
           CC.SEGMENT5                 ACCOUNT,
           FLEX.DESCRIPTION            ACCTDESC,
           XAH.DOC_SEQUENCE_VALUE      VOUCHER_NUMBER,
           XAL.ACCOUNTING_DATE         VOUCHER_DATE,
           XAL.DESCRIPTION             PARTICULARS,
           NVL (XAL.ENTERED_DR, 0)     ENTERED_DEBITS,
           NVL (XAL.ENTERED_CR, 0)     ENTERED_CREDITS,
           XAL.ACCOUNTED_DR,
           XAL.ACCOUNTED_CR,
           APS.SEGMENT1                PARTY_CODE,
           APS.VENDOR_NAME             PARTY_NAME,
           GJH.LEDGER_ID
      FROM AP_SUPPLIERS                  APS,
           AP_INVOICES_ALL               API,
           XLA.XLA_TRANSACTION_ENTITIES  XTE,
           XLA_AE_HEADERS                XAH,
           XLA_AE_LINES                  XAL,
           GL_IMPORT_REFERENCES          GIR,
           GL_JE_HEADERS                 GJH,
           GL_JE_LINES                   GJL,
           GL_CODE_COMBINATIONS          CC,
           FND_FLEX_VALUES_VL            FLEX
     WHERE     NVL (APS.VENDOR_ID(+), -222) = API.VENDOR_ID
           AND API.INVOICE_ID = XTE.SOURCE_ID_INT_1
           AND XTE.ENTITY_ID = XAH.ENTITY_ID
           AND XTE.ENTITY_CODE = 'AP_INVOICES'
           AND XTE.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID = 200
           AND XAH.APPLICATION_ID = XAL.APPLICATION_ID
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.GL_SL_LINK_ID = GIR.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE IN ('APECL', 'XLAJEL')
           AND GJH.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND (   NVL (XAL.ACCOUNTED_DR, 0) <> 0
                OR NVL (XAL.ACCOUNTED_CR, 0) <> 0)
           AND XAL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJL.STATUS = 'P'
    UNION ALL
    SELECT 7                           SL,
           200                         APPLICATION_ID,
           'AP'                        JE_SOURCE,
           GJH.JE_CATEGORY,
           CC.SEGMENT1                 COMPANY,
           CC.SEGMENT5                 ACCOUNT,
           FLEX.DESCRIPTION            ACCTDESC,
           XAH.DOC_SEQUENCE_VALUE      VOUCHER_NUMBER,
           --          GJH.DOC_SEQUENCE_VALUE GL_VOUCHER_NUMBER,
           XAL.ACCOUNTING_DATE         VOUCHER_DATE,
           APC.DESCRIPTION             PARTICULARS,
           NVL (XAL.ENTERED_DR, 0)     ENTERED_DEBITS,
           NVL (XAL.ENTERED_CR, 0)     ENTERED_CREDITS,
           XAL.ACCOUNTED_DR,
           XAL.ACCOUNTED_CR,
           APS.SEGMENT1                PARTY_CODE,
           APS.VENDOR_NAME             PARTY_NAME,
           GJH.LEDGER_ID
      FROM AP_CHECKS_ALL                 APC,
           AP_SUPPLIERS                  APS,
           XLA.XLA_TRANSACTION_ENTITIES  XTE,
           XLA_AE_HEADERS                XAH,
           XLA_AE_LINES                  XAL,
           GL_IMPORT_REFERENCES          GIR,
           GL_JE_HEADERS                 GJH,
           GL_JE_LINES                   GJL,
           GL_CODE_COMBINATIONS          CC,
           FND_FLEX_VALUES_VL            FLEX
     WHERE     APC.VENDOR_ID = NVL (APS.VENDOR_ID(+), -222)
           AND APC.CHECK_ID = XTE.SOURCE_ID_INT_1
           AND XTE.ENTITY_CODE = 'AP_PAYMENTS'
           AND XTE.ENTITY_ID = XAH.ENTITY_ID
           AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
           AND XTE.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID = 200
           AND XAH.APPLICATION_ID = XAL.APPLICATION_ID
           AND XAL.GL_SL_LINK_ID = GIR.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE IN ('APECL', 'XLAJEL')
           AND GJH.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GIR.JE_HEADER_ID = GJL.JE_HEADER_ID
           AND GIR.JE_LINE_NUM = GJL.JE_LINE_NUM
           AND (   NVL (XAL.ACCOUNTED_DR, 0) <> 0
                OR NVL (XAL.ACCOUNTED_CR, 0) <> 0)
           AND GJL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJL.STATUS = 'P'
    UNION ALL
    SELECT 8                             SL,
           260                           APPLICATION_ID,
           'CM'                          JE_SOURCE,
           GJH.JE_CATEGORY,
           CC.SEGMENT1                   COMPANY,
           CC.SEGMENT5                   ACCOUNT,
           FLEX.DESCRIPTION              ACCTDESC,
           CPT.TRXN_REFERENCE_NUMBER     VOUCHER_NUMBER,
           XEL.ACCOUNTING_DATE           VOUCHER_DATE,
           NULL                          PARTICULARS,
           NVL (XEL.ENTERED_DR, 0)       ENTERED_DEBITS,
           NVL (XEL.ENTERED_CR, 0)       ENTERED_CREDITS,
           XEL.ACCOUNTED_DR,
           XEL.ACCOUNTED_CR,
           NULL                          PARTY_CODE,
           NULL                          PARTY_NAME,
           GJH.LEDGER_ID
      FROM GL_JE_LINES                   GLL,
           GL_JE_HEADERS                 GJH,
           GL_IMPORT_REFERENCES          GIR,
           XLA_AE_LINES                  XEL,
           XLA_AE_HEADERS                XEH,
           CE_PAYMENT_TRANSACTIONS       CPT,
           CE_CASHFLOWS                  CFLOW,
           XLA.XLA_TRANSACTION_ENTITIES  XTE,
           GL_CODE_COMBINATIONS          CC,
           FND_FLEX_VALUES_VL            FLEX
     WHERE     XTE.APPLICATION_ID = 260
           AND XEL.APPLICATION_ID = XEH.APPLICATION_ID
           AND XTE.APPLICATION_ID = XEH.APPLICATION_ID
           AND XEL.AE_HEADER_ID = XEH.AE_HEADER_ID
           AND XTE.ENTITY_CODE = 'CE_CASHFLOWS'
           AND XTE.SOURCE_ID_INT_1 = CFLOW.CASHFLOW_ID
           AND CPT.TRXN_REFERENCE_NUMBER = CFLOW.TRXN_REFERENCE_NUMBER
           AND XTE.ENTITY_ID = XEH.ENTITY_ID
           AND XEL.GL_SL_LINK_ID = GIR.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE IN ('XLAJEL')
           AND GJH.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GIR.JE_HEADER_ID = GLL.JE_HEADER_ID
           AND GIR.JE_LINE_NUM = GLL.JE_LINE_NUM
           AND (   NVL (XEL.ACCOUNTED_DR, 0) <> 0
                OR NVL (XEL.ACCOUNTED_CR, 0) <> 0)
           AND GLL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND GJH.ACTUAL_FLAG = 'A'
           AND GLL.STATUS = 'P'
    UNION ALL
    SELECT 9                           SL,
           140                         APPLICATION_ID,
           'FA'                        JE_SOURCE,
           GJH.JE_CATEGORY,
           CC.SEGMENT1                 COMPANY,
           CC.SEGMENT5                 ACCOUNT,
           FLEX.DESCRIPTION            ACCTDESC,
           GJH.DOC_SEQUENCE_VALUE      VOUCHER_NUMBER,
           GJL.EFFECTIVE_DATE          VOUCHER_DATE,
           XAL.DESCRIPTION             PARTICULARS,
           NVL (XAL.ENTERED_DR, 0)     ENTERED_DEBITS,
           NVL (XAL.ENTERED_CR, 0)     ENTERED_CREDITS,
           XAL.ACCOUNTED_DR,
           XAL.ACCOUNTED_CR,
           NULL,
           NULL,
           GJH.LEDGER_ID
      FROM XLA.XLA_TRANSACTION_ENTITIES  XTE,
           XLA_AE_HEADERS                XAH,
           XLA_AE_LINES                  XAL,
           GL_IMPORT_REFERENCES          GIR,
           GL_JE_HEADERS                 GJH,
           GL_JE_LINES                   GJL,
           GL_CODE_COMBINATIONS          CC,
           FND_FLEX_VALUES_VL            FLEX
     WHERE     XTE.ENTITY_ID = XAH.ENTITY_ID
           AND XTE.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID = 140
           AND XAH.APPLICATION_ID = XAL.APPLICATION_ID
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.GL_SL_LINK_ID = GIR.GL_SL_LINK_ID
           AND GJH.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND (   NVL (XAL.ACCOUNTED_DR, 0) <> 0
                OR NVL (XAL.ACCOUNTED_CR, 0) <> 0)
           AND XAL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJL.STATUS = 'P'
    UNION ALL
    SELECT 10
               SL,
           XAL.APPLICATION_ID,
           'DIS_INV'
               JE_SOURCE,
           GJH.JE_CATEGORY,
           CC.SEGMENT1
               COMPANY,
           CC.SEGMENT5
               ACCOUNT,
           FLEX.DESCRIPTION
               ACCTDESC,
           --          NVL (
           --             TO_NUMBER (APPS.XX_GET_RCV_NUMBER_FROM_TRX_ID (SOURCE_ID_INT_1)),
           --             GJH.DOC_SEQUENCE_VALUE)
           --             VOUCHER_NUMBER,
           GJH.DOC_SEQUENCE_VALUE
               VOUCHER_NUMBER,
           GJL.EFFECTIVE_DATE
               VOUCHER_DATE,
           XAL.DESCRIPTION
               PARTICULARS,
           NVL (XAL.ENTERED_DR, 0)
               ENTERED_DEBITS,
           NVL (XAL.ENTERED_CR, 0)
               ENTERED_CREDITS,
           XAL.ACCOUNTED_DR,
           XAL.ACCOUNTED_CR,
           -- APPS.XX_GET_LC_NUMBER_FROM_TRX_ID (SOURCE_ID_INT_1) CHEQUE_NUMBER,
           --TRUNC (SYSDATE) CHEQUE_DATE,
           APPS.XX_GET_VENDOR_CODE_FROM_TRX_ID (SOURCE_ID_INT_1)
               PARTY_CODE,
           APPS.XX_GET_VENDOR_NAME_FROM_TRX_ID (SOURCE_ID_INT_1)
               PARTY_NAME,
           --XTE.ENTITY_CODE TRANSACTION_TYPE,
           -- CC.CHART_OF_ACCOUNTS_ID,
           GJH.LEDGER_ID
      FROM XLA.XLA_TRANSACTION_ENTITIES  XTE,
           XLA_AE_HEADERS                XAH,
           XLA_AE_LINES                  XAL,
           GL_IMPORT_REFERENCES          GIR,
           GL_JE_HEADERS                 GJH,
           GL_JE_LINES                   GJL,
           GL_CODE_COMBINATIONS          CC,
           FND_FLEX_VALUES_VL            FLEX,
           MTL_MATERIAL_TRANSACTIONS     MMT
     WHERE     XTE.ENTITY_ID = XAH.ENTITY_ID
           AND XTE.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID NOT IN (140,
                                          200,
                                          222,
                                          260,
                                          555)
           AND XAH.APPLICATION_ID = XAL.APPLICATION_ID
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.GL_SL_LINK_ID = GIR.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE IN ('APECL', 'XLAJEL')
           AND GJH.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND (   NVL (XAL.ACCOUNTED_DR, 0) <> 0
                OR NVL (XAL.ACCOUNTED_CR, 0) <> 0)
           AND XAL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJL.STATUS = 'P'
           AND XTE.SOURCE_ID_INT_1 = MMT.TRANSACTION_ID(+)
    UNION ALL
      SELECT 11                          SL,
             XAL.APPLICATION_ID,
             'OPM_INV_RCV'               JE_SOURCE,
             XAH.JE_CATEGORY_NAME        JE_CATEGORY,
             CC.SEGMENT1                 COMPANY,
             CC.SEGMENT5                 ACCOUNT,
             FLEX.DESCRIPTION            ACCTDESC,
             GEH.TRANSACTION_ID          VOUCHER_NUMBER,
             --            GJH.DOC_SEQUENCE_VALUE GL_VOUCHER_NUMBER,
             --            GJL.JE_LINE_NUM GL_JE_LINE_NUM,
             XAL.ACCOUNTING_DATE         VOUCHER_DATE,
             NULL                        PARTICULARS,
             NVL (XAL.ENTERED_DR, 0)     ENTERED_DEBITS,
             NVL (XAL.ENTERED_CR, 0)     ENTERED_CREDITS,
             SUM (XAL.ACCOUNTED_DR)      ACCOUNTED_DR,
             XAL.ACCOUNTED_CR,
             -- NULL CHEQUE_NUMBER,
             -- TRUNC (SYSDATE) CHEQUE_DATE,
             APS.SEGMENT1                PARTY_CODE,
             APS.VENDOR_NAME             PARTY_NAME,
             -- ENTITY_CODE TRANSACTION_TYPE,
             --CC.CHART_OF_ACCOUNTS_ID,
             GJH.LEDGER_ID
        FROM APPS.XLA_AE_LINES                XAL,
             APPS.XLA_AE_HEADERS              XAH,
             APPS.GL_IMPORT_REFERENCES        GIR,
             APPS.GL_JE_LINES                 GJL,
             APPS.GL_JE_HEADERS               GJH,
             APPS.FND_DOC_SEQUENCE_CATEGORIES CAT,
             APPS.GL_CODE_COMBINATIONS        CC,
             APPS.FND_FLEX_VALUES_VL          FLEX,
             APPS.MTL_SYSTEM_ITEMS_B          MST,
             APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
             APPS.MTL_ITEM_CATEGORIES         MIC,
             APPS.MTL_CATEGORIES_B            MCB,
             APPS.GMF_XLA_EXTRACT_HEADERS     GEH,
             APPS.GMF_XLA_EXTRACT_LINES       GEL,
             APPS.XLA_DISTRIBUTION_LINKS      XDL,
             APPS.RCV_TRANSACTIONS            RT,
             APPS.RCV_SHIPMENT_HEADERS        RSH,
             APPS.RCV_SHIPMENT_LINES          RSL,
             APPS.AP_SUPPLIERS                APS
       WHERE     XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
             AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
             AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
             AND XAL.GL_SL_LINK_ID = GIR.GL_SL_LINK_ID
             AND GIR.GL_SL_LINK_TABLE IN ('APECL', 'XLAJEL')
             AND GIR.JE_HEADER_ID = GJL.JE_HEADER_ID
             AND GIR.JE_LINE_NUM = GJL.JE_LINE_NUM
             AND GIR.JE_HEADER_ID = GJH.JE_HEADER_ID
             AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
             AND GJL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
             AND GJH.JE_CATEGORY = CAT.CODE
             AND CAT.APPLICATION_ID = 101
             AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
             AND GEH.ORGANIZATION_ID = MST.ORGANIZATION_ID
             AND GEH.INVENTORY_ITEM_ID = MST.INVENTORY_ITEM_ID
             AND GEH.ORGANIZATION_ID = ORG.ORGANIZATION_ID
             AND MIC.INVENTORY_ITEM_ID = MST.INVENTORY_ITEM_ID
             AND MIC.ORGANIZATION_ID = MST.ORGANIZATION_ID
             AND MCB.STRUCTURE_ID = 101
             AND MCB.CATEGORY_ID = MIC.CATEGORY_ID
             AND GJH.ACTUAL_FLAG = 'A'
             AND GJL.STATUS = 'P'
             AND (   NVL (XAL.ACCOUNTED_DR, 0) <> 0
                  OR NVL (XAL.ACCOUNTED_CR, 0) <> 0)
             AND GEH.HEADER_ID = GEL.HEADER_ID
             AND GEH.EVENT_ID = GEL.EVENT_ID
             AND XDL.SOURCE_DISTRIBUTION_TYPE = GEH.ENTITY_CODE
             AND XDL.EVENT_ID = GEH.EVENT_ID
             AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 = GEL.LINE_ID
             AND XDL.APPLICATION_ID = 555
             AND CATEGORY_SET_ID = 1
             AND GEH.SOURCE_LINE_ID(+) = RT.TRANSACTION_ID
             AND RSH.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
             AND RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID
             AND RSL.SHIPMENT_LINE_ID = RT.SHIPMENT_LINE_ID
             AND APS.VENDOR_ID = RSH.VENDOR_ID
             AND GEH.ENTITY_CODE = 'PURCHASING'
    GROUP BY XAL.APPLICATION_ID,
             'OPM_INV_RCV',
             XAH.JE_CATEGORY_NAME,
             CC.SEGMENT1,
             CC.SEGMENT5,
             FLEX.DESCRIPTION,
             TO_CHAR (NULL),
             GEH.TRANSACTION_ID,
             XAL.ACCOUNTING_DATE,
             NULL,
             NVL (XAL.ENTERED_DR, 0),
             NVL (XAL.ENTERED_CR, 0),
             XAL.ACCOUNTED_CR,
             NULL,
             TRUNC (SYSDATE),
             APS.SEGMENT1,
             APS.VENDOR_NAME,
             ENTITY_CODE,
             CC.CHART_OF_ACCOUNTS_ID,
             GJH.LEDGER_ID;