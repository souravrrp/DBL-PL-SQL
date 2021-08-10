/* Formatted on 3/21/2021 5:04:51 PM (QP5 v5.287) */
SELECT ood.organization_code org,
       ffm.formula_no,
       ffm.formula_desc1 formula_name,
       DECODE (fmd.line_type,
               -1, 'Ingredient',
               1, 'Product',
               2, 'By-product')
          product_type,
       msi.segment1 item_code,
       fmd.qty,
       drh.kg_per_pkg,
       fmd.last_update_date
  FROM apps.fm_matl_dtl fmd,
       apps.fm_form_mst ffm,
       apps.mtl_system_items_b msi,
       apps.org_organization_definitions ood,
       xxdbl.xxdbl_dyehouse_routing_hdr drh
 WHERE     fmd.formula_id = ffm.formula_id
       AND (    fmd.inventory_item_id = msi.inventory_item_id(+)
            AND fmd.organization_id = msi.organization_id(+))
       AND fmd.organization_id = ood.organization_id
       AND fmd.line_type = -1
       AND ood.organization_code = '193'
       AND ffm.formula_no = drh.article_ticket(+)
       AND ffm.formula_no = 'EE01120';


--------------------------------------------------------------------------------


SELECT ood.organization_code org,
       ffm.formula_no,
       ffm.formula_desc1 formula_name,
       DECODE (fmd.line_type,
               -1, 'Ingredient',
               1, 'Product',
               2, 'By-product')
          product_type,
       msi.segment1 item_code,
       fmd.qty,
       drh.kg_per_pkg,
       fmd.last_update_date
  FROM apps.fm_matl_dtl fmd,
       apps.fm_form_mst ffm,
       apps.mtl_system_items_b msi,
       apps.org_organization_definitions ood,
       xxdbl.xxdbl_dyehouse_routing_hdr drh
 WHERE     fmd.formula_id = ffm.formula_id
       AND (    fmd.inventory_item_id = msi.inventory_item_id(+)
            AND fmd.organization_id = msi.organization_id(+))
       AND fmd.organization_id = ood.organization_id
       AND fmd.line_type = -1
       AND ood.organization_code = '193'
       AND ffm.formula_no = drh.article_ticket(+)
       --AND ffm.formula_no = 'EE01120'
       AND EXISTS
              (SELECT 1
                 FROM apps.mtl_system_items_b msib,
                      apps.mtl_item_categories_v cat
                WHERE     1 = 1
                      AND msib.inventory_item_id = cat.inventory_item_id
                      AND msib.organization_id = cat.organization_id
                      AND cat.category_set_name = 'DBL_SALES_PLAN_CAT'
                      AND msib.inventory_item_status_code = 'Active'
                      AND cat.segment1 = 'SEWING THREAD'
                      AND ffm.formula_no = cat.segment2
                      AND msi.organization_id = 150
                      AND ffm.formula_no = msib.segment1);