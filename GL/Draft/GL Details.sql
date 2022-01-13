/* Formatted on 9/21/2021 5:46:13 PM (QP5 v5.354) */
SELECT gl.name
           ledger_name,
       hou.name
           operating_unit,
       hou.short_code,
       gl.currency_code,
       gl.period_set_name,
       glh.period_name,
       fu.user_name
           created_by,
       glh.creation_date,
       GLB.name
           Journal_batch_name,
       glh.name
           journal_name,
       gcc.concatenated_segments
           charge_account,
       gll.entered_cr,
       gll.entered_dr,
       glh.default_effective_date,
       DECODE (gll.status,  'P', 'POSTED',  'U', 'UNPOSTED',  gll.status)
           posted_status,
       glh.posted_date,
       gp.start_date
           period_start_date,
       gp.end_date
           period_end_date,
       gp.period_year,
       gp.period_num,
       gp.quarter_num,
       hou.organization_id,
       gll.je_line_num,
       gll.je_header_id
  FROM gl_ledgers                gl,
       gl_je_batches             GLB,
       gl_je_headers             glh,
       gl_je_lines               gll,
       gl_code_combinations_kfv  gcc,
       gl_periods                gp,
       hr_operating_units        hou,
       xxdbl_company_le_mapping_v  ou,
       fnd_user                  fu
 WHERE     1 = 1
       AND GLB.je_batch_id = glh.je_batch_id
       AND glh.je_header_id = gll.je_header_id
       AND gcc.code_combination_id = gll.code_combination_id
       AND glh.created_by = fu.user_id
       AND gp.period_name = glh.period_name
       AND gl.period_set_name = gp.period_set_name
       AND glh.ledger_id = gl.ledger_id
       AND gl.ledger_id = hou.set_of_books_id
       AND hou.organization_id = ou.org_id
       --AND glh.actual_flag = 'B'
       --AND glh.je_source = 'Budget Journal'
       --AND glh.je_category = 'Budget'
       --AND glh.period_name IN ('')
       AND (   :p_period_name IS NULL OR (glh.period_name = UPPER(:p_period_name)))
       AND (   :p_ou_name IS NULL OR (hou.name = :p_ou_name))
       AND (   :p_ledger_name IS NULL OR (UPPER (ou.LEDGER_NAME) LIKE UPPER ('%' || :p_ledger_name || '%')));