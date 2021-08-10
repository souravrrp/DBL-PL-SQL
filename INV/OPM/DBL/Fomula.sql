/* Formatted on 8/19/2020 3:57:25 PM (QP5 v5.287) */
SELECT *
  FROM gmd_recipes rcp,
       fm_form_mst mst,
       fm_rout_hdr rt,
       fm_matl_dtl fmd,
       fm_rout_dtl frd
 WHERE     rcp.formula_id = mst.formula_id
       AND mst.formula_id = fmd.formula_id
       AND fmd.line_type = -1
       AND fmd.line_no = 1
       AND rcp.owner_organization_id = 150
       AND rcp.routing_id = rt.routing_id
       AND rt.owner_organization_id = 150
       AND rt.routing_id = frd.routing_id
       AND frd.routingstep_no = '20'
       AND mst.formula_class IN ('FD', 'YD')
       AND mst.owner_organization_id = 150;


--------------------------------------------------------------------------------


SELECT *
  FROM gmd_recipes rcp;

SELECT *
  FROM fm_form_mst mst;

SELECT *
  FROM fm_rout_hdr rcp;

SELECT *
  FROM fm_matl_dtl mst;

SELECT * FROM fm_rout_dtl