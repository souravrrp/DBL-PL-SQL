/* Formatted on 5/10/2021 12:02:23 PM (QP5 v5.287) */
  SELECT customer_number,
         customer_name,
         order_type,
         order_number,
         ordered_date,
         delivery_date,
         challan_confirm_date,
         TRANSPOTER_CHALLAN_NUMBER,
         freight,
         SUM (ordered_quantity) SFT_QTY,
         uom AS SFT_UOM,
         SUM (ordered_quantity2) CARTON_QTY,
         uom2 AS CARTON_UOM,
         --TO_NUMBER (SAMPLE_PCS) SAMPLE_PCS,
         challan_no,
         transpoter,
         delivery_person,
         vehicle_number,
         vehicle_type,
         driver_name,
         driver_contact_no
    FROM (SELECT ac.customer_number,
                 ac.customer_name,
                 ott.name order_type,
                 oha.order_number,
                 oha.ordered_date AS ordered_date,
                 ola.actual_shipment_date delivery_date,
                 wnd.confirm_date challan_confirm_date,
                 oha.freight_terms_code freight,
                 ola.flow_status_code,
                 ola.ordered_item,
                 msi.description,
                 ola.preferred_grade grade,
                 cat.segment2 item_size,
                 cat.category_concat_segs product_category,
                 cay.segment3 product_type,
                 ola.ordered_quantity,
                 ola.order_quantity_uom uom,
                 ola.ordered_quantity2,
                 ola.ordered_quantity_uom2 uom2,
                 CASE
                    WHEN ott.transaction_type_id IN ('1006', '1014')
                    THEN
                       ola.shipping_instructions || ''
                    ELSE
                       NULL
                 END
                    sample_pcs,
                 olv.delivery_challan_number challan_no,
                 olv.transport_name transpoter,
                 th.delivery_person,
                 th.vehicle_no vehicle_number,
                 th.delivery_mode_code vehicle_type,
                 th.driver_name driver_name,
                 th.transporter_no driver_contact_no,
                 th.transpoter_challan_number AS TRANSPOTER_CHALLAN_NUMBER
            FROM oe_order_headers_all oha,
                 oe_order_lines_all ola,
                 apps.oe_transaction_types_tl ott,
                 inv.mtl_system_items_b msi,
                 ar_customers ac,
                 mtl_item_categories_v cat,
                 mtl_item_categories_v cay,
                 xxdbl.xxdbl_omshipping_line_v olv,
                 wsh_new_deliveries wnd,
                 xxdbl_transpoter_headers th
           WHERE     oha.header_id = ola.header_id
                 AND oha.org_id = ola.org_id
                 AND oha.order_type_id = ott.transaction_type_id
                 AND ola.inventory_item_id = msi.inventory_item_id
                 AND ola.ship_from_org_id = msi.organization_id
                 AND oha.sold_to_org_id = ac.customer_id
                 AND msi.inventory_item_id = cat.inventory_item_id(+)
                 AND msi.inventory_item_id = cay.inventory_item_id
                 AND cat.category_set_name = 'DBL_SALES_CAT_SET'
                 AND cay.category_set_name = 'Inventory'
                 AND ott.transaction_type_id NOT IN (1008,
                                                     1010,
                                                     1030,
                                                     1032,
                                                     1034)
                 AND ola.line_id = olv.order_line_id
                 AND ola.inventory_item_id = olv.item_id
                 AND olv.delivery_id = wnd.delivery_id
                 AND olv.transport_challan_number =
                        th.transpoter_challan_number(+)
                 AND cay.organization_id = 152
                 AND cat.organization_id = 152
                 AND ola.flow_status_code IN ('CLOSED')
                 AND omshipping_line_status IN ('CLOSED')
                 AND oha.org_id = 126
                 --AND oha.org_id = :p_org_id
                 --AND (:p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
                 --AND (   :p_order_number IS NULL OR oha.order_number = :p_order_number)
                 AND TRUNC (ola.actual_shipment_date) BETWEEN TO_DATE (
                                                                 '01-May-2021',
                                                                 'DD-Mon-RRRR')
                                                          AND TO_DATE (
                                                                 '10-May-2021',
                                                                 'DD-Mon-RRRR'))
GROUP BY customer_number,
         customer_name,
         order_type,
         order_number,
         ordered_date,
         delivery_date,
         challan_confirm_date,
         freight,
         uom,
         uom2,
         challan_no,
         transpoter,
         delivery_person,
         vehicle_number,
         vehicle_type,
         driver_name,
         driver_contact_no,
         TRANSPOTER_CHALLAN_NUMBER
ORDER BY challan_confirm_date ASC;