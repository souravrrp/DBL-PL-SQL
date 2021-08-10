spool diag.lst
SET line 400
SET pages 9999
undef org_id
undef item_id
define org_id = &org_id
define item_id = &item_id
/*
Get Item Information */
PROMPT Item Information
PROMPT =========
PROMPT
select organization_id,
	   padded_concatenated_segments,
       enabled_flag,
       Start_DATE_ACTIVE,
       END_DATE_ACTIVE,
       INVENTORY_ITEM_FLAG,
       INVENTORY_ASSET_FLAG,
       costing_enabled_flag
  from mtl_system_items_b_kfv
 where inventory_item_id = &item_id
/
/* 
Get org parameters */
PROMPT Organization Parameters (mtl_parameters)
PROMPT ==========================================
PROMPT 
SELECT organization_id org, primary_cost_method pcm,
       cost_organization_id cost_org, default_cost_group_id dcg,
       organization_code org_code, project_reference_enabled pre,
       wms_enabled_flag wms, NEGATIVE_INV_RECEIPT_CODE neg_inv,
       avg_rates_cost_type_id act
  FROM mtl_parameters
 WHERE organization_id = &org_id
/

/*
Get currency info for org */
PROMPT Organization Currency Parameters (fnd_currencies/cst_organization_definitions)
PROMPT ===============================================================================
PROMPT 
SELECT fc.currency_code, fc.precision,
       fc.extended_precision ext_prec,
       fc.minimum_accountable_unit mau
  FROM fnd_currencies fc,
       cst_organization_definitions cod
 WHERE cod.organization_id = &org_id
   AND fc.currency_code = cod.currency_code
/
/* 
 Inter-org parameters */
PROMPT Inter-Organization Parameters (mtl_interorg_parameters)
PROMPT =======================================================
PROMPT 
SELECT from_organization_id from_org, 
       to_organization_id to_org, 
       decode(intransit_type,1,'Direct',2,'Intransit','None') tr_type, 
       decode(fob_point,1,'Shipment',2,'Receipt','None') fob_pt,
       internal_order_required_flag iorf,  NVL(elemental_visibility_enabled,'N') ev,
       matl_interorg_transfer_code mitc,
       INTERORG_TRNSFR_CHARGE_PERCENT itcp
  FROM mtl_interorg_parameters  
 WHERE (from_organization_id = &org_id OR
        to_organization_id = &org_id)
/
/*
MMT data */
PROMPT (mtl_material_transactions/mtl_system_items/mtl_secondary_inventories)
PROMPT =======================================================================
PROMPT 
SELECT to_char(mmt.transaction_date,'DD-MM-YYYY HH24:MI:SS')  txn_dte,
       mmt.transaction_id txn,
       mmt.organization_id org,
       mmt.cost_group_id cg,   
       mmt.transaction_action_id action,  
       mmt.transaction_source_type_id src,
       mmt.transaction_type_id ttype, 
       mmt.inventory_item_id item,
       mmt.subinventory_code subinv, 
       mmt.primary_quantity p_qty, 
       mmt.distribution_account_id acct_id,
       msi.inventory_asset_flag iaf,
       mse.asset_inventory ai, 
       mmt.actual_cost ac, 
       mmt.prior_cost pc,
       mmt.new_cost nc,
       mmt.transaction_cost tc,
       mmt.prior_costed_quantity pcq,
       costed_flag cf,
       mmt.transfer_transaction_id ttxn,
       mmt.transfer_organization_id torg,
       mmt.transfer_subinventory tsub,
       mmt.transfer_cost_group_id tcg,
       substr(mmt.shipment_number,1,15) ship_num,
       mmt.transfer_cost tfrc,
       mmt.transportation_cost tpc,
       mmt.currency_code cc,
       mmt.currency_conversion_rate ccr,
       to_char(mmt.creation_date,'DD-MM-YYYY HH24:MI:SS')  cr_dte
 FROM  mtl_material_transactions mmt,
       mtl_system_items msi,
       mtl_secondary_inventories mse
WHERE  (mmt.organization_id = &org_id or mmt.transfer_organization_id = &org_id)
  AND  mmt.inventory_item_id = &item_id /* item id with reported problem */
  AND  msi.organization_id = mmt.organization_id 
  AND  msi.inventory_item_id = mmt.inventory_item_id    
  AND  mse.organization_id (+) = mmt.organization_id 
  AND  mse.secondary_inventory_name(+) = mmt.subinventory_code
ORDER BY mmt.transaction_date, mmt.transaction_id,mmt.creation_date
/
/*
CQL data */
PROMPT (cst_quantity_layers)
PROMPT =====================
PROMPT 
SELECT layer_id, organization_id org,
       layer_quantity lqty,  cost_group_id cg,
       material_cost mc, material_overhead_cost mohc,
       resource_cost rc, outside_processing_cost ospc,
       overhead_cost ohc,  item_cost ic,
       create_transaction_id cr_txn,
       update_transaction_id upd_txn
  FROM cst_quantity_layers
 WHERE inventory_item_id = &item_id
   AND organization_id = &org_id
/
/*
CLCD data */
PROMPT (cst_layer_cost_details)
PROMPT ========================
PROMPT 
SELECT clcd.layer_id lyr_id,
       clcd.cost_element_id ce,
       clcd.level_type lt,
       clcd.item_cost ic
  FROM cst_layer_cost_details clcd
 WHERE exists ( select cql.layer_id
                from   cst_quantity_layers cql
                where  cql.layer_id = clcd.layer_id
                and    cql.inventory_item_id = &item_id
                and    cql.organization_id = &org_id)
ORDER BY clcd.layer_id,
         clcd.cost_element_id,
         clcd.level_type
/
/*
MCTCD data */
PROMPT (mtl_cst_txn_cost_details)
PROMPT ==========================
PROMPT 
SELECT transaction_id txn,
       organization_id org,
       cost_element_id ce,
       level_type lt,
       transaction_cost tc,
       value_change vc,
       new_average_cost nac,
       percentage_change pc,      
       to_char(creation_date,'DD-MM-YYYY HH24:MI:SS')  cr_dte
  FROM mtl_cst_txn_cost_details
 WHERE transaction_id IN (SELECT transaction_id
                            FROM mtl_material_transactions
                           WHERE (organization_id = &org_id or transfer_organization_id = &org_id)
                             AND inventory_item_id = &item_id)
/
/*
MCACD data */
PROMPT (mtl_cst_actual_cost_details)
PROMPT =============================
PROMPT 
SELECT organization_id org_id,
       transaction_id txn,
       transaction_action_id action,
       cost_element_id ce,
       level_type lt,
       layer_id,
       actual_cost ac,
       prior_cost pc,
       new_cost nc,
       to_char(transaction_costed_date,'DD-MM-YYYY HH24:MI:SS') tc_dte,
       to_char(creation_date,'DD-MM-YYYY HH24:MI:SS')  cr_dte,
       insertion_flag if
  FROM mtl_cst_actual_cost_details
 WHERE transaction_id IN  (SELECT transaction_id
                            FROM mtl_material_transactions
                           WHERE (organization_id = &org_id or transfer_organization_id = &org_id)
                             AND inventory_item_id = &item_id)
							  order by transaction_costed_date
/
/*
MTA data */
PROMPT (mtl_transaction_accounts)
PROMPT ==========================
PROMPT 
SELECT mta.transaction_id txn_id, 
       mta.accounting_line_type alt,
       mta.cost_element_id ce, 
       mta.reference_account acct, 
       mta.base_transaction_value btv,
       mta.organization_id,
       to_char(creation_date,'DD-MM-YYYY HH24:MI:SS')  cr_dte
 FROM  mtl_transaction_accounts mta
WHERE  mta.transaction_id IN  (SELECT transaction_id
                                 FROM mtl_material_transactions
                                WHERE (organization_id = &org_id or transfer_organization_id = &org_id)
                                  AND inventory_item_id = &item_id)
/
/*
CIC Data */
PROMPT (cst_item_costs)
PROMPT ================
PROMPT 
SELECT organization_id org, inventory_item_id item_id,
       cost_type_id ct,
       material_cost mc, material_overhead_cost mohc,
       resource_cost rc, outside_processing_cost ospc,
       overhead_cost ohc,  item_cost ic,
       inventory_asset_flag iaf,
	   BASED_ON_ROLLUP_FLAG 
  FROM cst_item_costs
 WHERE inventory_item_id = &item_id
   AND organization_id = &org_id
/
/*
CICD Data */
PROMPT (cst_item_cost_details)
PROMPT =======================
PROMPT 
SELECT organization_id org, inventory_item_id item_id,
       clcd.cost_type_id ct,
       clcd.cost_element_id ce,
       clcd.level_type lt,
       clcd.item_cost ic
  FROM cst_item_cost_details clcd
 WHERE inventory_item_id = &item_id
   AND organization_id = &org_id 
/
/*
MOQ Data */
PROMPT (mtl_onhand_quantities)
PROMPT =======================
PROMPT 
SELECT organization_id org, inventory_item_id item_id,
       subinventory_code subinv,cost_group_id cg_id,
       sum(transaction_quantity) qty
  FROM mtl_onhand_quantities
 WHERE inventory_item_id = &item_id
   AND organization_id = &org_id 
 GROUP BY organization_id, inventory_item_id, subinventory_code,cost_group_id 
/
/*
MSE data */
PROMPT (mtl_secondary_inventories)
PROMPT ===========================
PROMPT 
SELECT organization_id org, secondary_inventory_name subinv,
       asset_inventory ai,default_cost_group_id dcg
  FROM mtl_secondary_inventories
 WHERE organization_id = &org_id
/
/*
MS Data */
PROMPT (mtl_supply)
PROMPT ============
PROMPT 
SELECT item_id, quantity qty, to_org_primary_quantity p_qty,
       intransit_owning_org_id org,
       supply_type_code supp,
       to_organization_id to_org,
       from_organization_id from_org
  FROM mtl_supply
 WHERE supply_type_code IN ('SHIPMENT','RECEIVING')
   AND intransit_owning_org_id IS NOT NULL
   AND item_id = &item_id
/
/*
purge data */
PROMPT (mtl_purge_header)
PROMPT ==================
PROMPT 
SELECT purge_id, purge_date, organization_id
  FROM mtl_purge_header
/
spool off
