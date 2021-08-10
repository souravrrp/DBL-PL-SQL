/* Formatted on 3/3/2021 4:50:16 PM (QP5 v5.287) */
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
       qpa.pricing_attr_value_from item_grade
  --,opl.*
  --,opll.*
  --,qpa.*
  FROM oe_price_lists opl,
       oe_price_list_lines opll,
       qp_pricing_attributes qpa
 WHERE     1 = 1
       AND opl.price_list_id = opll.price_list_id
       AND opll.concatenated_segments = 'GL3060-006GN'
       AND TRUNC (SYSDATE) BETWEEN TRUNC (opll.start_date_active)
                               AND TRUNC (opll.end_date_active)
       AND opll.price_list_line_id = qpa.list_line_id
       AND qpa.pricing_attribute = 'PRICING_ATTRIBUTE19'
--AND opll.pricing_attribute_id = qpa.pricing_attribute_id