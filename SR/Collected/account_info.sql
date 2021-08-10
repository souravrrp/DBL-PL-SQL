/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : account_info.sql                                           |
| Description  : Diagnostic for a particular account in GL and sub ledger.  |
|                This will create a spool file  glinv.lst                   |
|                Customer needs to give input as                            |
|                account id (acct_id)                                       |
|                Sob id (sob_id)                                            |
| Revision                                                                  |
|  06/10/2004      Anup Jha    Creation                                     |
|  09/28/2007      Satendra Bhati Added GL balances query                   |
|                                                                           |
+==========================================================================*/
SET SERVEROUTPUT ON SIZE 100000
SET line 500
SET pages 9999
spool glinv.lst
undef organization_id
undef acct_id
undef operating_unit_id
undef sob_id
/*
MTA data */
SELECT organization_id organization_id,
       reference_account acct,
       accounting_line_type alt,
       gl_batch_id,
       sum(base_transaction_value)
  FROM mtl_transaction_accounts
 WHERE reference_account = &&acct_id
 GROUP BY organization_id ,
          reference_account ,
          accounting_line_type,
          gl_batch_id
/
/*
WTA data */
SELECT organization_id worganization_id,
       reference_account wacct,
       accounting_line_type walt,
       gl_batch_id wbatch,
       sum(base_transaction_value) w_val
  FROM wip_transaction_accounts
 WHERE reference_account = &&acct_id
 GROUP BY organization_id ,
          reference_account ,
          accounting_line_type,
          gl_batch_id
/
/*
 MTA DATA period wise
*/
SELECT mta.organization_id organization_id,
       mta.reference_account acct,
       mta.accounting_line_type alt,
       oap.period_name period,
       mta.gl_batch_id,
       sum(mta.base_transaction_value)
 FROM mtl_transaction_accounts mta,
      org_acct_periods oap
 WHERE reference_account = &&acct_id
  and mta.transaction_date >=oap.period_start_date 
  and mta.transaction_date <=(oap.schedule_close_date+0.999999)
  and oap.organization_id = mta.organization_id
 GROUP BY mta.organization_id ,
          mta.reference_account ,
          mta.accounting_line_type,
          oap.period_name,
          mta.gl_batch_id
/
/* 
WTA DATA period wise
*/
 SELECT mta.organization_id worganization_id,
        mta.reference_account wacct,
        mta.accounting_line_type walt,
        mta.gl_batch_id wbatch,
        oap.period_name w_period,
        sum(mta.base_transaction_value) w_val
  FROM wip_transaction_accounts mta,
       org_acct_periods oap
  WHERE mta.reference_account = &&acct_id
  and mta.transaction_date >=oap.period_start_date 
  and mta.transaction_date <=(oap.schedule_close_date+0.999999)
  and oap.organization_id = mta.organization_id
  GROUP BY mta.organization_id ,
          mta.reference_account ,
          mta.accounting_line_type,
          oap.period_name,
          mta.gl_batch_id 
/
/*
 RRSL data period wise
*/
SELECT      rrsl.je_source_name je_src,
            rrsl.je_category_name je_cat,
	    rrsl.set_of_books_id sob,
            pod.destination_type_code dest_type,
            pod.destination_organization_id dest_org,
	    rrsl.period_name,
            sum(nvl(rrsl.accounted_cr,0)) cr,
            sum(nvl(rrsl.accounted_dr,0)) dr,
            sum(nvl(rrsl.accounted_nr_tax,0)) nr_tax
      FROM rcv_receiving_sub_ledger rrsl,
           po_distributions_all pod
     WHERE  rrsl.code_combination_id = &&acct_id
     AND  pod.po_distribution_id = to_number(rrsl.reference3)
     AND rrsl.actual_flag = 'A'
 GROUP BY rrsl.je_source_name,
          rrsl.je_category_name,
          rrsl.set_of_books_id,
          pod.destination_type_code ,
          pod.destination_organization_id,
	  rrsl.period_name
/
/*
GL INTERFACE */
SELECT gli.set_of_books_id sob,
       substr(gli.reference21,1,20) gl_batch,
       substr(gli.reference22,1,20) org,
       gli.code_combination_id ccid,
       actual_flag,
       user_je_category_name je_category,
       trunc(gli.accounting_date, 'MONTH') period,
       sum(nvl(gli.accounted_cr,0)) inv_cr_gli,
       sum(nvl(gli.accounted_dr,0)) inv_dr_gli
  FROM gl_interface gli
 WHERE user_je_source_name = 'Inventory'
   and gli.code_combination_id = &&acct_id
 GROUP BY gli.set_of_books_id, 
       substr(gli.reference21,1,20),
       substr(gli.reference22,1,20) ,
       gli.code_combination_id ,
       gli.actual_flag,
       user_je_category_name,
       trunc(gli.accounting_date, 'MONTH')
/
/*
GL INTERFACE */
SELECT substr(gli.reference21,1,20) gl_batch,
       substr(gli.reference22,1,20) org,
       gli.code_combination_id ccid,
       actual_flag,
       gli.user_je_source_name je_source,
       user_je_category_name je_category,
       trunc(gli.accounting_date, 'MONTH') period,
       sum(nvl(gli.accounted_cr,0)) inv_cr_gli,
       sum(nvl(gli.accounted_dr,0)) inv_dr_gli
  FROM gl_interface gli
 WHERE gli.code_combination_id = &&acct_id
 GROUP BY gli.set_of_books_id, 
       substr(gli.reference21,1,20),
       substr(gli.reference22,1,20) ,
       gli.code_combination_id ,
       gli.actual_flag,
       gli.user_je_source_name,
       user_je_category_name,
       trunc(gli.accounting_date, 'MONTH')
/
/*
GL JE LINES 
provide code combination id of the account for
which problem is reported */
SELECT substr(glir.reference_1,1,20) gl_batch,
       substr(gjl.reference_2,1,20) org,
       gjh.je_category,
       gjl.status,
       gjl.code_combination_id ccid,
       NVL(sum(gjl.accounted_cr),0) inv_CR_gl, 
       NVL(sum(gjl.accounted_dr),0) inv_DR_gl
  FROM gl_je_lines gjl, gl_je_headers gjh,
       gl_import_references glir
 WHERE gjl.je_header_id = gjh.je_header_id
   AND gjl.code_combination_id = &&acct_id
   AND gjh.je_source = 'Inventory'
   AND gjh.actual_flag = 'A'
   AND glir.je_header_id = gjl.je_header_id
   AND glir.je_line_num = gjl.je_line_num
 GROUP BY substr(glir.reference_1,1,20) ,
        substr(gjl.reference_2,1,20),
       gjh.je_category,
       gjl.status,
       gjl.code_combination_id
/
/*
GL value for the account for the sob 
*/
 select    gjh.je_source,
           gjh.je_category,
           gjl.status,
           gjh.period_name,
           gjl.code_combination_id ccid,
           NVL(sum(nvl(gjl.accounted_cr,0)),0) CR,
           NVL(sum(nvl(gjl.accounted_dr,0)),0) DR
      FROM gl_je_lines gjl,
           gl_je_headers gjh
    WHERE gjl.je_header_id = gjh.je_header_id
      AND gjl.set_of_books_id = &&sob_id
      AND gjh.actual_flag = 'A'
      AND gjl.code_combination_id = &&acct_id
      GROUP BY gjh.je_source,
               gjh.je_category,
               gjl.status,
               gjh.period_name,
               gjl.code_combination_id 
/
/*
GL value for the account in all sobs 
*/

 select    gjl.set_of_books_id,
           gjh.je_source,
           gjh.je_category,
           gjl.status,
           gjh.period_name,
           gjl.code_combination_id ccid,
           NVL(sum(nvl(gjl.accounted_cr,0)),0) CR,
           NVL(sum(nvl(gjl.accounted_dr,0)),0) DR
      FROM gl_je_lines gjl,
           gl_je_headers gjh
    WHERE gjl.je_header_id = gjh.je_header_id
      AND gjh.actual_flag = 'A'
      AND gjl.code_combination_id = &&acct_id
      GROUP BY gjl.set_of_books_id,
               gjh.je_source,
               gjh.je_category,
               gjl.status,
               gjh.period_name,
               gjl.code_combination_id 
/
/*
GL Balances for Account
*/
SELECT  set_of_books_id,
	code_combination_id,
	currency_code,
	period_name,
	actual_flag,
	revaluation_status,
	period_type,
	period_year,
	period_num,
	period_net_dr,
	period_net_cr,
	quarter_to_date_dr,
	quarter_to_date_cr,
	project_to_date_dr,
	project_to_date_cr,
	begin_balance_dr,
	begin_balance_cr,
	period_net_dr_beq,
	period_net_cr_beq,
	begin_balance_dr_beq,
	begin_balance_cr_beq,
	encumbrance_doc_id,
	encumbrance_line_num
  FROM GL_BALANCES 
 WHERE code_combination_id =&&acct_id
/
select PADDED_CONCATENATED_SEGMENTS
 from gl_code_combinations_kfv
  where code_combination_id = &&acct_id
/
spool off