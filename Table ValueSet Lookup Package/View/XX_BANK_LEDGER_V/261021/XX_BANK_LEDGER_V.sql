/* Formatted on 10/26/2021 3:35:50 PM (QP5 v5.365) */
CREATE OR REPLACE FORCE VIEW APPS.XX_BANK_LEDGER_V
(
    SOURCE,
    ORG_ID,
    LE_ID,
    BANK_ID,
    BANK_NAME,
    BRANCH_ID,
    BRANCH_NAME,
    ACCOUNT_TYPE,
    ACCOUNT_ID,
    ACCOUNT_NUM,
    ACCOUNT_NAME,
    CHEQUE_NUM,
    CHECK_DATE,
    CLEARED_DATE,
    VOID_DATE,
    VOUCHER,
    STATUS,
    PARTY_NAME,
    DESCRIPTION,
    CURRENCY_CODE,
    ENTERED_DR,
    ENTERED_CR,
    DR_AMOUNT,
    CR_AMOUNT,
    BANK_CCID,
    GL_CODE
)
BEQUEATH DEFINER
AS
    SELECT 'OB',                                                       --1 SL,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           NULL,
           NVL (ba.start_date, '30-SEP-2017'),
           NVL (ba.start_date, '30-SEP-2017'),
           NULL,
           NULL,
           'CLEARED',
           'Opening',
           'Balance B/F',
           ba.currency_code,
           CASE
               WHEN SIGN (NVL (ob.opening_balance_fc, 0)) >= 0
               THEN
                   NVL (ob.opening_balance_fc, 0)
               ELSE
                   0
           END                             entered_dr,
           CASE
               WHEN SIGN (NVL (ob.opening_balance_fc, 0)) < 0
               THEN
                   NVL (0 - ob.opening_balance_fc, 0)
               ELSE
                   0
           END                             entered_cr,
           CASE
               WHEN SIGN (NVL (ob.opening_balance, 0)) >= 0
               THEN
                   NVL (ob.opening_balance, 0)
               ELSE
                   0
           END                             accounted_dr,
           CASE
               WHEN SIGN (NVL (ob.opening_balance, 0)) < 0
               THEN
                   NVL (0 - ob.opening_balance, 0)
               ELSE
                   0
           END                             accounted_cr,
           ba.asset_code_combination_id    bank_ccid,
           gcc.segment5                    gl_code
      FROM xx_ce_bank_acct_balances  ob,
           ce_bank_accounts          ba,
           gl_code_combinations      gcc,
           ce_bank_branches_v        bb
     WHERE     ob.bank_account_id(+) = ba.bank_account_id
           AND ba.asset_code_combination_id = gcc.code_combination_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
    UNION ALL
    SELECT 'CL',                                                          --2,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           ob.check_number,
           ob.check_date,
           ob.cleared_date,
           NULL,
           NULL,
           CASE
               WHEN ob.cleared_date IS NOT NULL THEN 'CLEARED'
               ELSE 'UNCLEARED'
           END,
           ob.party_name,
           ob.description,
           ob.currency_code,
           CASE
               WHEN SIGN (NVL (ob.cleared_amount_fc, 0)) < 0
               THEN
                   NVL (0 - NVL (ob.cleared_amount_fc, ob.check_amount_fc),
                        0)
               ELSE
                   0
           END
               entered_dr,
           CASE
               WHEN SIGN (NVL (ob.cleared_amount_fc, 0)) >= 0
               THEN
                   NVL (NVL (ob.cleared_amount_fc, ob.check_amount_fc), 0)
               ELSE
                   0
           END
               entered_cr,
           CASE
               WHEN SIGN (NVL (ob.cleared_amount, 0)) < 0
               THEN
                   NVL (0 - NVL (ob.cleared_amount, ob.check_amount), 0)
               ELSE
                   0
           END
               accounted_dr,
           CASE
               WHEN SIGN (NVL (ob.cleared_amount, 0)) >= 0
               THEN
                   NVL (NVL (ob.cleared_amount, ob.check_amount), 0)
               ELSE
                   0
           END
               accounted_cr,
           ba.asset_code_combination_id
               bank_ccid,
           gcc.segment5
               gl_code
      FROM xx_ce_bank_acct_clearing  ob,
           ce_bank_accounts          ba,
           gl_code_combinations      gcc,
           ce_bank_branches_v        bb
     WHERE     ob.bank_account_id = ba.bank_account_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
           AND ba.asset_code_combination_id = gcc.code_combination_id
           AND ob.void_date IS NULL
    UNION ALL
    SELECT 'AP',                                                          --3,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           CASE
               WHEN ac.attribute_category = 'Voided Cheque'
               THEN
                   ac.attribute1
               ELSE
                   TO_CHAR (ac.check_number)
           END,
           ac.check_date,
           AC.CLEARED_DATE,
           NULL,
           ac.doc_sequence_value,
           DECODE (ac.status_lookup_code,
                   'CLEARED BUT UNACCOUNTED', 'CLEARED',
                   'RECONCILED', 'CLEARED',
                   'RECONCILED UNACCOUNTED', 'CLEARED',
                   ac.status_lookup_code),
           apps.xx_ap_pkg.get_party_name_with_number (hp.party_id),
           ac.description,
           ac.currency_code,
           ABS (LEAST (NVL (ac.cleared_amount, ac.amount), 0)),
           GREATEST (NVL (ac.cleared_amount, ac.amount), 0),
           ABS (
               LEAST (
                   NVL (NVL (ac.cleared_base_amount, ac.cleared_amount),
                        NVL (ac.base_amount, ac.amount)),
                   0)),
           GREATEST (
               NVL (NVL (ac.cleared_base_amount, ac.cleared_amount),
                    NVL (ac.base_amount, ac.amount)),
               0),
           ba.asset_code_combination_id
               bank_ccid,
           gcc.segment5
               gl_code
      FROM ap_checks_all           ac,
           ap_payment_history_all  aph,
           ce_bank_acct_uses_all   au,
           ce_bank_accounts        ba,
           gl_code_combinations    gcc,
           ce_bank_branches_v      bb,
           hz_parties              hp
     WHERE     ac.check_id = aph.check_id
           AND ac.ce_bank_acct_use_id = au.bank_acct_use_id
           AND au.bank_account_id = ba.bank_account_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
           AND ba.asset_code_combination_id = gcc.code_combination_id
           AND ac.party_id = hp.party_id
           AND aph.transaction_type IN ('PAYMENT CREATED', 'REFUND RECORDED')
           AND ac.status_lookup_code IN ('ISSUED', 'NEGOTIABLE')
           AND NOT EXISTS
                   (SELECT 1
                      FROM ap_payment_history_all rev
                     WHERE     rev.check_id = aph.check_id
                           AND NVL (rev.related_event_id,
                                    rev.accounting_event_id) =
                               NVL (aph.related_event_id,
                                    aph.accounting_event_id)
                           AND rev.rev_pmt_hist_id IS NOT NULL)
    UNION ALL
    SELECT 'AP',                                                          --4,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           CASE
               WHEN ac.attribute_category = 'Voided Cheque'
               THEN
                   ac.attribute1
               ELSE
                   TO_CHAR (ac.check_number)
           END,
           ac.check_date,
           -- aph.accounting_date,
           AC.CLEARED_DATE,
           NULL,
           ac.doc_sequence_value,
           DECODE (ac.status_lookup_code,
                   'CLEARED BUT UNACCOUNTED', 'CLEARED',
                   'RECONCILED', 'CLEARED',
                   'RECONCILED UNACCOUNTED', 'CLEARED',
                   ac.status_lookup_code),
           apps.xx_ap_pkg.get_party_name_with_number (hp.party_id),
           ac.description,
           ac.currency_code,
           ABS (LEAST (NVL (ac.cleared_amount, ac.amount), 0)),
           GREATEST (NVL (ac.cleared_amount, ac.amount), 0),
           ABS (
               LEAST (
                   NVL (NVL (ac.cleared_base_amount, ac.cleared_amount),
                        NVL (ac.base_amount, ac.amount)),
                   0)),
           GREATEST (
               NVL (NVL (ac.cleared_base_amount, ac.cleared_amount),
                    NVL (ac.base_amount, ac.amount)),
               0),
           ba.asset_code_combination_id
               bank_ccid,
           gcc.segment5
               gl_code
      FROM ap_checks_all           ac,
           ap_payment_history_all  aph,
           ce_bank_acct_uses_all   au,
           ce_bank_accounts        ba,
           gl_code_combinations    gcc,
           ce_bank_branches_v      bb,
           hz_parties              hp
     WHERE     ac.check_id = aph.check_id
           AND ac.ce_bank_acct_use_id = au.bank_acct_use_id
           AND au.bank_account_id = ba.bank_account_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
           AND ba.asset_code_combination_id = gcc.code_combination_id
           AND ac.party_id = hp.party_id
           AND aph.transaction_type IN ('PAYMENT CLEARING')
           AND ac.status_lookup_code IN ('CLEARED',
                                         'CLEARED BUT UNACCOUNTED',
                                         'RECONCILED',
                                         'RECONCILED UNACCOUNTED')
           AND NOT EXISTS
                   (SELECT 1
                      FROM ap_payment_history_all rev
                     WHERE     rev.check_id = aph.check_id
                           AND NVL (rev.related_event_id,
                                    rev.accounting_event_id) =
                               NVL (aph.related_event_id,
                                    aph.accounting_event_id)
                           AND rev.rev_pmt_hist_id IS NOT NULL)
    UNION ALL
    SELECT 'AR',
           --5,--27518  AND BA.ASSET_CODE_COMBINATION_ID=GCC.CODE_COMBINATION_ID
           cr.legal_entity_id,
           apps.xx_ce_pkg.get_org_id_from_account_id (
               cr.remit_bank_account_id),
           cr.remit_bank_id,
           cr.remit_bank_name,
           cr.remittance_bank_branch_id,
           cr.remit_bank_branch,
           cr.remit_bank_account_type,
           cr.remit_bank_account_id,
           cr.remit_bank_account_num,
           cr.remit_bank_account_name,
           cr.receipt_number,
           cr.gl_date,
           ch.gl_date,
           NULL,
           cr.document_number,
           cr.state,
           CASE
               WHEN cr.TYPE = 'MISC' THEN cr.activity
               ELSE cr.customer_number || ' - ' || cr.customer_name
           END,
           NULL,
           cr.currency_code,
           GREATEST (ch.amount, 0),
           ABS (LEAST (ch.amount, 0)),
           GREATEST (cr.functional_amount, 0),
           ABS (LEAST (cr.functional_amount, 0)),
           cr.remit_bank_account_ccid,
           gcc.segment5
               gl_account
      FROM xx_ar_cash_receipts_v        cr,
           ar_cash_receipt_history_all  ch,
           gl_code_combinations         gcc
     WHERE     cr.cash_receipt_id = ch.cash_receipt_id
           AND NVL (ch.current_record_flag, 'N') = 'Y'
           AND NVL (state, 'XX') <> 'REVERSED'
           AND cr.remit_bank_account_ccid = gcc.code_combination_id
    UNION ALL
    SELECT 'AR',                                                          --6,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           'N/A',
           rent.gl_date,
           rent.gl_date,
           NULL,
           cr.doc_sequence_value,
           'CLEARED',
           apps.xx_ar_pkg.get_customer_name_with_number (
               cr.pay_from_customer),
           'Rental Adjusted',
           cr.currency_code,
           CASE
               WHEN SIGN (rent.amount) = -1 THEN (0 - rent.amount)
               ELSE 0
           END
               entered_dr,
           CASE WHEN SIGN (rent.amount) = 1 THEN rent.amount ELSE 0 END
               entered_cr,
           CASE
               WHEN SIGN (rent.acctd_amount) = -1
               THEN
                   (0 - rent.acctd_amount)
               ELSE
                   0
           END
               dr_amount,
           CASE
               WHEN SIGN (rent.acctd_amount) = 1 THEN rent.acctd_amount
               ELSE 0
           END
               cr_amount,
           ba.asset_code_combination_id,
           rent.gl_account
      FROM ce_bank_accounts      ba,
           ce_bank_branches_v    bb,
           ar_cash_receipts_all  cr,
           (  SELECT associated_cash_receipt_id,
                     gl_date,
                     gcc.segment5           gl_account,
                     gcc.code_combination_id,
                     SUM (amount)           amount,
                     SUM (acctd_amount)     acctd_amount
                FROM ar_adjustments_all adj, gl_code_combinations gcc
               WHERE     UPPER (adjustment_type) = 'M'
                     AND status = 'A'
                     AND adj.code_combination_id = gcc.code_combination_id
                     AND gcc.segment5 = '122145'
                     AND associated_cash_receipt_id IS NOT NULL
            GROUP BY associated_cash_receipt_id,
                     gl_date,
                     gcc.segment5,
                     gcc.code_combination_id
              HAVING SUM (acctd_amount) <> 0) rent
     WHERE     rent.code_combination_id = ba.asset_code_combination_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
           AND cr.cash_receipt_id = rent.associated_cash_receipt_id
    UNION ALL
    /*   SELECT 'CE',
              XX_CE_PKG.GET_ORG_ID_FROM_ACCOUNT_ID (BA.BANK_ACCOUNT_ID),
              BB.BANK_PARTY_ID,
              BB.BANK_NAME,
              BB.BRANCH_PARTY_ID,
              BB.BANK_BRANCH_NAME,
              BA.BANK_ACCOUNT_TYPE,
              BA.BANK_ACCOUNT_ID,
              BA.BANK_ACCOUNT_NUM,
              BA.BANK_ACCOUNT_NAME,
              PT.BANK_TRXN_NUMBER,
              PT.TRANSACTION_DATE,
              NULL,
              NULL,
              PT.TRXN_REFERENCE_NUMBER,
              PT.TRXN_STATUS_CODE,
              SA.BANK_ACCOUNT_ID || ' - ' || SA.BANK_ACCOUNT_NAME,
              PT.TRANSACTION_DESCRIPTION,
              PT.PAYMENT_CURRENCY_CODE,
              NVL (PT.PAYMENT_AMOUNT, 0),
              0,
              NVL (PT.PAYMENT_AMOUNT, 0),
              0,
              BA.ASSET_CODE_COMBINATION_ID,
              gcc.segment5 GL_CODE
         FROM CE_PAYMENT_TRANSACTIONS PT,
              CE_BANK_ACCOUNTS BA,
              GL_CODE_COMBINATIONS GCC,
              CE_BANK_BRANCHES_V BB,
              CE_BANK_ACCOUNTS SA
        WHERE     PT.DESTINATION_BANK_ACCOUNT_ID = BA.BANK_ACCOUNT_ID
              AND BA.BANK_ID = BB.BANK_PARTY_ID
              AND BA.BANK_BRANCH_ID = BB.BRANCH_PARTY_ID
              AND BA.ASSET_CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
              AND PT.SOURCE_BANK_ACCOUNT_ID = SA.BANK_ACCOUNT_ID
              AND NVL (PT.TRXN_STATUS_CODE, 'XX') = 'NEW'
       UNION ALL
       SELECT 'CE',
              XX_CE_PKG.GET_ORG_ID_FROM_ACCOUNT_ID (BA.BANK_ACCOUNT_ID),
              BB.BANK_PARTY_ID,
              BB.BANK_NAME,
              BB.BRANCH_PARTY_ID,
              BB.BANK_BRANCH_NAME,
              BA.BANK_ACCOUNT_TYPE,
              BA.BANK_ACCOUNT_ID,
              BA.BANK_ACCOUNT_NUM,
              BA.BANK_ACCOUNT_NAME,
              PT.BANK_TRXN_NUMBER,
              PT.TRANSACTION_DATE,
              NULL,
              NULL,
              PT.TRXN_REFERENCE_NUMBER,
              PT.TRXN_STATUS_CODE,
              DA.BANK_ACCOUNT_ID || ' - ' || DA.BANK_ACCOUNT_NAME,
              PT.TRANSACTION_DESCRIPTION,
              PT.PAYMENT_CURRENCY_CODE,
              0,
              NVL (PT.PAYMENT_AMOUNT, 0),
              0,
              NVL (PT.PAYMENT_AMOUNT, 0),
              BA.ASSET_CODE_COMBINATION_ID,
              gcc.segment5 GL_CODE
         FROM CE_PAYMENT_TRANSACTIONS PT,
              CE_BANK_ACCOUNTS BA,
              GL_CODE_COMBINATIONS GCC,
              CE_BANK_BRANCHES_V BB,
              CE_BANK_ACCOUNTS DA
        WHERE     PT.SOURCE_BANK_ACCOUNT_ID = BA.BANK_ACCOUNT_ID
              AND BA.BANK_ID = BB.BANK_PARTY_ID
              AND BA.ASSET_CODE_COMBINATION_ID = CODE_COMBINATION_ID
              AND BA.BANK_BRANCH_ID = BB.BRANCH_PARTY_ID
              AND PT.DESTINATION_BANK_ACCOUNT_ID = DA.BANK_ACCOUNT_ID
              AND NVL (PT.TRXN_STATUS_CODE, 'XX') = 'NEW'
       UNION ALL*/
    SELECT 'CE',                                                          --7,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           pt.bank_trxn_number,
           cf.cashflow_date,
           CASE
               WHEN cf.cashflow_status_code IN ('RECONCILED', 'CLEARED')
               THEN
                   cf.cashflow_date
               ELSE
                   NULL
           END,
           NULL,
           cf.trxn_reference_number,
           DECODE (CF.CASHFLOW_STATUS_CODE,
                   'CREATED', 'CLEARED',
                   'RECONCILED', 'CLEARED',
                   'RECONCILED UNACCOUNTED', 'CLEARED',
                   CF.CASHFLOW_STATUS_CODE),
           sa.bank_account_id || ' - ' || sa.bank_account_name,
           cf.description,
           pt.payment_currency_code,
           NVL (pt.payment_amount, 0),
           0,
           NVL (cf.base_amount, 0),
           0,
           ba.asset_code_combination_id,
           gcc.segment5
               gl_code
      FROM ce_payment_transactions  pt,
           ce_cashflows             cf,
           ce_cashflow_acct_h       ch,
           ce_bank_accounts         ba,
           gl_code_combinations     gcc,
           ce_bank_branches_v       bb,
           ce_bank_accounts         sa
     WHERE     pt.trxn_reference_number = cf.trxn_reference_number
           AND cf.cashflow_id = ch.cashflow_id
           AND ba.asset_code_combination_id = gcc.code_combination_id
           AND cf.cashflow_bank_account_id = ba.bank_account_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
           AND cf.counterparty_bank_account_id = sa.bank_account_id
           AND NVL (ch.current_record_flag, 'N') = 'Y'
           AND (                                 --cf.TRXN_REFERENCE_NUMBER IN
                --    ('102308', '97171', '102547', '102548')
                --OR
                NVL (cf.cashflow_status_code, 'XX') <> 'CANCELED')
           -- AND NVL (CF.CASHFLOW_STATUS_CODE, 'XX') <> 'CANCELED'
           AND cf.cashflow_direction = 'RECEIPT'
    UNION ALL
    SELECT 'CE',                                                          --8,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           pt.bank_trxn_number,
           cf.cashflow_date,
           CASE
               WHEN cf.cashflow_status_code IN ('RECONCILED', 'CLEARED')
               THEN
                   cf.cashflow_date
               ELSE
                   NULL
           END,
           NULL,
           cf.trxn_reference_number,
           DECODE (CF.CASHFLOW_STATUS_CODE,
                   'CREATED', 'CLEARED',
                   'RECONCILED', 'CLEARED',
                   'RECONCILED UNACCOUNTED', 'CLEARED',
                   CF.CASHFLOW_STATUS_CODE),
           sa.bank_account_id || ' - ' || sa.bank_account_name,
           cf.description,
           pt.payment_currency_code,
           0,
           NVL (pt.payment_amount, 0),
           0,
           NVL (cf.base_amount, 0),
           ba.asset_code_combination_id,
           gcc.segment5
               gl_code
      FROM ce_payment_transactions  pt,
           ce_cashflows             cf,
           ce_cashflow_acct_h       ch,
           ce_bank_accounts         ba,
           ce_bank_branches_v       bb,
           ce_bank_accounts         sa,
           gl_code_combinations     gcc
     WHERE     pt.trxn_reference_number = cf.trxn_reference_number
           AND cf.cashflow_id = ch.cashflow_id
           AND ba.asset_code_combination_id = gcc.code_combination_id
           AND cf.cashflow_bank_account_id = ba.bank_account_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
           AND cf.counterparty_bank_account_id = sa.bank_account_id
           AND NVL (ch.current_record_flag, 'N') = 'Y'
           AND (                                 --cf.TRXN_REFERENCE_NUMBER IN
                --    ('102308', '97171', '102547', '102548')
                --OR
                NVL (cf.cashflow_status_code, 'XX') <> 'CANCELED')
           --          AND NVL (CF.CASHFLOW_STATUS_CODE, 'XX') <> 'CANCELED'
           AND cf.cashflow_direction = 'PAYMENT'
    UNION ALL
    SELECT 'AP',                                                          --9,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           'N/A',
           ad.accounting_date,
           ad.accounting_date,
           NULL,
           ai.doc_sequence_value,
           'CLEARED',
           av.vendor_name,
           ad.description,
           ai.invoice_currency_code,
           GREATEST (NVL (ad.amount, 0), 0),
           ABS (LEAST (NVL (ad.amount, 0), 0)),
           GREATEST (NVL (ad.base_amount, ad.amount), 0),
           ABS (LEAST (NVL (ad.base_amount, ad.amount), 0)),
           ba.asset_code_combination_id,
           gcc.segment5     gl_code
      FROM ap_suppliers                  av,
           ap_invoices_all               ai,
           ap_invoice_distributions_all  ad,
           ce_bank_accounts              ba,
           ce_bank_branches_v            bb,
           gl_code_combinations          gcc
     WHERE     ai.vendor_id = av.vendor_id
           AND ai.invoice_id = ad.invoice_id
           AND ba.asset_code_combination_id = gcc.code_combination_id
           AND ad.dist_code_combination_id = ba.asset_code_combination_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
    --          AND NVL (AD.REVERSAL_FLAG, 'N') <> 'Y'
    UNION ALL
    SELECT 'GL',                                                         --10,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           'N/A',
           jeh.default_effective_date     accounting_date,
           jeh.default_effective_date     cleared_date,
           NULL,
           --CAST (jeh.doc_sequence_value AS NUMBER (16))     voucher,
           jeh.doc_sequence_value         voucher,
           'CLEARED',
           NULL,
           jel.description,
           jeh.currency_code,
           jel.entered_dr,
           jel.entered_cr,
           jel.accounted_dr,
           jel.accounted_cr,
           ba.asset_code_combination_id,
           gcc.segment5                   gl_code
      FROM gl_je_headers         jeh,
           gl_je_lines           jel,
           gl_ledgers            gll,
           ce_bank_accounts      ba,
           ce_bank_branches_v    bb,
           gl_code_combinations  gcc
     WHERE     jeh.je_header_id = jel.je_header_id
           AND jeh.ledger_id = gll.ledger_id
           AND ba.asset_code_combination_id = gcc.code_combination_id
           AND jel.code_combination_id = ba.asset_code_combination_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
           AND gll.ledger_category_code = 'PRIMARY'
           AND NVL (jeh.je_from_sla_flag, 'N') <> 'Y'
           AND je_category NOT IN ('Carry Forward', '182')
           AND jeh.accrual_rev_je_header_id IS NULL
           AND jel.CONTEXT <> 'Bank Gain Loss Adjustment'
    UNION ALL
    SELECT DISTINCT
           'AP',                                                         --11,
           apps.xx_ce_pkg.get_org_id_from_account_id (ba.bank_account_id),
           bb.bank_party_id,
           bb.bank_name,
           bb.branch_party_id,
           bb.bank_branch_name,
           ba.bank_account_type,
           ba.bank_account_id,
           ba.bank_account_num,
           ba.bank_account_name,
           CASE
               WHEN ac.attribute_category = 'Voided Cheque'
               THEN
                   ac.attribute1
               ELSE
                   TO_CHAR (ac.check_number)
           END,
           aph.accounting_date,
           NULL,
           TO_DATE (ac.attribute1, 'RRRR/MM/DD HH24:MI:SS'),
           ac.doc_sequence_value,
           ac.status_lookup_code,
           apps.xx_ap_pkg.get_party_name_with_number (hp.party_id),
           CASE
               WHEN aph.rev_pmt_hist_id IS NULL THEN ac.description
               ELSE ac.attribute2
           END,
           ac.currency_code,
           CASE
               WHEN aph.rev_pmt_hist_id IS NULL
               THEN
                   ABS (LEAST (NVL (ac.cleared_amount, ac.amount), 0))
               ELSE
                   GREATEST (NVL (ac.cleared_amount, ac.amount), 0)
           END,
           CASE
               WHEN aph.rev_pmt_hist_id IS NULL
               THEN
                   GREATEST (NVL (ac.cleared_amount, ac.amount), 0)
               ELSE
                   ABS (LEAST (NVL (ac.cleared_amount, ac.amount), 0))
           END,
           CASE
               WHEN aph.rev_pmt_hist_id IS NULL
               THEN
                   ABS (
                       LEAST (
                           NVL (
                               NVL (ac.cleared_base_amount,
                                    ac.cleared_amount),
                               NVL (ac.base_amount, ac.amount)),
                           0))
               ELSE
                   GREATEST (
                       NVL (NVL (ac.cleared_base_amount, ac.cleared_amount),
                            NVL (ac.base_amount, ac.amount)),
                       0)
           END,
           CASE
               WHEN aph.rev_pmt_hist_id IS NULL
               THEN
                   GREATEST (
                       NVL (NVL (ac.cleared_base_amount, ac.cleared_amount),
                            NVL (ac.base_amount, ac.amount)),
                       0)
               ELSE
                   ABS (
                       LEAST (
                           NVL (
                               NVL (ac.cleared_base_amount,
                                    ac.cleared_amount),
                               NVL (ac.base_amount, ac.amount)),
                           0))
           END,
           ba.asset_code_combination_id
               bank_ccid,
           gcc.segment5
               gl_code
      FROM ap_checks_all           ac,
           ap_payment_history_all  aph,
           ce_bank_acct_uses_all   au,
           ce_bank_accounts        ba,
           ce_bank_branches_v      bb,
           hz_parties              hp,
           gl_code_combinations    gcc
     WHERE     ac.check_id = aph.check_id
           AND ac.ce_bank_acct_use_id = au.bank_acct_use_id
           AND au.bank_account_id = ba.bank_account_id
           AND ba.bank_id = bb.bank_party_id
           AND ba.bank_branch_id = bb.branch_party_id
           AND ac.party_id = hp.party_id
           AND ba.asset_code_combination_id = gcc.code_combination_id
           AND ac.attribute_category = 'Cancelled Cheque'
           AND ac.doc_sequence_value NOT IN ('315001944')
    --   UNION ALL
    --   SELECT 'GL',                                                          --12,
    --          apps.XX_CE_PKG.GET_ORG_ID_FROM_ACCOUNT_ID (BA.BANK_ACCOUNT_ID),
    --          BB.BANK_PARTY_ID,
    --          BB.BANK_NAME,
    --          BB.BRANCH_PARTY_ID,
    --          BB.BANK_BRANCH_NAME,
    --          BA.BANK_ACCOUNT_TYPE,
    --          BA.BANK_ACCOUNT_ID,
    --          BA.BANK_ACCOUNT_NUM,
    --          BA.BANK_ACCOUNT_NAME,
    --          NULL,
    --          EFFECTIVE_DATE,
    --          EFFECTIVE_DATE,
    --          NULL,
    --          JH.doc_sequence_value,
    --          'CLEARED',
    --          'Gain/Loss Adjustment',
    --          'Gain/Loss Adjustment',
    --          BA.CURRENCY_CODE,
    --          0 ENTERED_DR,
    --          0 ENTERED_CR,
    --          ACCOUNTED_DR,
    --          ACCOUNTED_CR ACCOUNTED_CR,
    --          BA.ASSET_CODE_COMBINATION_ID BANK_CCID,
    --          GCC.SEGMENT5 GL_CODE
    --     FROM GL_JE_LINES OB,
    --          GL_CODE_COMBINATIONS GCC,
    --          GL_JE_HEADERS JH,
    --          CE_BANK_ACCOUNTS BA,
    --          CE_BANK_BRANCHES_V BB,
    --          gl_ledgers xep
    --    WHERE     OB.ATTRIBUTE2(+) = BA.BANK_ACCOUNT_ID
    --          AND BA.BANK_ID = BB.BANK_PARTY_ID
    --          AND BA.BANK_BRANCH_ID = BB.BRANCH_PARTY_ID
    --          AND OB.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
    --          AND OB.JE_HEADER_ID = JH.JE_HEADER_ID
    --          -- AND GCC.SEGMENT4 = '41050101'
    --          AND JH.ACCRUAL_REV_JE_HEADER_ID IS NULL
    --          AND xep.ledger_id = ob.ledger_id
    --          --and ba.BANK_ACCOUNT_ID = 11091
    --          AND OB.CONTEXT = 'Bank Gain Loss Adjustment'
    --          AND xep.LEDGER_CATEGORY_CODE = 'PRIMARY'
    --   --AND OB.LEDGER_ID = 2075;
    UNION ALL
    SELECT 'GL',                                                         --12,
           APPS.XX_CE_PKG.GET_ORG_ID_FROM_ACCOUNT_ID (BA.BANK_ACCOUNT_ID),
           BB.BANK_PARTY_ID,
           BB.BANK_NAME,
           BB.BRANCH_PARTY_ID,
           BB.BANK_BRANCH_NAME,
           BA.BANK_ACCOUNT_TYPE,
           BA.BANK_ACCOUNT_ID,
           BA.BANK_ACCOUNT_NUM,
           BA.BANK_ACCOUNT_NAME,
           NULL,
           EFFECTIVE_DATE,
           EFFECTIVE_DATE,
           NULL,
           JH.DOC_SEQUENCE_VALUE,
           'CLEARED',
           'Gain/Loss Adjustment',
           -- 'Gain/Loss Adjustment',
           OB.DESCRIPTION,
           BA.CURRENCY_CODE,
           0                                ENTERED_DR,
           0                                ENTERED_CR,
           ACCOUNTED_DR,
           ACCOUNTED_CR                     ACCOUNTED_CR,
           BA.ASSET_CODE_COMBINATION_ID     BANK_CCID,
           GCC.SEGMENT5                     GL_CODE
      FROM GL_JE_LINES           OB,
           GL_CODE_COMBINATIONS  GCC,
           GL_JE_HEADERS         JH,
           CE_BANK_ACCOUNTS      BA,
           CE_BANK_BRANCHES_V    BB,
           GL_LEDGERS            XEP
     WHERE     OB.ATTRIBUTE2(+) = BA.BANK_ACCOUNT_ID
           AND BA.BANK_ID = BB.BANK_PARTY_ID
           AND BA.BANK_BRANCH_ID = BB.BRANCH_PARTY_ID
           AND OB.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND OB.JE_HEADER_ID = JH.JE_HEADER_ID
           -- AND GCC.SEGMENT4 = '41050101'
           --AND JH.ACCRUAL_REV_JE_HEADER_ID IS NULL
           AND XEP.LEDGER_ID = OB.LEDGER_ID
           --and ba.BANK_ACCOUNT_ID = 11091
           AND OB.CONTEXT = 'Bank Gain Loss Adjustment'
           AND XEP.LEDGER_CATEGORY_CODE = 'PRIMARY';


CREATE OR REPLACE SYNONYM APPSRO.XX_BANK_LEDGER_V FOR APPS.XX_BANK_LEDGER_V;


GRANT SELECT ON APPS.XX_BANK_LEDGER_V TO APPSRO;