/* Formatted on 11/21/2020 6:07:44 PM (QP5 v5.287) */
SELECT qt.test_code,
       qt.test_desc,
       qt.test_class,
       qt.test_unit,
       qt.min_value_num,
       qt.max_value_num,
       res.result_value_num,
       sam.sample_no,
       sam.sample_desc,
       a.segment1 AS "Item Code",
       sam.subinventory,
       sam.lot_number
  FROM gmd_qc_tests qt,
       gmd_samples sam,
       gmd_results res,
       apps.mtl_system_items_b_kfv a
 WHERE     sam.sample_id = res.sample_id
       AND qt.test_id = res.test_id
       AND sam.lab_organization_id = 150
       AND sam.inventory_item_id = a.inventory_item_id
       AND sam.organization_id = a.organization_id