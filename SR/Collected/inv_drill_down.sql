/*==========================================================================+
|   Copyright (c) 2007 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : inv_drill_down.sql                                         |
| Description  : Diagnostic for Drill down problems in Inventory journals.  |
|                This will create a spool file with                         |
|                inv_je_header_<<je_header_id>>                             |
|                Customer needs to give input as je_header_id and           |
|                organization_id .                                          |
|                je_header_id can be got from journal inquiry screen.       |
|                At the journal inquiry one needs to go to                  |
|                Diagnostics -> Examine ->                                  |
|                Block : Header                                             |
|                Field : JE_HEADER_ID                                       |
|                                                                           |
| Revision                                                                  |
|  01/30/2007      Anup Jha    Creation                                     |
|                                                                           |
|                                                                           |
+==========================================================================*/
set pages 999
set lines 500
undef je_header_id
undef organization_id
define je_header_id = &&je_header_id
define organization_id = &&organization_id
undef spool_file
define spool_file = inv_je_header_&&je_header_id
spool &&spool_file
/* 
 Instance name and org and date of run
*/
select name,
       &&organization_id organization_id,
       to_char(sysdate,'DD-MM-YYYY hh24:mi:ss')
 from V$DATABASE
/
/*
 Organization Parameter
*/
SELECT organization_id org,
       primary_cost_method pcm,
       cost_organization_id cost_org,
       default_cost_group_id dcg,
       organization_code org_code,
       project_reference_enabled pre,
       wms_enabled_flag wms,
       NEGATIVE_INV_RECEIPT_CODE neg_inv,
       general_ledger_update_code
  FROM mtl_parameters
 WHERE organization_id = &&organization_id
/
/* 
  Value from Gl drill down view of mta(Inventory Sub ledger)
*/
SELECT cagl.application_id
      ,cagl.set_of_books_id
      ,cagl.je_line_num
      ,cagl.code_combination_id    
      ,SUM(NVL(cagl.accounted_dr,0))
      ,SUM(NVL(cagl.accounted_cr,0))
 FROM  CST_AEL_GL_INV_V cagl
 WHERE cagl.je_header_id = &&je_header_id
 GROUP BY cagl.application_id
      ,cagl.set_of_books_id
      ,cagl.je_line_num
      ,cagl.code_combination_id
/
/* 
  Value from Gl drill down view of WTA (wip sub ledger)
*/
SELECT cagl.application_id
      ,cagl.set_of_books_id
      ,cagl.je_line_num
      ,cagl.code_combination_id    
      ,SUM(NVL(cagl.accounted_dr,0))
      ,SUM(NVL(cagl.accounted_cr,0))
 FROM  CST_AEL_GL_WIP_V cagl
 WHERE cagl.je_header_id = &&je_header_id
 GROUP BY cagl.application_id
      ,cagl.set_of_books_id
      ,cagl.je_line_num
      ,cagl.code_combination_id
/
/* 
 GL_JE_HEADERS
*/
 SELECT  JE_HEADER_ID          
        ,SET_OF_BOOKS_ID
	,JE_BATCH_ID
	,ACTUAL_FLAG
        ,JE_CATEGORY            
        ,JE_SOURCE              
        ,PERIOD_NAME            
        ,CURRENCY_CODE          
        ,STATUS                 
        ,to_char(DATE_CREATED,'DD-MM-YYYY hh24:mi:ss')
 FROM gl_je_headers
 WHERE je_header_id = &&je_header_id
/
/* 
 GL_IMPORT_REFERENCES
*/
 SELECT DISTINCT 
        je_batch_id
       ,je_header_id
       ,substr(reference_1,1,20) gl_batch
       ,substr(reference_2,1,20) org_code
       ,gl_sl_link_table
   FROM gl_import_references 
  WHERE je_header_id = &&je_header_id
/
/* 
 Value from GL
*/ 
 SELECT  gh.set_of_books_id
        ,gl.code_combination_id
        ,gh.actual_flag
        ,gh.je_category
	,gh.je_source
        ,SUM(NVL(gl.accounted_dr,0))
        ,SUM(NVL(gl.accounted_cr,0))
 FROM   gl_je_lines gl,gl_je_headers gh
 WHERE  gh.je_header_id = &&je_header_id
 AND    gl.je_header_id = gh.je_header_id
 GROUP  BY gh.set_of_books_id
        ,gl.code_combination_id
        ,gh.actual_flag
        ,gh.je_category
	,gh.je_source
/
/* 
 Value from GL period wise
*/ 
 SELECT  gh.set_of_books_id
        ,gl.code_combination_id
        ,gh.actual_flag
        ,gh.je_category
	,gh.je_source
	,gh.period_name
        ,SUM(NVL(gl.accounted_dr,0))
        ,SUM(NVL(gl.accounted_cr,0))
 FROM   gl_je_lines gl,gl_je_headers gh
 WHERE  gh.je_header_id = &&je_header_id
 AND    gl.je_header_id = gh.je_header_id
 GROUP  BY gh.set_of_books_id
        ,gl.code_combination_id
        ,gh.actual_flag
        ,gh.je_category
	,gh.je_source
	,gh.period_name
/
/*
 Duplicate GLIR If this query gives output then the drill down may give 
 duplicate records.
*/
 SELECT je_batch_id,    
        je_header_id,   
        je_line_num,
	reference_3,
	count(1)
   FROM GL_IMPORT_REFERENCES 
 WHERE je_header_id = &&je_header_id
GROUP BY je_batch_id,    
        je_header_id,   
        je_line_num,
	reference_3
 HAVING count(1) > 1
/
/* 
MTA Value for the GL batch id
*/
 SELECT mta.reference_account,
        decode(mta.encumbrance_type_ID,NULL,'A','E') actual_flag,
        mta.accounting_line_type alt,
	mta.organization_id,
	mta.gl_batch_id,
        sum(mta.base_transaction_value) value
   FROM mtl_transaction_accounts mta
  WHERE mta.gl_batch_id IN (SELECT to_number(glir.reference_1)
			      FROM gl_import_references glir
			     WHERE glir.je_header_id = &&je_header_id
			     )
GROUP BY mta.reference_account,
        decode(mta.encumbrance_type_ID,NULL,'A','E') ,
        mta.accounting_line_type ,
	mta.organization_id,
	mta.gl_batch_id
/
/* 
MTA Value for the GL batch id period wise
*/
SELECT  mta.reference_account,
        decode(mta.encumbrance_type_ID,NULL,'A','E') actual_flag,
        mta.accounting_line_type alt,
	mta.organization_id,
	mta.gl_batch_id,
	oap.period_name,
        sum(mta.base_transaction_value) value
   FROM mtl_transaction_accounts mta,
        org_acct_periods oap
  WHERE mta.gl_batch_id IN (SELECT to_number(glir.reference_1)
			      FROM gl_import_references glir
			     WHERE glir.je_header_id = &&je_header_id
			     )
    AND oap.organization_id = mta.organization_id
    AND mta.transaction_date BETWEEN oap.period_start_date
                                 AND (oap.schedule_close_date+0.9999)
GROUP BY mta.reference_account,
        decode(mta.encumbrance_type_ID,NULL,'A','E') ,
        mta.accounting_line_type ,
	mta.organization_id,
	mta.gl_batch_id,
	oap.period_name
/
/* 
WTA Value for the GL batch id
*/
 SELECT mta.reference_account,
        'A' actual_flag,
        mta.accounting_line_type alt,
	mta.organization_id,
	mta.gl_batch_id,
        sum(mta.base_transaction_value) value
   FROM wip_transaction_accounts mta
  WHERE mta.gl_batch_id IN (SELECT to_number(glir.reference_1)
			      FROM gl_import_references glir
			     WHERE glir.je_header_id = &&je_header_id
			     )
GROUP BY mta.reference_account,
         mta.accounting_line_type ,
	 mta.organization_id,
	 mta.gl_batch_id
/
/* 
WTA Value for the GL batch id period wise
*/
SELECT  mta.reference_account,
        'A' actual_flag,
        mta.accounting_line_type alt,
	mta.organization_id,
	mta.gl_batch_id,
	oap.period_name,
        sum(mta.base_transaction_value) value
   FROM wip_transaction_accounts mta,
        org_acct_periods oap
  WHERE mta.gl_batch_id IN (SELECT to_number(glir.reference_1)
			      FROM gl_import_references glir
			     WHERE glir.je_header_id = &&je_header_id
			     )
    AND oap.organization_id = mta.organization_id
    AND mta.transaction_date BETWEEN oap.period_start_date
                                 AND (oap.schedule_close_date+0.9999)
GROUP BY mta.reference_account,
         mta.accounting_line_type ,
	 mta.organization_id,
	 mta.gl_batch_id,
	 oap.period_name
/
spool off 