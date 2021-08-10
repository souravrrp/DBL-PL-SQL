/* Formatted on 1/21/2021 5:31:42 PM (QP5 v5.354) */
  SELECT ffm.formula_no,
         ffm.formula_desc1                                    formula_name,
         DECODE (fmd.line_type,
                 -1, 'Ingredient',
                 1, 'Product',
                 2, 'By-product')                             TYPE,
         msi.segment1                                         item_code,
         ood.organization_code                                org,
         fmd.qty,
         fmd.detail_uom,
         DECODE (ffm.formula_status, 700, 'Active', 'New')    status
    FROM apps.fm_matl_dtl                 fmd,
         apps.fm_form_mst                 ffm,
         apps.mtl_system_items_b          msi,
         apps.org_organization_definitions ood
   WHERE     fmd.formula_id = ffm.formula_id
         AND (    fmd.inventory_item_id = msi.inventory_item_id(+)
              AND fmd.organization_id = msi.organization_id(+))
         AND fmd.organization_id = ood.organization_id
         --AND ood.organization_code in ('251')
         --AND (   :p_formula_no IS NULL OR (UPPER (ffm.formula_no) LIKE UPPER ('%' || :p_formula_no || '%')))
         AND (   :p_formula_no IS NULL
              OR (UPPER (ffm.formula_no) = UPPER ( :p_formula_no)))
         AND (   :p_org_code IS NULL
              OR (UPPER (ood.organization_code) = UPPER ( :p_org_code)))
ORDER BY formula_no,
         DECODE (fmd.line_type,
                 -1, 'Ingredient',
                 1, 'Product',
                 2, 'By-product') DESC;