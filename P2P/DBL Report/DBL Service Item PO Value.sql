--q1:
SELECT hou.NAME "Operating Unit",
       ph.segment1 po_num,
       prh.segment1 req_num,
       prh.type_lookup_code req_method,
       nvl(ppx1.EMPLOYEE_NUMBER,ppx1.npw_number) emp_number,
       ppx1.full_name "Requisition requestor",
       apps.xx_com_pkg.get_dept_from_user_name_id (nvl(ppx1.EMPLOYEE_NUMBER,ppx1.npw_number), null) dept_name,
       ---  ph.creation_date,
       ppx.full_name "Buyer Name",
    --    ph.type_lookup_code "PO Type",
       plc.displayed_field "PO Status",
       ph.comments,
       pl.line_num,
       (select concatenated_Segments from mtl_categories_kfv
       where category_id =pl.category_id ) itm_Catg,
       --     plt.order_type_lookup_code "Line Type",
   --    msi.segment1 "Item Code",
       pl.item_description,
       pl.unit_meas_lookup_code "UOM",
       ood.organization_code "Shipment Org Code",
       ood.organization_name "Shipment Org Name",
       pv.vendor_name supplier,
       pvs.vendor_site_code,
  --     mic.segment1 LOB,
   --    mic.segment2 Major,
   --    mic.segment3 Minor,
       ph.currency_code,
       ph.rate,
       pl.base_unit_price,
       pl.unit_price,
       pl.quantity,
       DECODE (ph.currency_CODE,
               'BDT', pl.unit_price * pl.quantity,
               (pl.unit_price * PH.RATE) * pl.quantity)
          "Line Amount"
  FROM po_headers_all ph,
       po_lines_all pl,
       po_distributions_all pda,
       po_vendors pv,
       po_vendor_sites_all pvs,
       po_distributions_all pd,
       po_req_distributions_all prd,
       po_requisition_lines_all prl,
       po_requisition_headers_all prh,
       hr_operating_units hou,
       per_people_x ppx,
           po_line_types_b plt,
       org_organization_definitions ood,
       per_people_x ppx1,
       po_lookup_codes plc
 WHERE     1 = 1
       AND TO_CHAR (ph.approved_date, 'YYYY') IN (2020)
       AND ph.vendor_id = pv.vendor_id
       AND ph.po_header_id = pl.po_header_id
       AND ph.vendor_site_id = pvs.vendor_site_id
       AND ph.po_header_id = pd.po_header_id
       AND pl.po_line_id = pd.po_line_id
       AND pd.req_distribution_id = prd.distribution_id(+)
       AND prd.requisition_line_id = prl.requisition_line_id(+)
       AND prl.requisition_header_id = prh.requisition_header_id(+)
       AND hou.organization_id = ph.org_id
       AND ph.agent_id = ppx.person_id
       AND pda.po_header_id = ph.po_header_id
       AND pda.po_line_id = pl.po_line_id
       AND pl.line_type_id = plt.line_type_id
       AND ood.organization_id = pda.destination_organization_id
       AND ppx1.person_id(+) = prh.preparer_id
    --   AND pda.destination_organization_id = msi.organization_id(+)
       --AND msi.inventory_item_id = NVL (pl.item_id, msi.inventory_item_id)
    --   AND msi.inventory_item_id = mic.inventory_item_id
    --   AND msi.organization_id = mic.organization_id
    --   AND msi.inventory_item_id = pl.item_id
    --   AND mic.category_set_id = 1
       AND plc.lookup_type = 'DOCUMENT STATE'
    --   AND mic.segment1 IN ('IT', 'FIXED ASSET', 'SERVICE')
       AND plc.lookup_code = ph.closed_code
   AND pl.item_id IS  NULL
   AND pl.CANCEL_FLAG='N';

--q2:
SELECT hou.NAME "Operating Unit",
       ph.segment1 po_num,
       prh.segment1 req_num,
       prh.type_lookup_code req_method,
      nvl(ppx1.EMPLOYEE_NUMBER,ppx1.npw_number) emp_number,
       ppx1.full_name "Requisition requestor",
       apps.xx_com_pkg.get_dept_from_user_name_id (nvl(ppx1.EMPLOYEE_NUMBER,ppx1.npw_number), null) dept_name,
       ph.creation_date,
       ppx.full_name "Buyer Name",
       -- ph.type_lookup_code "PO Type",
       plc.displayed_field "PO Status",
       ph.comments,
       pl.line_num,
--        plt.order_type_lookup_code "Line Type",
       msi.segment1 "Item Code",
       pl.item_description,
       pl.unit_meas_lookup_code "UOM",
       ood.organization_code "Shipment Org Code",
       ood.organization_name "Shipment Org Name",
       pv.SEGMENT1 vendor_number,
       pv.vendor_name supplier,
       pvs.vendor_site_code,
       mic.segment1 LOB,
       mic.segment2 Major,
       mic.segment3 Minor,
       ph.currency_code,
       ph.rate,
       pl.base_unit_price,
       pl.unit_price,
       pl.quantity,
       pda.QUANTITY_BILLED,
       pda.AMOUNT_BILLED,
       DECODE (ph.currency_CODE,
               'BDT', pl.unit_price * pl.quantity,
               (pl.unit_price * PH.RATE) * pl.quantity)
          "Line Amount"
  FROM po_headers_all ph,
       po_lines_all pl,
       po_distributions_all pda,
       po_vendors pv,
       po_vendor_sites_all pvs,
       po_distributions_all pd,
       po_req_distributions_all prd,
       po_requisition_lines_all prl,
       po_requisition_headers_all prh,
       hr_operating_units hou,
       per_people_x ppx,
       mtl_system_items_b msi,
       mtl_item_Categories_v mic,
       po_line_types_b plt,
       org_organization_definitions ood,
       per_people_x ppx1,
       po_lookup_codes plc
 WHERE     1 = 1
       AND TO_CHAR (ph.creation_date, 'YYYY') ='2020'
       AND ph.vendor_id = pv.vendor_id
       AND ph.po_header_id = pl.po_header_id
       AND ph.vendor_site_id = pvs.vendor_site_id
       AND ph.po_header_id = pd.po_header_id
       AND pl.po_line_id = pd.po_line_id
       AND pd.req_distribution_id = prd.distribution_id(+)
       AND prd.requisition_line_id = prl.requisition_line_id(+)
       AND prl.requisition_header_id = prh.requisition_header_id(+)
       AND hou.organization_id = ph.org_id
       AND ph.agent_id = ppx.person_id
       AND pda.po_header_id = ph.po_header_id
       AND pda.po_line_id = pl.po_line_id
       AND pl.line_type_id = plt.line_type_id
       AND ood.organization_id = pda.destination_organization_id
       AND ppx1.person_id(+) = prh.preparer_id
       AND pda.destination_organization_id = msi.organization_id(+)
       AND msi.inventory_item_id = NVL (pl.item_id, msi.inventory_item_id)
       AND msi.inventory_item_id = mic.inventory_item_id
       AND msi.organization_id = mic.organization_id
       AND msi.inventory_item_id = pl.item_id
       AND mic.category_set_id = 1
       AND plc.lookup_type = 'DOCUMENT STATE'
   --     AND mic.segment1 IN ('IT', 'FIXED ASSET', 'SERVICE')
       AND plc.lookup_code = ph.closed_code
--       AND hou.ORGANIZATION_ID=125
       AND ph.CANCEL_FLAG<>'Y'
       --   AND ph.ATTRIBUTE8='LOCAL'
       AND pl.item_id IS NOT NULL;