/* Formatted on 11/24/2020 5:50:50 PM (QP5 v5.287) */
FUNCTION populate_cust_price (p_color VARCHAR2, p_customer VARCHAR2,p_buyer VARCHAR2)
   RETURN NUMBER
IS
   l_price   NUMBER;
BEGIN
   SELECT operand
     INTO l_price
     FROM (SELECT llv.operand
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
                  AND cus.customer_number = p_customer
                  AND mcv.concatenated_segments = p_color
                  AND boe.lookup_code = p_buyer
                  AND lhv.list_header_id = '118211'
           UNION ALL
           SELECT llv.operand
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
                  AND cus.customer_number = p_customer
                  AND mcv.concatenated_segments = p_color);

   RETURN l_price;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 0;
END;