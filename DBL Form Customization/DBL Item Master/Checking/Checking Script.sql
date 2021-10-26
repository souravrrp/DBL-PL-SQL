/* Formatted on 10/24/2021 3:19:20 PM (QP5 v5.365) */
SELECT b.batch_name, xim.*
  FROM xxdbl_item_master xim, xxdbl_item_batches b
 WHERE     xim.batch_id = :p_batch_id
       AND b.batch_id = xim.batch_id
       AND xim.item_status != 'COMPLETED';


SELECT io.organization_id,
       io.organization_code,
       io.org_name,
       ioh.item_org_hierarchy_id,
       ioh.item_master_id,
       ioh.organization_structure_id,
       ioh.org_hierarchy,
       ioh.template_id,
       ioh.template_name,
       ioh.category_set_id,
       ioh.category_id,
       ioh.category_name,
       ioh.lead_time,
       ioh.min_quantity,
       ioh.max_quantity,
       ioh.rfq_flag,
       ioh.lcm_flag,
       ioh.routing,
       ioh.expense_account,
       ioh.expense_sub_account,
       ioh.product_line
  FROM xxdbl_item_orgs io, xxdbl.xxdbl_item_org_hierarchy ioh
 WHERE     io.item_org_hierarchy_id = ioh.item_org_hierarchy_id
       AND ioh.item_master_id = :p_item_master_id
       AND NOT EXISTS
               (SELECT 1
                  FROM mtl_system_items si
                 WHERE     si.inventory_item_id = :p_inventory_item_id
                       AND si.organization_id = io.organization_id);

SELECT *
  FROM xxdbl.xxdbl_item_org_hierarchy ioh
 WHERE 1 = 1                      --AND ioh.item_master_id = :p_item_master_id
             AND ioh.batch_id = :p_batch_id;