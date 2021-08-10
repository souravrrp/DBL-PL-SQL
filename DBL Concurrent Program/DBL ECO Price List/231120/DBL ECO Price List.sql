/* Formatted on 03-Nov-19 17:38:49 (QP5 v5.136.908.31019) */
SELECT lhv.name price_list_name,
       lhv.description price_list_description,
       lhv.currency_code currency,
       clt.name currency_conversion,
       llv.start_date_active effective_date_from,
       llv.end_date_active effective_date_to,
       llv.attribute1 line_of_business,
       llv.product_attribute_context ln_product_context,
       'Item Category' ln_product_attribute,
       mcv.concatenated_segments ln_product_value,
       qpf.price_formula_id dynamic_formula,
       uom.uom_code uom,
       qpa.product_uom_code ln_uom_code,
       llv.list_line_type_code ln_type_code,
       llv.arithmetic_operator ln_application_operator,
       llv.operand ln_value,
       llv.attribute3 ln_attribute1,
       NULL ln_attribute2,
       NULL ln_attribute3,
       NULL ln_attribute4,
       'DBL_CUSTOMER' cust_pricing_attribute,
       qpab.comparison_operator_code cust_operator,
       cus.customer_number,
       cus.customer_name,
       'DBL_BUYER' buyer_pricing_attribute,
       qpal.comparison_operator_code buyer_operator,
       qpab.pricing_attr_value_from buyer_lookup_code,
       boe.lookup_code buyer_name,
       qpal.attribute1 process_loss
  FROM qp_list_headers lhv,
       qp_list_lines_v llv,
       qp_currency_lists_tl clt,
       qp_price_formulas qpf,
       mtl_categories_kfv mcv,
       qp_pricing_attributes qpa,
       qp_pricing_attributes qpal,
       qp_pricing_attributes qpab,
       ar_customers cus,
       apps.hz_cust_acct_sites_all hcasa,
       apps.hz_cust_site_uses_all hcsua,
       mtl_units_of_measure_vl uom,
       oe_lookups boe
 WHERE     lhv.list_header_id = llv.list_header_id
       AND lhv.currency_header_id = clt.currency_header_id
       AND llv.product_id = mcv.category_id
       AND llv.price_by_formula_id = qpf.price_formula_id(+)
       AND llv.list_line_id = qpa.list_line_id
       AND llv.pricing_attribute_id = qpa.pricing_attribute_id(+)
       AND llv.list_line_id = qpal.list_line_id(+)
       AND llv.list_line_id = qpab.list_line_id(+)
       AND qpal.pricing_attribute = 'PRICING_ATTRIBUTE25'
       AND qpab.pricing_attribute = 'PRICING_ATTRIBUTE26'
       AND qpal.pricing_attr_value_from_number = hcsua.site_use_id
       AND customer_id = hcasa.cust_account_id
       AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
       AND llv.product_uom_code = uom.uom_code
       AND qpab.pricing_attr_value_from = boe.lookup_code(+)
       AND lhv.list_header_id = :p_list_header_id
       AND (:p_line_of_business IS NULL
            OR llv.attribute1 = :p_line_of_business)
       AND (:p_item_sales_category IS NULL
            OR llv.product_attr_val_disp = :p_item_sales_category)
       AND (:p_customer_id IS NULL OR cus.customer_id = :p_customer_id)
       AND (:p_buyer_name IS NULL OR boe.lookup_code = :p_buyer_name)
       AND TRUNC (llv.start_date_active) BETWEEN :p_start_date
                                             AND  :p_end_date
       AND TRUNC (llv.end_date_active) BETWEEN :p_start_date AND :p_end_date
       AND lhv.list_header_id = '118211'
--AND lhv.name = 'ETY-ST-PL'
--       AND qpab.pricing_attr_value_from = 'BERSHKA'
--       AND llv.attribute3 = 'SOORTY TEXTILE LTD.BERSHKA'
--       AND mcv.concatenated_segments = 'ES01025.COLOUR'
UNION ALL
SELECT lhv.name price_list_name,
       lhv.description price_list_description,
       lhv.currency_code currency,
       clt.name currency_conversion,
       llv.start_date_active effective_date_from,
       llv.end_date_active effective_date_to,
       llv.attribute1 line_of_business,
       llv.product_attribute_context ln_product_context,
       'Item Category' ln_product_attribute,
       mcv.concatenated_segments ln_product_value,
       qpf.price_formula_id dynamic_formula,
       uom.uom_code uom,
       qpa.product_uom_code ln_uom_code,
       llv.list_line_type_code ln_type_code,
       llv.arithmetic_operator ln_application_operator,
       llv.operand ln_value,
       llv.attribute3 ln_attribute1,
       NULL ln_attribute2,
       NULL ln_attribute3,
       NULL ln_attribute4,
       'DBL_CUSTOMER' cust_pricing_attribute,
       NULL cust_operator,
       cus.customer_number,
       cus.customer_name,
       'DBL_BUYER' buyer_pricing_attribute,
       qpal.comparison_operator_code buyer_operator,
       NULL buyer_lookup_code,
       NULL buyer_name,
       qpal.attribute1 process_loss
  FROM qp_list_headers lhv,
       qp_list_lines_v llv,
       qp_currency_lists_tl clt,
       qp_price_formulas qpf,
       mtl_categories_kfv mcv,
       qp_pricing_attributes qpa,
       qp_pricing_attributes qpal,
       ar_customers cus,
       apps.hz_cust_acct_sites_all hcasa,
       apps.hz_cust_site_uses_all hcsua,
       mtl_units_of_measure_vl uom
 WHERE     lhv.list_header_id = llv.list_header_id
       AND lhv.currency_header_id = clt.currency_header_id
       AND llv.product_id = mcv.category_id
       AND llv.price_by_formula_id = qpf.price_formula_id(+)
       AND llv.list_line_id = qpa.list_line_id
       AND llv.pricing_attribute_id = qpa.pricing_attribute_id
       AND llv.list_line_id = qpal.list_line_id
       AND qpal.pricing_attribute = 'PRICING_ATTRIBUTE25'
       AND qpal.pricing_attr_value_from_number = hcsua.site_use_id
       AND cus.customer_id = hcasa.cust_account_id
       AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
       AND llv.product_uom_code = uom.uom_code
       AND lhv.list_header_id NOT IN ('118211')
       AND lhv.list_header_id = :p_list_header_id
       AND (:p_line_of_business IS NULL
            OR llv.attribute1 = :p_line_of_business)
       AND (:p_item_sales_category IS NULL
            OR llv.product_attr_val_disp = :p_item_sales_category)
       AND (:p_customer_id IS NULL OR cus.customer_id = :p_customer_id)
       --AND (:p_buyer_name IS NULL OR boe.lookup_code = :p_buyer_name)
       AND TRUNC (llv.start_date_active) BETWEEN :p_start_date
                                             AND  :p_end_date
       AND TRUNC (llv.end_date_active) BETWEEN :p_start_date AND :p_end_date
--       AND lhv.name = 'ECO-THREAD-PL'
--       AND qpab.pricing_attr_value_from = 'BERSHKA'
--       AND llv.attribute3 = 'SOORTY TEXTILE LTD.BERSHKA'
--       AND mcv.concatenated_segments = 'ES01025.COLOUR'
