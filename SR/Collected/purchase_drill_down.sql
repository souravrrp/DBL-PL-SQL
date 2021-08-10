/*==========================================================================+
|   Copyright (c) 2007 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : purchasing_drill_down.sql                                  |
| Description  : Diagnostic for Drill down problems in Purchasing journals. |
|                This will create a spool file with                         |
|                purch_je_header_<<je_header_id>>                           |
|                Customer needs to give input as je_header_id               |
|                je_header_id can be got from journal inquiry screen.       |
|                At the journal inquiry one needs to go to                  |
|                Diagnostics -> Examine ->                                  |
|                Block : Header                                             |
|                Field : JE_HEADER_ID                                       |
| Revision                                                                  |
|  01/30/2007      Anup Jha    Creation                                     |
|                                                                           |
|                                                                           |
+==========================================================================*/
set pages 999
set lines 500
undef je_header_id
define je_header_id = &&je_header_id
undef spool_file
define spool_file = purch_je_header_&&je_header_id
spool &&spool_file
/* 
 Instance name and date of run
*/
select name,to_char(sysdate,'DD-MM-YYYY hh24:mi:ss')
 from V$DATABASE
/
/* 
  Value from Gl drill down view
*/
SELECT rrsl.application_id
      ,rrsl.set_of_books_id
      ,rrsl.je_line_num
      ,rrsl.code_combination_id    
      ,SUM(NVL(rrsl.accounted_dr,0))
      ,SUM(NVL(rrsl.accounted_cr,0))
 FROM  rcv_ael_gl_v rrsl
 WHERE rrsl.je_header_id = &&je_header_id
 GROUP BY rrsl.application_id
      ,rrsl.set_of_books_id
      ,rrsl.je_line_num
      ,rrsl.code_combination_id
/
/*
  Value from RRSL(Purchasing sub ledger)
*/
SELECT rrsl.set_of_books_id   
      ,rrsl.code_combination_id
      ,rrsl.actual_flag 
      ,rrsl.je_source_name
      ,rrsl.je_category_name
      ,SUM(NVL(rrsl.accounted_dr,0))
      ,SUM(NVL(rrsl.accounted_cr,0))
 FROM  rcv_receiving_sub_ledger rrsl
 WHERE rrsl.gl_sl_link_id IN
       ( SELECT glir.gl_sl_link_id
         FROM   gl_import_references glir
         WHERE  glir.je_header_id = &&je_header_id
       )
 GROUP BY rrsl.set_of_books_id
       ,rrsl.code_combination_id
       ,rrsl.actual_flag
       ,rrsl.je_source_name
       ,rrsl.je_category_name
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
 Duplicate GLIR(gl_import_references) 
 If this query gives output then the drill down may give 
 duplicate records.
*/
 SELECT je_batch_id,    
        je_header_id,   
        je_line_num,
	reference_5,
	count(1)
   FROM GL_IMPORT_REFERENCES 
 WHERE je_header_id = &&je_header_id
GROUP BY je_batch_id,    
        je_header_id,   
        je_line_num,
	reference_5
 HAVING count(1) > 1
/
/* 
 Referenc3(po_distribution_id) null in RRSL
 This is a data corruption in Receiving sub ledger
*/
SELECT rrsl.actual_flag,            
       rrsl.je_source_name,
       rrsl.je_category_name,
       rrsl.set_of_books_id,
       rrsl.accounting_date,
       rrsl.code_combination_id,
       rrsl.rcv_transaction_id,
       sum(nvl(accounted_dr,0)) accounted_dr,
       sum(nvl(accounted_cr,0)) accounted_cr
 FROM  rcv_receiving_sub_ledger rrsl
 WHERE rrsl.gl_sl_link_id IN
       ( SELECT glir.gl_sl_link_id
         FROM   gl_import_references glir
         WHERE  glir.je_header_id = &&je_header_id
       )
 AND   rrsl.reference3 IS NULL
 GROUP BY rrsl.actual_flag,            
          rrsl.je_source_name,
          rrsl.je_category_name,
          rrsl.set_of_books_id,
          rrsl.accounting_date,
          rrsl.code_combination_id,
	  rrsl.rcv_transaction_id
/
/* 
 rcv_transaction_id null in RRSL
 This is a data corruption in Receiving sub ledger
*/
SELECT rrsl.actual_flag,            
       rrsl.je_source_name,
       rrsl.je_category_name,
       rrsl.set_of_books_id,
       rrsl.accounting_date,
       rrsl.code_combination_id,
       substr(rrsl.reference3,1,20) po_dist,
       sum(nvl(accounted_dr,0)) accounted_dr,
       sum(nvl(accounted_cr,0)) accounted_cr
 FROM  rcv_receiving_sub_ledger rrsl
 WHERE rrsl.gl_sl_link_id IN
       ( SELECT glir.gl_sl_link_id
         FROM   gl_import_references glir
         WHERE  glir.je_header_id = &&je_header_id
       )
 AND   rrsl.rcv_transaction_id IS NULL
 GROUP BY rrsl.actual_flag,            
          rrsl.je_source_name,
          rrsl.je_category_name,
          rrsl.set_of_books_id,
          rrsl.accounting_date,
          rrsl.code_combination_id,
	  substr(rrsl.reference3,1,20)
/
/*
  missing Rcv_shipment_headers 
  This is a data corruption in Receiving Transaction
*/
 SELECT rct.transaction_id txn_id,
        rct.transaction_type txn_type,
        rct.shipment_header_id ship_header,
	rct.shipment_line_id ship_line,
	rct.po_header_id po_header,
	rct.po_line_location_id po_line_loc,
	rct.po_distribution_id po_dist,
	rct.organization_id org,
	rct.destination_type_code dets_typ_code,
	rct.source_doc_quantity sd_qty,
	rct.po_unit_price
   FROM rcv_transactions rct
 WHERE rct.transaction_id in
    ( SELECT rrsl.rcv_transaction_id
       FROM rcv_receiving_sub_ledger rrsl
      WHERE rrsl.gl_sl_link_id IN
        ( SELECT glir.gl_sl_link_id
          FROM   gl_import_references glir
          WHERE  glir.je_header_id = &&je_header_id
        )
     )
 AND NOT EXISTS ( SELECT 'x'
                   FROM rcv_shipment_headers rsh
   WHERE rsh.shipment_header_id = rct.shipment_header_id
                 )
/
/* 
 Missing Rcv_shipment_lines 
 This is a data corruption in Receiving Transaction
*/
 SELECT rct.transaction_id txn_id,
        rct.transaction_type txn_type,
        rct.shipment_header_id ship_header,
	rct.shipment_line_id ship_line,
	rct.po_header_id po_header,
	rct.po_line_location_id po_line_loc,
	rct.po_distribution_id po_dist,
	rct.organization_id org,
	rct.destination_type_code dets_typ_code,
	rct.source_doc_quantity sd_qty,
	rct.po_unit_price
   FROM rcv_transactions rct
 WHERE rct.transaction_id in
    ( SELECT rrsl.rcv_transaction_id
       FROM rcv_receiving_sub_ledger rrsl
      WHERE rrsl.gl_sl_link_id IN
        ( SELECT glir.gl_sl_link_id
          FROM   gl_import_references glir
          WHERE  glir.je_header_id = &&je_header_id
        )
     )
 AND NOT EXISTS ( SELECT 'x'
                   FROM rcv_shipment_lines rsl
   WHERE rsl.shipment_line_id = rct.shipment_line_id
                 )
/
/* 
  Missing PO_Vendors 
  This is a data corruption in PO tables
*/
SELECT poh.po_header_id,
       poh.org_id,
       poh.segment1,
       poh.type_lookup_code po_type,
       poh.vendor_id,
       poh.vendor_site_id,
       poh.closed_date
  FROM po_headers_all poh
 WHERE poh.po_header_id IN
       ( SELECT pod.po_header_id
           FROM po_distributions_all pod
 WHERE pod.po_distribution_id IN
    ( SELECT to_number(rrsl.reference3)
                FROM rcv_receiving_sub_ledger rrsl
               WHERE rrsl.gl_sl_link_id IN
                     ( SELECT glir.gl_sl_link_id
                         FROM   gl_import_references glir
                        WHERE  glir.je_header_id = &&je_header_id
                      )
     )
        )
   AND NOT EXISTS ( SELECT 'x'
                      FROM po_vendors pov
     WHERE pov.vendor_id = poh.vendor_id)
/
/*
Missing PO_Vendor SITE
This is a data corruption in PO tables
*/
SELECT poh.po_header_id,
        poh.org_id,
        poh.segment1,
        poh.type_lookup_code po_type,
        poh.vendor_id,
        poh.vendor_site_id,
        poh.closed_date
  FROM po_headers_all poh
 WHERE poh.po_header_id IN
       ( SELECT pod.po_header_id
           FROM po_distributions_all pod
 WHERE pod.po_distribution_id IN
    ( SELECT to_number(rrsl.reference3)
                FROM rcv_receiving_sub_ledger rrsl
               WHERE rrsl.gl_sl_link_id IN
                     ( SELECT glir.gl_sl_link_id
                         FROM   gl_import_references glir
                        WHERE  glir.je_header_id = &&je_header_id
                      )
     )
        )
   AND NOT EXISTS ( SELECT 'x'
                      FROM po_vendor_sites_all povs
     WHERE povs.vendor_site_id = poh.vendor_site_id)
/
/* 
  Missing PO Distribution 
  This is a data corruption in PO tables
*/
 SELECT rrsl.actual_flag act_flg,            
        rrsl.je_source_name source,
        rrsl.je_category_name cat_name,
        rrsl.set_of_books_id sob,
        rrsl.accounting_date acct_dte,
        rrsl.code_combination_id account,
	substr(rrsl.reference3,1,20) po_dist,
        sum(nvl(accounted_dr,0)) accounted_dr,
        sum(nvl(accounted_cr,0)) accounted_cr
   FROM rcv_receiving_sub_ledger rrsl
  WHERE rrsl.gl_sl_link_id IN
       ( SELECT glir.gl_sl_link_id
           FROM   gl_import_references glir
          WHERE  glir.je_header_id = &&je_header_id
        )
    AND NOT EXISTS ( SELECT 'x'
                       FROM po_distributions_all pod
      WHERE pod.po_distribution_id = to_number(rrsl.reference3)
    )
  GROUP BY rrsl.actual_flag ,            
        rrsl.je_source_name ,
        rrsl.je_category_name ,
        rrsl.set_of_books_id ,
        rrsl.accounting_date ,
        rrsl.code_combination_id ,
	substr(rrsl.reference3,1,20)
/
/* 
 Missing PO Headers 
 This is a data corruption in PO tables
*/
 SELECT rrsl.actual_flag act_flg,            
        rrsl.je_source_name source,
        rrsl.je_category_name cat_name,
        rrsl.set_of_books_id sob,
        rrsl.accounting_date acct_dte,
        rrsl.code_combination_id account,
	substr(rrsl.reference3,1,20) po_dist,
        sum(nvl(accounted_dr,0)) accounted_dr,
        sum(nvl(accounted_cr,0)) accounted_cr
   FROM rcv_receiving_sub_ledger rrsl
  WHERE rrsl.gl_sl_link_id IN
       ( SELECT glir.gl_sl_link_id
           FROM   gl_import_references glir
          WHERE  glir.je_header_id = &&je_header_id
        )
    AND NOT EXISTS ( SELECT 'x'
                       FROM po_distributions_all pod,
            po_headers_all poh
      WHERE pod.po_distribution_id = to_number(rrsl.reference3)
        AND pod.po_header_id = poh.po_header_id
    )
GROUP BY rrsl.actual_flag ,            
         rrsl.je_source_name ,
         rrsl.je_category_name ,
         rrsl.set_of_books_id ,
         rrsl.accounting_date ,
         rrsl.code_combination_id ,
	 substr(rrsl.reference3,1,20)
/
/* 
  Missing PO Line Location 
  This is a data corruption in PO tables
*/
 SELECT rrsl.actual_flag act_flg,            
        rrsl.je_source_name source,
        rrsl.je_category_name cat_name,
        rrsl.set_of_books_id sob,
        rrsl.accounting_date acct_dte,
        rrsl.code_combination_id account,
	substr(rrsl.reference3,1,20) po_dist,
        sum(nvl(accounted_dr,0)) accounted_dr,
        sum(nvl(accounted_cr,0)) accounted_cr
   FROM rcv_receiving_sub_ledger rrsl
  WHERE rrsl.gl_sl_link_id IN
       ( SELECT glir.gl_sl_link_id
           FROM   gl_import_references glir
          WHERE  glir.je_header_id = &&je_header_id
        )
    AND NOT EXISTS ( SELECT 'x'
                       FROM po_distributions_all pod,
            po_line_locations_all poll
      WHERE pod.po_distribution_id = to_number(rrsl.reference3)
        AND pod.line_location_id = poll.line_location_id
    )
 GROUP BY rrsl.actual_flag ,            
         rrsl.je_source_name ,
         rrsl.je_category_name ,
         rrsl.set_of_books_id ,
         rrsl.accounting_date ,
         rrsl.code_combination_id ,
	 substr(rrsl.reference3,1,20)
/
/* 
  Missing PO Lines 
  This is a data corruption in PO tables
*/
SELECT rrsl.actual_flag act_flg,            
        rrsl.je_source_name source,
        rrsl.je_category_name cat_name,
        rrsl.set_of_books_id sob,
        rrsl.accounting_date acct_dte,
        rrsl.code_combination_id account,
	substr(rrsl.reference3,1,20) po_dist,
        sum(nvl(accounted_dr,0)) accounted_dr,
        sum(nvl(accounted_cr,0)) accounted_cr
   FROM rcv_receiving_sub_ledger rrsl
  WHERE rrsl.gl_sl_link_id IN
       ( SELECT glir.gl_sl_link_id
           FROM   gl_import_references glir
          WHERE  glir.je_header_id = &&je_header_id
        )
    AND NOT EXISTS ( SELECT 'x'
                       FROM po_distributions_all pod,
            po_lines_all pol
      WHERE pod.po_distribution_id = to_number(rrsl.reference3)
        AND pol.po_line_id = pod.po_line_id
    )
GROUP BY rrsl.actual_flag ,            
         rrsl.je_source_name ,
         rrsl.je_category_name ,
         rrsl.set_of_books_id ,
         rrsl.accounting_date ,
         rrsl.code_combination_id ,
	 substr(rrsl.reference3,1,20)
/
/* 
  Missing gl import reference_5 
  This is a data corruption in GL import references table
*/
SELECT  rrsl.actual_flag act_flg,            
        rrsl.je_source_name source,
        rrsl.je_category_name cat_name,
        rrsl.set_of_books_id sob,
        rrsl.accounting_date acct_dte,
        rrsl.code_combination_id account,
	rrsl.rcv_transaction_id,
	substr(rrsl.reference3,1,20) po_dist,
        sum(nvl(accounted_dr,0)) accounted_dr,
        sum(nvl(accounted_cr,0)) accounted_cr
   FROM rcv_receiving_sub_ledger rrsl,
        gl_import_references glir
  WHERE rrsl.gl_sl_link_id = glir.gl_sl_link_id
    AND glir.je_header_id = 70845
    AND nvl(glir.reference_5,'-1233') <> rrsl.rcv_transaction_id
GROUP BY rrsl.actual_flag ,            
         rrsl.je_source_name ,
         rrsl.je_category_name ,
         rrsl.set_of_books_id ,
         rrsl.accounting_date ,
         rrsl.code_combination_id ,
	 rrsl.rcv_transaction_id,
	 substr(rrsl.reference3,1,20)
/
spool off