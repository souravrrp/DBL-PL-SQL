PO Queries in Oracle Apps
Purchase Requisition details
====================================================
SELECT prh.segment1 "Req #", prh.creation_date, prh.created_by,
       poh.segment1 "PO #", ppx.full_name "Requestor Name",
       prh.description "Req Description", prh.authorization_status,
       prh.note_to_authorizer, prh.type_lookup_code, prl.line_num,
       prl.line_type_id, prl.item_description, prl.unit_meas_lookup_code,
       prl.unit_price, prl.quantity, prl.quantity_delivered, prl.need_by_date,
       prl.note_to_agent, prl.currency_code, prl.rate_type, prl.rate_date,
       prl.quantity_cancelled, prl.cancel_date, prl.cancel_reason
  FROM po_requisition_headers_all prh,
       po_requisition_lines_all prl,
       po_req_distributions_all prd,
       per_people_x ppx,
       po_headers_all poh,
       po_distributions_all pda
 WHERE prh.requisition_header_id = prl.requisition_header_id
   AND ppx.person_id = prh.preparer_id
   AND prh.type_lookup_code = 'PURCHASE'
   AND prd.requisition_line_id = prl.requisition_line_id
   AND pda.req_distribution_id = prd.distribution_id
   AND pda.po_header_id = poh.po_header_id
  -- AND TO_CHAR (prh.creation_date, 'YYYY') IN ('2010', '2011')
 
Internal Requisition details
====================================================
SELECT prh.segment1 "Req #", prh.creation_date, prh.created_by,
       poh.segment1 "PO #", ppx.full_name "Requestor Name",
       prh.description "Req Description", prh.authorization_status,
       prh.note_to_authorizer, prl.line_num, prl.line_type_id,
       prl.source_type_code, prl.item_description, prl.unit_meas_lookup_code,
       prl.unit_price, prl.quantity, prl.quantity_delivered, prl.need_by_date,
       prl.note_to_agent, prl.currency_code, prl.rate_type, prl.rate_date,
       prl.quantity_cancelled, prl.cancel_date, prl.cancel_reason
  FROM po_requisition_headers_all prh,
       po_requisition_lines_all prl,
       po_req_distributions_all prd,
       per_people_x ppx,
       po_headers_all poh,
       po_distributions_all pda
 WHERE prh.requisition_header_id = prl.requisition_header_id
   AND ppx.person_id = prh.preparer_id
   AND prh.type_lookup_code = 'INTERNAL'
   AND prd.requisition_line_id = prl.requisition_line_id
   AND pda.req_distribution_id(+) = prd.distribution_id
   AND pda.po_header_id = poh.po_header_id(+)
   AND TO_CHAR (prh.creation_date, 'YYYY') IN ('2010', '2011')
 
Purchase Order details
====================================================
-- Purchase Orders for non inventory items like service
SELECT ph.segment1 po_num, ph.creation_date, hou.NAME "Operating Unit",
       ppx.full_name "Buyer Name", ph.type_lookup_code "PO Type",
       plc.displayed_field "PO Status", ph.comments, pl.line_num,
       plt.order_type_lookup_code "Line Type", NULL "Item Code",
       pl.item_description, pl.unit_meas_lookup_code "UOM",
       pl.base_unit_price, pl.unit_price, pl.quantity,
       ood.organization_code "Shipment Org Code",
       ood.organization_name "Shipment Org Name", pv.vendor_name supplier,
       pvs.vendor_site_code, (pl.unit_price * pl.quantity) "Line Amount",
       prh.segment1 req_num, prh.type_lookup_code req_method,
       ppx1.full_name "Requisition requestor"
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
 WHERE 1 = 1
   AND TO_CHAR (ph.creation_date, 'YYYY') IN (2010, 2011)
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
   AND plc.lookup_type = 'DOCUMENT STATE'
   AND plc.lookup_code = ph.closed_code
   AND pl.item_id IS NULL
UNION
-- Purchase Orders for inventory items
SELECT ph.segment1 po_num, ph.creation_date, hou.NAME "Operating Unit",
       ppx.full_name "Buyer Name", ph.type_lookup_code "PO Type",
       plc.displayed_field "PO Status", ph.comments, pl.line_num,
       plt.order_type_lookup_code "Line Type", msi.segment1 "Item Code",
       pl.item_description, pl.unit_meas_lookup_code "UOM",
       pl.base_unit_price, pl.unit_price, pl.quantity,
       ood.organization_code "Shipment Org Code",
       ood.organization_name "Shipment Org Name", pv.vendor_name supplier,
       pvs.vendor_site_code, (pl.unit_price * pl.quantity) "Line Amount",
       prh.segment1 req_num, prh.type_lookup_code req_method,
       ppx1.full_name "Requisition requestor"
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
       po_line_types_b plt,
       org_organization_definitions ood,
       per_people_x ppx1,
       po_lookup_codes plc
 WHERE 1 = 1
   AND TO_CHAR (ph.creation_date, 'YYYY') IN (2010, 2011)
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
   AND plc.lookup_type = 'DOCUMENT STATE'
   AND plc.lookup_code = ph.closed_code
   AND pl.item_id IS NOT NULL

Receiving transactions with PO and requisition information
====================================================
SELECT   ph.segment1 po_num, ood.organization_name, pol.po_line_id,
         pll.quantity, rsh.receipt_source_code, rsh.vendor_id,
         rsh.vendor_site_id, rsh.organization_id, rsh.shipment_num,
         rsh.receipt_num, rsh.ship_to_location_id, rsh.bill_of_lading,
         rsl.shipment_line_id, rsl.quantity_shipped, rsl.quantity_received,
         rct.transaction_type, rct.transaction_id,
         NVL (rct.source_doc_quantity, 0) transaction_qty
    FROM rcv_transactions rct,
         rcv_shipment_headers rsh,
         rcv_shipment_lines rsl,
         po_lines_all pol,
         po_line_locations_all pll,
         po_headers_all ph,
         org_organization_definitions ood
   WHERE 1 = 1
     AND TO_CHAR (rct.creation_date, 'YYYY') IN ('2010', '2011')
     AND rct.po_header_id = ph.po_header_id
     AND rct.po_line_location_id = pll.line_location_id
     AND rct.po_line_id = pol.po_line_id
     AND rct.shipment_line_id = rsl.shipment_line_id
     AND rsl.shipment_header_id = rsh.shipment_header_id
     AND rsh.ship_to_org_id = ood.organization_id
ORDER BY rct.transaction_id  


Cancel Requisitions
====================================================

SELECT prh.requisition_header_id, prh.preparer_id, prh.segment1 "REQ NUM",
       TRUNC (prh.creation_date), prh.description, prh.note_to_authorizer
  FROM apps.po_requisition_headers_all prh, apps.po_action_history pah
 WHERE action_code = 'CANCEL'
   AND pah.object_type_code = 'REQUISITION'
   AND pah.object_id = prh.requisition_header_id
 
Internal Requisitions that do not have an associated Internal Sales Order
====================================================
 
   SELECT   rqh.segment1, rql.line_num, rql.requisition_header_id,
         rql.requisition_line_id, rql.item_id, rql.unit_meas_lookup_code,
         rql.unit_price, rql.quantity, rql.quantity_cancelled,
         rql.quantity_delivered, rql.cancel_flag, rql.source_type_code,
         rql.source_organization_id, rql.destination_organization_id,
         rqh.transferred_to_oe_flag
    FROM po_requisition_lines_all rql, po_requisition_headers_all rqh
   WHERE rql.requisition_header_id = rqh.requisition_header_id
     AND rql.source_type_code = 'INVENTORY'
     AND rql.source_organization_id IS NOT NULL
     AND NOT EXISTS (
            SELECT 'existing internal order'
              FROM oe_order_lines_all lin
             WHERE lin.source_document_line_id = rql.requisition_line_id
               AND lin.source_document_type_id = 10)
ORDER BY rqh.requisition_header_id, rql.line_num

Relation with Requisition and PO
====================================================

SELECT r.segment1 "Req Num", p.segment1 "PO Num"
  FROM po_headers_all p,
       po_distributions_all d,
       po_req_distributions_all rd,
       po_requisition_lines_all rl,
       po_requisition_headers_all r
 WHERE p.po_header_id = d.po_header_id
   AND d.req_distribution_id = rd.distribution_id
   AND rd.requisition_line_id = rl.requisition_line_id
   AND rl.requisition_header_id = r.requisition_header_id
 
Purchase Requisition without a Purchase Order
====================================================

SELECT   prh.segment1 "PR NUM", TRUNC (prh.creation_date) "CREATED ON",
         TRUNC (prl.creation_date) "Line Creation Date", prl.line_num "Seq #",
         msi.segment1 "Item Num", prl.item_description "Description",
         prl.quantity "Qty", TRUNC (prl.need_by_date) "Required By",
         ppf1.full_name "REQUESTOR", ppf2.agent_name "BUYER"
    FROM po.po_requisition_headers_all prh,
         po.po_requisition_lines_all prl,
         apps.per_people_f ppf1,
         (SELECT DISTINCT agent_id, agent_name
                     FROM apps.po_agents_v) ppf2,
         po.po_req_distributions_all prd,
         inv.mtl_system_items_b msi,
         po.po_line_locations_all pll,
         po.po_lines_all pl,
         po.po_headers_all ph
   WHERE prh.requisition_header_id = prl.requisition_header_id
     AND prl.requisition_line_id = prd.requisition_line_id
     AND ppf1.person_id = prh.preparer_id
     AND prh.creation_date BETWEEN ppf1.effective_start_date
                               AND ppf1.effective_end_date
     AND ppf2.agent_id(+) = msi.buyer_id
     AND msi.inventory_item_id = prl.item_id
     AND msi.organization_id = prl.destination_organization_id
     AND pll.line_location_id(+) = prl.line_location_id
     AND pll.po_header_id = ph.po_header_id(+)
     AND pll.pl_line_id = pl.po_line_id(+)
     AND prh.authorization_status = 'APPROVED'
     AND pll.line_location_id IS NULL
     AND prl.closed_code IS NULL
     AND NVL (prl.cancel_flag, 'N') <> 'Y'
ORDER BY 1, 2

Requisition moved from different stages till converting into PR
====================================================

SELECT DISTINCT u.description "Requestor", porh.segment1 AS "Req Number",
                TRUNC (porh.creation_date) "Created On", pord.last_updated_by,
                porh.authorization_status "Status",
                porh.description "Description", poh.segment1 "PO Number",
                TRUNC (poh.creation_date) "PO Creation Date",
                poh.authorization_status "PO Status",
                TRUNC (poh.approved_date) "Approved Date"
           FROM apps.po_headers_all poh,
                apps.po_distributions_all pod,
                apps.po_req_distributions_all pord,
                apps.po_requisition_lines_all porl,
                apps.po_requisition_headers_all porh,
                apps.fnd_user u
          WHERE porh.requisition_header_id = porl.requisition_header_id
            AND porl.requisition_line_id = pord.requisition_line_id
            AND pord.distribution_id = pod.req_distribution_id(+)
            AND pod.po_header_id = poh.po_header_id(+)
            AND porh.created_by = u.user_id
       ORDER BY 2
     
 PO’s which does not have any PR
====================================================
      
SELECT   prh.segment1 "PR NUM", TRUNC (prh.creation_date) "CREATED ON",
         TRUNC (prl.creation_date) "Line Creation Date", prl.line_num "Seq #",
         msi.segment1 "Item Num", prl.item_description "Description",
         prl.quantity "Qty", TRUNC (prl.need_by_date) "Required By",
         ppf1.full_name "REQUESTOR", ppf2.agent_name "BUYER"
    FROM po.po_requisition_headers_all prh,
         po.po_requisition_lines_all prl,
         apps.per_people_f ppf1,
         (SELECT DISTINCT agent_id, agent_name
                     FROM apps.po_agents_v) ppf2,
         po.po_req_distributions_all prd,
         inv.mtl_system_items_b msi,
         po.po_line_locations_all pll,
         po.po_lines_all pl,
         po.po_headers_all ph
   WHERE prh.requisition_header_id = prl.requisition_header_id
     AND prl.requisition_line_id = prd.requisition_line_id
     AND ppf1.person_id = prh.preparer_id
     AND prh.creation_date BETWEEN ppf1.effective_start_date
                               AND ppf1.effective_end_date
     AND ppf2.agent_id(+) = msi.buyer_id
     AND msi.inventory_item_id = prl.item_id
     AND msi.organization_id = prl.destination_organization_id
     AND pll.line_location_id(+) = prl.line_location_id
     AND pll.po_header_id = ph.po_header_id(+)
     AND pll.po_line_id = pl.po_line_id(+)
     AND prh.authorization_status = 'APPROVED'
     AND pll.line_location_id IS NULL
     AND prl.closed_code IS NULL
     AND NVL (prl.cancel_flag, 'N') <> 'Y'
ORDER BY 1, 2    

All Open Purchase Orders
====================================================

SELECT h.segment1 "PO NUM", h.authorization_status "STATUS",
       l.line_num "SEQ NUM", ll.line_location_id, d.po_distribution_id,
       h.type_lookup_code "TYPE"
  FROM po.po_headers_all h,
       po.po_lines_all l,
       po.po_line_locations_all ll,
       po.po_distributions_all d
 WHERE h.po_header_id = l.po_header_id
   AND ll.po_line_id = l.po_line_id
   AND ll.line_location_id = d.line_location_id
   AND h.closed_date IS NULL
   AND h.type_lookup_code NOT IN ('QUOTATION')
 
All POs with Approval, Invoice & Payment details
====================================================

SELECT a.org_id "ORG ID", e.segment1 "VENDOR NUM",
       e.vendor_name "SUPPLIER NAME",
       UPPER (e.vendor_type_lookup_code) "VENDOR TYPE",
       f.vendor_site_code "VENDOR SITE CODE", f.address_line1 "ADDRESS",
       f.city "CITY", f.country "COUNTRY",
       TO_CHAR (TRUNC (d.creation_date)) "PO Date", d.segment1 "PO NUM",
       d.type_lookup_code "PO Type", c.quantity_ordered "QTY ORDERED",
       c.quantity_cancelled "QTY CANCELLED", g.item_id "ITEM ID",
       g.item_description "ITEM DESCRIPTION", g.unit_price "UNIT PRICE",
         (NVL (c.quantity_ordered, 0) - NVL (c.quantity_cancelled, 0)
         )
       * NVL (g.unit_price, 0) "PO Line Amount",
       (SELECT DECODE (ph.approved_flag, 'Y', 'Approved')
          FROM po.po_headers_all ph
         WHERE ph.po_header_id = d.po_header_id) "PO Approved?",
       a.invoice_type_lookup_code "INVOICE TYPE",
       a.invoice_amount "INVOICE AMOUNT",
       TO_CHAR (TRUNC (a.invoice_date)) "INVOICE DATE",
       a.invoice_num "INVOICE NUMBER",
       (SELECT DECODE (x.match_status_flag,
                       'A', 'Approved'
                      )
          FROM ap.ap_invoice_distributions_all x
         WHERE x.invoice_distribution_id = b.invoice_distribution_id)
                                                          "Invoice Approved?",
       a.amount_paid, h.amount, h.check_id, h.invoice_payment_id "Payment Id",
       i.check_number "Cheque Number",
       TO_CHAR (TRUNC (i.check_date)) "Payment Date"
  FROM ap.ap_invoices_all a,
       ap.ap_invoice_distributions_all b,
       po.po_distributions_all c,
       po.po_headers_all d,
       po.po_vendors e,
       po.po_vendor_sites_all f,
       po.po_lines_all g,
       ap.ap_invoice_payments_all h,
       ap.ap_checks_all i
 WHERE a.invoice_id = b.invoice_id
   AND b.po_distribution_id = c.po_distribution_id(+)
   AND c.po_header_id = d.po_header_id(+)
   AND e.vendor_id(+) = d.vendor_id
   AND f.vendor_site_id(+) = d.vendor_site_id
   AND d.po_header_id = g.po_header_id
   AND c.po_line_id = g.po_line_id
   AND a.invoice_id = h.invoice_id
   AND h.check_id = i.check_id
   AND f.vendor_site_id = i.vendor_site_id
   AND c.po_header_id IS NOT NULL
   AND a.payment_status_flag = 'Y'
   AND d.type_lookup_code != 'BLANKET'
 
Po Which are not received for a perticular Preparer
====================================================

SELECT p.po_header_id po_header_id, r.segment1 req_number,
       p.segment1 po_number
  FROM po_headers_all p,
       po_distributions_all d,
       po_req_distributions_all rd,
       po_requisition_lines_all rl,
       po_requisition_headers_all r
 WHERE p.po_header_id = d.po_header_id
   AND d.req_distribution_id = rd.distribution_id
   AND rd.requisition_line_id = rl.requisition_line_id
   AND rl.requisition_header_id = r.requisition_header_id
   AND r.preparer_id = 12345
   AND p.po_header_id NOT IN (
          SELECT po_header_id
            FROM apps.rcv_transactions
           WHERE po_header_id IN (
                    SELECT   p.po_header_id po_header_id
                        FROM po_headers_all p,
                             po_distributions_all d,
                             po_req_distributions_all rd,
                             po_requisition_lines_all rl,
                             po_requisition_headers_all r
                       WHERE p.po_header_id = d.po_header_id
                         AND d.req_distribution_id = rd.distribution_id
                         AND rd.requisition_line_id = rl.requisition_line_id
                         AND rl.requisition_header_id =
                                                       r.requisition_header_id
                         AND r.preparer_id = 12345
                    GROUP BY p.po_header_id))   