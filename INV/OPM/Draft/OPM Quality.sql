---------------------------------------------OPM Quality Details
  SELECT gsb.spec_id,
         gsb.spec_name,
         gsb.spec_vers       version,
         gs.meaning          spec_status,
         lkp1.meaning        spec_type,
         msi.segment1        item,
         msi.description     item_desc,
         fu.user_name        owner,
         gstb.seq,
         gqtb.test_code,
         gtmb.test_method_code,
         gstb.test_qty,
         gstb.test_qty_uom,
         gstb.test_replicate
    FROM gmd_specifications_b gsb,
         gmd_specifications_tl gst,
         fnd_user             fu,
         gmd_status_tl        gs,
         gem_lookups          lkp1,
         mtl_system_items_b   msi,
         gmd_spec_tests_b     gstb,
         gmd_qc_tests_b       gqtb,
         gmd_test_methods_b   gtmb
   WHERE     1 = 1
         --AND gsb.spec_id = 523
         AND gsb.spec_id = gst.spec_id
         AND gst.language = USERENV ('lang')
         AND gsb.owner_id = fu.user_id
         AND gsb.spec_status = gs.status_code
         AND gs.language = USERENV ('lang')
         AND gsb.spec_type = lkp1.lookup_code
         AND lkp1.lookup_type = 'GMD_QC_SPEC_TYPE'
         AND gsb.inventory_item_id = msi.inventory_item_id
         AND gsb.owner_organization_id = msi.organization_id
         AND gsb.spec_id = gstb.spec_id
         AND gstb.test_id = gqtb.test_id
         AND gqtb.test_method_id = gtmb.test_method_id
         AND gsb.spec_name='RMTTRS00000000000309'
ORDER BY gstb.seq;



--OPM Quality BASIC Queries

SELECT test_class Class, test_class_desc Description FROM GMD_TEST_CLASSES;

SELECT * FROM gmd_test_classes;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ------------------------CLASSSES AVAILABLE

---------TEST METHODS
SELECT * FROM GMD_TEST_METHODS;                          
;

------------------------------------Test_Methods
SELECT TEST_METHOD_CODE      METHOD,
       TEST_METHOD_DESC      DESCRIPTION,
       TEST_QTY              QTY,
       TEST_QTY_UOM          UOM,
       DISPLAY_PRECISION     Stored_Precision,
       Days,
       hours,
       Minutes,
       seconds,
       TEST_REPLICATE        Replicate
  FROM GMD_TEST_METHODS       
;


---------------------------------Test_Units
SELECT * FROM GMD_UNITS            
;

-----------------Test Units
SELECT QCUNIT_CODE Units, QCUNIT_DESC Description FROM gmd_units 
;

--------------------action codes
SELECT * FROM MTL_ACTIONS  
;

-----action codes
SELECT ACTION_CODE Action, DESCRIPTION FROM mtl_actions      
;

----------------------------------Process Quality Parameters
SELECT ORGANIZATION_ID          Organization,
       SAMPLE_LAST_ASSIGNED     Sample_Last_Assigned,
       SS_LAST_ASSIGNED         SS_Last_Assigned
  FROM gmd_quality_config 
;

--------------------------------Process Quality Parameters
SELECT * FROM gmd_quality_config 
;


----------------------------------------------------sampling Plan
SELECT SAMPLING_PLAN_NAME                              Plan_Name,
       SAMPLING_PLAN_DESC                              Description,
       SAMPLE_CNT_REQ                                  COUNT,
       SAMPLE_QTY                                      Quantity,
       SAMPLE_QTY_UOM                                  UOM,
       DECODE (Frequency_type, 'F', 'Fixed Number')    Frequency,
       FREQUENCY_CNT                                   Per,
       DECODE (FREQUENCY_PER,
               'FS', 'Batch step',
               'FR', 'Receipt',
               'FB', 'Batch')                          Sample_UOM,
       RESERVE_CNT_REQ                                 Res_Count,
       RESERVE_QTY                                     Res_Qty,
       ARCHIVE_CNT_REQ                                 Arch_Count,
       ARCHIVE_QTY                                     Arch_Qty
  FROM gmd_sampling_plans 
;

------------sampling Plan
SELECT * FROM gmd_sampling_plans                     
;

--------------------TEST DATA
SELECT *
  FROM GMD_QC_TESTS
 WHERE 1=1
 --AND test_code = '% BTM'                       
;

------------------------------------------------Test Data
SELECT TE.TEST_CODE
           Test,
       TE.TEST_DESC
           Description,
       TE.TEST_CLASS
           Class,
       ME.TEST_METHOD_CODE
           Method,
       ME.TEST_METHOD_DESC
           Method_DESCRIPTION,
       DECODE (TE.TEST_TYPE,
               'L', 'Numeric range With Display Text',
               'E', 'Expression',
               'N', 'Numeric Range',
               'T', 'Text Range',
               'U', 'Non-Validated',
               'V', 'List of Test Values')
           Data_Type,
       TE.TEST_UNIT
           Unit,
       DECODE (TE.PRIORITY,  '1L', 'Low',  '5N', 'Normal',  '8H', 'high')
           Priority,
       TE.MIN_VALUE_NUM
           Range_from,
       TE.MAX_VALUE_NUM
           Range_To,
       TE.DISPLAY_PRECISION
           Stored_Precision,
       TE.REPORT_PRECISION
           Report_Precision,
       TE.EXPRESSION,
       tv.MIN_NUM
           Min_Value,
       tv.max_num
           Max_Value,
       tv.DISPLAY_LABEL_NUMERIC_RANGE
           Display
  FROM GMD_QC_TESTS TE, GMD_TEST_METHODS ME, gmd_qc_test_values tv
 WHERE te.test_method_id = me.test_method_id AND te.test_id = tv.test_id 
;

---------------------------Values in Test Data Samples
SELECT * FROM gmd_qc_test_values 
;

----------------Process Quality Specifiction
SELECT *
  FROM gmd_specifications
 WHERE 1=1
 --AND spec_name = '726 Sell / 200 Kg' 
;

---------------------------------------------Product Quality specifications
SELECT gmsp.Spec_name
           Spec,
       gmsp.SPEC_DESC
           Description,
       gmsp.SPEC_VERS
           Version,
       gms.description
           Status,
       DECODE (gmsp.SPEC_TYPE,  'I', 'Item',  'M', 'Monitoring')
           Spec_Type,
       gmsp.OVERLAY_IND
           Overlay,
       gmsp.base_spec_id
           Base_Spec,
       gmsp.INVENTORY_ITEM_ID
           Item_ID,
       kfiv.CONCATENATED_SEGMENTS
           Item_code,
       kfiv.description
           Item_desc,
       gmsp.GRADE_CODE
           Grade,
       gmsp.OWNER_ORGANIZATION_ID
           Owner_Organization,
       fnu.user_name,
       gst.seq
           Target_Seq,
       (SELECT gct.TEST_CLASS
          FROM GMD_QC_TESTS gct
         WHERE gct.test_id = gst.test_id)
           Target_Class,
       (SELECT TEST_METHOD_CODE
          FROM GMD_TEST_METHODS gtm
         WHERE gtm.TEST_METHOD_ID = gst.TEST_METHOD_ID)
           Target_Test_Method,
       (SELECT TEST_METHOD_DESC
          FROM GMD_TEST_METHODS gtm
         WHERE gtm.TEST_METHOD_ID = gst.TEST_METHOD_ID)
           Target_Test_Method_Desc,
       gst.MIN_VALUE_NUM
           Target_Minimum,
       gst.MAX_VALUE_NUM
           Target_Maximum,
       gst.TEST_QTY
           Target_Quantity,
       gst.TEST_QTY_UOM
           Target_UOM,
       gst.TEST_REPLICATE
           Target_Replicate,
       DECODE (gst.TEST_PRIORITY,
               '1L', 'Low',
               '5N', 'Normal',
               '8H', 'High')
           Target_Priority,
       gst.OPTIONAL_IND
           Target_optional,
       gst.DISPLAY_PRECISION
           Formating_Stored_Precision,
       gst.REPORT_PRECISION
           Report_Stored_Precision
  FROM gmd_specifications    gmsp,
       gmd_status            gms,
       mtl_system_items_kfv  kfiv,
       gmd_spec_tests        gst,
       fnd_user              fnu
 WHERE     gmsp.spec_status = gms.status_code
       AND gmsp.spec_id = gst.spec_id
       --and gst.test_id=gct.test_id
       AND gmsp.INVENTORY_ITEM_ID = kfiv.INVENTORY_ITEM_ID
       AND gmsp.OWNER_ORGANIZATION_ID = kfiv.ORGANIZATION_ID
       AND fnu.user_id = gmsp.owner_id 
;

---------------------------------------------Product Quality specifications With Validity Rules
SELECT gmsp.Spec_name
           Spec,
       gmsp.SPEC_DESC
           DESCRIPTION,
       gmsp.SPEC_VERS
           VERSION,
       gms.description
           Status,
       DECODE (gmsp.SPEC_TYPE,  'I', 'Item',  'M', 'Monitoring')
           Spec_Type,
       gmsp.OVERLAY_IND
           Overlay,
       gmsp.base_spec_id
           Base_Spec,
       gmsp.INVENTORY_ITEM_ID
           Item_ID,
       kfiv.CONCATENATED_SEGMENTS
           Item_code,
       kfiv.description
           Item_desc,
       gmsp.GRADE_CODE
           Grade,
       gmsp.OWNER_ORGANIZATION_ID
           Owner_Organization,
       fnu.user_name,
       gst.seq
           Target_Seq,
       (SELECT gct.TEST_CLASS
          FROM GMD_QC_TESTS gct
         WHERE gct.test_id = gst.test_id)
           Target_Class,
       (SELECT TEST_METHOD_CODE
          FROM GMD_TEST_METHODS gtm
         WHERE gtm.TEST_METHOD_ID = gst.TEST_METHOD_ID)
           Target_Test_Method,
       (SELECT TEST_METHOD_DESC
          FROM GMD_TEST_METHODS gtm
         WHERE gtm.TEST_METHOD_ID = gst.TEST_METHOD_ID)
           Target_Test_Method_Desc,
       gst.MIN_VALUE_NUM
           Target_Minimum,
       gst.MAX_VALUE_NUM
           Target_Maximum,
       gst.TEST_QTY
           Target_Quantity,
       gst.TEST_QTY_UOM
           Target_UOM,
       gst.TEST_REPLICATE
           Target_Replicate,
       DECODE (gst.TEST_PRIORITY,
               '1L', 'Low',
               '5N', 'Normal',
               '8H', 'High')
           Target_Priority,
       gst.OPTIONAL_IND
           Target_optional,
       gst.DISPLAY_PRECISION
           Formating_Stored_Precision,
       gst.REPORT_PRECISION
           Report_Stored_Precision,
       ver.ORGANIZATION_CODE
           VALIDITY_ORG_CODE,
       DECODE (ver.SPEC_TYPE,
               'I', 'Inventory',
               'W', 'WIP',
               'C', 'Customer',
               'S', 'Supplier')
           VALIDITY_Spec_Type,
       DECODE (ver.DELETE_MARK,  '0', 'No',  '1', 'Yes')
           Validity_Deleted,
       ver.SPEC_VR_STATUS_DESC
           Validity_Spec_rule,
       ver.start_date
           Validity_start_date,
       ver.end_date
           Validity_end_date,
       ver.PARENT_LOT_NUMBER
           Validity_Parent_Lot,
       ver.LOT_NUMBER
           Validity_Lot_Number,
       ver.SUBINVENTORY
           Validity_SubInventory,
       ver.IN_SPEC_LOT_STATUS_CODE
           Validity_LOT_Status,
       ver.OUT_OF_SPEC_LOT_STATUS_CODE
           Validity_out_of_spec_Lot
  FROM gmd_specifications    gmsp,
       gmd_status            gms,
       mtl_system_items_kfv  kfiv,
       gmd_spec_tests        gst,
       GMD_ALL_SPEC_VRS_VL   ver,
       fnd_user              fnu
 WHERE     gmsp.spec_status = gms.status_code
       AND gmsp.spec_id = gst.spec_id
       AND ver.spec_id = gmsp.spec_id
       AND ver.spec_id = gst.spec_id
       AND gmsp.INVENTORY_ITEM_ID = kfiv.INVENTORY_ITEM_ID
       AND gmsp.OWNER_ORGANIZATION_ID = kfiv.ORGANIZATION_ID
       AND fnu.user_id = gmsp.owner_id;
       
       
---------------------------------------------Sample Details
SELECT gs.sample_no,
       sample_desc,
       gs.organization_id,
       msi.segment1     item_number,
       msi.description,
       gs.sampling_event_id,
       gs.step_no,
       gs.step_id,
       gs.sample_id,
       gs.sample_no,
       gs.sample_desc,
       gs.TYPE,
       gs.qc_lab_orgn_code,
       gs.item_id,
       gs.location,
       gs.expiration_date,
       gs.lot_id,
       gs.lot_no,
       gs.batch_id,
       gs.recipe_id,
       gs.formula_id,
       gs.formulaline_id,
       gs.routing_id,
       gs.oprn_id,
       gs.charge,
       gs.cust_id,
       gs.order_id,
       gs.order_line_id,
       gs.org_id,
       gs.supplier_id,
       gs.sample_qty,
       gs.sample_uom,
       gs.source,
       gl1.meaning      "SOURCE",
       gs.sampler_id,
       gs.date_drawn,
       gs.source_comment,
       gs.storage_whse,
       gs.storage_location,
       gs.external_id,
       gs.sample_approver_id,
       gs.inv_approver_id,
       gl2.meaning      "PRIORITY",
       gs.sample_inv_trans_ind,
       gs.delete_mark,
       gs.text_code,
       gs.attribute_category,
       gs.creation_date,
       gs.created_by,
       gs.last_updated_by,
       gs.last_update_date,
       gs.last_update_login,
       gs.supplier_site_id,
       gs.whse_code,
       gs.orgn_code,
       gs.po_header_id,
       gs.po_line_id,
       gs.receipt_id,
       gs.receipt_line_id,
       gs.sample_disposition,
       --gl3.meaning      "SAMPLE_DISPOSITION",
       gs.ship_to_site_id,
       gs.supplier_lot_no,
       gs.lot_retest_ind,
       gs.sample_instance,
       gs.sublot_no,
       gs.source_whse,
       gs.source_location,
       gs.date_received,
       gs.date_required,
       gs.instance_id,
       gs.resources,
       gs.retrieval_date,
       gl4.meaning      "SAMPLE_TYPE",
       gs.time_point_id,
       gs.variant_id,
       gs.remaining_qty,
       gs.retain_as,
       gs.inventory_item_id,
       gs.lab_organization_id,
       gs.locator_id,
       gs.lot_number,
       gs.organization_id,
       gs.parent_lot_number,
       gs.revision,
       gs.sample_qty_uom,
       gs.source_locator_id,
       gs.source_subinventory,
       gs.storage_locator_id,
       gs.storage_organization_id,
       gs.storage_subinventory,
       gs.subinventory,
       gs.migrated_ind,
       gs.material_detail_id,
       gspec.spec_name,
       gspec.spec_vers,
       gspec.spec_desc
  FROM gmd_samples          gs,
       mtl_system_items_b   msi,
       gem_lookups          gl1,
       gem_lookups          gl2,
       --gem_lookups          gl3,
       gem_lookups          gl4,
       gmd_event_spec_disp  gesd,
       gmd_specifications   gspec
 WHERE      1=1
       --AND gs.sample_id = 4969--Sample ID
       AND gs.inventory_item_id = msi.inventory_item_id
       AND gs.organization_id = msi.organization_id
       AND gl1.lookup_type = 'GMD_QC_SOURCE'
       AND gl1.lookup_code = gs.source
       AND gl2.lookup_type = 'GMD_QC_TEST_PRIORITY'
       AND gl2.lookup_code = gs.priority
       --AND gl3.lookup_type = 'GMD_QC_SAMPLE_DISP'
       --AND gl3.lookup_code = gs.sample_disposition
       AND gl4.lookup_type = 'GMD_QC_SPEC_TYPE'
       AND gl4.lookup_code = gs.sample_type
       AND gs.sampling_event_id = gesd.sampling_event_id
       AND gesd.spec_id = gspec.spec_id
       --AND gs.sample_disposition IS NOT NULL;