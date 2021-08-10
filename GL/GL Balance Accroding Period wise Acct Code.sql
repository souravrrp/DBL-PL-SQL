/* Formatted on 11/8/2020 10:25:47 AM (QP5 v5.354) */
  SELECT gb.ledger_id
             sets_of_books_id,
         gb.period_name,
         gb.actual_flag,
         DECODE (gb.actual_flag,
                 'A', 'Actual',
                 'B', 'Budget',
                 'E', 'Encumbrance',
                 'Not Defined')
             "ACTUAL_FLAG_MEANING",
         NVL (SUM (gb.begin_balance_dr - gb.begin_balance_cr), 0)
             "Begin Balance",
         gb.period_net_dr,
         gb.period_net_cr,
         NVL (
             SUM (
                   gb.begin_balance_dr
                 - gb.begin_balance_cr
                 + gb.period_net_dr
                 - gb.period_net_cr),
             0)
             "Closing Balance",
         gcck.concatenated_segments
             account_code,
         gcck.gl_account_type,
         DECODE (gcck.gl_account_type,
                 'A', 'Asset',
                 'E', 'Expense',
                 'L', 'Liability',
                 'O', 'Owners Equity',
                 'R', 'Revenue',
                 'Not Defined')
             "Account_Type"
    FROM apps.gl_code_combinations_kfv gcck, apps.gl_balances gb
   WHERE     1 = 1
         AND gcck.code_combination_id = gb.code_combination_id
         --AND GB.LEDGER_ID=2025
         --AND GCCK.GL_ACCOUNT_TYPE='E'
         --AND GCCK.CONCATENATED_SEGMENTS='2110.PSU.4030709.9999.00'
         AND gb.period_name = 'OCT-18'
GROUP BY gb.ledger_id,
         gb.period_name,
         gb.actual_flag,
         gb.actual_flag,
         gcck.concatenated_segments,
         gcck.gl_account_type,
         gb.period_net_dr,
         gb.period_net_cr;