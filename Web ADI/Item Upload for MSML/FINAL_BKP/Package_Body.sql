/* Formatted on 6/30/2020 11:33:44 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_ITEM_UPLOAD_WEBADI_PKG
IS
   PROCEDURE cust_import_data_to_interface
   IS
      CURSOR int_trans
      IS
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
                enabled_flag,
                item_catalog_group_id,
                dual_uom_control
           FROM XXDBL_ITEM_UPLOAD_WEBADI
          WHERE FLAG IS NULL;
   BEGIN
      FOR r_int_trans IN int_trans
      LOOP
         BEGIN
            INSERT
              INTO MTL_SYSTEM_ITEMS_INTERFACE (segment1,
                                               segment2,
                                               segment3,
                                               segment4,
                                               segment5,
                                               segment6,
                                               segment7,
                                               segment8,
                                               organization_id,
                                               description,
                                               long_description,
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
                                               enabled_flag,
                                               item_catalog_group_id,
                                               dual_uom_control)
            VALUES (r_int_trans.segment1,
                    r_int_trans.segment2,
                    r_int_trans.segment3,
                    r_int_trans.segment4,
                    r_int_trans.segment5,
                    r_int_trans.segment6,
                    r_int_trans.segment7,
                    r_int_trans.segment8,
                    r_int_trans.organization_id,
                    r_int_trans.description,
                    r_int_trans.description,
                    r_int_trans.inventory_item_status_code,
                    r_int_trans.template_id,
                    r_int_trans.primary_uom_code,
                    r_int_trans.tracking_quantity_ind,
                    r_int_trans.ont_pricing_qty_source,
                    r_int_trans.secondary_uom_code,
                    r_int_trans.secondary_default_ind,
                    r_int_trans.attribute_category,
                    r_int_trans.attribute1,
                    r_int_trans.attribute2,
                    r_int_trans.attribute3,
                    r_int_trans.attribute4,
                    r_int_trans.attribute5,
                    r_int_trans.attribute6,
                    r_int_trans.attribute7,
                    r_int_trans.attribute8,
                    r_int_trans.attribute9,
                    r_int_trans.attribute10,
                    r_int_trans.attribute11,
                    r_int_trans.attribute12,
                    r_int_trans.attribute13,
                    r_int_trans.attribute14,
                    r_int_trans.attribute15,
                    r_int_trans.purchasing_item_flag,
                    r_int_trans.shippable_item_flag,
                    r_int_trans.customer_order_flag,
                    r_int_trans.internal_order_flag,
                    r_int_trans.service_item_flag,
                    r_int_trans.inventory_item_flag,
                    r_int_trans.inventory_asset_flag,
                    r_int_trans.purchasing_enabled_flag,
                    r_int_trans.customer_order_enabled_flag,
                    r_int_trans.internal_order_enabled_flag,
                    r_int_trans.so_transactions_flag,
                    r_int_trans.mtl_transactions_enabled_flag,
                    r_int_trans.stock_enabled_flag,
                    r_int_trans.bom_enabled_flag,
                    r_int_trans.build_in_wip_flag,
                    r_int_trans.returnable_flag,
                    r_int_trans.taxable_flag,
                    r_int_trans.allow_item_desc_update_flag,
                    r_int_trans.inspection_required_flag,
                    r_int_trans.receipt_required_flag,
                    r_int_trans.last_update_date,
                    r_int_trans.last_updated_by,
                    r_int_trans.last_update_login,
                    r_int_trans.created_by,
                    r_int_trans.creation_date,
                    r_int_trans.process_flag,
                    r_int_trans.transaction_type,
                    r_int_trans.set_process_id,
                    r_int_trans.summary_flag,
                    r_int_trans.enabled_flag,
                    r_int_trans.item_catalog_group_id,
                    r_int_trans.dual_uom_control);
         END;
      END LOOP;

      COMMIT;
   END cust_import_data_to_interface;

   PROCEDURE cust_upload_data_to_staging (p_item_code       VARCHAR2,
                                          p_description    VARCHAR2)
   IS
      l_error_message                VARCHAR2 (3000);
      l_error_code                   VARCHAR2 (3000);
      l_organization_id              NUMBER;
      l_template_id                  NUMBER;
      l_uom_validity                 VARCHAR2 (250);
      l_item_desc_len                NUMBER;

      p_inventory_item_status_code   VARCHAR2 (250) := 'Active';
      p_template_name                VARCHAR2 (250)
                                        := 'DBL DIS RAW MATL DUAL UOM LOT';
      p_organization_name            VARCHAR2 (250) := 'IMO';

      p_primary_uom_code             VARCHAR2 (250) := 'KG';
      p_secondary_uom_code           VARCHAR2 (250) := 'BAG';
   BEGIN
      ----------------------------------------
      ----------Select Org ID-----------------
      ----------------------------------------
      BEGIN
         SELECT ood.organization_id
           INTO l_organization_id
           FROM org_organization_definitions ood
          WHERE ood.organization_code = p_organization_name;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct organization';
            l_error_code := 'E';
      END;

      ----------------------------------------
      ----------Select Template ID------------
      ----------------------------------------

      IF p_template_name IS NOT NULL
      THEN
         BEGIN
            SELECT mit.TEMPLATE_ID
              INTO l_template_id
              FROM MTL_ITEM_TEMPLATES mit
             WHERE mit.TEMPLATE_NAME = p_template_name;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_error_message :=
                  l_error_message || ',' || 'Please enter correct template';
               l_error_code := 'E';
         END;
      END IF;


      ----------------------------------------
      ------Validate Primary UOM Code---------
      ----------------------------------------
      BEGIN
         SELECT 'Valid'
           INTO l_uom_validity
           FROM MTL_UNITS_OF_MEASURE_VL uom
          WHERE uom.UOM_CODE = p_primary_uom_code;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter the correct Primary/Secondary UOM Code';
            l_error_code := 'E';
      END;

      ----------------------------------------
      ------Validate Secondary UOM Code-------
      ----------------------------------------

      IF p_secondary_uom_code IS NOT NULL
      THEN
         BEGIN
            SELECT 'Valid'
              INTO l_uom_validity
              FROM MTL_UNITS_OF_MEASURE_VL uom
             WHERE uom.UOM_CODE = p_secondary_uom_code;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'Please enter the correct Primary/Secondary UOM Code';
               l_error_code := 'E';
         END;
      END IF;



      ----------------------------------------
      -----Validate Description entered-------
      ----------------------------------------

      BEGIN
         SELECT LENGTH (TRIM (p_description)) INTO l_item_desc_len FROM DUAL;

         IF l_item_desc_len > 240
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please ensure the description length is lesser than 240 characters';
            l_error_code := 'E';
         END IF;
      END;



      --------------------------------------------------------------------------------------------------------------
      --------Condition to show error if any of the above validation picks up a data entry error--------------------
      --------Condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------


      IF l_error_code = 'E'
      THEN
         raise_application_error (-20101, l_error_message);
      ELSIF NVL (l_error_code, 'A') <> 'E'
      THEN
         INSERT
           INTO apps.XXDBL_ITEM_UPLOAD_WEBADI (segment1,
                                               organization_id,
                                               description,
                                               inventory_item_status_code,
                                               template_id,
                                               primary_uom_code,
                                               secondary_uom_code,
                                               last_update_date,
                                               last_updated_by,
                                               last_update_login,
                                               created_by,
                                               creation_date,
                                               process_flag,
                                               transaction_type,
                                               set_process_id,
                                               summary_flag,
                                               enabled_flag,
                                               interface_status,
                                               item_catalog_group_id,
                                               SECONDARY_DEFAULT_IND,
                                               DUAL_UOM_CONTROL)
         VALUES (TRIM (p_item_code),
                 l_organization_id,
                 TRIM (p_description),
                 TRIM (p_inventory_item_status_code),
                 l_template_id,
                 TRIM (p_primary_uom_code),
                 TRIM (p_secondary_uom_code),
                 SYSDATE,
                 1113,
                 0,
                 1113,
                 SYSDATE,
                 1,
                 'CREATE',
                 202007,
                 'N',
                 'Y',
                 'NO',
                 26,
                 'D',
                 3);

         ----------------------------------------------------------------------------------------------------
         -----------Insert data into MTL_SYSTEM_ITEMS_INTERFACE after loading into staging table-------------
         ----------------------------------------------------------------------------------------------------

         BEGIN
            cust_import_data_to_interface;
         END;
      END IF;
   END cust_upload_data_to_staging;
END XXDBL_ITEM_UPLOAD_WEBADI_PKG;
/