/* Formatted on 2/27/2020 9:22:09 AM (QP5 v5.287) */
  SELECT                                                 --ood.operating_unit,
        msib.organization_id,
         msib.segment1 item_code,
         msib.description item_name,
         catb.segment2 major_category,
         catb.segment3 minor_category,
         cat.segment3 product_line,
         ROUND (SUM (dtl.actual_qty), 2) quantity,
         --ROUND(SUM (cd.cmpnt_cost),2) tot_value
         cd.cmpnt_cost
    FROM gme_batch_header hdr,
         fm_form_mst mst,
         gme_material_details dtl,
         mtl_system_items_b msib,
         mtl_system_items_b msi,
         gme_material_details dtl_prod,
         apps.org_organization_definitions ood,
         apps.mtl_item_categories_v catb,
         apps.mtl_item_categories_v cat
         --,apps.cm_cldr_mst_v clm
         --,apps.cm_cmpt_dtl cd
   WHERE        1 = 1
            AND msib.organization_id = ood.organization_id
            AND msib.inventory_item_id = catb.inventory_item_id
            AND msib.organization_id = catb.organization_id
            AND mst.formula_no = msi.segment1
            AND mst.owner_organization_id = msi.organization_id
            AND msi.inventory_item_id = cat.inventory_item_id
            AND msi.organization_id = cat.organization_id
            --AND OOD.OPERATING_UNIT='123'
            AND hdr.formula_id = mst.formula_id
            AND hdr.batch_id = dtl.batch_id
            AND dtl.line_type = -1
            AND dtl.inventory_item_id = msib.inventory_item_id
            AND msib.organization_id = :p_organization_id
            AND catb.SEGMENT3 IN ('CHEMICAL', 'DYES')
            AND catb.SEGMENT2 = 'RAW MATERIAL'
            AND cat.SEGMENT3 IN ('DYED FIBER', 'SEWING THREAD', 'DYED YARN')
            --AND msib.segment1 LIKE 'P%'
            AND mst.formula_class IN ('ST', 'FD', 'YD')
            AND hdr.organization_id = ood.organization_id
            AND dtl.organization_id = ood.organization_id
            AND mst.owner_organization_id = ood.organization_id
            AND hdr.batch_status IN (4)
            AND hdr.batch_id = dtl_prod.batch_id
            AND dtl_prod.line_type = 1
            AND hdr.batch_no = '54308'
            --AND TO_CHAR (hdr.actual_cmplt_date, 'MON-RR') = TO_CHAR (clm.period_code)
            --AND cd.organization_id = ood.organization_id
            --AND cd.inventory_item_id = msib.inventory_item_id
            --AND cd.organization_id = msib.organization_id
            --AND clm.legal_entity_id = ood.legal_entity
            --AND ( :P_CONCATENATED_SEGMENTS IS NULL OR MSIB.SEGMENT1 = :P_CONCATENATED_SEGMENTS)
--            AND (   :p_date_from IS NULL OR TRUNC (hdr.actual_cmplt_date) BETWEEN :p_date_from  AND :p_date_to)
GROUP BY                                                 --ood.operating_unit,
        msib.organization_id,
         cat.segment3,
         msib.description,
         msib.segment1,
         catb.segment2,
         catb.segment3,
         cd.cmpnt_cost
ORDER BY 1;

--------------------------------------------------------------------------------


  SELECT ood.operating_unit,
         msib.organization_id,
         hdr.batch_no,
         hdr.batch_status,
         mst.formula_no,
         cat.category_set_name category_set,
         cat.segment1 line_of_business,
         cat.segment2 item_category,
         cat.segment3 item_type,
         cat.segment4 catelog,
         cat.category_concat_segs category_segments,
         msib.segment1,
         catb.category_set_name ing_category_set,
         catb.segment1 ing_line_of_business,
         catb.segment2 ing_category,
         catb.segment3 ing_type,
         catb.segment4 ing_catelog,
         catb.category_concat_segs ing_category_segments,
         dtl.plan_qty plan_qty_ingrd,
         dtl.actual_qty actual_qty_ingrd,
         hdr.actual_cmplt_date,
         dtl_prod.plan_qty plan_qty_prod,
         dtl_prod.actual_qty actual_qty_prod
    FROM gme_batch_header hdr,
         fm_form_mst mst,
         gme_material_details dtl,
         mtl_system_items_b msib,
         mtl_system_items_b msi,
         gme_material_details dtl_prod,
         apps.org_organization_definitions ood,
         apps.mtl_item_categories_v catb,
         apps.mtl_item_categories_v cat
   WHERE     1 = 1
         AND msib.organization_id = ood.organization_id
         AND msib.inventory_item_id = catb.inventory_item_id
         AND msib.organization_id = catb.organization_id
         AND mst.formula_no = msi.segment1
         AND mst.owner_organization_id = msi.organization_id
         AND msi.inventory_item_id = cat.inventory_item_id
         AND msi.organization_id = cat.organization_id
         --AND OOD.OPERATING_UNIT='123'
         AND hdr.formula_id = mst.formula_id
         AND hdr.batch_id = dtl.batch_id
         AND dtl.line_type = -1
         AND dtl.inventory_item_id = msib.inventory_item_id
         AND msib.organization_id = :p_organization_id
         AND catb.SEGMENT3 IN ('CHEMICAL', 'DYES')
         AND catb.SEGMENT2 = 'RAW MATERIAL'
         AND cat.SEGMENT3 IN ('SEWING THREAD')
         --AND msib.segment1 LIKE 'P%'
         AND mst.formula_class IN ('ST', 'FD', 'YD')
         AND hdr.organization_id = ood.organization_id
         AND dtl.organization_id = ood.organization_id
         AND mst.owner_organization_id = ood.organization_id
         AND hdr.batch_status IN (2, 3, 4)
         AND hdr.batch_id = dtl_prod.batch_id
         AND dtl_prod.line_type = 1
         AND (   :p_date_from IS NULL
              OR TRUNC (hdr.actual_cmplt_date) BETWEEN :p_date_from
                                                   AND :p_date_to)
--AND hdr.batch_no = '54308'
ORDER BY 1;

--------------------------------------------------------------------------------