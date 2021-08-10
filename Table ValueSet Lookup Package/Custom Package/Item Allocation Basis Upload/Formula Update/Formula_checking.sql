/* Formatted on 10/14/2020 9:58:12 AM (QP5 v5.287) */
SELECT                                                                     --*
       DISTINCT mst.formula_class
  FROM fm_form_mst mst
 WHERE 1 = 1
--AND mst.formula_class IN ('FD', 'YD')
;


select
*
from
fm_rout_dtl frd;


SELECT rcp.recipe_id,
       fmd.formulaline_id,
       frd.routingstep_id,
       NULL,
       SYSDATE,
       fnd_global.user_id,
       fnd_global.user_id,
       SYSDATE,
       fnd_global.login_id,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL
  FROM gmd_recipes rcp,
       fm_form_mst mst,
       fm_rout_hdr rt,
       fm_matl_dtl fmd,
       fm_rout_dtl frd
 WHERE     rcp.formula_id = mst.formula_id
       AND mst.formula_id = fmd.formula_id
       AND fmd.line_type = -1
       AND fmd.line_no = 1
       AND rcp.owner_organization_id = 152
       AND rcp.routing_id = rt.routing_id
       AND rt.owner_organization_id = 152
       AND rt.routing_id = frd.routing_id
       AND frd.routingstep_no = '10'
       AND mst.formula_class = 'PWDR'
       AND mst.owner_organization_id = 152
       AND rcp.recipe_no = NVL (:l_recipe_no, rcp.recipe_no)
       AND rcp.recipe_id NOT IN (SELECT recipe_id
                                   FROM gmd_recipe_step_materials)
UNION ALL
SELECT rcp.recipe_id,
       fmd.formulaline_id,
       frd.routingstep_id,
       NULL,
       SYSDATE,
       fnd_global.user_id,
       fnd_global.user_id,
       SYSDATE,
       fnd_global.login_id,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL
  FROM gmd_recipes rcp,
       fm_form_mst mst,
       fm_rout_hdr rt,
       fm_matl_dtl fmd,
       fm_rout_dtl frd
 WHERE     rcp.formula_id = mst.formula_id
       AND mst.formula_id = fmd.formula_id
       AND fmd.line_type = -1
       AND fmd.line_no = 1
       AND rcp.owner_organization_id = 152
       AND rcp.routing_id = rt.routing_id
       AND rt.owner_organization_id = 152
       AND rt.routing_id = frd.routing_id
       AND frd.routingstep_no = '10'
       AND mst.formula_class = 'FT'
       AND mst.owner_organization_id = 152
       AND rcp.recipe_no = NVL (:l_recipe_no, rcp.recipe_no)
       AND rcp.recipe_id NOT IN (SELECT recipe_id
                                   FROM gmd_recipe_step_materials)
UNION ALL
SELECT rcp.recipe_id,
       fmd.formulaline_id,
       frd.routingstep_id,
       NULL,
       SYSDATE,
       fnd_global.user_id,
       fnd_global.user_id,
       SYSDATE,
       fnd_global.login_id,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL
  FROM gmd_recipes rcp,
       fm_form_mst mst,
       fm_rout_hdr rt,
       fm_matl_dtl fmd,
       fm_rout_dtl frd
 WHERE     rcp.formula_id = mst.formula_id
       AND mst.formula_id = fmd.formula_id
       AND fmd.line_type = -1
       AND fmd.line_no = 1
       AND rcp.owner_organization_id = 152
       AND rcp.routing_id = rt.routing_id
       AND rt.owner_organization_id = 152
       AND rt.routing_id = frd.routing_id
       AND frd.routingstep_no = '20'
       AND mst.formula_class='FG'
       AND mst.owner_organization_id = 152
       AND rcp.recipe_no = NVL (:l_recipe_no, rcp.recipe_no)
       AND rcp.recipe_id NOT IN (SELECT recipe_id
                                   FROM gmd_recipe_step_materials);