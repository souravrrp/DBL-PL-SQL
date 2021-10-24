/* Formatted on 2/3/2020 4:47:04 PM (QP5 v5.287) */
SELECT rt.transaction_id,
       rt.transaction_date,
       rsh.receipt_num,
       rt.quantity,
       rt.primary_quantity,
       rt.organization_id,
       rt.po_distribution_id,
       rt.po_header_id,
       rt.po_line_location_id,
       rt.po_line_id,
       rt.shipment_header_id,
       rt.shipment_line_id,
       rt.employee_id transacted_by,
       rt.vendor_id,
       rt.vendor_site_id,
       rt.transaction_type,
       rt.uom_code,
       rt.quantity_billed,
       rt.amount_billed,
       rsh.shipment_num,
       rsh.shipped_date,
       rsh.employee_id shipment_by,
       rsl.category_id,
       rsl.quantity_shipped,
       rsl.quantity_received,
       rsl.item_description,
       rsl.item_id,
       ood.operating_unit,
       ood.organization_code,
       hou.name ou_name
  --,rsh.*
  --,rt.*
  --,rsl.*
  FROM apps.rcv_transactions rt,
       apps.rcv_shipment_headers rsh,
       apps.rcv_shipment_lines rsl,
       apps.xxdbl_company_le_mapping_v led,
       apps.hr_operating_units hou,
       apps.org_organization_definitions ood
 WHERE     rsh.shipment_header_id = rt.shipment_header_id
       AND rsl.shipment_header_id = rsh.shipment_header_id
       AND rsl.po_header_id = rt.po_header_id
       AND rsl.po_line_id = rt.po_line_id
       AND rsl.po_line_location_id = rt.po_line_location_id
       AND ood.operating_unit = led.org_id
       AND rt.organization_id = ood.organization_id
       AND ood.operating_unit = hou.organization_id
       --AND rt.transaction_type = 'RECEIVE'
       AND ( :p_grn_no IS NULL OR (rsh.receipt_num = :p_grn_no))
       AND (   :p_operating_unit IS NULL OR (ood.operating_unit = :p_operating_unit))
       AND ( :p_ou_name IS NULL OR (hou.name = :p_ou_name))
       AND (   :p_organization_code IS NULL OR (ood.organization_code = :p_organization_code))
       AND (   :p_org_name IS NULL OR (UPPER (ood.organization_name) LIKE UPPER ('%' || :p_org_name || '%')))
       AND (   :p_legal_entity_name IS NULL OR (UPPER (led.legal_entity_name) LIKE UPPER ('%' || :p_legal_entity_name || '%')))
       AND (   :p_legal_entity IS NULL OR (hou.default_legal_context_id = :p_legal_entity))
       AND ( :p_ledger_id IS NULL OR (ood.set_of_books_id = :p_ledger_id))
       AND (   :p_organization_id IS NULL OR (ood.organization_id = :p_organization_id))
       AND EXISTS
               (SELECT 1
                  FROM mtl_system_items_b msi
                 WHERE     rsl.item_id = msi.inventory_item_id
                       AND (   :p_item_code is null         or (msi.segment1 = :p_item_code)))
       AND EXISTS
               (SELECT 1
                  FROM apps.po_headers_all pha
                 WHERE     pha.po_header_id = rsl.po_header_id
                       AND ( :p_po_no IS NULL OR (pha.segment1 = :p_po_no)));
                       
--------------------------------------------------------------------------------

SELECT *
    FROM apps.rcv_transactions
   WHERE 1 = 1 
   --AND TO_CHAR (transaction_date, 'DD-MON-RRRR') = '04-OCT-2021'
ORDER BY creation_date DESC;
