/* Formatted on 3/4/2021 12:26:08 PM (QP5 v5.354) */
SELECT opl.name
           price_list_name,
       opl.currency_code
           currency,
       opll.start_date_active
           effective_date_from,
       opll.end_date_active
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
       opll.list_price,
       apps.get_mod_val_from_itm_grade (299438,
                                        qpa.product_attr_value,
                                        qpa.pricing_attr_value_from)
           cssm,
       (  opll.list_price
        + apps.get_mod_val_from_itm_grade (299438,
                                           qpa.product_attr_value,
                                           qpa.pricing_attr_value_from))
           total_price,
       apps.get_mod_val_from_itm_grade (54182,
                                        qpa.product_attr_value,
                                        qpa.pricing_attr_value_from)
           line_discount,
       qpa.pricing_attr_value_from
           item_grade
  FROM oe_price_lists         opl,
       oe_price_list_lines    opll,
       qp_pricing_attributes  qpa
 WHERE     1 = 1
       AND opl.price_list_id = opll.price_list_id
       AND TRUNC (opll.start_date_active) BETWEEN :p_start_date AND :p_end_date
       AND TRUNC (SYSDATE) BETWEEN TRUNC (opll.start_date_active)
                               AND TRUNC (opll.end_date_active)
       AND opll.price_list_line_id = qpa.list_line_id
       AND qpa.pricing_attribute = 'PRICING_ATTRIBUTE19';