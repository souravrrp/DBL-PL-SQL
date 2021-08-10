/* Formatted on 6/2/2021 4:41:51 PM (QP5 v5.354) */
SELECT dt.price_list_name,
       dt.currency,
       dt.effective_date_from,
       dt.effective_date_to,
       dt.ln_product_context,
       dt.item_code,
       dt.description,
       dt.uom,
       dt.ln_application_operator,
       LN.list_price,
       dt.cssm,
       (LN.list_price + dt.total_price)     total_price,
       dt.line_discount,
       dt.item_grade
  FROM (  SELECT opl.name
                     price_list_name,
                 opl.currency_code
                     currency,
                 MAX (opll.start_date_active)
                     effective_date_from,
                 MAX (opll.end_date_active)
                     effective_date_to,
                 qpa.product_attribute_context
                     ln_product_context,
                 opll.concatenated_segments
                     item_code,
                 opll.item_description
                     description,
                 opll.unit_code
                     uom,
                 opll.method_code
                     ln_application_operator,
                 --opll.list_price,
                 apps.get_mod_val_from_itm_grade (299438,
                                                  qpa.product_attr_value,
                                                  qpa.pricing_attr_value_from)
                     cssm,
                 (                                           --opll.list_price
                  --+
                  apps.get_mod_val_from_itm_grade (299438,
                                                   qpa.product_attr_value,
                                                   qpa.pricing_attr_value_from))
                     total_price,
                 apps.get_mod_val_from_itm_grade (54182,
                                                  qpa.product_attr_value,
                                                  qpa.pricing_attr_value_from)
                     line_discount,
                 qpa.pricing_attr_value_from
                     item_grade,
                 MAX (opll.price_list_line_id)
                     line_id
            FROM oe_price_lists       opl,
                 oe_price_list_lines  opll,
                 qp_pricing_attributes qpa
           WHERE     1 = 1
                 AND opl.price_list_id = opll.price_list_id
                 --AND (  : p_start_date IS NULL OR TRUNC (opll.start_date_active) <= :p_start_date)
                 --AND (   :p_end_date IS NULL OR TRUNC (opll.end_date_active) >= :p_end_date)
                 AND opll.price_list_line_id = qpa.list_line_id
                 AND qpa.pricing_attribute = 'PRICING_ATTRIBUTE19'
        GROUP BY opl.name,
                 opl.currency_code,
                 qpa.product_attribute_context,
                 opll.concatenated_segments,
                 opll.item_description,
                 opll.unit_code,
                 opll.method_code,
                 --opll.list_price,
                 apps.get_mod_val_from_itm_grade (
                     299438,
                     qpa.product_attr_value,
                     qpa.pricing_attr_value_from),
                 apps.get_mod_val_from_itm_grade (
                     54182,
                     qpa.product_attr_value,
                     qpa.pricing_attr_value_from),
                 qpa.pricing_attr_value_from) dt,
       oe_price_list_lines  LN
 WHERE dt.line_id = LN.price_list_line_id