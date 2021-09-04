/* Formatted on 9/2/2021 9:54:31 AM (QP5 v5.287) */
  SELECT *
    FROM xxdbl_item_errors
   WHERE 1 = 1 AND BATCH_ID = 16828
ORDER BY CREATION_DATE DESC;

SELECT xim.*
  FROM xxdbl_item_master xim
 WHERE batch_id = :p_batch_id;

SELECT COUNT (1)                                                        --INTO
                l_complete_count
  FROM xxdbl_item_master
 WHERE batch_id = :p_batch_id AND item_status = 'COMPLETED';

SELECT COUNT (1) l_error_count
  --,xim.*
  FROM xxdbl_item_master xim
 WHERE batch_id = :p_batch_id AND item_status = 'ERROR';
 
 SELECT COUNT (1) l_error_count
  --,xim.*
  FROM xxdbl_item_master xim
 WHERE batch_id = :p_batch_id AND item_status = 'SUBMITTED';
 
SELECT *
  FROM xxdbl_item_batches
 WHERE batch_id = :p_batch_id;

SELECT *
  FROM xxdbl_item_orgs io
 WHERE io.item_master_id = :p_item_master_id;

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

SELECT organization_id
  FROM mtl_parameters mp
 WHERE master_organization_id = :p_organization_id;

SELECT template_id,
       lead_time,
       min_quantity,
       max_quantity,
       rfq_flag,
       routing,
       expense_account,
       expense_sub_account,
       product_line,
       category_id,
       category_set_id,
       category_name
  FROM xxdbl_item_org_hierarchy
 WHERE item_master_id = :p_item_master_id AND ROWNUM = 1;

SELECT msib.inventory_item_id
  FROM mtl_system_items_b msib
 WHERE     msib.segment1 = :p_item_code
       AND msib.organization_id = :l_master_org_id;