/* Formatted on 12-May-20 12:36:25 (QP5 v5.136.908.31019) */
SELECT lhv.name price_list_name,
       lhv.description price_list_description,
       lhv.currency_code currency,
       llv.start_date_active effective_date_from,
       llv.end_date_active effective_date_to,
       llv.product_attribute_context ln_product_context,
       llv.product_attr_val_disp item_code,
       msi.description description,
       uom.uom_code uom,
       qpa.product_uom_code ln_uom_code,
       llv.list_line_type_code ln_type_code,
       llv.arithmetic_operator ln_application_operator,
       llv.operand ln_value,
       qpal.comparison_operator_code grade_operator,
       qpal.pricing_attr_value_from item_grade
  FROM qp_list_headers lhv,
       qp_list_lines_v llv,
       qp_price_formulas qpf,
       inv.mtl_system_items_b msi,
       qp_pricing_attributes qpa,
       qp_pricing_attributes qpal,
       mtl_units_of_measure_vl uom
 WHERE     lhv.list_header_id = llv.list_header_id
       AND llv.product_attr_val_disp = msi.segment1
       AND llv.price_by_formula_id = qpf.price_formula_id(+)
       AND llv.list_line_id = qpa.list_line_id
       AND llv.pricing_attribute_id = qpa.pricing_attribute_id
       AND llv.list_line_id = qpal.list_line_id
       AND qpal.pricing_attribute = 'PRICING_ATTRIBUTE19'
       AND msi.organization_id = 152
       AND llv.product_uom_code = uom.uom_code
       --AND TRUNC (llv.start_date_active) BETWEEN :p_start_date AND  :p_end_date
       --AND TRUNC (llv.end_date_active) BETWEEN :p_start_date AND :p_end_date
       AND qpal.pricing_attr_value_from = 'B'
       AND TRUNC (SYSDATE) BETWEEN TRUNC (llv.start_date_active) AND TRUNC (llv.end_date_active)