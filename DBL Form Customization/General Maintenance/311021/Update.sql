/* Formatted on 10/31/2021 11:46:23 AM (QP5 v5.365) */
SELECT                                                                     --*
       NVL (COUNT (voucher_no), 100)
  --INTO l_count
  FROM xxaa_apinv_iface_tbl
 WHERE     voucher_no = :p_source
       AND NOT EXISTS
               (SELECT 1
                  FROM ap_invoices_all
                 WHERE invoice_num = :p_source);

SELECT COUNT (voucher_no)
  INTO l_count
  FROM xxaa_apinv_iface_tbl
 WHERE     voucher_no = p_source
       AND NOT EXISTS
               (SELECT 1
                  FROM ap_invoices_all
                 WHERE invoice_num = :p_source);