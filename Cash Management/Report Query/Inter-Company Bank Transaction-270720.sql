/* Formatted on 7/27/2020 9:35:47 AM (QP5 v5.354) */
  SELECT SRC_LEGAL_ENTITY,
         DEST_LEGAL_ENTITY,
         TRXN_REFERENCE_NUMBER,
         TRANSACTION_DATE,
         PAYMENT_CURRENCY_CODE,
         TRXN_STATUS_CODE,
         BANK_TRXN_NUMBER,
         TRANSACTION_DESCRIPTION,
         BANK_NAME,
         SRC_BANK_ACCT_NAME,
         DEST_BANK_ACCT_NAME,
         SUM (RECEIPT_AMNT),
         SUM (PAYMENT_AMNT)
    FROM (SELECT NULL                              SRC_LEGAL_ENTITY,
                 PT.DESTINATION_LEGAL_ENTITY_ID    DEST_LEGAL_ENTITY,
                 pt.trxn_reference_number,
                 pt.transaction_date,
                 pt.payment_currency_code,
                 pt.trxn_status_code,
                 pt.bank_trxn_number,
                 pt.transaction_description,
                 bb.bank_name,
                 (CASE
                      WHEN cf.cashflow_direction != 'PAYMENT'
                      THEN
                          ba.bank_account_name
                      ELSE
                          NULL
                  END)                             src_bank_acct_name,
                 NULL                              dest_bank_acct_name,
                 ROUND (
                     NVL (
                         DECODE (
                             ba.currency_code,
                             'BDT', ch.cleared_amount,
                             (ch.cleared_amount * ch.cleared_exchange_rate)),
                         cf.base_amount),
                     2)                            receipt_amnt,
                 0                                 payment_amnt
            --,ba.*
            FROM ce_payment_transactions pt,
                 ce_cashflows           cf,
                 ce_cashflow_acct_h     ch,
                 ce_bank_accounts       ba,
                 ce_bank_branches_v     bb
           WHERE     pt.trxn_reference_number = cf.trxn_reference_number
                 AND cf.cashflow_id = ch.cashflow_id
                 AND cf.cashflow_bank_account_id = ba.bank_account_id
                 AND ba.bank_id = bb.bank_party_id
                 AND ba.bank_branch_id = bb.branch_party_id
                 AND NVL (ch.current_record_flag, 'N') = 'Y'
                 AND NVL (cf.cashflow_status_code, 'XX') <> 'CANCELED'
                 AND cf.cashflow_direction != 'PAYMENT'
                 AND UPPER (ba.bank_account_name) NOT LIKE '%CASH%'
                 AND (ba.bank_account_name) NOT LIKE '%Dummy%'
                 AND PT.TRXN_REFERENCE_NUMBER = 33898
                 --AND PT.DESTINATION_LEGAL_ENTITY_ID = :P_DESTI_LEGAL_ID
                 AND (   :P_DATE_FROM IS NULL OR pt.transaction_date BETWEEN :P_DATE_FROM AND :P_DATE_TO)
          UNION ALL
          SELECT PT.SOURCE_LEGAL_ENTITY_ID    SRC_LEGAL_ENTITY,
                 NULL                         DEST_LEGAL_ENTITY,
                 pt.trxn_reference_number,
                 pt.transaction_date,
                 pt.payment_currency_code,
                 pt.trxn_status_code,
                 pt.bank_trxn_number,
                 pt.transaction_description,
                 bb.bank_name,
                 NULL                         src_bank_acct_name,
                 (CASE
                      WHEN cf.cashflow_direction = 'PAYMENT'
                      THEN
                          ba.bank_account_name
                      ELSE
                          NULL
                  END)                        dest_bank_acct_name,
                 0                            receipt_amnt,
                 ROUND (
                     NVL (
                         DECODE (
                             ba.currency_code,
                             'BDT', ch.cleared_amount,
                             (ch.cleared_amount * ch.cleared_exchange_rate)),
                         cf.base_amount),
                     2)                       payment_amnt
            FROM ce_payment_transactions pt,
                 ce_cashflows           cf,
                 ce_cashflow_acct_h     ch,
                 ce_bank_accounts       ba,
                 ce_bank_branches_v     bb
           WHERE     pt.trxn_reference_number = cf.trxn_reference_number
                 AND cf.cashflow_id = ch.cashflow_id
                 AND cf.cashflow_bank_account_id = ba.bank_account_id
                 AND ba.bank_id = bb.bank_party_id
                 AND ba.bank_branch_id = bb.branch_party_id
                 AND NVL (ch.current_record_flag, 'N') = 'Y'
                 AND NVL (cf.cashflow_status_code, 'XX') <> 'CANCELED'
                 AND cf.cashflow_direction = 'PAYMENT'
                 AND UPPER (ba.bank_account_name) NOT LIKE '%CASH%'
                 AND (ba.bank_account_name) NOT LIKE '%Dummy%'
                 AND PT.TRXN_REFERENCE_NUMBER = 33898
                 AND PT.SOURCE_LEGAL_ENTITY_ID = :P_SOURCE_LEGAL_ID
                 AND (   :P_DATE_FROM IS NULL OR pt.transaction_date BETWEEN :P_DATE_FROM AND :P_DATE_TO)
                 )
GROUP BY SRC_LEGAL_ENTITY,
         DEST_LEGAL_ENTITY,
         TRXN_REFERENCE_NUMBER,
         TRANSACTION_DATE,
         PAYMENT_CURRENCY_CODE,
         TRXN_STATUS_CODE,
         BANK_TRXN_NUMBER,
         TRANSACTION_DESCRIPTION,
         BANK_NAME,
         SRC_BANK_ACCT_NAME,
         DEST_BANK_ACCT_NAME
ORDER BY 1;