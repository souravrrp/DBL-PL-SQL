/* Formatted on 11/18/2020 3:01:33 PM (QP5 v5.287) */
SELECT * FROM xxdbl.xxdbl_manual_pi_header;


SELECT customer_number, customer_name
  FROM xx_ar_customer_site_v acs
 WHERE     1 = 1
       AND site_use_code = 'BILL_TO'
       AND primary_flag = 'Y'
       AND status = 'A'
       AND org_id = 125;



SELECT MSI.ORGANIZATION_ID,
       CAT.SEGMENT1 || '-' || CAT.SEGMENT2 ARTICLE,
       MSI.INVENTORY_ITEM_ID,
       MSI.SEGMENT1 ITEM_CODE,
       MSI.DESCRIPTION,
       MSI.PRIMARY_UOM_CODE,
       MSI.UNIT_WEIGHT,
       MSI.SECONDARY_UOM_CODE,
       MSI.ATTRIBUTE14 TEMPLATE_NAME,
       CAT.CATEGORY_SET_NAME CATEGORY_SET,
       CAT.CATEGORY_ID,
       CAT.SEGMENT1 LINE_OF_BUSINESS,
       CAT.SEGMENT2 ITEM_CATEGORY,
       CAT.SEGMENT3 ITEM_TYPE,
       CAT.SEGMENT4 CATELOG,
       CAT.CATEGORY_CONCAT_SEGS CATEGORY_SEGMENTS,
       MSI.CREATION_DATE,
       MUCC.CONVERSION_RATE
  --MSI.*
  --,CAT.*
  FROM APPS.MTL_SYSTEM_ITEMS_B MSI,
       APPS.MTL_ITEM_CATEGORIES_V CAT,
       MTL_UOM_CLASS_CONVERSIONS MUCC
 WHERE     1 = 1
       AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
       AND MSI.ORGANIZATION_ID = CAT.ORGANIZATION_ID
       AND MSI.INVENTORY_ITEM_STATUS_CODE = 'Active'
       AND MSI.INVENTORY_ITEM_ID = MUCC.INVENTORY_ITEM_ID
       --AND ORGANIZATION_CODE NOT IN ('IMO')
       --AND ORGANIZATION_CODE IN ('251')
       --AND OPERATING_UNIT IN (85)
       --AND MSI.INVENTORY_ITEM_ID IN ('7297')
       --AND MSI.SEGMENT1 IN ('ES05030-18690X')
       AND CAT.SEGMENT1 || '-' || CAT.SEGMENT2='EE01120-COLOUR'
       --AND MSI.SEGMENT1 LIKE ('PUMA%')
       --AND MSI.DESCRIPTION IN ('40S1-COTTON-100%-CH ORGANIC')
       --AND MSI.PRIMARY_UOM_CODE='PCS'
       AND MSI.ORGANIZATION_ID = 150
       --AND CAT.CATEGORY_SET_ID != 1
       AND CAT.CATEGORY_SET_NAME = 'DBL_SALES_CAT_SET'
       --AND CAT.CATEGORY_ID='74551'
       --AND CAT.SEGMENT2 = 'FINISH GOODS'
       --AND CAT.SEGMENT2='BRND'
       --AND CAT.SEGMENT3='GIFT'
       AND MSI.ENABLED_FLAG = 'Y';


SELECT cat.segment1 || '-' || cat.segment2 article,
       msi.segment1 item_code,
       msi.description,
       msi.primary_uom_code uom_code,
       msi.unit_weight gross_weight,
       mucc.conversion_rate net_weight
  FROM apps.mtl_system_items_b msi,
       apps.mtl_item_categories_v cat,
       mtl_uom_class_conversions mucc
 WHERE     1 = 1
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.organization_id = cat.organization_id
       AND msi.inventory_item_status_code = 'Active'
       AND msi.inventory_item_id = mucc.inventory_item_id
       AND msi.organization_id = 150
       AND cat.category_set_name = 'DBL_SALES_CAT_SET'
       AND msi.enabled_flag = 'Y';
       
       
       /* Formatted on 11/24/2020 11:41:40 AM (QP5 v5.287) */
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
       AND ( :p_customer_id IS NULL OR cus.customer_id = :p_customer_id)
       AND (   :p_color_group IS NULL
            OR mcv.concatenated_segments = :p_color_group)
       --AND ( :p_buyer_name IS NULL OR boe.lookup_code = :p_buyer_name)
       AND lhv.list_header_id = '118211'
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
       AND ( :p_customer_id IS NULL OR cus.customer_id = :p_customer_id)
       --AND (:p_buyer_name IS NULL OR boe.lookup_code = :p_buyer_name)
       AND (   :p_color_group IS NULL
            OR mcv.concatenated_segments = :p_color_group);
            
            
            
/* Formatted on 11/24/2020 3:39:16 PM (QP5 v5.354) */
SELECT lookup_code buyer
  FROM oe_lookups
 WHERE lookup_type = 'SALES_CHANNEL'
 
 
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
       AND ( :p_customer_id IS NULL OR cus.customer_id = :p_customer_id)
       AND (   :p_color_group IS NULL
            OR mcv.concatenated_segments = :p_color_group)
       --AND ( :p_buyer_name IS NULL OR boe.lookup_code = :p_buyer_name)
       AND lhv.list_header_id = '118211'
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
       AND ( :p_customer_id IS NULL OR cus.customer_id = :p_customer_id)
       --AND (:p_buyer_name IS NULL OR boe.lookup_code = :p_buyer_name)
       AND (   :p_color_group IS NULL
            OR mcv.concatenated_segments = :p_color_group);