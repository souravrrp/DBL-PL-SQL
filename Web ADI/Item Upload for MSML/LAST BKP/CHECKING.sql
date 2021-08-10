/* Formatted on 6/29/2020 12:00:40 PM (QP5 v5.287) */
           SELECT organization_code,
           org.organization_id
             FROM ORG_ORGANIZATION_DEFINITIONS org,
                  per_org_structure_elements_v pose,
                  per_organization_structures_v os
            WHERE     1 = 1
                  AND org.organization_id = pose.organization_id_child
                  AND OS.organization_structure_id = POSE.ORG_STRUCTURE_VERSION_ID
                  AND OS.NAME IN ('RMG-PROCESS')
       START WITH pose.organization_id_parent = 138
       CONNECT BY PRIOR pose.organization_id_child = pose.organization_id_parent
ORDER SIBLINGS BY pose.organization_id_child;


           SELECT organization_code,
                  org.organization_id
             FROM ORG_ORGANIZATION_DEFINITIONS org,
                  per_org_structure_elements_v pose,
                  per_organization_structures_v os
            WHERE     1 = 1
                  AND org.organization_id = pose.organization_id_child
                  AND OS.organization_structure_id = POSE.ORG_STRUCTURE_VERSION_ID
                  AND OS.NAME IN ('HTL-KNITTING')
       START WITH pose.organization_id_parent = 138
       CONNECT BY PRIOR pose.organization_id_child = pose.organization_id_parent
ORDER SIBLINGS BY pose.organization_id_child;


           SELECT organization_code,org.organization_id
             FROM ORG_ORGANIZATION_DEFINITIONS org,
                  per_org_structure_elements_v pose,
                  per_organization_structures_v os
            WHERE     1 = 1
                  AND org.organization_id = pose.organization_id_child
                  AND OS.organization_structure_id = POSE.ORG_STRUCTURE_VERSION_ID
                  AND OS.NAME IN ('SPINING-PROCESS')
       START WITH pose.organization_id_parent = 138
       CONNECT BY PRIOR pose.organization_id_child = pose.organization_id_parent
ORDER SIBLINGS BY pose.organization_id_child;


SELECT * FROM MTL_ITEM_REVISIONS_INTERFACE;

  SELECT                                                  --INVENTORY_ITEM_ID,
        SEGMENT1,
         SEGMENT2,
         SEGMENT3,
         SEGMENT4,
         SEGMENT5,
         SEGMENT6,
         SEGMENT7,
         SEGMENT8,
         'IMO' ORGANIZATION_NAME,
         DESCRIPTION,
         INVENTORY_ITEM_STATUS_CODE,
         'DBL Spares and Civil Item' TEMPLATE_NAME,
         PRIMARY_UOM_CODE,
         TRACKING_QUANTITY_IND,
         ONT_PRICING_QTY_SOURCE,
         SECONDARY_UOM_CODE,
         SECONDARY_DEFAULT_IND,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         PURCHASING_ITEM_FLAG,
         SHIPPABLE_ITEM_FLAG,
         CUSTOMER_ORDER_FLAG,
         INTERNAL_ORDER_FLAG,
         SERVICE_ITEM_FLAG,
         INVENTORY_ITEM_FLAG,
         INVENTORY_ASSET_FLAG,
         PURCHASING_ENABLED_FLAG,
         CUSTOMER_ORDER_ENABLED_FLAG,
         INTERNAL_ORDER_ENABLED_FLAG,
         SO_TRANSACTIONS_FLAG,
         'Y' MTL_TRANSACTIONS_ENAB_FLAG,
         STOCK_ENABLED_FLAG,
         BOM_ENABLED_FLAG,
         BUILD_IN_WIP_FLAG,
         RETURNABLE_FLAG,
         TAXABLE_FLAG,
         ALLOW_ITEM_DESC_UPDATE_FLAG,
         INSPECTION_REQUIRED_FLAG,
         RECEIPT_REQUIRED_FLAG
    --,MSI.*
    FROM APPS.MTL_SYSTEM_ITEMS_B MSI
   WHERE 1=1
   AND ORGANIZATION_ID = 138 
   --AND ORGANIZATION_ID = 138 
   AND SEGMENT1 = 'YRNAC22S2|00731F8999'
ORDER BY CREATION_DATE DESC;

SELECT *
  FROM APPS.MTL_SYSTEM_ITEMS_KFV MSI;

SELECT ood.organization_id
  INTO l_organization_id
  FROM org_organization_definitions ood
 WHERE ood.organization_code = :p_organization_name;


  SELECT segment1,
         segment2,
         segment3,
         segment4,
         segment5,
         segment6,
         segment7,
         segment8,
         organization_id,
         description,
         inventory_item_status_code,
         template_id,
         primary_uom_code,
         tracking_quantity_ind,
         ont_pricing_qty_source,
         secondary_uom_code,
         secondary_default_ind,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         purchasing_item_flag,
         shippable_item_flag,
         customer_order_flag,
         internal_order_flag,
         service_item_flag,
         inventory_item_flag,
         inventory_asset_flag,
         purchasing_enabled_flag,
         customer_order_enabled_flag,
         internal_order_enabled_flag,
         so_transactions_flag,
         mtl_transactions_enabled_flag,
         stock_enabled_flag,
         bom_enabled_flag,
         build_in_wip_flag,
         returnable_flag,
         taxable_flag,
         allow_item_desc_update_flag,
         inspection_required_flag,
         receipt_required_flag,
         last_update_date,
         last_updated_by,
         last_update_login,
         created_by,
         creation_date,
         process_flag,
         transaction_type,
         set_process_id,
         summary_flag,
         enabled_flag
    FROM MTL_SYSTEM_ITEMS_INTERFACE
   WHERE 1 = 1 AND segment1 = 'YRN24S100CTN534E4099'
ORDER BY CREATION_DATE DESC;

UPDATE MTL_SYSTEM_ITEMS_INTERFACE
   SET inspection_required_flag = 'N'
 WHERE 1 = 1 AND segment1 = 'YRN24S100CTN534E4099';

SELECT * FROM apps.XXDBL_ITEM_UPLOAD_WEBADI;

DELETE apps.XXDBL_ITEM_UPLOAD_WEBADI
 WHERE SEGMENT1 = 'SPRECONS000000066954';

    EXECUTE apps.xxdbl_item_assign_webadi_pkg.assign_item_org_and_category

    EXECUTE APPS.XXDBL_ITEM_UPLOAD_WEBADI_PKG.cust_upload_data_to_staging('YRN24S100CTN534E4099','24S1-COTTON-(50%+50%)-BLACK RECYCLE-R36','KG','BAG');