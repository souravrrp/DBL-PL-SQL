CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_ECC_ITEM_ALLOC
AS-- $Header: INVEONHB.pls 120.0.12020000.4 2019/05/08 10:26:50 ppulloor noship $

/*
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


PROCEDURE debug_print(p_message IN VARCHAR2, p_level IN NUMBER := 9) IS
BEGIN
inv_log_util.TRACE(p_message, 'XXDBL_ECC_ITEM_ALLOC', p_level);
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

l_inv_ebs_sql_full_text VARCHAR2(30000) := 'SELECT ALLOC_CODE, CONCATENATED_SEGMENTS
  FROM GL_ALOC_BAS A, APPS.MTL_SYSTEM_ITEMS_KFV B, GL_ALOC_MST C
 WHERE     A.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
       AND A.ORGANIZATION_ID = B.ORGANIZATION_ID
       AND A.ALLOC_ID = C.ALLOC_ID
       AND A.DELETE_MARK = 0 for LANGUAGE in ('||v_for_lang_pivot_clause||'))';

query_det_arr ecc_query_det_arr_type := ecc_query_det_arr_type(null);

BEGIN

IF (p_dataset_key='xxdbl-itemalloc') THEN
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
FUNCTION f_alloc_code (
p_alloc_code VARCHAR2,
p_concatenated_segments VARCHAR2
)
RETURN VARCHAR2
IS
l_alloc_code VARCHAR2;
l_concatenated_segments VARCHAR2 := p_concatenated_segments;
l_result_code VARCHAR2(30);



BEGIN

l_result_code := GMF_CMCOMMON.Get_Process_Item_Cost
( x_return_status => l_alloc_code
, x_concatenated_segments => l_concatenated_segments
);

RETURN ( l_alloc_code );
END f_alloc_code;



END XXDBL_ECC_ITEM;
/