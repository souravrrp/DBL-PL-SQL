/* Formatted on 2/13/2021 2:53:10 PM (QP5 v5.354) */
SELECT ood.organization_name,
       ood.organization_code org_code,
       grt.routing_no,
       gr.recipe_no,
       --gr.recipe_description,
       ffmb.formula_no,
       (SELECT meaning FROM apps.gem_lookups gl WHERE     gl.lookup_type = 'LINE_TYPE' AND TO_CHAR (fmd.line_type) = TO_CHAR (gl.lookup_code)) formulae_line_type,
       ffmb.formula_class,
       msi.segment1 item_code,
       msi.description,
       cat.segment1 line_of_business,
       cat.segment2 item_category,
       cat.segment3 item_type,
       cat.segment4 catelog
  --,GOR.*
  --,MTLV.*
  --,GOV.*
  --,GOA.*
  --,GBS.*
  --,GOA.*
  --,GBSA.*
  --,GBSR.*
  --,GBHS.*
  --,MTRL.*
  --,grvr.*
  --,gr.*
  --,fmd.*
  --,gbh.*
  --,gmd.*
  --,mmt.*
  --,mtt.*
  --,mtln.*
  --,grt.*
  FROM 
       gmd_routings_b                  grt,
       gmd_recipes_b                   gr,
       gmd_recipe_validity_rules     grvr,
       fm_form_mst_b                 ffmb,
       fm_matl_dtl                   fmd,
       inv.mtl_system_items_b        msi,
       org_organization_definitions  ood,
       apps.mtl_item_categories_v    cat
 WHERE     1 = 1
       AND grt.routing_id = gr.routing_id
       AND gr.recipe_id = grvr.recipe_id
       AND gr.formula_id = ffmb.formula_id
       AND ffmb.formula_id = fmd.formula_id
       AND fmd.inventory_item_id = msi.inventory_item_id
       AND fmd.organization_id = msi.organization_id
       AND grt.owner_organization_id = ood.organization_id
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.organization_id = cat.organization_id
       AND cat.category_set_id = 1
       --AND goa.activity = 'DRY_SQUARING'
       --AND gr.recipe_no = 'W3050-007BR'
       --AND ffmb.formula_no='D2540-001PK'
       AND (   :p_organization_code is null or (ood.organization_code = :p_organization_code))
       AND (   :p_routing_no is null        or (grt.routing_no = :p_routing_no))
       AND (   :p_recipe_no is null         or (gr.recipe_no = :p_recipe_no))
       AND (   :p_formula_no is null        or (ffmb.formula_no = :p_formula_no))
       AND (   :p_item_code is null         or (msi.segment1 = :p_item_code))
       AND (   :p_item_desc is null         or (upper(msi.description) like upper('%'||:p_item_desc||'%') ))
       ;


--------------------------------------------------------------------------------

SELECT ood.organization_name,
       ood.organization_code org_code,
       gav.activity_desc,
       gov.oprn_desc,
       (SELECT gs.description FROM gmd_status gs WHERE gov.operation_status = gs.status_code) operation_status,
       gor.resources,
       frh.routing_no,
       gr.recipe_no,
       gr.recipe_description,
       ffmb.formula_no,
       (SELECT meaning FROM apps.gem_lookups gl WHERE     gl.lookup_type = 'LINE_TYPE' AND TO_CHAR (fmd.line_type) = TO_CHAR (gl.lookup_code)) formulae_line_type,
       ffmb.formula_class,
       msi.segment1 item_code,
       msi.description,
       cat.segment1 line_of_business,
       cat.segment2 item_category,
       cat.segment3 item_type,
       cat.segment4 catelog
  --,GOR.*
  --,MTLV.*
  --,GOV.*
  --,GOA.*
  --,GBS.*
  --,GOA.*
  --,GBSA.*
  --,GBSR.*
  --,GBHS.*
  --,MTRL.*
  --,grvr.*
  --,gr.*
  --,fmd.*
  --,gbh.*
  --,gmd.*
  --mmt.*
  --mtt.*
  --,mtln.*
  FROM gmd_activities_vl             gav,
       gmd_operation_activities      goa,
       gmd_operations_vl             gov,
       gmd_operation_resources       gor,
       fm_rout_dtl                   frl,
       fm_rout_hdr                   frh,
       --gmd_routings                  grt,
       gmd_recipes                   gr,
       gmd_recipe_validity_rules     grvr,
       fm_form_mst_b                 ffmb,
       fm_matl_dtl                   fmd,
       inv.mtl_system_items_b        msi,
       org_organization_definitions  ood,
       apps.mtl_item_categories_v cat
 WHERE     1 = 1
       AND gav.activity = goa.activity(+)
       AND goa.oprn_id = gov.oprn_id(+)
       AND goa.oprn_line_id = gor.oprn_line_id(+)
       AND gov.oprn_id = frl.oprn_id(+)
       AND frl.routing_id = frh.routing_id(+)
       --AND frh.routing_id = grt.routing_id(+)
       AND frh.routing_id = gr.routing_id(+)
       AND gr.recipe_id = grvr.recipe_id(+)
       AND gr.formula_id = ffmb.formula_id(+)
       AND ffmb.formula_id = fmd.formula_id(+)
       AND fmd.inventory_item_id = msi.inventory_item_id(+)
       AND fmd.organization_id = msi.organization_id(+)
       AND frh.owner_organization_id = ood.organization_id(+)
       AND msi.inventory_item_id = cat.inventory_item_id(+)
       AND msi.organization_id = cat.organization_id(+)
       AND cat.category_set_id=1       
       --AND goa.activity = 'DRY_SQUARING'
       --AND gr.recipe_no = 'W3050-007BR'
       --AND ffmb.formula_no='D2540-001PK'
       AND (   :p_organization_code is null or (ood.organization_code = :p_organization_code))
       AND (   :p_routing_no is null        or (frh.routing_no = :p_routing_no))
       AND (   :p_recipe_no is null         or (gr.recipe_no = :p_recipe_no))
       AND (   :p_formula_no is null        or (ffmb.formula_no = :p_formula_no))
       AND (   :p_item_code is null         or (msi.segment1 = :p_item_code))
       AND (   :p_item_desc is null         or (upper(msi.description) like upper('%'||:p_item_desc||'%') ))
       ;