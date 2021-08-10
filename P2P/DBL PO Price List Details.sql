/* Formatted on 5/4/2021 1:00:08 PM (QP5 v5.354) */
  SELECT DISTINCT qph.name         Price_List_Name,
                  msi.segment1     Item_Name,
                  cat.segment2     item_category,
                  cat.segment3     item_type,
                  qpl.operand,
                  qpl.start_date_active,
                  qpl.end_date_active,
                  qph.*
    FROM qp_list_headers           qph,
         apps.qp_list_lines_v      qpl,
         inv.mtl_system_items_b    msi,
         apps.mtl_item_categories_v cat
   WHERE     qph.list_header_id = qpl.list_header_id
         AND ( :p_price_list IS NULL OR (qph.name = :p_price_list))
         --AND msi.organization_id = :p_org_id
         --AND msi.segment1 = :p_item_number
         AND ( :p_item_code IS NULL OR (msi.segment1 = :p_item_code))
         AND qpl.end_date_active IS NULL
         --AND TRUNC (SYSDATE) BETWEEN TRUNC (qpl.start_date_active) AND TRUNC (qpl.end_date_active)
         AND TO_CHAR (qpl.product_attr_value) = TO_CHAR (msi.inventory_item_id)
         AND msi.inventory_item_status_code = 'Active'
         AND cat.category_set_id = 1
         AND msi.enabled_flag = 'Y'
         AND msi.inventory_item_id = cat.inventory_item_id
         AND msi.organization_id = cat.organization_id
         AND (   :p_line_of_business IS NULL
              OR (cat.segment1 = :p_line_of_business))
         AND ( :p_major_category IS NULL OR (cat.segment2 = :p_major_category))
         AND ( :p_minor_category IS NULL OR (cat.segment3 = :p_minor_category))
         AND ( :p_item_catelog IS NULL OR (cat.segment4 = :p_item_catelog))
ORDER BY qph.name, cat.segment2, cat.segment3;