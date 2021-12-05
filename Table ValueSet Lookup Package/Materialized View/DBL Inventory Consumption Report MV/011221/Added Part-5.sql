SELECT '5.eAM Work Order'             AS tr_source,
       'WIP Transaction'              tr_type,
       a.transaction_id,
       c.segment1                     item_code,
       c.description                  item_description,
       c.primary_uom_code             uom,
       mic.segment2                   item_category,
       mic.segment3                   item_type,
       (a.primary_quantity)           trx_quantity,
       CASE
           WHEN mp.process_enabled_flag = 'N'
           THEN
               apps.xx_inv_tran_val_t (a.transaction_id)
           ELSE
               apps.xx_oinv_tran_val (a.transaction_id)
       END                            AS total_cost,
       cc.segment5                    natural_acc,
       cc.segment1                    company,
       cc.segment2                    location_desc,
       cc.segment3                    product_line_desc,
       cc.segment4                    cost_center_desc,
       cc.segment5                    natural_account_desc,
       cc.segment6                    sub_acccount_desc,
       cc.segment7                    inter_company,
       cc.segment8                    exp_category_desc,
       ood.operating_unit             org_id,
       ood.organization_name,
       ood.set_of_books_id,
       ood.organization_id,
       b.request_number               mo_no,
       TRUNC (a.transaction_date)     transaction_date,
       prd.period_name,
          --NVL ( MTRL . ATTRIBUTE7 ,  MTRL . ATTRIBUTE13 )     USE_AREA ,
          cc.segment1
       || '.'
       || cc.segment2
       || '.'
       || cc.segment3
       || '.'
       || cc.segment4
       || '.'
       || cc.segment5
       || '.'
       || cc.segment6
       || '.'
       || cc.segment7
       || '.'
       || cc.segment8
       || '.'
       || cc.segment9                 code_combination,
       NULL                           buyer_name,
       NULL                           customer_name,
       b.created_by                   created_by,
       wod.asset_number               asset,
       wod.asset_group_description    asset_category
  FROM apps.mtl_material_transactions     a,
       apps.mtl_txn_request_headers       b,
       mtl_txn_request_lines              mtl,
       apps.mtl_system_items_b_kfv        c,
       apps.mtl_item_categories_v         mic,
       apps.gl_code_combinations          cc,
       inv.mtl_parameters                 mp,
       apps.org_organization_definitions  ood,
       apps.hr_operating_units            hou,
       inv.org_acct_periods               prd,
       applsys.fnd_user                   fnu,
       eam_cfr_work_order_v               wod
 WHERE     a.organization_id = mp.organization_id
       AND mp.organization_id = ood.organization_id
       AND ood.operating_unit = hou.organization_id
       AND a.inventory_item_id = c.inventory_item_id
       AND a.organization_id = c.organization_id
       AND a.inventory_item_id = mic.inventory_item_id
       AND a.organization_id = mic.organization_id
       AND a.transaction_type_id IN (35,43)
       AND a.transaction_source_id = mtl.txn_source_id
       AND b.header_id = mtl.header_id
       AND b.created_by = fnu.user_id
       --and a.distribution_account_id = cc.code_combination_id(+)
       AND wod.material_account = cc.code_combination_id(+)
       AND a.acct_period_id = prd.acct_period_id
       AND a.transaction_quantity < 0
       AND a.organization_id = prd.organization_id
       AND mtl.txn_source_id = wod.wip_entity_id
       AND a.organization_id = wod.organization_id
       AND a.move_order_line_id = mtl.line_id
       AND a.transaction_source_id = wod.wip_entity_id
       AND mic.category_set_name = 'Inventory'