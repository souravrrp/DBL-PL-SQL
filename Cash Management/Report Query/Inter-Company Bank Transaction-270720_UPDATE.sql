/* Formatted on 7/27/2020 9:47:57 AM (QP5 v5.354) */
  SELECT SRC.SRC_LEGAL_ENTITY,
         DST.DEST_LEGAL_ENTITY,
         SRC.TRXN_REFERENCE_NUMBER,
         SRC.TRANSACTION_DATE,
         SRC.PAYMENT_CURRENCY_CODE,
         SRC.TRXN_STATUS_CODE,
         SRC.BANK_TRXN_NUMBER,
         SRC.TRANSACTION_DESCRIPTION,
         SRC.BANK_NAME,
         SRC.SRC_BANK_ACCT_NAME,
         DST.DEST_BANK_ACCT_NAME,
         SUM (DST.RECEIPT_AMNT),
         SUM (SRC.PAYMENT_AMNT)
    FROM (SELECT PT.DESTINATION_LEGAL_ENTITY_ID    DEST_LEGAL_ENTITY,
                 pt.trxn_reference_number,
                 pt.transaction_date,
                 pt.payment_currency_code,
                 pt.trxn_status_code,
                 pt.bank_trxn_number,
                 pt.transaction_description,
                 bb.bank_name,
                 ba.bank_account_name              dest_bank_acct_name,
                 ROUND (
                     NVL (
                         DECODE (
                             ba.currency_code,
                             'BDT', ch.cleared_amount,
                             (ch.cleared_amount * ch.cleared_exchange_rate)),
                         cf.base_amount),
                     2)                            receipt_amnt
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
                 --AND PT.TRXN_REFERENCE_NUMBER = 33898
                 --AND PT.DESTINATION_LEGAL_ENTITY_ID = :P_DESTI_LEGAL_ID
                 AND (   :P_DATE_FROM IS NULL
                      OR pt.transaction_date BETWEEN :P_DATE_FROM
                                                 AND :P_DATE_TO)) DST,
         (SELECT PT.SOURCE_LEGAL_ENTITY_ID    SRC_LEGAL_ENTITY,
                 pt.trxn_reference_number,
                 pt.transaction_date,
                 pt.payment_currency_code,
                 pt.trxn_status_code,
                 pt.bank_trxn_number,
                 pt.transaction_description,
                 bb.bank_name,
                 ba.bank_account_name         src_bank_acct_name,
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
                 --AND PT.TRXN_REFERENCE_NUMBER = 33898
                 AND PT.SOURCE_LEGAL_ENTITY_ID = :P_SOURCE_LEGAL_ID
                 AND (   :P_DATE_FROM IS NULL
                      OR pt.transaction_date BETWEEN :P_DATE_FROM
                                                 AND :P_DATE_TO)) SRC
   WHERE SRC.TRXN_REFERENCE_NUMBER = DST.TRXN_REFERENCE_NUMBER
GROUP BY SRC.SRC_LEGAL_ENTITY,
         DST.DEST_LEGAL_ENTITY,
         SRC.TRXN_REFERENCE_NUMBER,
         SRC.TRANSACTION_DATE,
         SRC.PAYMENT_CURRENCY_CODE,
         SRC.TRXN_STATUS_CODE,
         SRC.BANK_TRXN_NUMBER,
         SRC.TRANSACTION_DESCRIPTION,
         SRC.BANK_NAME,
         SRC.SRC_BANK_ACCT_NAME,
         DST.DEST_BANK_ACCT_NAME