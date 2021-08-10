/* Formatted on 2/10/2020 12:51:20 PM (QP5 v5.287) */
  SELECT                                                 -- rt.transaction_id,
        rsh.shipment_header_id,
         TRUNC (rd.transaction_date) transaction_date,
         poh.segment1 po_number,
         lc.lc_number,
         poh.approved_Date,
         sup.vendor_name,
         sup.segment1 vendor_id,
         sus.vendor_site_code,
         rsh.receipt_num grn_no,
         rsh.attribute3,
         rt.transaction_date creation_date,
         rsh.comments remarks,
         rsh.shipment_num Shipment_Number,
         ash.ship_date,
         ood.organization_code,
         ood.organization_name,
         rsl.to_organization_id Organization_id,
         rd.subinventory to_subinventory,
         msi.segment1 item_code,
         rsl.item_description,
         muom.uom_code uom,
         SUM (rt1.quantity) - NVL (SUM (rr.quantity), 0) rcv_qty,
         SUM (rt1.quantity) - NVL (SUM (rr.quantity), 0) Ins_qty,
         NVL (SUM (rd.quantity), 0) del_qty,
         SUM (TO_NUMBER (rd.acctual_qty)) acctual_qty
    FROM apps.rcv_shipment_headers rsh,
         apps.rcv_shipment_lines rsl,
         apps.ap_suppliers sup,
         apps.ap_supplier_sites_all sus,
         apps.po_headers_all poh,
         apps.po_lines_all pol,
         apps.org_organization_definitions ood,
         apps.rcv_transactions rt,
         (  SELECT r.shipment_line_id,
                   r.shipment_header_id,
                   SUM (TO_NUMBER (r.attribute3)) acctual_qty,
                   MAX (r.transaction_date) transaction_date,
                   SUM (rd1.quantity) quantity,
                   subinventory
              FROM apps.rcv_transactions r,
                   (  SELECT transaction_id, SUM (quantity) quantity
                        FROM (  SELECT rcv.transaction_id transaction_id,
                                       SUM (rcv.quantity) quantity
                                  FROM apps.rcv_transactions rcv
                                 WHERE rcv.transaction_type = 'DELIVER'
                              GROUP BY rcv.transaction_id
                              UNION ALL
                                SELECT r1.parent_transaction_id transaction_id,
                                       SUM (r1.quantity)
                                  FROM apps.rcv_transactions r1,
                                       apps.rcv_transactions r2
                                 WHERE     r1.parent_transaction_id =
                                              r2.transaction_id
                                       AND r1.shipment_header_id =
                                              r2.shipment_header_id
                                       AND r1.shipment_line_id = r2.shipment_line_id
                                       AND r1.transaction_type = 'CORRECT'
                                       AND r2.transaction_type = 'DELIVER'
                              GROUP BY r1.parent_transaction_id
                              UNION ALL
                                SELECT r1.parent_transaction_id transaction_id,
                                       SUM (r1.quantity) * -1
                                  FROM apps.rcv_transactions r1,
                                       apps.rcv_transactions r2
                                 WHERE     r1.parent_transaction_id =
                                              r2.transaction_id
                                       AND r1.shipment_header_id =
                                              r2.shipment_header_id
                                       AND r1.shipment_line_id = r2.shipment_line_id
                                       AND r1.transaction_type =
                                              'RETURN TO RECEIVING'
                                       AND r2.transaction_type = 'DELIVER'
                              GROUP BY r1.parent_transaction_id)
                    GROUP BY transaction_id
                      HAVING SUM (quantity) > 0) rd1
             WHERE     transaction_type = 'DELIVER'
                   AND r.transaction_id = rd1.transaction_id
          GROUP BY r.shipment_line_id, r.shipment_header_id, subinventory) rd,
         (  SELECT transaction_id, SUM (quantity) quantity
              FROM (  SELECT rcv.transaction_id transaction_id,
                             SUM (rcv.quantity) quantity
                        FROM apps.rcv_transactions rcv
                       WHERE rcv.transaction_type IN ('RECEIVE', 'MATCH')
                    GROUP BY rcv.transaction_id
                    UNION ALL
                      SELECT r1.parent_transaction_id transaction_id,
                             SUM (r1.quantity)
                        FROM apps.rcv_transactions r1, apps.rcv_transactions r2
                       WHERE     r1.parent_transaction_id = r2.transaction_id
                             AND r1.shipment_header_id = r2.shipment_header_id
                             AND r1.shipment_line_id = r2.shipment_line_id
                             AND r1.transaction_type = 'CORRECT'
                             AND r2.transaction_type IN ('RECEIVE', 'MATCH')
                    GROUP BY r1.parent_transaction_id)
          GROUP BY transaction_id
            HAVING SUM (quantity) > 0) rt1,
         (  SELECT shipment_header_id,
                   shipment_line_id,
                   transaction_id,
                   SUM (quantity) quantity
              FROM rcv_transactions
             WHERE transaction_type = 'RETURN TO VENDOR'
          GROUP BY shipment_header_id, transaction_id, shipment_line_id) RR,
         apps.mtl_system_items_b msi,
         apps.mtl_units_of_measure_tl muom,
         apps.po_line_locations_all pll,
         (SELECT                                         --rsh.ship_to_org_id,
                 --  isha.ship_num,
                 rsh.shipment_header_id, shipped_date AS ship_date
            FROM rcv_shipment_headers rsh) ash,                    ---Ashraful
         (SELECT po_number,
                 lc_number,
                 lc_opening_date,
                 bank_name
            FROM xx_lc_details lc
           WHERE lc_status = 'Y') lc
   WHERE     rsh.shipment_header_id = rsl.shipment_header_id
         AND rsh.shipment_header_id = Ash.shipment_header_id(+)
         AND rsl.po_header_id = poh.po_header_id(+)
         AND rsl.po_line_id = pol.po_line_id(+)
         AND poh.segment1 = lc.po_number(+)
         AND sup.vendor_id = sus.vendor_id
         AND rsh.vendor_id(+) = sup.vendor_id
         AND rt.vendor_site_id = sus.vendor_site_id(+)
         AND rsl.to_organization_id = ood.organization_id
         AND rsl.shipment_header_id = rt.shipment_header_id
         AND rsl.shipment_line_id = rt.shipment_line_id
         AND rt.transaction_type IN ('RECEIVE', 'MATCH')
         AND rt.transaction_id = rt1.transaction_id(+)
         AND rsl.shipment_header_id = rd.shipment_header_id(+)
         AND rsl.shipment_line_id = rd.shipment_line_id(+)
         AND rsl.item_id = msi.inventory_item_id
         AND msi.organization_id = rsl.to_organization_id
         AND rsl.unit_of_measure = muom.unit_of_measure
         AND rsl.po_line_location_id = pll.line_location_id(+)
         AND rsh.shipment_header_id = rr.shipment_header_id(+)
         --   and rt.transaction_id=rr.transaction_id(+)
         AND rt.shipment_line_id = rr.shipment_line_id(+)
         AND rsl.to_organization_id = :p_organization_id
         AND rsh.shipment_header_id BETWEEN NVL ( :p_grn_f,
                                                 rsh.shipment_header_id)
                                        AND NVL ( :p_grn_t,
                                                 rsh.shipment_header_id)
GROUP BY rsh.shipment_header_id,
         -- rt.transaction_id,
         rd.transaction_date,
         poh.segment1,
         lc.lc_number,
         poh.approved_Date,
         sup.vendor_name,
         sup.segment1,
         sus.vendor_site_code,
         rsh.receipt_num,
         rsh.attribute3,
         rt.transaction_date,
         rsh.COMMENTS,
         rsh.shipment_num,
         ash.ship_date,
         ood.organization_code,
         ood.organization_name,
         rsl.to_organization_id,
         rd.subinventory,
         msi.segment1,
         rsl.item_description,
         muom.uom_code
UNION ALL
  SELECT rsh.shipment_header_id,
         rsh.creation_date transaction_date,
         pha.segment1 po_number,
         NULL lc_number,
         pha.approved_Date,
         sup.vendor_name,
         sup.segment1 vendor_id,
         sus.vendor_site_code,
         rsh.receipt_num grn_no,
         rsh.attribute3,
         rsh.creation_date,
         rsh.comments remarks,
         rsh.shipment_num Shipment_Number,
         NULL ship_date,
         ood.organization_code,
         ood.organization_name,
         rsl.to_organization_id Organization_id,
         NULL to_subinventory,
         'NA' item_code,
         rsl.item_description,
         rsl.unit_of_measure uom,
         pll.quantity_received rcv_qty,
         pll.quantity_received Ins_qty,
         pll.quantity_received del_qty,
         NULL acctual_qty
    FROM rcv_shipment_headers rsh,
         rcv_shipment_lines rsl,
         po_headers_all pha,
         po_lines_all pla,
         po_line_locations_all pll,
         org_organization_definitions ood,
         ap_suppliers sup,
         ap_supplier_sites_all sus
   WHERE     rsh.shipment_header_id = rsl.shipment_header_id
         AND pha.po_header_id = rsl.po_header_id
         AND pha.po_header_id = pla.po_header_id
         AND rsl.po_line_id = pla.po_line_id
         AND pha.po_header_id = pll.po_header_id
         AND pla.po_line_id = pll.po_line_id
         AND pll.po_line_id = rsl.po_line_id
         AND rsl.to_organization_id = ood.organization_id
         AND pha.vendor_id = sup.vendor_id
         AND sup.vendor_id = sus.vendor_id
         AND rsl.item_id IS NULL
         AND pll.quantity_received <> 0
         --and receipt_num='10324200129'
         AND rsl.to_organization_id = :p_organization_id
         AND rsh.shipment_header_id BETWEEN NVL ( :p_grn_f,
                                                 rsh.shipment_header_id)
                                        AND NVL ( :p_grn_t,
                                                 rsh.shipment_header_id)
GROUP BY rsh.shipment_header_id,
         rsh.creation_date,
         pha.segment1,
         pha.approved_Date,
         sup.vendor_name,
         sup.segment1,
         sus.vendor_site_code,
         rsh.receipt_num,
         rsh.attribute3,
         rsh.creation_date,
         rsh.comments,
         rsh.shipment_num,
         ood.organization_code,
         ood.organization_name,
         rsl.to_organization_id,
         rsl.item_description,
         rsl.unit_of_measure,
         pll.quantity_received,
         pll.quantity_received,
         pll.quantity_received