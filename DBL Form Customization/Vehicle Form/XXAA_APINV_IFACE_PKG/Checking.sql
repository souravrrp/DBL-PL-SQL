select
*
FROM xx_vms_bill_mst api
where BLL_NO=:BLL_NO    --BILL71750 --BILL71751 ---BILL71752    --BILL71753 --BILL71754 --BILL71755 --BILL71756

select
*
from
xxaa_apinv_iface_tbl
where 1=1
and VOUCHER_NO='71757'

SELECT NVL (COUNT (voucher_no), 100)
        FROM xxaa_apinv_iface_tbl
       WHERE voucher_no = '71757';
       
       
       SELECT SUM (NVL (apl.item_qty, 1) * NVL (apl.unit_price, 1))
        --INTO v_bill_amount
        FROM xx_vms_bill_dtl apl, xx_vms_bill_mst api
       WHERE api.VMS_BILL_ID = apl.VMS_BILL_ID AND API.VMS_BILL_ID = '71757';
       
       
       SELECT api.purch_ou,
                api.org_id,
                api.vandor_name,
                api.vendor_id,
                api.vendor_site_id,
                api.bill_date,
                API.VMS_BILL_ID voucher_no,
                api.remarks,
                api.maintaince_type,
                api.invoice_amount,
                apl.sl,
                --         apl.bill_amount,
                NVL (apl.item_qty, 1) * NVL (apl.unit_price, 1) bill_amount,
                apl.item_dtl,
                apl.vehicle_number,
                apl.dr_ccid,
                API.voucher_no inv_num
           --         apl.remarks
           FROM xx_vms_bill_mst api, xx_vms_bill_dtl apl
          WHERE     api.VMS_BILL_ID = apl.VMS_BILL_ID
                AND ledger_name IS NOT NULL
                AND vendor_id IS NOT NULL
                AND vendor_site_id IS NOT NULL
                AND API.VMS_BILL_ID = '71757';

SELECT   api.source,
                           api.org_id,
                           api.invoice_type,
                           api.vendor_id,
                           api.vendor_site_id,
                           api.invoice_date,
                           api.invoice_number,
                           api.line_description,
                           api.invoice_amount,
                           api.term_id,
                           api.invoice_currency,
                 api.gl_date,
                           api.payment_currency,
                           api.payment_method,
                           api.voucher_no
             FROM xxaa_apinv_iface_tbl api
            WHERE api.ERROR_CODE = 'V'
            and voucher_no='71755'
         ORDER BY api.org_id,
                  api.invoice_type,
                  api.vendor_id,
                  api.vendor_site_id,
                  api.invoice_number;

SELECT apl.line_num,
                  apl.line_type,
                  apl.line_amount,
                  apl.code_combination_id,
                  apl.line_description,
                  apl.maintanance_area,                                   --31
                  apl.item_dtl,
                  apl.vehicle_number
             FROM xxaa_apinv_iface_tbl apl
            WHERE apl.ERROR_CODE = 'V'
                  and voucher_no='71755'
         ORDER BY apl.line_num;
         
         
         
         SELECT *
         --COUNT (voucher_no)
        --INTO l_count
        FROM xxaa_apinv_iface_tbl
       WHERE voucher_no = :p_source;
       
       select
       *
       from
       ap_invoices_interface
       where 1=1
       and INVOICE_NUM='TEST45362327667';
       
       
       delete ap_invoices_interface
            --SET STATUS = 'REJECTED'
          WHERE INVOICE_NUM='TEST45362327667';
          
          select STATUS from ap_invoices_interface
             --SET STATUS = 'REJECTED'
             where invoice_num='71751';
             
             
             commit;
       
       SELECT *
        FROM ap_invoice_lines_interface
       WHERE INVOICE_ID = '1581456';
       
        delete ap_invoice_lines_interface
            --SET STATUS = 'REJECTED'
          WHERE INVOICE_ID in ('1581456');
       
       SELECT DISTINCT org_id, invoice_amount
        --INTO l_organization_id, p_total_invoice_amount
        FROM xxaa_apinv_iface_tbl
       WHERE voucher_no = :p_source
       
       SELECT doc_sequence_value
        --INTO l_invoice_number
        FROM ap_invoices_all
       WHERE 
       invoice_num = :p_source;
       
       
          
      execute apps.xxaa_apinv_iface_pkg.xxaa_apinv_iface_load_prc(71757);
    
      execute apps.xxaa_apinv_iface_pkg.xxaa_apinv_iface_import_prc(71757);