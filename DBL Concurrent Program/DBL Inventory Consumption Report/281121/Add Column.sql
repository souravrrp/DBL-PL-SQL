/* Formatted on 11/28/2021 5:31:37 PM (QP5 v5.365) */
  SELECT DISTINCT MAX (mmt.transaction_id),
                  mmt.inventory_item_id,
                  l.po_header_id,
                  l.po_number,
                  l.lc_number,
                  l.supplier_name
    FROM xx_lc_details             l,
         mtl_material_transactions mmt,
         apps.xxdbl_inv_con_rpt_mv# icrm,
         apps.po_headers_all       pha,
         apps.mtl_system_items_fvl itm
   WHERE     mmt.organization_id = icrm.organization_id
         AND mmt.organization_id = itm.organization_id
         AND icrm.transaction_id = mmt.transaction_id
         AND mmt.inventory_item_id = itm.inventory_item_id
         AND mmt.transaction_source_id = pha.po_header_id
         AND mmt.transaction_source_id = l.po_header_id
         AND pha.po_header_id = l.po_header_id
         AND TRUNC (mmt.transaction_date) < :p_date_to
         AND mmt.inventory_item_id = 11950
         AND (   :p_set_of_books_id IS NULL
              OR icrm.set_of_books_id = :p_set_of_books_id)
         AND ( :p_company IS NULL OR icrm.company_code = :p_company)
         AND ( :p_org_id IS NULL OR icrm.organization_id = :p_org_id)
         AND ( :p_account IS NULL OR icrm.natural_acc = :p_account)
         AND mmt.transaction_id =
             (SELECT MAX (mt.transaction_id)
                FROM inv.mtl_material_transactions mt,
                     po.po_headers_all            pha,
                     xx_lc_details                l
               WHERE     1 = 1
                     AND mt.transaction_source_id = pha.po_header_id
                     AND pha.po_header_id = l.po_header_id
                     AND ( :p_org_id IS NULL OR mt.organization_id = :p_org_id)
                     AND mt.inventory_item_id = mmt.inventory_item_id)
         AND :p_report_type = 'Rawdata'
GROUP BY mmt.inventory_item_id,
         l.po_header_id,
         l.po_number,
         l.lc_number,
         l.supplier_name,
         mmt.transaction_date
--having max (mmt.transaction_date) = mmt.transaction_date