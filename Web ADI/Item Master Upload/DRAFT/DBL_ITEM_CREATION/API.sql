DBL Item Upload from Staging: xx_dbl_item_template.xxdbl_insert

select
*
from
xxdbl_item_conv_stg


XXDBL Item Staging for Thread
Item Category Assignment Open Interface
XXDBL Item Staging for Thread    : xxdbl_item_conv_prc_thread
DBL Thread Catalog Upload
DBL Thread UOM Conversion Upload : XXDBL_THD_UOM_CONV_UPLOAD : xxdbl_thd_uom_conv_upload.main
XXDBL Basis Staging Program      :  xxdbl_basis_upd
DBL GL Allocation Basis Upload Procedure

DBL Thread Formula Upload:  xxdbl_thread_fml_upload_prc

SELECT   *
        FROM   xxdbl_thread_formula_upd_stg;


--DBL Item Creation Program
--XXDBL_ITEM_CREATION_PROG
--xx_dbl_item_template.xxdbl_insert
CREATE OR REPLACE PACKAGE BODY APPS.xx_dbl_item_template
IS
   PROCEDURE xxdbl_insert (
      p_new_at                       IN   VARCHAR2 DEFAULT NULL,
      p_item_code                    IN   VARCHAR2 DEFAULT NULL,
      p_item_description             IN   VARCHAR2 DEFAULT NULL,
      p_primary_uom                  IN   VARCHAR2 DEFAULT NULL,
      p_secondary_uom                IN   VARCHAR2 DEFAULT NULL,
      p_item_conversion_factor       IN   VARCHAR2 DEFAULT NULL,
      p_organization_code            IN   VARCHAR2 DEFAULT NULL,
      p_item_template                IN   VARCHAR2 DEFAULT NULL,
      p_inv_category_set             IN   VARCHAR2 DEFAULT NULL,
      p_item_category_segment1       IN   VARCHAR2 DEFAULT NULL,
      p_item_category_segment2       IN   VARCHAR2 DEFAULT NULL,
      p_item_category_segment3       IN   VARCHAR2 DEFAULT NULL,
      p_item_category_segment4       IN   VARCHAR2 DEFAULT NULL,
      p_sales_category_set           IN   VARCHAR2 DEFAULT NULL,
      p_sales_category_segment1      IN   VARCHAR2 DEFAULT NULL,
      p_sales_category_segment2      IN   VARCHAR2 DEFAULT NULL,
      p_cogs_account                 IN   VARCHAR2 DEFAULT NULL,
      p_sales_account                IN   VARCHAR2 DEFAULT NULL,
      p_rma_insp_reqd                IN   VARCHAR2 DEFAULT NULL,
      p_supply_sub_inv               IN   VARCHAR2 DEFAULT NULL,
      p_supply_loc                   IN   VARCHAR2 DEFAULT NULL,
      p_yield_sub_inv                IN   VARCHAR2 DEFAULT NULL,
      p_yield_loc                    IN   VARCHAR2 DEFAULT NULL,
      p_status                       IN   VARCHAR2 DEFAULT NULL,
      p_status_message               IN   VARCHAR2 DEFAULT NULL,
      p_attr_context                 IN   VARCHAR2 DEFAULT NULL,
      p_legacy_item_code             IN   VARCHAR2 DEFAULT NULL,
      p_product_line                 IN   VARCHAR2 DEFAULT NULL,
      p_set_proc_id                  IN   VARCHAR2 DEFAULT NULL,
      p_fixed_lead_time              IN   VARCHAR2 DEFAULT NULL,
      p_fixed_days_supply            IN   VARCHAR2 DEFAULT NULL,
      p_plan_cat_set                 IN   VARCHAR2 DEFAULT NULL,
      p_pln_item_category_segment1   IN   VARCHAR2 DEFAULT NULL,
      p_pln_item_category_segment2   IN   VARCHAR2 DEFAULT NULL,
      p_pln_item_category_segment3   IN   VARCHAR2 DEFAULT NULL,
      p_pln_item_category_segment4   IN   VARCHAR2 DEFAULT NULL,
      p_planner                      IN   VARCHAR2 DEFAULT NULL,
      p_item_type                    IN   VARCHAR2 DEFAULT NULL,
      p_long_description             IN   VARCHAR2 DEFAULT NULL,
      p_weight_uom_code              IN   VARCHAR2 DEFAULT NULL,
      p_unit_weight                  IN   VARCHAR2 DEFAULT NULL,
      p_catalog_1_item_type          IN   VARCHAR2 DEFAULT NULL,
      p_catalog_2_art                IN   VARCHAR2 DEFAULT NULL,
      p_catalog_3_length             IN   VARCHAR2 DEFAULT NULL,
      p_catalog_4_tkt                IN   VARCHAR2 DEFAULT NULL,
      p_catalog_5_shade              IN   VARCHAR2 DEFAULT NULL,
      p_brand_short_code             IN   VARCHAR2 DEFAULT NULL,
      p_tracking_uom_mode            IN   VARCHAR2 DEFAULT NULL,
      p_pricing_uom_mode             IN   VARCHAR2 DEFAULT NULL,
      p_dye_house_kg_per_pkg         IN   VARCHAR2 DEFAULT NULL,
      p_status_catalog               IN   VARCHAR2 DEFAULT NULL,
      p_status_message_catalog       IN   VARCHAR2 DEFAULT NULL,
      p_catalog_batch_number         IN   VARCHAR2 DEFAULT NULL,
      p_hs_code                      IN   VARCHAR2 DEFAULT NULL
   )
   AS
      l_count                  NUMBER;
      l_temp                   VARCHAR2 (250);
      l_message                VARCHAR2 (250);
      e_validation             EXCEPTION;
      l_error                  BOOLEAN         := FALSE;
      l_set_proc_id            VARCHAR2 (4000) := NULL;
      l_catalog_batch_number   VARCHAR2 (4000) := NULL;
   BEGIN
      --validating Item_Code
      IF p_item_code IS NULL
      THEN
         l_error := TRUE;
         l_message := 'item code cannot be null';
         RAISE e_validation;
      ELSE
         IF p_organization_code IS NULL
         THEN
            l_error := TRUE;
            l_message := 'organization code cannot be null';
            RAISE e_validation;
         ELSE
            SELECT COUNT (1)
              INTO l_count
              FROM mtl_parameters a, mtl_system_items_b b
             WHERE a.organization_id = b.organization_id
               AND b.segment1 = p_item_code
               AND a.organization_code = p_organization_code;

            IF l_count != 0
            THEN
               l_message :=
                     p_item_code
                  || ' is alreday available for  '
                  || p_organization_code
                  || 'organization';
               l_error := TRUE;
               RAISE e_validation;
            END IF;
         END IF;
      END IF;

      --Validating Set_proc_id
--      IF p_set_proc_id IS NULL
--      THEN
--         l_message := 'Set_proc_id can not be Null';
--         l_error := TRUE;
--         RAISE e_validation;
--      END IF;

      -- Validating Cogs ACcount
      IF p_cogs_account IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM gl_code_combinations_v
          WHERE p_cogs_account =
                      segment1
                   || '.'
                   || segment2
                   || '.'
                   || segment3
                   || '.'
                   || segment4
                   || '.'
                   || segment5
                   || '.'
                   || segment6
                   || '.'
                   || segment7
                   || '.'
                   || segment8
                   || '.'
                   || segment9
            AND account_type = 'E';

         IF l_count = 0
         THEN
            l_message := 'Cogs_Account not found for No - ' || p_cogs_account;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

-- Validating Sales_Account
      IF p_sales_account IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM gl_code_combinations_v
          WHERE p_sales_account =
                      segment1
                   || '.'
                   || segment2
                   || '.'
                   || segment3
                   || '.'
                   || segment4
                   || '.'
                   || segment5
                   || '.'
                   || segment6
                   || '.'
                   || segment7
                   || '.'
                   || segment8
                   || '.'
                   || segment9
            AND account_type = 'R';

         IF l_count = 0
         THEN
            l_message :=
                       'Sales_Account not found for No - ' || p_sales_account;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

-- Validating Primary UOM
      IF p_primary_uom IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_units_of_measure_vl
          WHERE uom_code = p_primary_uom;

         IF l_count = 0
         THEN
            l_message :=
                     'Primary UOM unit not found for Value ' || p_primary_uom;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

-- Validating Secondary UOM
      IF p_secondary_uom IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_units_of_measure_vl
          WHERE uom_code = p_secondary_uom;

         IF l_count = 0
         THEN
            l_message :=
                 'Secondary UOM unit not found for Value ' || p_secondary_uom;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

--Validating Sales_Ctaegory_Name
      IF p_sales_category_set IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Order Entry'
            AND mtlcs.category_set_name = p_sales_category_set;

         IF l_count = 0
         THEN
            l_message :=
                    'Sales Category Set not Found - ' || p_sales_category_set;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

--Validating Sales_segment1
      IF p_sales_category_segment1 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Order Entry'
            AND mtlk.segment1 = p_sales_category_segment1;

         IF l_count = 0
         THEN
            l_message :=
                   'Sales Segment1 not found - ' || p_sales_category_segment1;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

--Validating Sales_segment2
      IF p_sales_category_segment2 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Order Entry'
            AND mtlk.segment2 = p_sales_category_segment2;

         IF l_count = 0
         THEN
            l_message :=
                   'Sales Segment2 not found - ' || p_sales_category_segment2;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

      IF p_sales_category_set IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Order Entry'
            AND mtlk.segment1 = p_sales_category_segment1
            AND mtlk.segment2 = p_sales_category_segment2;

         IF l_count = 0
         THEN
            l_message :=
                  'Sales Category Combination not found - '
               || p_sales_category_segment1
               || '.'
               || p_sales_category_segment2;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

      --Validating Inventory_category_name and its segment
      IF p_inv_category_set IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Inventory'
            AND mtlcs.category_set_name = p_inv_category_set;

         IF l_count = 0
         THEN
            l_message :=
                  'Inventory Category Set not found - ' || p_inv_category_set;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

--Validating Item_Category_Segment_1
      IF p_item_category_segment1 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Inventory'
            AND mtlk.segment1 = p_item_category_segment1;

         IF l_count = 0
         THEN
            l_message :=
                  'Item_category_segment_1 not found - '
               || p_item_category_segment1;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

--Validating Item_Category_Segment_2
      IF p_item_category_segment2 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Inventory'
            AND mtlk.segment2 = p_item_category_segment2;

         IF l_count = 0
         THEN
            l_message :=
                  'Item_category_segment_2 not found - '
               || p_item_category_segment2;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

--Validating Item_Category_Segment_3
      IF p_item_category_segment3 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Inventory'
            AND mtlk.segment3 = p_item_category_segment3;

         IF l_count = 0
         THEN
            l_message :=
                  'Item_category_segment_3 not found - '
               || p_item_category_segment3;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

--Validating Item_Category_Segment_4
      IF p_item_category_segment4 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Inventory'
            AND mtlk.segment4 = p_item_category_segment4;

         IF l_count = 0
         THEN
            l_message :=
                  'Item_category_segment_4 not found -'
               || p_item_category_segment4;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

      IF p_inv_category_set IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk,
                mtl_category_sets mtlcs,
                mtl_default_category_sets_fk_v mtldcsf
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_id = mtldcsf.category_set_id
            AND mtldcsf.functional_area_desc = 'Inventory'
            AND mtlk.segment1 = p_item_category_segment1
            AND mtlk.segment2 = p_item_category_segment2
            AND mtlk.segment3 = p_item_category_segment3
            AND mtlk.segment4 = p_item_category_segment4;

         IF l_count = 0
         THEN
            l_message :=
                  'Item Category Combination not found -'
               || p_item_category_segment1
               || '.'
               || p_item_category_segment2
               || '.'
               || p_item_category_segment3
               || '.'
               || p_item_category_segment4;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

-- Validating Plan Category Set
      IF p_plan_cat_set IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk, mtl_category_sets mtlcs
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_name = p_plan_cat_set;

         IF l_count = 0
         THEN
            l_message := 'Plan Category Set not Found - ' || p_plan_cat_set;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

-- Validating Plan Category Segment1
      IF p_pln_item_category_segment1 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk, mtl_category_sets mtlcs
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_name = 'DBL_SALES_PLAN_CAT'
            AND mtlk.segment1 = p_pln_item_category_segment1;

         IF l_count = 0
         THEN
            l_message :=
                  'p_pln_item_category_segment1 not Found - '
               || p_pln_item_category_segment1;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

-- Validating Plan Category Segment2
      IF p_pln_item_category_segment2 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk, mtl_category_sets mtlcs
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_name = 'DBL_SALES_PLAN_CAT'
            AND mtlk.segment2 = p_pln_item_category_segment2;

         IF l_count = 0
         THEN
            l_message :=
                  'p_pln_item_category_segment2 not Found - '
               || p_pln_item_category_segment2;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

-- Validating Plan Category Segment3
      IF p_pln_item_category_segment3 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk, mtl_category_sets mtlcs
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_name = 'DBL_SALES_PLAN_CAT'
            AND mtlk.segment3 = p_pln_item_category_segment3;

         IF l_count = 0
         THEN
            l_message :=
                  'p_pln_item_category_segment3 not Found - '
               || p_pln_item_category_segment3;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

-- Validating Plan Category Segment4
      IF p_pln_item_category_segment4 IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk, mtl_category_sets mtlcs
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_name = 'DBL_SALES_PLAN_CAT'
            AND mtlk.segment4 = p_pln_item_category_segment4;

         IF l_count = 0
         THEN
            l_message :=
                  'p_pln_item_category_segment4 not Found-'
               || p_pln_item_category_segment4;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

      IF p_plan_cat_set IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO l_count
           FROM mtl_categories_kfv mtlk, mtl_category_sets mtlcs
          WHERE mtlk.structure_id = mtlcs.structure_id
            AND mtlcs.category_set_name = 'DBL_SALES_PLAN_CAT'
            AND mtlk.segment1 = p_pln_item_category_segment1
            AND mtlk.segment2 = p_pln_item_category_segment2
            AND mtlk.segment3 = p_pln_item_category_segment3
            AND mtlk.segment4 = p_pln_item_category_segment4;

         IF l_count = 0
         THEN
            l_message :=
                  'Planning Category Combination not Found-'
               || p_pln_item_category_segment1
               || '.'
               || p_pln_item_category_segment2
               || '.'
               || p_pln_item_category_segment3
               || '.'
               || p_pln_item_category_segment4;
            l_error := TRUE;
            RAISE e_validation;
         END IF;
      END IF;

-- Inserting in the table
      IF p_set_proc_id IS NULL
      THEN
         IF xxdbl_set_process_id_4_item.l_proc_id IS NULL
         THEN
            SELECT xxdbl_set_process_id_s.NEXTVAL
              INTO xxdbl_set_process_id_4_item.l_proc_id
              FROM DUAL;

            IF xxdbl_set_process_id_4_item.l_proc_id IS NULL
            THEN
               l_message := 'Unable to get the value for p_set_proc_id';
               l_error := TRUE;
               RAISE e_validation;
            ELSE
               l_set_proc_id := xxdbl_set_process_id_4_item.l_proc_id;
               l_catalog_batch_number :=
                                        xxdbl_set_process_id_4_item.l_proc_id;
            END IF;
         ELSE
            l_set_proc_id := xxdbl_set_process_id_4_item.l_proc_id;
            l_catalog_batch_number := xxdbl_set_process_id_4_item.l_proc_id;
         END IF;
      ELSE
         l_catalog_batch_number := p_set_proc_id;
         l_set_proc_id := p_set_proc_id;
      END IF;

      IF l_error = FALSE
      THEN
         BEGIN
            INSERT INTO xxdbl_item_conv_stg
                        (new_at, item_code, item_description,
                         primary_uom, secondary_uom,
                         item_conversion_factor, organization_code,
                         item_template, inv_category_set,
                         item_category_segment1, item_category_segment2,
                         item_category_segment3, item_category_segment4,
                         sales_category_set, sales_category_segment1,
                         sales_category_segment2, cogs_account,
                         sales_account, rma_insp_reqd, supply_sub_inv,
                         supply_loc, yield_sub_inv, yield_loc,
                         status, status_message, attr_context,
                         legacy_item_code, product_line, set_proc_id,
                         fixed_lead_time, fixed_days_supply,
                         plan_cat_set, pln_item_category_segment1,
                         pln_item_category_segment2,
                         pln_item_category_segment3,
                         pln_item_category_segment4, planner,
                         item_type, long_description, weight_uom_code,
                         unit_weight, catalog_1_item_type,
                         catalog_2_art, catalog_3_length,
                         catalog_4_tkt, catalog_5_shade,
                         brand_short_code, tracking_uom_mode,
                         pricing_uom_mode, dye_house_kg_per_pkg,
                         status_catalog, status_message_catalog,
                         catalog_batch_no, hs_code
                        )
                 VALUES (p_new_at, p_item_code, p_item_description,
                         p_primary_uom, p_secondary_uom,
                         p_item_conversion_factor, p_organization_code,
                         p_item_template, p_inv_category_set,
                         p_item_category_segment1, p_item_category_segment2,
                         p_item_category_segment3, p_item_category_segment4,
                         p_sales_category_set, p_sales_category_segment1,
                         p_sales_category_segment2, p_cogs_account,
                         p_sales_account, p_rma_insp_reqd, p_supply_sub_inv,
                         p_supply_loc, p_yield_sub_inv, p_yield_loc,
                         p_status, p_status_message, p_attr_context,
                         p_legacy_item_code, p_product_line, l_set_proc_id,
                         p_fixed_lead_time, p_fixed_days_supply,
                         p_plan_cat_set, p_pln_item_category_segment1,
                         p_pln_item_category_segment2,
                         p_pln_item_category_segment3,
                         p_pln_item_category_segment4, p_planner,
                         p_item_type, p_long_description, p_weight_uom_code,
                         p_unit_weight, p_catalog_1_item_type,
                         p_catalog_2_art, p_catalog_3_length,
                         p_catalog_4_tkt, p_catalog_5_shade,
                         p_brand_short_code, p_tracking_uom_mode,
                         p_pricing_uom_mode, p_dye_house_kg_per_pkg,
                         p_status_catalog, p_status_message_catalog,
                         l_catalog_batch_number, p_hs_code
                        );
         END;
      END IF;
   EXCEPTION
      WHEN e_validation
      THEN
--            fnd_message.set_name('XXDBL', 'XXDBL_ITEM_CUSTOM_MSG');
--            fnd_message.set_token('ERROR_MESSAGE', 'Error in Validation - ' || l_message);
--            l_temp := fnd_message.get;
--            fnd_message.raise_error;
--            raise_application_error(-20119, l_temp);
         raise_application_error (-20102, l_message);
      WHEN OTHERS
      THEN
         l_message := SUBSTRB ('Error in inserting in ' || SQLERRM, 1, 200);
--            fnd_message.set_name('XXDBL', 'XXDBL_ITEM_CUSTOM_MSG');
--            fnd_message.set_token('ERROR_MESSAGE', 'Error in Validation - ' || l_message);
--            l_temp := fnd_message.get;
--            fnd_message.raise_error;
--            raise_application_error(-20117, l_temp);
         raise_application_error (-20001, l_message, TRUE);
   END;
END xx_dbl_item_template;
/
