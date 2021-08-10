/* Formatted on 3/3/2021 5:13:30 PM (QP5 v5.287) */
SELECT                                                    --OPL.PRICE_LIST_ID,
       --OPLL.PRICE_LIST_LINE_ID,
       --OPL.START_DATE_ACTIVE,
       --OPL.END_DATE_ACTIVE,
       --ATTRIBUTE2, --Transport Mode
       --OPL.ATTRIBUTE3, --Warehouse_id
       opl.name,
       --OPL.DESCRIPTION,
       opll.list_price,
       TO_CHAR (opll.start_date_active) start_active_date,
       TO_CHAR (opll.end_date_active) line_end_date,
       --OPLL.INVENTORY_ITEM_ID,
       opll.concatenated_segments item_code,
       opll.item_description,
       opll.unit_code,
       qpa.pricing_attr_value_from price_item_grade,
       qll.operand val,
       qpa.pricing_attr_value_from mod_item_grade
  --OPL.*
  FROM oe_price_lists opl,
       oe_price_list_lines opll,
       qp_pricing_attributes qpa,
       apps.qp_list_headers_vl qlh,
       apps.qp_list_lines qll,
       apps.qp_pricing_attributes qpam,
       apps.mtl_system_items_b msi
 WHERE     1 = 1
       AND opl.price_list_id = opll.price_list_id
       --AND opll.concatenated_segments = 'GL3060-006GN'
       AND opll.price_list_line_id = qpa.list_line_id
       AND qpa.pricing_attribute = 'PRICING_ATTRIBUTE19'
       AND TRUNC (SYSDATE) BETWEEN TRUNC (opll.start_date_active)
                               AND TRUNC (opll.end_date_active)
       AND opll.concatenated_segments = msi.segment1
       AND qpa.pricing_attr_value_from = qpam.pricing_attr_value_from
       AND msi.organization_id = 152
       AND TO_CHAR (qpam.product_attr_value) = msi.inventory_item_id
       AND qlh.list_header_id = qll.list_header_id
       AND qlh.name = 'CSSM'
       AND qll.list_header_id = qpam.list_header_id
       AND qll.list_line_id = qpam.list_line_id
       --AND qpam.product_attr_value = '189491'
       AND qpam.pricing_attribute = 'PRICING_ATTRIBUTE19'