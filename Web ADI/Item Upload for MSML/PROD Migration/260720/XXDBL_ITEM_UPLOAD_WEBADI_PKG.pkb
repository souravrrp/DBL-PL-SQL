CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_ITEM_UPLOAD_WEBADI_PKG
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 18-JUL-2020
   -- LAST UPDATE DATE :26-JUL-2020
   -- PURPOSE : INSERT ITEM INTO ACCORDING ORGANIZATION
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
           FROM XXDBL.XXDBL_ITEM_UPLOAD_WEBADI XXDBL
          WHERE     FLAG IS NULL
                AND NOT EXISTS
                       (SELECT 1
                          FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                         WHERE XXDBL.SEGMENT1 = MSII.SEGMENT1);
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

   PROCEDURE cust_upload_data_to_staging (p_item_type       VARCHAR2,
                                          p_item_count      VARCHAR2,
                                          p_product_type    VARCHAR2,
                                          p_item_content    VARCHAR2,
                                          p_item_style      VARCHAR2,
                                          p_item_process    VARCHAR2,
                                          p_description     VARCHAR2)
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
      ---
      cd_item_type                   VARCHAR2 (3);
      cd_item_count                  VARCHAR2 (6);
      cd_product_type                VARCHAR2 (3);
      cd_item_content                VARCHAR2 (3);
      cd_item_style                  VARCHAR2 (3);
      cd_item_process                VARCHAR2 (2);
      cd_item_code                   VARCHAR2 (20);

      l_item_type                    VARCHAR2 (250);
      l_item_count                   VARCHAR2 (250);
      l_product_type                 VARCHAR2 (250);
      l_item_content                 VARCHAR2 (250);
      l_item_style                   VARCHAR2 (250);
      l_item_process                 VARCHAR2 (250);

      --LENGTH OF ITEM_CODE SEGMENTS
      p_item_type_len                NUMBER;
      p_item_count_len               NUMBER;
      p_product_type_len             NUMBER;
      p_item_content_len             NUMBER;
      p_item_style_len               NUMBER;
      p_item_process_len             NUMBER;
      cd_item_code_len               NUMBER;
   --
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
               || 'Please enter the correct Primary UOM Code';
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
                  || 'Please enter the correct Secondary UOM Code';
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


      --------------------------------------------------------------------------
      ------------------ITEM CODE SEGEMENT VALIDATION AND CONCAT----------------
      --------------------------------------------------------------------------

      ----------------------------------------
      -----Validate Item Type entered-------
      ----------------------------------------

      BEGIN
         SELECT LENGTH (TRIM (p_item_type)) INTO p_item_type_len FROM DUAL;

         IF p_item_type_len != 3
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please ensure the length of item type is three characters';
            l_error_code := 'E';
         END IF;
      END;

      -------------------------------------------
      --------Validate Item Type-----------------
      -------------------------------------------
      BEGIN
         SELECT ffv.flex_value, ffv.attribute1
           INTO l_item_type, cd_item_type
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_ITEM_TYPE'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = p_item_type
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Item Type: '
               || p_item_type;
            l_error_code := 'E';
      END;

      ----------------------------------------
      -----Validate Item Count entered--------
      ----------------------------------------

      BEGIN
         SELECT LENGTH (TRIM (p_item_count)) INTO p_item_count_len FROM DUAL;

         IF p_item_count_len != 6
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please ensure the length of item Count is six characters';
            l_error_code := 'E';
         END IF;
      END;

      --------------------------------------
      --------Validate Count----------------
      --------------------------------------


      BEGIN
         SELECT ffv.flex_value, ffv.attribute1
           INTO l_item_count, cd_item_count
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_COUNT'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = p_item_count
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct item Count'|| p_item_count;
            l_error_code := 'E';
      END;


      -----------------------------------------
      -----Validate Product Type entered-------
      -----------------------------------------

      BEGIN
         SELECT LENGTH (TRIM (p_product_type))
           INTO p_product_type_len
           FROM DUAL;

         IF p_product_type_len != 3
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please ensure the length of Count is three characters';
            l_error_code := 'E';
         END IF;
      END;


      --------------------------------------
      ----Validate Product Type-------------
      --------------------------------------
      BEGIN
         SELECT ffv.flex_value, ffv.attribute1
           INTO l_product_type, cd_product_type
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name =
                       'XXDBL_SPINNING_FG_PRODUCT_TYPE'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = p_product_type
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter the correct Product Type: '|| p_product_type;
            l_error_code := 'E';
      END;


      -----------------------------------------
      -----Validate item Content entered-------
      -----------------------------------------

      BEGIN
         SELECT LENGTH (TRIM (p_item_content))
           INTO p_item_content_len
           FROM DUAL;

         IF p_item_content_len != 3
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please ensure the length of item Count is three characters';
            l_error_code := 'E';
         END IF;
      END;

      --------------------------------------
      ----Validate Content------------------
      --------------------------------------


      BEGIN
         SELECT ffv.flex_value, ffv.attribute1
           INTO l_item_content, cd_item_content
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_CONTENT'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = p_item_content
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter the correct item Content: '|| p_item_content;
            l_error_code := 'E';
      END;

      ----------------------------------------
      -----Validate item Style entered--------
      ----------------------------------------

      BEGIN
         SELECT LENGTH (TRIM (p_item_style)) INTO p_item_style_len FROM DUAL;

         IF p_item_style_len != 3
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please ensure the length of item Style is three characters';
            l_error_code := 'E';
         END IF;
      END;


      --------------------------------------
      ----Validate Style--------------------
      --------------------------------------
      BEGIN
         SELECT ffv.flex_value, ffv.attribute1
           INTO l_item_style, cd_item_style
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_STYLE'
                AND ffv.attribute1 = p_item_style
                AND ENABLED_FLAG = 'Y'
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter the correct item Style: '|| p_item_style;
            l_error_code := 'E';
      END;


      -----------------------------------------
      -----Validate item Process entered-------
      -----------------------------------------

      BEGIN
         SELECT LENGTH (TRIM (p_item_process))
           INTO p_item_process_len
           FROM DUAL;

         IF p_item_process_len != 2
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please ensure the length of item Process is two characters';
            l_error_code := 'E';
         END IF;
      END;

      --------------------------------------
      ----Validate Process------------------
      --------------------------------------


      BEGIN
         SELECT ffv.flex_value, ffv.attribute1
           INTO l_item_process, cd_item_process
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_PROCESS'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = p_item_process
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter the correct item Process: '|| p_item_process;
            l_error_code := 'E';
      END;

      --------------------------------------
      ----Validate Items code length--------
      --------------------------------------

      BEGIN
         SELECT    cd_item_type
                || ''
                || cd_item_count
                || ''
                || cd_product_type
                || ''
                || cd_item_content
                || ''
                || cd_item_style
                || ''
                || cd_item_process
           INTO cd_item_code
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter the correct Item Code';
            l_error_code := 'E';
      END;

      BEGIN
         SELECT LENGTH (TRIM (cd_item_code)) INTO cd_item_code_len FROM DUAL;

         IF cd_item_code_len > 20
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please ensure the length of item code is more than twenty(20) characters';
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
           INTO XXDBL.XXDBL_ITEM_UPLOAD_WEBADI (segment1,
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
         VALUES (TRIM (cd_item_code),
                 l_organization_id,
                 TRIM (UPPER(p_description)),
                 TRIM (p_inventory_item_status_code),
                 l_template_id,
                 TRIM (p_primary_uom_code),
                 TRIM (p_secondary_uom_code),
                 SYSDATE,
                 0,
                 0,
                 0,
                 SYSDATE,
                 1,
                 'CREATE',
                 vl_set_process_id,
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

   --------------------------------------------------------------------------------------------------------------------------------------------------------
   FUNCTION check_error_log_to_assign_data
      RETURN NUMBER
   IS
      vlp_category_id     NUMBER;
      vlp_template_name   VARCHAR2 (100);

      CURSOR cur_stg
      IS
         SELECT *
           FROM XXDBL.XXDBL_ITEM_UPLOAD_WEBADI XXDBL
          WHERE     FLAG IS NULL
                AND EXISTS
                       (SELECT 1
                          FROM MTL_SYSTEM_ITEMS_B MSI
                         WHERE XXDBL.SEGMENT1 = MSI.SEGMENT1);

      CURSOR cur_spining
      IS
                    SELECT org.organization_id
                      FROM ORG_ORGANIZATION_DEFINITIONS org,
                           per_org_structure_elements_v pose,
                           per_organization_structures_v os
                     WHERE     1 = 1
                           AND org.organization_id = pose.organization_id_child
                           AND OS.organization_structure_id =
                                  POSE.ORG_STRUCTURE_VERSION_ID
                           AND OS.NAME IN ('SPINING-PROCESS')
                START WITH pose.organization_id_parent = 138
                CONNECT BY PRIOR pose.organization_id_child =
                              pose.organization_id_parent
         ORDER SIBLINGS BY pose.organization_id_child;

      CURSOR cur_rmg
      IS
                    SELECT org.organization_id
                      FROM ORG_ORGANIZATION_DEFINITIONS org,
                           per_org_structure_elements_v pose,
                           per_organization_structures_v os
                     WHERE     1 = 1
                           AND org.organization_id = pose.organization_id_child
                           AND OS.organization_structure_id =
                                  POSE.ORG_STRUCTURE_VERSION_ID
                           AND OS.NAME IN ('RMG-PROCESS')
                START WITH pose.organization_id_parent = 138
                CONNECT BY PRIOR pose.organization_id_child =
                              pose.organization_id_parent
         ORDER SIBLINGS BY pose.organization_id_child;

      CURSOR cur_htl_knit
      IS
                    SELECT org.organization_id
                      FROM ORG_ORGANIZATION_DEFINITIONS org,
                           per_org_structure_elements_v pose,
                           per_organization_structures_v os
                     WHERE     1 = 1
                           AND org.organization_id = pose.organization_id_child
                           AND OS.organization_structure_id =
                                  POSE.ORG_STRUCTURE_VERSION_ID
                           AND OS.NAME IN ('HTL-KNITTING')
                START WITH pose.organization_id_parent = 138
                CONNECT BY PRIOR pose.organization_id_child =
                              pose.organization_id_parent
         ORDER SIBLINGS BY pose.organization_id_child;
   BEGIN
      FOR ln_cur_stg IN cur_stg
      LOOP
         BEGIN
            UPDATE mtl_system_items_b m
               SET mcc_control_code = 1, expense_account = 10753
             WHERE segment1 = ln_cur_stg.segment1;

            COMMIT;
         END;

         CASE
            WHEN SUBSTR (ln_cur_stg.segment1, 0, 5) != 'YRNDY'      --For Yarn
            THEN
               ---spining
               BEGIN
                  FOR ln_cur_spining IN cur_spining
                  LOOP
                     BEGIN
                        IF ln_cur_spining.organization_id NOT IN (198)
                        THEN
                           vlp_template_name := 'OPM FG DUAL UOM LOT';
                           item_assign_template (
                              ln_cur_stg.segment1,
                              ln_cur_spining.organization_id,
                              vlp_template_name);
                           vlp_category_id := 2125;
                           assign_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_spining.organization_id,
                              vlp_category_id);
                        END IF;
                     END;
                  END LOOP;
               END;


               ---rmg
               BEGIN
                  FOR ln_cur_rmg IN cur_rmg
                  LOOP
                     BEGIN
                        IF ln_cur_rmg.organization_id NOT IN (143, 144)
                        THEN
                           vlp_template_name :=
                              'DBL DIS RAW MATL DUAL UOM LOT';
                           item_assign_template (ln_cur_stg.segment1,
                                                 ln_cur_rmg.organization_id,
                                                 vlp_template_name);
                           vlp_category_id := 2126;
                           assign_item_category (ln_cur_stg.segment1,
                                                 ln_cur_rmg.organization_id,
                                                 vlp_category_id);
                        END IF;

                        IF ln_cur_rmg.organization_id IN (139,
                                                          177,
                                                          182,
                                                          187,
                                                          192)
                        THEN
                           create_lcm_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_rmg.organization_id);
                        END IF;
                     END;
                  END LOOP;
               END;

               ---htl_knitting
               BEGIN
                  FOR ln_cur_htl_knit IN cur_htl_knit
                  LOOP
                     BEGIN
                        vlp_template_name := 'OPM RAW MATL DUAL UOM LOT';
                        item_assign_template (
                           ln_cur_stg.segment1,
                           ln_cur_htl_knit.organization_id,
                           vlp_template_name);
                        vlp_category_id := 2126;
                        assign_item_category (
                           ln_cur_stg.segment1,
                           ln_cur_htl_knit.organization_id,
                           vlp_category_id);

                        IF ln_cur_htl_knit.organization_id IN (169)
                        THEN
                           create_lcm_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_htl_knit.organization_id);
                        END IF;
                     END;
                  END LOOP;
               END;


               vlp_category_id := 2126;
               assign_item_category (ln_cur_stg.segment1,
                                     ln_cur_stg.organization_id,
                                     vlp_category_id);
            ELSE                                               --For Dyed Yarn
               ---rmg
               BEGIN
                  FOR ln_cur_rmg IN cur_rmg
                  LOOP
                     BEGIN
                        IF ln_cur_rmg.organization_id NOT IN (143, 144)
                        THEN
                           vlp_template_name :=
                              'DBL DIS RAW MATL DUAL UOM LOT';
                           item_assign_template (ln_cur_stg.segment1,
                                                 ln_cur_rmg.organization_id,
                                                 vlp_template_name);
                           vlp_category_id := 3488;
                           assign_item_category (ln_cur_stg.segment1,
                                                 ln_cur_rmg.organization_id,
                                                 vlp_category_id);
                        END IF;

                        IF ln_cur_rmg.organization_id IN (139,
                                                          177,
                                                          182,
                                                          187,
                                                          192)
                        THEN
                           create_lcm_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_rmg.organization_id);
                        END IF;
                     END;
                  END LOOP;
               END;

               ---htl_knitting
               BEGIN
                  FOR ln_cur_htl_knit IN cur_htl_knit
                  LOOP
                     BEGIN
                        vlp_template_name := 'OPM RAW MATL DUAL UOM LOT';
                        item_assign_template (
                           ln_cur_stg.segment1,
                           ln_cur_htl_knit.organization_id,
                           vlp_template_name);
                        vlp_category_id := 3488;
                        assign_item_category (
                           ln_cur_stg.segment1,
                           ln_cur_htl_knit.organization_id,
                           vlp_category_id);

                        IF ln_cur_htl_knit.organization_id IN (169)
                        THEN
                           create_lcm_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_htl_knit.organization_id);
                        END IF;
                     END;
                  END LOOP;
               END;


               vlp_category_id := 3488;
               assign_item_category (ln_cur_stg.segment1,
                                     ln_cur_stg.organization_id,
                                     vlp_category_id);
         END CASE;



         BEGIN
            item_assign_uom_conv (ln_cur_stg.segment1);
         END;


         UPDATE XXDBL.XXDBL_ITEM_UPLOAD_WEBADI
            SET FLAG = 'Y'
          WHERE FLAG IS NULL AND segment1 = ln_cur_stg.segment1;

         COMMIT;
      END LOOP;

      RETURN 0;
   END;

   PROCEDURE assign_item_org_and_category (ERRBUF    OUT VARCHAR2,
                                           RETCODE   OUT VARCHAR2)
   IS
      L_Retcode              NUMBER;
      CONC_STATUS            BOOLEAN;
      l_error                VARCHAR2 (100);

      ln_req_id              NUMBER;
      lv_req_phase           VARCHAR2 (240);
      lv_req_status          VARCHAR2 (240);
      lv_req_dev_phase       VARCHAR2 (240);
      lv_req_dev_status      VARCHAR2 (240);
      lv_req_message         VARCHAR2 (240);
      lv_req_return_status   BOOLEAN;
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      BEGIN
         fnd_file.put_line (fnd_file.output,
                            '*** Call The Item Import Program  ***');
         FND_GLOBAL.APPS_INITIALIZE (0, 20634, 401);
         MO_GLOBAL.SET_POLICY_CONTEXT ('S', '138');
         FND_GLOBAL.SET_NLS_CONTEXT ('AMERICAN');
         MO_GLOBAL.INIT ('INV');
         ln_req_id :=
            fnd_request.submit_request (application   => 'INV',
                                        Program       => 'INCOIN',
                                        description   => NULL,
                                        start_time    => SYSDATE,
                                        sub_request   => FALSE,
                                        argument1     => 138,
                                        argument2     => 1,
                                        argument3     => 1,
                                        argument4     => 1,
                                        argument5     => 1,
                                        argument6     => vl_set_process_id,
                                        argument7     => 1);
         COMMIT;

         IF ln_req_id = 0
         THEN
            fnd_file.put_line (
               fnd_file.LOG,
               'Request Not Submitted due to "' || fnd_message.get || '".');
         ELSE
            fnd_file.put_line (
               fnd_file.LOG,
                  'The Item Import Program submitted - Request id :'
               || ln_req_id);
         END IF;

         IF ln_req_id > 0
         THEN
            LOOP
               lv_req_return_status :=
                  fnd_concurrent.wait_for_request (ln_req_id,
                                                   60,
                                                   0,
                                                   lv_req_phase,
                                                   lv_req_status,
                                                   lv_req_dev_phase,
                                                   lv_req_dev_status,
                                                   lv_req_message);
               EXIT WHEN    UPPER (lv_req_phase) = 'COMPLETED'
                         OR UPPER (lv_req_status) IN
                               ('CANCELLED', 'ERROR', 'TERMINATED');
            END LOOP;

            DBMS_OUTPUT.PUT_LINE ('Request Phase  : ' || lv_req_dev_phase);
            DBMS_OUTPUT.PUT_LINE ('Request Status : ' || lv_req_dev_status);
            DBMS_OUTPUT.PUT_LINE ('Request id     : ' || ln_req_id);
            Fnd_File.PUT_LINE (
               Fnd_File.LOG,
                  'The Item Import Program Completion Phase: '
               || lv_req_dev_phase);
            Fnd_File.PUT_LINE (
               Fnd_File.LOG,
                  'The Item Import Program Completion Status: '
               || lv_req_dev_status);

            CASE
               WHEN     UPPER (lv_req_phase) = 'COMPLETED'
                    AND UPPER (lv_req_status) = 'ERROR'
               THEN
                  fnd_file.put_line (
                     fnd_file.LOG,
                     'The Item Import prog completed in error. See log for request id');
                  fnd_file.put_line (fnd_file.LOG, SQLERRM);
               WHEN    (    UPPER (lv_req_phase) = 'COMPLETED'
                        AND UPPER (lv_req_status) = 'NORMAL')
                    OR (    UPPER (lv_req_phase) = 'COMPLETED'
                        AND UPPER (lv_req_status) = 'WARNING')
               THEN
                  BEGIN
                     L_Retcode := check_error_log_to_assign_data;
                     Fnd_File.PUT_LINE (
                        Fnd_File.LOG,
                           'The Item successfully Assigned to the respected Organization for request id: '
                        || ln_req_id);
                  END;

                  Fnd_File.PUT_LINE (
                     Fnd_File.LOG,
                        'The Item Import successfully completed for request id: '
                     || ln_req_id);
               ELSE
                  Fnd_File.PUT_LINE (
                     Fnd_File.LOG,
                     'The Item Import request failed.Review log for Oracle request id ');
                  Fnd_File.PUT_LINE (Fnd_File.LOG, SQLERRM);
            END CASE;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            fnd_file.put_line (
               fnd_file.LOG,
                  'OTHERS exception while submitting The Item  Import Program: '
               || SQLERRM);
      END;

      --L_Retcode := check_error_log_to_assign_data;



      IF L_Retcode = 0
      THEN
         RETCODE := 'Success';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
      ELSIF L_Retcode = 1
      THEN
         RETCODE := 'Warning';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
      ELSIF L_Retcode = 2
      THEN
         RETCODE := 'Error';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error := 'error while executing the procedure ' || SQLERRM;
         errbuf := l_error;
         RETCODE := 1;
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
   END assign_item_org_and_category;

   PROCEDURE assign_item_into_org (l_item_code          VARCHAR2,
                                   l_organization_id    NUMBER)
   IS
      g_user_id         fnd_user.user_id%TYPE := NULL;
      l_appl_id         fnd_application.application_id%TYPE;
      l_resp_id         fnd_responsibility_tl.responsibility_id%TYPE;
      l_api_version     NUMBER := 1.0;
      x_message_list    error_handler.error_tbl_type;
      x_return_status   VARCHAR2 (2);
      x_msg_count       NUMBER := 0;
      l_error_msg       VARCHAR2 (1000);
   BEGIN
      SELECT fa.application_id
        INTO l_appl_id
        FROM fnd_application fa
       WHERE fa.application_short_name = 'INV';

      SELECT fr.responsibility_id
        INTO l_resp_id
        FROM fnd_application fa, fnd_responsibility_tl fr
       WHERE     fa.application_short_name = 'INV'
             AND fa.application_id = fr.application_id
             AND UPPER (fr.responsibility_name) = 'INVENTORY';

      fnd_global.apps_initialize (g_user_id, l_resp_id, l_appl_id);



      FOR r1 IN (SELECT inventory_item_id, l_organization_id
                   --INTO V_Inventory_Item_Id, v_Organization_id
                   FROM mtl_system_items_b
                  WHERE segment1 = l_item_code AND organization_id = 138)
      LOOP
         --Call API for IO Assignment to Inventory Item
         ego_item_pub.assign_item_to_org (
            p_api_version         => l_api_version,
            p_inventory_item_id   => r1.inventory_item_id,
            p_organization_id     => r1.l_organization_id,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count);
         COMMIT;

         l_error_msg :=
               'Status: '
            || x_return_status
            || ' for inventory item id : '
            || r1.inventory_item_id;
         DBMS_OUTPUT.put_line (l_error_msg);

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            DBMS_OUTPUT.put_line ('Error Messages :');
            error_handler.get_message_list (x_message_list => x_message_list);

            FOR j IN 1 .. x_message_list.COUNT
            LOOP
               DBMS_OUTPUT.put_line (x_message_list (j).MESSAGE_TEXT);
            END LOOP;
         END IF;
      END LOOP;

      DBMS_LOCK.SLEEP (6);                     --Break process every 6 seconds
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Exception Occured :');
         DBMS_OUTPUT.put_line (SQLCODE || ':' || SQLERRM);
   END assign_item_into_org;

   PROCEDURE assign_item_category (VL_ITEM_CODE          VARCHAR2,
                                   vl_organization_id    NUMBER,
                                   vlu_category_id       NUMBER)
   IS
      v_return_status       VARCHAR2 (1) := NULL;
      v_msg_count           NUMBER := 0;
      v_msg_data            VARCHAR2 (2000);
      v_errorcode           VARCHAR2 (1000);
      v_category_id         NUMBER;
      v_old_category_id     NUMBER;
      v_category_set_id     NUMBER;
      v_inventory_item_id   NUMBER;
      vl_ITEM_ID            NUMBER;
      v_organization_id     NUMBER := vl_organization_id;
      v_context             VARCHAR2 (2);



      FUNCTION set_context (i_user_name   IN VARCHAR2,
                            i_resp_name   IN VARCHAR2,
                            i_org_id      IN NUMBER)
         RETURN VARCHAR2
      IS
         vi_category_id   NUMBER := vlu_category_id;
         v_user_id        NUMBER;
         v_resp_id        NUMBER;
         v_resp_appl_id   NUMBER;
         v_lang           VARCHAR2 (100);
         v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
         v_return         VARCHAR2 (10) := 'T';
         v_nls_lang       VARCHAR2 (100);
         v_org_id         NUMBER := i_org_id;

         CURSOR cur_user
         IS
            SELECT user_id
              FROM fnd_user
             WHERE user_name = i_user_name;

         CURSOR cur_resp
         IS
            SELECT responsibility_id, application_id, language
              FROM fnd_responsibility_tl
             WHERE responsibility_name = i_resp_name;

         CURSOR cur_lang (p_lang_code VARCHAR2)
         IS
            SELECT nls_language
              FROM fnd_languages
             WHERE language_code = p_lang_code;
      BEGIN
         SELECT MSI.INVENTORY_ITEM_ID
           INTO vl_ITEM_ID
           FROM APPS.MTL_SYSTEM_ITEMS_B MSI
          WHERE MSI.SEGMENT1 = VL_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

         INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE (INVENTORY_ITEM_ID,
                                                    CATEGORY_SET_ID,
                                                    OLD_CATEGORY_ID,
                                                    CATEGORY_ID,
                                                    PROCESS_FLAG,
                                                    ORGANIZATION_ID,
                                                    SET_PROCESS_ID,
                                                    TRANSACTION_TYPE)
              VALUES (vl_ITEM_ID,
                      1,
                      2124,
                      vi_category_id,
                      1,
                      v_organization_id,
                      1,
                      'UPDATE');

         COMMIT;

         OPEN cur_user;

         FETCH cur_user INTO v_user_id;

         IF cur_user%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_user;

         OPEN cur_resp;

         FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

         IF cur_resp%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_resp;

         fnd_global.apps_initialize (user_id        => v_user_id,
                                     resp_id        => v_resp_id,
                                     resp_appl_id   => v_resp_appl_id);

         mo_global.set_policy_context ('S', v_org_id);

         IF v_session_lang != v_lang
         THEN
            OPEN cur_lang (v_lang);

            FETCH cur_lang INTO v_nls_lang;

            CLOSE cur_lang;

            fnd_global.set_nls_context (v_nls_lang);
         END IF;

         RETURN v_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'F';
      END set_context;
   BEGIN
      v_context := set_context ('SYSADMIN', 'Inventory', 131);

      IF v_context = 'F'
      THEN
         DBMS_OUTPUT.put_line ('Error while setting the context');
      END IF;

      SELECT MSI.INVENTORY_ITEM_ID
        INTO vl_ITEM_ID
        FROM APPS.MTL_SYSTEM_ITEMS_B MSI
       WHERE MSI.SEGMENT1 = VL_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

      --- context done ------------
      v_old_category_id := 2124;
      v_category_id := vlu_category_id;
      v_category_set_id := 1;
      v_inventory_item_id := vl_ITEM_ID;
      v_organization_id := v_organization_id;

      INV_ITEM_CATEGORY_PUB.UPDATE_CATEGORY_ASSIGNMENT (
         p_api_version         => 1.0,
         p_init_msg_list       => FND_API.G_TRUE,
         p_commit              => FND_API.G_FALSE,
         x_return_status       => v_return_status,
         x_errorcode           => v_errorcode,
         x_msg_count           => v_msg_count,
         x_msg_data            => v_msg_data,
         p_old_category_id     => v_old_category_id,
         p_category_id         => v_category_id,
         p_category_set_id     => v_category_set_id,
         p_inventory_item_id   => v_inventory_item_id,
         p_organization_id     => v_organization_id);
      COMMIT;

      IF v_return_status = fnd_api.g_ret_sts_success
      THEN
         COMMIT;
         DBMS_OUTPUT.put_line (
               'Updation of category assigment is Sucessfull : '
            || v_category_id);
      ELSE
         DBMS_OUTPUT.put_line (
            'Updation of category assigment failed:' || v_msg_data);
         ROLLBACK;

         FOR i IN 1 .. v_msg_count
         LOOP
            v_msg_data := oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.put_line (i || ') ' || v_msg_data);
         END LOOP;
      END IF;
   END assign_item_category;

   PROCEDURE create_lcm_item_category (LCM_ITEM_CODE          VARCHAR2,
                                       Lcm_organization_id    NUMBER)
   IS
      v_return_status       VARCHAR2 (1) := NULL;
      v_msg_count           NUMBER := 0;
      v_msg_data            VARCHAR2 (2000);
      v_errorcode           VARCHAR2 (1000);
      v_category_id         NUMBER;
      v_category_set_id     NUMBER;
      v_inventory_item_id   NUMBER;
      vl_ITEM_ID            NUMBER;
      v_organization_id     NUMBER := Lcm_organization_id;
      v_context             VARCHAR2 (2);



      FUNCTION set_context (i_user_name   IN VARCHAR2,
                            i_resp_name   IN VARCHAR2,
                            i_org_id      IN NUMBER)
         RETURN VARCHAR2
      IS
         v_user_id        NUMBER;
         v_resp_id        NUMBER;
         v_resp_appl_id   NUMBER;
         v_lang           VARCHAR2 (100);
         v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
         v_return         VARCHAR2 (10) := 'T';
         v_nls_lang       VARCHAR2 (100);
         v_org_id         NUMBER := i_org_id;

         CURSOR cur_user
         IS
            SELECT user_id
              FROM fnd_user
             WHERE user_name = i_user_name;

         CURSOR cur_resp
         IS
            SELECT responsibility_id, application_id, language
              FROM fnd_responsibility_tl
             WHERE responsibility_name = i_resp_name;

         CURSOR cur_lang (p_lang_code VARCHAR2)
         IS
            SELECT nls_language
              FROM fnd_languages
             WHERE language_code = p_lang_code;
      BEGIN
         SELECT MSI.INVENTORY_ITEM_ID
           INTO vl_ITEM_ID
           FROM APPS.MTL_SYSTEM_ITEMS_B MSI
          WHERE MSI.SEGMENT1 = LCM_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

         INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE (INVENTORY_ITEM_ID,
                                                    CATEGORY_SET_ID,
                                                    CATEGORY_ID,
                                                    PROCESS_FLAG,
                                                    ORGANIZATION_ID,
                                                    SET_PROCESS_ID,
                                                    TRANSACTION_TYPE)
              VALUES (vl_ITEM_ID,
                      1,
                      2124,
                      1,
                      v_organization_id,
                      1,
                      'INSERT');

         COMMIT;

         OPEN cur_user;

         FETCH cur_user INTO v_user_id;

         IF cur_user%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_user;

         OPEN cur_resp;

         FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

         IF cur_resp%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_resp;

         fnd_global.apps_initialize (user_id        => v_user_id,
                                     resp_id        => v_resp_id,
                                     resp_appl_id   => v_resp_appl_id);

         mo_global.set_policy_context ('S', v_org_id);


         IF v_session_lang != v_lang
         THEN
            OPEN cur_lang (v_lang);

            FETCH cur_lang INTO v_nls_lang;

            CLOSE cur_lang;

            fnd_global.set_nls_context (v_nls_lang);
         END IF;

         RETURN v_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'F';
      END set_context;
   BEGIN
      v_context := set_context ('SYSADMIN', 'Inventory', 131);

      IF v_context = 'F'
      THEN
         DBMS_OUTPUT.put_line ('Error while setting the context');
      END IF;

      SELECT MSI.INVENTORY_ITEM_ID
        INTO vl_ITEM_ID
        FROM APPS.MTL_SYSTEM_ITEMS_B MSI
       WHERE MSI.SEGMENT1 = LCM_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

      --- context done ------------
      v_category_id := 2124;
      v_category_set_id := 1100000041;
      v_inventory_item_id := vl_ITEM_ID;
      v_organization_id := v_organization_id;

      INV_ITEM_CATEGORY_PUB.CREATE_CATEGORY_ASSIGNMENT (
         p_api_version         => 1.0,
         p_init_msg_list       => FND_API.G_TRUE,
         p_commit              => FND_API.G_FALSE,
         x_return_status       => v_return_status,
         x_errorcode           => v_errorcode,
         x_msg_count           => v_msg_count,
         x_msg_data            => v_msg_data,
         p_category_id         => v_category_id,
         p_category_set_id     => v_category_set_id,
         p_inventory_item_id   => v_inventory_item_id,
         p_organization_id     => v_organization_id);
      COMMIT;

      IF v_return_status = fnd_api.g_ret_sts_success
      THEN
         COMMIT;
         DBMS_OUTPUT.put_line (
               'The Item assignment to category is Successful : '
            || v_category_id);
      ELSE
         DBMS_OUTPUT.put_line (
            'The Item assignment to category failed:' || v_msg_data);
         ROLLBACK;

         FOR i IN 1 .. v_msg_count
         LOOP
            v_msg_data := oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.put_line (i || ') ' || v_msg_data);
         END LOOP;
      END IF;
   END create_lcm_item_category;

   PROCEDURE item_assign_uom_conv (um_item_code IN VARCHAR2)
   IS
      p_from_uom_code        VARCHAR2 (200);
      p_to_uom_code          VARCHAR2 (200);
      p_item_id              NUMBER;
      p_uom_rate             NUMBER;
      x_return_status        VARCHAR2 (200);
      l_msg_data             VARCHAR2 (2000);
      v_context              VARCHAR2 (100);
      um_Inventory_Item_Id   NUMBER;


      FUNCTION set_context (i_user_name   IN VARCHAR2,
                            i_resp_name   IN VARCHAR2,
                            i_org_id      IN NUMBER)
         RETURN VARCHAR2
      IS
         v_user_id        NUMBER;
         v_resp_id        NUMBER;
         v_resp_appl_id   NUMBER;
         v_lang           VARCHAR2 (100);
         v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
         v_return         VARCHAR2 (10) := 'T';
         v_nls_lang       VARCHAR2 (100);
         v_org_id         NUMBER := i_org_id;

         CURSOR cur_user
         IS
            SELECT user_id
              FROM fnd_user
             WHERE user_name = i_user_name;

         CURSOR cur_resp
         IS
            SELECT responsibility_id, application_id, language
              FROM fnd_responsibility_tl
             WHERE responsibility_name = i_resp_name;

         CURSOR cur_lang (p_lang_code VARCHAR2)
         IS
            SELECT nls_language
              FROM fnd_languages
             WHERE language_code = p_lang_code;
      BEGIN
         OPEN cur_user;

         FETCH cur_user INTO v_user_id;

         IF cur_user%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_user;

         OPEN cur_resp;

         FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

         IF cur_resp%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_resp;

         fnd_global.apps_initialize (user_id        => v_user_id,
                                     resp_id        => v_resp_id,
                                     resp_appl_id   => v_resp_appl_id);

         mo_global.set_policy_context ('S', v_org_id);

         IF v_session_lang != v_lang
         THEN
            OPEN cur_lang (v_lang);

            FETCH cur_lang INTO v_nls_lang;

            CLOSE cur_lang;

            fnd_global.set_nls_context (v_nls_lang);
         END IF;

         RETURN v_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'F';
      END set_context;
   BEGIN
      BEGIN
         v_context := set_context ('SYSADMIN', 'Inventory', 131);

         IF v_context = 'F'
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'Error while setting the context' || SQLERRM (SQLCODE));
         END IF;
      END;

      SELECT inventory_item_id
        INTO um_Inventory_Item_Id
        FROM mtl_system_items_b
       WHERE segment1 = um_item_code AND organization_id = 138;

      p_from_uom_code := 'KG';
      p_to_uom_code := 'NO';
      p_item_id := um_Inventory_Item_Id;
      p_uom_rate := '50';

      INV_CONVERT.CREATE_UOM_CONVERSION (P_FROM_UOM_CODE   => p_from_uom_code,
                                         P_TO_UOM_CODE     => p_to_uom_code,
                                         P_ITEM_ID         => p_item_id,
                                         P_UOM_RATE        => p_uom_rate,
                                         X_RETURN_STATUS   => x_return_status);

      COMMIT;

      IF x_return_status = 'S'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Got Created Sucessfully ');
      ELSIF x_return_status = 'W'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Already Exists ');
      ELSIF x_return_status = 'U'
      THEN
         DBMS_OUTPUT.put_line (' Unexpected Error Occured ');
      ELSIF x_return_status = 'E'
      THEN
         LOOP
            l_msg_data :=
               FND_MSG_PUB.Get (FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);

            IF l_msg_data IS NULL
            THEN
               EXIT;
            END IF;

            DBMS_OUTPUT.PUT_LINE ('Message' || l_msg_data);
         END LOOP;
      END IF;
   END item_assign_uom_conv;

   PROCEDURE item_assign_template (tm_item_code       IN VARCHAR2,
                                   tm_org_id          IN NUMBER,
                                   tm_template_name   IN VARCHAR2)
   IS
      l_item_tbl             EGO_Item_PUB.Item_Tbl_Type;
      x_item_tbl             EGO_Item_PUB.Item_Tbl_Type;
      l_msg_data             VARCHAR2 (2000);
      v_context              VARCHAR2 (100);
      tm_Inventory_Item_Id   NUMBER;
      tm_Item_description    VARCHAR2 (100);
      x_return_status        VARCHAR2 (1);
      x_msg_count            NUMBER (10);


      FUNCTION set_context (i_user_name   IN VARCHAR2,
                            i_resp_name   IN VARCHAR2,
                            i_org_id      IN NUMBER)
         RETURN VARCHAR2
      IS
         v_user_id        NUMBER;
         v_resp_id        NUMBER;
         v_resp_appl_id   NUMBER;
         v_lang           VARCHAR2 (100);
         v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
         v_return         VARCHAR2 (10) := 'T';
         v_nls_lang       VARCHAR2 (100);
         v_org_id         NUMBER := i_org_id;

         CURSOR cur_user
         IS
            SELECT user_id
              FROM fnd_user
             WHERE user_name = i_user_name;

         CURSOR cur_resp
         IS
            SELECT responsibility_id, application_id, language
              FROM fnd_responsibility_tl
             WHERE responsibility_name = i_resp_name;

         CURSOR cur_lang (p_lang_code VARCHAR2)
         IS
            SELECT nls_language
              FROM fnd_languages
             WHERE language_code = p_lang_code;
      BEGIN
         OPEN cur_user;

         FETCH cur_user INTO v_user_id;

         IF cur_user%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_user;


         OPEN cur_resp;

         FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

         IF cur_resp%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_resp;


         fnd_global.apps_initialize (user_id        => v_user_id,
                                     resp_id        => v_resp_id,
                                     resp_appl_id   => v_resp_appl_id);


         mo_global.set_policy_context ('S', v_org_id);


         IF v_session_lang != v_lang
         THEN
            OPEN cur_lang (v_lang);

            FETCH cur_lang INTO v_nls_lang;

            CLOSE cur_lang;

            fnd_global.set_nls_context (v_nls_lang);
         END IF;

         RETURN v_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'F';
      END set_context;
   BEGIN
      BEGIN
         v_context := set_context ('SYSADMIN', 'Inventory', 131);

         IF v_context = 'F'
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'Error while setting the context' || SQLERRM (SQLCODE));
         END IF;
      END;

      SELECT inventory_item_id, description
        INTO tm_Inventory_Item_Id, tm_Item_description
        FROM mtl_system_items_b
       WHERE segment1 = tm_item_code AND organization_id = 138;


      l_item_tbl (1).Transaction_Type := 'CREATE';
      l_item_tbl (1).Inventory_Item_Status_Code := 'Active';
      l_item_tbl (1).Organization_ID := tm_org_id;
      l_item_tbl (1).Description := tm_Item_description;
      l_item_tbl (1).Segment1 := tm_item_code;
      l_item_tbl (1).Template_Name := tm_template_name;



      DBMS_OUTPUT.PUT_LINE ('=====================================');
      DBMS_OUTPUT.PUT_LINE ('Calling EGO_ITEM_PUB.Process_Items API');
      ego_item_pub.process_items (p_api_version     => 1.0,
                                  p_init_msg_list   => fnd_api.g_true,
                                  p_commit          => fnd_api.g_true,
                                  p_item_tbl        => l_item_tbl,
                                  x_item_tbl        => x_item_tbl,
                                  x_return_status   => x_return_status,
                                  x_msg_count       => x_msg_count);

      DBMS_OUTPUT.PUT_LINE ('=====================================');


      COMMIT;

      IF x_return_status = 'S'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Got Created Sucessfully ');
      ELSIF x_return_status = 'W'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Already Exists ');
      ELSIF x_return_status = 'U'
      THEN
         DBMS_OUTPUT.put_line (' Unexpected Error Occured ');
      ELSIF x_return_status = 'E'
      THEN
         LOOP
            l_msg_data :=
               FND_MSG_PUB.Get (FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);

            IF l_msg_data IS NULL
            THEN
               EXIT;
            END IF;

            DBMS_OUTPUT.PUT_LINE ('Message' || l_msg_data);
         END LOOP;
      END IF;
   END item_assign_template;
END XXDBL_ITEM_UPLOAD_WEBADI_PKG;
/