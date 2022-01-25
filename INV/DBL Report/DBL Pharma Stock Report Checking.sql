/* Formatted on 1/24/2022 11:29:09 AM (QP5 v5.374) */
SELECT SUM (prla.quantity) pq_qty
  FROM po.po_requisition_lines_all prla, po.po_requisition_headers_all prha
 WHERE     1 = 1
       AND 583106 = prla.item_id(+)
       AND 158 = prla.destination_organization_id(+)
       AND prla.requisition_header_id = prha.requisition_header_id(+)
       --AND pla.item_id IS NOT NULL
       AND prla.parent_req_line_id IS NULL;

SELECT (CASE
            WHEN SUM (pll.quantity_received) = 0 THEN SUM (pla.quantity)
            WHEN SUM (pll.quantity_received) > SUM (pla.quantity) THEN 0
            ELSE ABS (SUM (pll.quantity) - SUM (pll.quantity_received))
        END)    po_quantity,
        SUM (pla.quantity) po_qty
  FROM po.po_headers_all         pha,
       po.po_lines_all           pla,
       po.po_line_locations_all  pll,
       po.po_distributions_all   pda
 WHERE     1 = 1
       AND 583106 = pla.item_id(+)
       AND 158 = pda.destination_organization_id(+)
       AND pla.po_header_id = pha.po_header_id(+)
       AND pla.po_header_id = pda.po_header_id(+)
       AND pla.po_line_id = pda.po_line_id(+)
       AND pla.po_header_id = pll.po_header_id(+)
       AND pla.po_line_id = pll.po_line_id(+)
       AND pda.line_location_id = pll.line_location_id(+);

SELECT SUM (rt.quantity)     grn_quantity
  FROM apps.rcv_shipment_lines rsl, apps.rcv_transactions rt
 WHERE     1 = 1
       AND rsl.shipment_header_id = rt.shipment_header_id
       AND rt.organization_id = 158
       AND rsl.item_id = 583106
       AND rt.transaction_type = 'RECEIVE'
       --AND rt.transaction_type = 'DELIVER'
       AND rt.shipment_header_id = rsl.shipment_header_id
       AND rt.po_header_id = rsl.po_header_id
       AND rt.po_line_id = rsl.po_line_id
       AND rt.po_line_location_id = rsl.po_line_location_id;

SELECT apps.xxdbl_fnc_get_onhand_qty (583106, 158, 'OHQ')     onhand_quantity
  FROM DUAL;

SELECT NVL (SUM (mr.reservation_quantity), 0)     rsv_qty
  FROM inv.mtl_reservations mr
 WHERE mr.organization_id = 158 AND mr.inventory_item_id = 583106;

SELECT NVL(SUM (ohqd.primary_transaction_quantity),0) 
  FROM apps.mtl_onhand_quantities_detail ohqd
 WHERE     1 = 1
       AND EXISTS
               (SELECT 1
                  FROM apps.mtl_secondary_inventories imsi
                 WHERE     1 = 1
                       AND imsi.organization_id = ohqd.organization_id
                       AND imsi.secondary_inventory_name =
                           ohqd.subinventory_code
                       AND (UPPER (imsi.description) LIKE '%QUARANTINE%'))
       AND ohqd.organization_id = 158
       AND ohqd.inventory_item_id = 583106;