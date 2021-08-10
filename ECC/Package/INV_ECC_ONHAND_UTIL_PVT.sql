/* Formatted on 3/10/2020 4:38:54 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.INV_ECC_ONHAND_UTIL_PVT
AS-- $Header: INVEONHB.pls 120.0.12020000.4 2019/05/08 10:26:50 ppulloor noship $


/ +======================================================================+ /
/ | Copyright (c) 2016, 2019 Oracle and/or its affiliates. | /
/ | All rights reserved. | /
/ | Version 1.0.0 | /
/ +======================================================================+ /
/ /
/ +======================================================================+ /
/ FILENAME: INVEONHB.pls /
/ DESCRIPTION: /
/ Package body for EBS Data Load in ECC Aging /
/ /
/ Version History /
/ /
/ 1.0 ppulloor Created /
/ /
/ +======================================================================+ /

/*
** DEBUG_PRINT - Logging Debug messages
***/
g_org_id NUMBER := NULL;

PROCEDURE debug_print(p_message IN VARCHAR2, p_level IN NUMBER := 9) IS
BEGIN
inv_log_util.TRACE(p_message, 'INV_ECC_ONHAND_UTIL_PVT', p_level);
END debug_print;

/*

** GET_ECC_DATA_LOAD_INFO - Retrieves the data load details for the given data set key
**
** IN parameters
** p_dataset_id - dataset key
** p_load_type - Indicating Full or incremental load (F/I/Custom).For custom there are no data load rules defined
** p_ds_last_success_run - Returns the last successful etl run for the dataset key
** OUT parameters
** x_ecc_ds_meta_rec - ecc_ds_meta_rec
** x_return_status - return status
*/


PROCEDURE GET_ECC_DATA_LOAD_INFO(
p_dataset_key IN VARCHAR2,
p_load_type IN VARCHAR2,
p_ds_last_success_run IN TIMESTAMP,
p_languages IN VARCHAR2,
P_ADDL_PARAMS IN ECC_SEC_FIELD_VALUES DEFAULT NULL,
x_ecc_ds_meta_rec OUT NOCOPY ecc_ds_meta_rec,
x_return_status OUT NOCOPY VARCHAR2)
IS
l_exists VARCHAR2(1);
v_for_lang_pivot_clause varchar2(400) := FND_ECC_UTIL_MLS_PVT.GEN_ECC_MLS_PIVOT_FOR_LANG_CL(p_languages); --MLS

l_inv_ebs_sql_full_text VARCHAR2(30000) := 'SELECT * FROM INV_ECC_ONHAND_V
PIVOT (max(ITEM_DESC) as ITEM_DESC, max(OWNING_PARTY) as OWNING_PARTY for LANGUAGE in ('||v_for_lang_pivot_clause||'))';

query_det_arr ecc_query_det_arr_type := ecc_query_det_arr_type(null);

BEGIN

IF (p_dataset_key='inv-onhand') THEN
IF (p_load_type in ('FULL_LOAD')) THEN
/*
** Insert the records into ECC Database if p_load_type is "FULL_LOAD" AND "INCREMENTAL_LOAD"
***/

query_det_arr := ecc_query_det_arr_type( ecc_query_det_rec(l_inv_ebs_sql_full_text,G_INV_ECC_INS_OP));
x_ecc_ds_meta_rec := ecc_ds_meta_rec(p_dataset_key,query_det_arr);
x_return_status :='S';

debug_print('x_return_status:'||x_return_status);

END IF;
END IF;

END GET_ECC_DATA_LOAD_INFO;

--GET ITEM UNIT COST
FUNCTION f_unit_cost (
p_org_id NUMBER,
p_item_id NUMBER,
p_locator_id NUMBER,
p_cost_group_id NUMBER,
p_date DATE,
p_process_enabled_flag VARCHAR2,
p_primary_cost_method NUMBER,
p_default_cost_group_id NUMBER,
p_project_id NUMBER
)
RETURN NUMBER
IS
l_item_cost NUMBER;
l_locator_id NUMBER := p_locator_id;
l_cost_group_id NUMBER := p_cost_group_id;
l_project_id NUMBER := p_project_id;
l_debug NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
l_process_enabled_flag VARCHAR2(1) := p_process_enabled_flag;
l_result_code VARCHAR2(30);
l_return_status VARCHAR2(30);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_inventory_item_id NUMBER := p_item_id;
l_organization_id NUMBER := p_org_id;
l_transaction_date DATE := NVL(p_date, SYSDATE);
l_cost_mthd VARCHAR2(15);
l_cmpntcls NUMBER;
l_analysis_code VARCHAR2(15);
l_no_of_rows NUMBER;


BEGIN
IF ( l_debug = 1 ) THEN
inv_trx_util_pub.trace ( '***get_item_cost***' ,'f_unit_cost',1);
END IF;


IF l_process_enabled_flag = 'Y' THEN
BEGIN
IF(l_debug = 1) THEN
inv_trx_util_pub.trace ( 'Calling GMF_CMCOMMON.Get_Process_Item_Cost' ,'f_unit_cost',1);

END IF;
l_result_code := GMF_CMCOMMON.Get_Process_Item_Cost
( p_api_version => 1
, p_init_msg_list => 'F'
, x_return_status => l_return_status
, x_msg_count => l_msg_count
, x_msg_data => l_msg_data
, p_inventory_item_id => l_inventory_item_id
, p_organization_id => l_organization_id
, p_transaction_date => l_transaction_date / Cost as on date /
, p_detail_flag => 1 / 1 = total cost, 2 = details; 3 = cost for a specific component class/analysis code, etc. /
, p_cost_method => l_cost_mthd / OPM Cost Method /
, p_cost_component_class_id => l_cmpntcls
, p_cost_analysis_code => l_analysis_code
, x_total_cost => l_item_cost / total cost /
, x_no_of_rows => l_no_of_rows / number of detail rows retrieved /
);

IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
l_item_cost := 0;
END IF;

EXCEPTION
WHEN OTHERS THEN
l_item_cost := 0;
END;
IF(l_debug = 1) THEN
inv_trx_util_pub.trace ( 'OPM Item Cost: ' || l_item_cost ,'f_unit_cost',1);
END IF;
ELSE

BEGIN
SELECT NVL ( ccicv.item_cost, 0 )
INTO l_item_cost
FROM cst_cg_item_costs_view ccicv
WHERE l_locator_id IS NULL
AND ccicv.organization_id = p_org_id
AND ccicv.inventory_item_id = p_item_id
AND ccicv.cost_group_id =
DECODE ( p_primary_cost_method,
1, 1,
NVL ( l_cost_group_id, p_default_cost_group_id)
)
UNION ALL
SELECT NVL ( ccicv.item_cost, 0 )
FROM cst_cg_item_costs_view ccicv
WHERE l_locator_id IS NOT NULL
AND l_project_id IS NULL
AND ccicv.organization_id = p_org_id
AND ccicv.inventory_item_id = p_item_id
AND ccicv.cost_group_id =
DECODE ( p_primary_cost_method,
1, 1,
NVL ( l_cost_group_id, p_default_cost_group_id)
)
UNION ALL
SELECT NVL ( ccicv.item_cost, 0 )
FROM mrp_project_parameters mrp,
cst_cg_item_costs_view ccicv
WHERE l_locator_id IS NOT NULL
AND l_project_id IS NOT NULL
AND mrp.organization_id = p_org_id
AND mrp.project_id = l_project_id
AND ccicv.organization_id = p_org_id
AND ccicv.inventory_item_id = p_item_id
AND ccicv.cost_group_id =
DECODE ( p_primary_cost_method,
1, 1,
NVL ( mrp.costing_group_id, 1 )
);
EXCEPTION
WHEN NO_DATA_FOUND THEN
l_item_cost := 0;
END;
END IF;

RETURN ( l_item_cost );
END f_unit_cost;

FUNCTION get_owning_party (p_organization_id IN NUMBER,
p_owning_organization_id IN NUMBER,
p_language IN VARCHAR2,
p_is_consigned IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS

v_owning_pary VARCHAR2(200);
l_debug NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

BEGIN

IF(l_debug = 1) THEN
inv_trx_util_pub.trace ( 'p_is_consigned: ' || p_is_consigned ,'get_owning_party',1);
END IF;

begin
IF (p_is_consigned = 2) then
SELECT substr(hout.NAME,1,60) Party into v_owning_pary
FROM hr_all_organization_units_tl hout
WHERE hout.organization_id = p_organization_id
AND hout.language = p_language;

ELSIF (p_is_consigned =1) THEN
SELECT vendor_name || '-' || pvsa.vendor_site_code into v_owning_pary
FROM po_vendors pv,
po_vendor_sites_all pvsa
WHERE pvsa.vendor_id = pv.vendor_id
AND pvsa.vendor_site_id = p_owning_organization_id;

ELSE
v_owning_pary :=null;
end if;

EXCEPTION WHEN OTHERS THEN
v_owning_pary :=NULL;
END;
return v_owning_pary;

end get_owning_party;


END INV_ECC_ONHAND_UTIL_PVT;
/