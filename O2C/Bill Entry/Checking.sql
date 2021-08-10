SELECT   pha.segment1, pla.unit_price
    FROM po_headers_all pha, apps.po_lines_all pla, po_vendors pv, xxdbl_company_le_mapping_v cl
   WHERE 1=1
        AND pha.type_lookup_code IN ('BLANKET', 'STANDARD')
     AND NVL (pha.authorization_status, 'INCOMPLETE') = 'APPROVED'
     AND pha.approved_flag = 'Y'
     AND NVL (pha.cancel_flag, 'N') = 'N'
     AND pha.vendor_id = pv.vendor_id(+)
     AND cl.org_id = pha.org_id
     and pla.po_header_id=pha.po_header_id
     AND pha.segment1 = :P_PO_NUMBER
     and exists(select 1 from apps.mtl_system_items_vl msi where msi.inventory_item_id=pla.item_id and msi.segment1 =:P_ITEM_CODE )
     --and =:P_ITEM_CODE     --YRN20S100CVC54699919
     AND UPPER (cl.legal_entity_name) LIKE
             RTRIM (UPPER (:xx_ar_bills_headers_all--.customer_name
             ), '.')
             || '%'
     AND EXISTS (SELECT 1
                   FROM xx_dbl_po_recv_adjust x
                  WHERE x.po_no = pha.segment1);