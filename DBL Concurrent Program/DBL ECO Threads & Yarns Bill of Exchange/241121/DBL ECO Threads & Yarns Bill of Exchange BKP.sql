/* Formatted on 18-Jan-20 14:39:05 (QP5 v5.136.908.31019) */
WITH commercial_invoice_details
        AS (SELECT ph.customer_number,
                   ph.customer_name,
                   ph.cutomer_address,
                   cih.comm_inv_number,
                   cih.comm_inv_status,
                   REGEXP_SUBSTR (mlh.bank_name, '^[^-]*') bank_name,
                   mlh.bank_address,
                   ph.attribute1 pi_bank_name,
                   ph.attribute2 pi_branch_name,
                   pi_all.pi_num,
                   pi_dt.pi_date,
                   TRUNC (cih.comm_inv_date) invoice_date,
                   mic.segment3,
                   --msi.description,
                   (CASE
                       WHEN mic.segment3 = 'DYED FIBER'
                       THEN
                          'Fiber Dyeing Charges'
                       WHEN mic.segment3 = 'DYED YARN'
                       THEN
                          'Yarn Dyeing Charges'
                       WHEN mic.segment3 = 'SEWING THREAD'
                       THEN
                          'Sewing Thread'
                    END)
                      type_of_goods,
                   (TO_NUMBER (cil.delivery_qty))
                   * (100 / (100 - ola.cust_model_serial_number))
                      shipped_quantity,
                   cil.uom,
                   --cil.line_value / cil.delivery_qty rate,
                   --cil.rate rate,
                   mic.category_concat_segs article_ticket,
                   (TO_NUMBER (cil.attribute4)) net_weight,
                   (TO_NUMBER (cil.attribute5)) gross_weight,
                   line_value,
                   mlh.bin_number,
                   mlh.tin_number,
                   mlh.irc_number,
                   mlh.erc_number,
                   mlh.master_lc_number bblc_no,
                   TRUNC (mlh.master_lc_received_date) bb_lc_date,
                   TRUNC (mlh.attribute1) last_date_delivery,
                   mlh.amd_no,
                   mlh.attribute6 amd_date,
                   mlh.exp_number exp_no,
                   mlh.exp_date exp_date,
                   lcd.lc_number master_lc,
                   lcd.lc_date master_lc_date,
                   lcd.c_bin_no,
                   lcd.c_tin_no,
                   lcd.c_irc_no,
                   lcd.c_erc_no,
                   lcd.buyers_po,
                   lcd.lacf_number,
                   lcd.hs_code,
                   lcd.bank_bin_no,
                   lcd.bbdc_no,
                   lcd.cbc_no,
                   ph.attribute4 payment_terms
              FROM mtl_item_categories_v mic,
                   mtl_system_items msi,
                   xxdbl_comm_inv_headers cih,
                   xxdbl_comm_inv_lines cil,
                   ra_customer_trx_lines_all ctl,
                   oe_order_lines_all ola,
                   xxdbl_master_lc_headers mlh,
                   xxdbl_master_lc_line1 mll,
                   --                   xxdbl_master_lc_line2 mll2,
                   xxdbl_proforma_headers ph,
                   (  SELECT comm_inv_number,
                             listagg (pi_number, ',')
                                WITHIN GROUP (ORDER BY pi_number)
                                AS pi_num
                        FROM (  SELECT cih.comm_inv_number, cil.pi_number
                                  FROM xxdbl_comm_inv_headers cih,
                                       xxdbl_comm_inv_lines cil
                                 WHERE cih.comm_inv_header_id =
                                          cil.comm_inv_header_id
                              GROUP BY cih.comm_inv_number, cil.pi_number) pi
                    GROUP BY comm_inv_number) pi_all,
                   (  SELECT comm_inv_number,
                             listagg (pi_dat, ',')
                                WITHIN GROUP (ORDER BY pi_dat)
                                AS pi_date
                        FROM (  SELECT cih.comm_inv_number, cil.attribute3 pi_dat
                                  FROM xxdbl_comm_inv_headers cih,
                                       xxdbl_comm_inv_lines cil
                                 WHERE cih.comm_inv_header_id =
                                          cil.comm_inv_header_id
                              GROUP BY cih.comm_inv_number, cil.attribute3) pi
                    GROUP BY comm_inv_number) pi_dt,
                   (  SELECT master_lc_number,
                             amd_no,
                             listagg (lc_number, ',')
                                WITHIN GROUP (ORDER BY lc_number)
                                AS lc_number,
                             listagg (master_lc_date, ',')
                                WITHIN GROUP (ORDER BY lc_number)
                                AS lc_date,
                             MAX (c_bin_no) AS c_bin_no,
                             MAX (c_tin_no) AS c_tin_no,
                             MAX (c_irc_no) AS c_irc_no,
                             MAX (c_erc_no) AS c_erc_no,
                             MAX (buyers_po) AS buyers_po,
                             MAX (lacf_number) AS lacf_number,
                             MAX (hs_code) AS hs_code,
                             MAX (bank_bin_no) AS bank_bin_no,
                             MAX (bbdc_no) AS bbdc_no,
                             MAX (cbc_no) AS cbc_no
                        FROM (  SELECT mlh.master_lc_number,
                                       mlh.amd_no,
                                       mll2.lc_number,
                                       mll2.master_lc_date,
                                       mll2.bin_number c_bin_no,
                                       mll2.tin_number c_tin_no,
                                       mll2.irc_number c_irc_no,
                                       mll2.erc_number c_erc_no,
                                       mll2.buyers_po,
                                       mll2.lacf_number,
                                       mll2.attribute1 hs_code,
                                       mll2.attribute2 bank_bin_no,
                                       mll2.attribute3 bbdc_no,
                                       mll2.attribute4 cbc_no
                                  FROM xxdbl_master_lc_headers mlh,
                                       xxdbl_master_lc_line2 mll2
                                 WHERE mlh.master_lc_header_id =
                                          mll2.master_lc_header_id
                                       AND mlh.master_lc_status <> 'CANCELLED'
                              GROUP BY master_lc_number,
                                       amd_no,
                                       lc_number,
                                       mll2.master_lc_date,
                                       mll2.bin_number,
                                       mll2.tin_number,
                                       mll2.irc_number,
                                       mll2.erc_number,
                                       mll2.buyers_po,
                                       mll2.lacf_number,
                                       mll2.attribute1,
                                       mll2.attribute2,
                                       mll2.attribute3,
                                       mll2.attribute4) tt
                    GROUP BY master_lc_number, amd_no) lcd
             WHERE     cil.inventory_item_id = mic.inventory_item_id
                   AND cil.inventory_item_id = msi.inventory_item_id
                   AND mic.organization_id = msi.organization_id
                   AND mic.organization_id = 150
                   AND mic.category_set_name = 'Inventory'
                   --AND mic.category_set_id = '1100000061'
                   AND cih.comm_inv_header_id = cil.comm_inv_header_id
                   AND cil.pi_number = mll.pi_number
                   AND mlh.master_lc_header_id = mll.master_lc_header_id
                   --AND mlh.master_lc_header_id = mll2.master_lc_header_id
                   AND cil.pi_number = mll.pi_number
                   AND mll.pi_number = ph.proforma_number
                   AND cih.attribute4 = mlh.master_lc_header_id
                   AND cih.attribute8 = mlh.amd_no
                   AND cih.attribute1 = lcd.master_lc_number
                   AND cih.attribute8 = lcd.amd_no
                   AND interface_line_attribute6 = line_id
                   AND cil.invoice_line_id = ctl.customer_trx_line_id
                   AND ctl.interface_line_attribute6 = ola.line_id
                   AND cih.comm_inv_status = 'CONFIRMED'
                   AND mlh.master_lc_status IN ('CONFIRMED', 'AMENDED')
                   --AND cih.comm_inv_number = 'eco/2020/CI000074'
                   --AND pi_all.pi_num = ph.proforma_number
                   AND cih.comm_inv_number = pi_all.comm_inv_number
                   AND cih.comm_inv_number = pi_dt.comm_inv_number)
  SELECT comm_inv_number,
         invoice_date comm_inv_date,
         comm_inv_status,
         payment_terms trem,
         MAX (pi_bank_name) bank_name,
         MAX (pi_branch_name) branch_name,
         customer_name,
         MAX (cutomer_address) cutomer_address,
         type_of_goods,
         bblc_no bb_lc_number,
         bb_lc_date bb_lc_date,
         ROUND(SUM (line_value),2) lc_value,
         bblc_no credit_no,
         bank_name lc_bank_name,
         bank_address lc_bank_address,
         exp_no,
         exp_date,
         amd_no,
         amd_date,
         master_lc lc_number,
         master_lc_date lc_date,
         bin_number,
         tin_number,
         irc_number,
         erc_number,
         bbdc_no,
         c_bin_no a_bin,
         c_tin_no a_tin,
         c_irc_no a_irc,
         buyers_po a_po,
         lacf_number a_lacf,
         bank_bin_no bank_bin,
         hs_code hs_code
    FROM commercial_invoice_details
   WHERE comm_inv_number = :p_comm_inv_number
GROUP BY customer_number,
         comm_inv_status,
         customer_name,
         comm_inv_number,
         bank_name,
         bank_address,
         pi_num,
         pi_date,
         invoice_date,
         type_of_goods,
         uom,
         article_ticket,
         bin_number,
         tin_number,
         irc_number,
         erc_number,
         bblc_no,
         bb_lc_date,
         last_date_delivery,
         amd_no,
         amd_date,
         exp_no,
         exp_date,
         master_lc,
         master_lc_date,
         c_bin_no,
         c_tin_no,
         c_irc_no,
         c_erc_no,
         buyers_po,
         lacf_number,
         hs_code,
         bank_bin_no,
         bbdc_no,
         cbc_no,
         payment_terms