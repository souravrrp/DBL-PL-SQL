CREATE OR REPLACE PROCEDURE APPS.xxdbl_item_conv_prc (
   p_commit_level IN BOOLEAN DEFAULT FALSE)
IS
   TYPE item_interface_typ IS TABLE OF mtl_system_items_interface%ROWTYPE
                                 INDEX BY BINARY_INTEGER;

   TYPE item_cat_interface_typ IS TABLE OF mtl_item_categories_interface%ROWTYPE
                                     INDEX BY BINARY_INTEGER;

   l_item_int_tbl       item_interface_typ;
   l_category_int_tbl   item_cat_interface_typ;

   CURSOR cur_stg (
      p_org_code IN VARCHAR2 DEFAULT NULL)
   IS
      SELECT pw.ROWID rx, pw.*
        FROM xxdbl.xxdbl_item_master_conv pw
       WHERE 1 = 1 AND NVL (pw.status, 'X') NOT IN ('I', 'S', 'D')
             --AND pw.item_code LIKE 'YRN%'
             AND ( (p_org_code IS NULL AND pw.organization_code != 'IMO')
                  OR pw.organization_code = p_org_code)
             AND NOT EXISTS
                   (SELECT 1
                      FROM mtl_system_items_b msb, mtl_parameters mp
                     WHERE     msb.organization_id = mp.organization_id
                           AND msb.segment1 = pw.item_code
                           AND mp.organization_code = pw.organization_code);

   --  AND ROWNUM <= 2;

   i                    INTEGER := 0;
   l_set_process_id     NUMBER := 1000;
   l_error              VARCHAR2 (4000);
   l_process            VARCHAR2 (1);
BEGIN
   FOR r IN cur_stg ('IMO')
   -- Only process Item Master records ---
   LOOP
      i := i + 1;
      l_item_int_tbl (i).transaction_type := 'CREATE';
      l_item_int_tbl (i).set_process_id := l_set_process_id;
      l_item_int_tbl (i).process_flag := 1;
      -----
      l_item_int_tbl (i).segment1 := r.item_code;
      l_item_int_tbl (i).description := r.item_description;
      l_item_int_tbl (i).long_description := r.item_description;
      l_item_int_tbl (i).primary_uom_code := r.primary_uom;
      l_item_int_tbl (i).secondary_uom_code := r.secondary_uom;
      l_item_int_tbl (i).organization_code := r.organization_code;
      l_item_int_tbl (i).lot_divisible_flag :=
         SUBSTR (UPPER (NVL (r.lot_divisible, 'N')), 1, 1);
      l_item_int_tbl (i).list_price_per_unit := r.list_price;
      l_item_int_tbl (i).full_lead_time := r.lead_time;
      l_item_int_tbl (i).item_catalog_group_name := r.item_category_segment4;


      BEGIN
         SELECT mp.process_enabled_flag
           INTO l_process
           FROM mtl_parameters mp
          WHERE mp.organization_code = l_item_int_tbl (i).organization_code;

         -- Deriving Template for Raw Materials (non- FG and non-Trading) ---
         IF l_process = 'Y'
         THEN
            IF r.secondary_uom IS NULL
            THEN
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name :=
                     'OPM RAW MATL SINGLE UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'OPM RAW MATL SINGLE UOM NO-LOT';
               END IF;
            ELSE
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name :=
                     'OPM RAW MATL DUAL UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'OPM RAW MATL DUAL UOM NO-LOT';
               END IF;
            END IF;
         ELSE
            IF r.secondary_uom IS NULL
            THEN
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name :=
                     'DIS RAW MATL SINGLE UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'DIS RAW MATL SINGLE UOM NO-LOT';
               END IF;
            ELSE
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name :=
                     'DIS RAW MATL DUAL UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'DIS RAW MATL DUAL UOM NO-LOT';
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20001,
               'failed to retrieve process flag for org '
               || l_item_int_tbl (i).organization_code);
      END;

      --- Continuing Template derivation for Trading type Item --
      IF UPPER (r.item_type) = 'TRADING'
      THEN
         IF UPPER (NVL (NVL (r.lot_controlled, 'NO'), 'No')) = 'YES'
         THEN
            l_item_int_tbl (i).template_name := 'DIS TRADING SINGLE UOM LOT';
         ELSE
            l_item_int_tbl (i).template_name :=
               'DIS TRADING SINGLE UOM NO-LOT';
         END IF;
      END IF;

      --- Continuing Template derivation for Spre  type Item --
      IF UPPER (r.item_type) = 'PURCHASE ITEM'
      THEN
         l_item_int_tbl (i).template_name := 'DBL Spares and Civil Item';
      END IF;

      --- Continuing Template derivation for FG type Item --
      IF UPPER (r.item_type) = 'FINISH GOODS'
      THEN
         IF l_process = 'Y'
         THEN
            IF r.secondary_uom IS NULL
            THEN
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name := 'OPM FG SINGLE UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'OPM FG  SINGLE UOM NO-LOT';
               END IF;
            ELSE
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name := 'OPM FG DUAL UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name := 'OPM FG DUAL UOM NO-LOT';
               END IF;
            END IF;
         END IF;
      END IF;

      BEGIN
         SELECT template_id
           INTO l_item_int_tbl (i).template_id
           FROM mtl_item_templates
          WHERE template_name = l_item_int_tbl (i).template_name;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20004,
               'failed to validate template '
               || l_item_int_tbl (i).template_name);
      END;

      l_item_int_tbl (i).attribute14 := l_item_int_tbl (i).template_name;
      ----
      l_item_int_tbl (i).lot_control_code := 1;

      IF SUBSTR (UPPER (NVL (r.lot_controlled, 'NO')), 1, 1) = 'Y'
      THEN
         l_item_int_tbl (i).lot_control_code := 2;
      END IF;

      /*IF r.secondary_uom IS NULL
      THEN
         l_item_int_tbl (i).dual_uom_control := 1;
         l_item_int_tbl (i).tracking_quantity_ind := 'P';
         l_item_int_tbl (i).secondary_default_ind := '';
         l_item_int_tbl (i).dual_uom_deviation_high := 0;
         l_item_int_tbl (i).dual_uom_deviation_low := 0;
      ELSE
         l_item_int_tbl (i).dual_uom_control := 1;
         l_item_int_tbl (i).tracking_quantity_ind := 'PS';
         l_item_int_tbl (i).secondary_default_ind := 'D';
         l_item_int_tbl (i).dual_uom_deviation_high := 500;
         l_item_int_tbl (i).dual_uom_deviation_low := 100;
      END IF;*/

      -------------
      -------------
      l_category_int_tbl (i).transaction_type := 'CREATE';
      l_category_int_tbl (i).set_process_id := l_set_process_id;
      l_category_int_tbl (i).process_flag := 1;
      -----
      l_category_int_tbl (i).organization_code := r.organization_code;
      l_category_int_tbl (i).item_number := r.item_code;
      /*l_category_int_tbl (i).category_name :=
            r.item_category_segment1
         || '.'
         || r.item_category_segment2
         || '.'
         || r.item_category_segment3
         || '.'
         || r.item_category_segment4;*/
      l_category_int_tbl (i).category_set_name := 'Inventory';

      BEGIN
         SELECT mc.category_id
           INTO l_category_int_tbl (i).category_id
           FROM mtl_categories_kfv mc, mtl_category_sets mcs
          WHERE mcs.structure_id = mc.structure_id
                AND mcs.category_set_name =
                      l_category_int_tbl (i).category_set_name
                AND mc.concatenated_segments =
                         TRIM (r.item_category_segment1)
                      || '.'
                      || TRIM (r.item_category_segment2)
                      || '.'
                      || TRIM (r.item_category_segment3)
                      || '.'
                      || TRIM (r.item_category_segment4);
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20002,
                  'failed to retrieve category_id for '
               || r.item_category_segment1
               || '.'
               || r.item_category_segment2
               || '.'
               || r.item_category_segment3
               || '.'
               || r.item_category_segment4
               || ' - '
               || SQLERRM);
      END;
   END LOOP cur_stg;

   ----------------
   l_set_process_id := 1001;

   FOR r IN cur_stg
   -- Process Org Items ---
   LOOP
      i := i + 1;
      l_set_process_id := TO_NUMBER (r.organization_code);
      l_item_int_tbl (i).transaction_type := 'CREATE';
      l_item_int_tbl (i).set_process_id := l_set_process_id;
      l_item_int_tbl (i).process_flag := 1;
      -----
      l_item_int_tbl (i).segment1 := r.item_code;
      l_item_int_tbl (i).description := r.item_description;
      l_item_int_tbl (i).long_description := r.item_description;
      l_item_int_tbl (i).primary_uom_code := r.primary_uom;
      l_item_int_tbl (i).secondary_uom_code := r.secondary_uom;
      l_item_int_tbl (i).organization_code := r.organization_code;
      l_item_int_tbl (i).lot_divisible_flag :=
         SUBSTR (UPPER (NVL (r.lot_divisible, 'N')), 1, 1);
      l_item_int_tbl (i).list_price_per_unit := NVL (r.list_price, 1);
      l_item_int_tbl (i).full_lead_time := r.lead_time;

      l_item_int_tbl (i).attribute15 := R.LEGACY_ITEM_CODE;

      BEGIN
         SELECT mp.process_enabled_flag
           INTO l_process
           FROM mtl_parameters mp
          WHERE mp.organization_code = l_item_int_tbl (i).organization_code;

         -- Deriving Template for Raw Materials (non- FG and non-Trading) ---
         IF l_process = 'Y'
         THEN
            IF r.secondary_uom IS NULL
            THEN
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name :=
                     'OPM RAW MATL SINGLE UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'OPM RAW MATL SINGLE UOM NO-LOT';
               END IF;
            ELSE
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name :=
                     'OPM RAW MATL DUAL UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'OPM RAW MATL DUAL UOM NO-LOT';
               END IF;
            END IF;
         ELSE
            IF r.secondary_uom IS NULL
            THEN
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name :=
                     'DIS RAW MATL SINGLE UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'DIS RAW MATL SINGLE UOM NO-LOT';
               END IF;
            ELSE
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name :=
                     'DIS RAW MATL DUAL UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'DIS RAW MATL DUAL UOM NO-LOT';
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20001,
               'failed to retrieve process flag for org '
               || l_item_int_tbl (i).organization_code);
      END;

      --- Continuing Template derivation for Trading type Item --
      IF UPPER (r.item_type) = 'TRADING'
      THEN
         IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
         THEN
            l_item_int_tbl (i).template_name := 'DIS TRADING SINGLE UOM LOT';
         ELSE
            l_item_int_tbl (i).template_name :=
               'DIS TRADING SINGLE UOM NO-LOT';
         END IF;
      END IF;

      --- Continuing Template derivation for FG type Item --
      IF UPPER (r.item_type) = 'FINISH GOODS'
      THEN
         IF l_process = 'Y'
         THEN
            IF r.secondary_uom IS NULL
            THEN
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name := 'OPM FG SINGLE UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name :=
                     'OPM FG  SINGLE UOM NO-LOT';
               END IF;
            ELSE
               IF UPPER (NVL (r.lot_controlled, 'NO')) = 'YES'
               THEN
                  l_item_int_tbl (i).template_name := 'OPM FG DUAL UOM LOT';
               ELSE
                  l_item_int_tbl (i).template_name := 'OPM FG DUAL UOM NO-LOT';
               END IF;
            END IF;
         END IF;
      END IF;

      --- Continuing Template derivation for Spre  type Item --
      IF UPPER (r.item_type) = 'PURCHASE ITEM'
      THEN
         l_item_int_tbl (i).template_name := 'DBL Spares and Civil Item';
      END IF;

      BEGIN
         SELECT template_id
           INTO l_item_int_tbl (i).template_id
           FROM mtl_item_templates
          WHERE template_name = l_item_int_tbl (i).template_name;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20004,
               'failed to validate template '
               || l_item_int_tbl (i).template_name);
      END;

      l_item_int_tbl (i).attribute14 := l_item_int_tbl (i).template_name;
      ----
      l_item_int_tbl (i).lot_control_code := 1;

      IF SUBSTR (UPPER (NVL (r.lot_controlled, 'N')), 1, 1) = 'Y'
      THEN
         l_item_int_tbl (i).lot_control_code := 2;
      END IF;

      /*IF r.secondary_uom IS NULL
      THEN
         l_item_int_tbl (i).dual_uom_control := 1;
         l_item_int_tbl (i).tracking_quantity_ind := 'P';
         l_item_int_tbl (i).secondary_default_ind := '';
         l_item_int_tbl (i).dual_uom_deviation_high := 0;
         l_item_int_tbl (i).dual_uom_deviation_low := 0;
      ELSE
         l_item_int_tbl (i).dual_uom_control := 1;
         l_item_int_tbl (i).tracking_quantity_ind := 'PS';
         l_item_int_tbl (i).secondary_default_ind := 'D';
         l_item_int_tbl (i).dual_uom_deviation_high := 500;
         l_item_int_tbl (i).dual_uom_deviation_low := 100;
      END IF;*/

      -------------
      -------------
      l_category_int_tbl (i).transaction_type := 'CREATE';
      l_category_int_tbl (i).set_process_id := l_set_process_id;
      l_category_int_tbl (i).process_flag := 1;
      -----
      l_category_int_tbl (i).organization_code := r.organization_code;
      l_category_int_tbl (i).item_number := r.item_code;
      /*l_category_int_tbl (i).category_name :=
            r.item_category_segment1
         || '.'
         || r.item_category_segment2
         || '.'
         || r.item_category_segment3
         || '.'
         || r.item_category_segment4;*/
      l_category_int_tbl (i).category_set_name := 'Inventory';

      BEGIN
         SELECT mc.category_id
           INTO l_category_int_tbl (i).category_id
           FROM mtl_categories_kfv mc, mtl_category_sets mcs
          WHERE mcs.structure_id = mc.structure_id
                AND mcs.category_set_name =
                      l_category_int_tbl (i).category_set_name
                AND mc.concatenated_segments =
                         TRIM (r.item_category_segment1)
                      || '.'
                      || TRIM (r.item_category_segment2)
                      || '.'
                      || TRIM (r.item_category_segment3)
                      || '.'
                      || TRIM (r.item_category_segment4);
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error (
               -20002,
                  'failed to retrieve category_id for '
               || r.item_category_segment1
               || '.'
               || r.item_category_segment2
               || '.'
               || r.item_category_segment3
               || '.'
               || r.item_category_segment4
               || ' - '
               || SQLERRM);
      END;
   END LOOP cur_stg;

   ----------------
   FOR j IN 1 .. i
   LOOP
      BEGIN
         SAVEPOINT xx_item;

         INSERT INTO mtl_system_items_interface
             VALUES l_item_int_tbl (j);

         INSERT INTO mtl_item_categories_interface
             VALUES l_category_int_tbl (j);

         UPDATE xxdbl.xxdbl_item_master_conv pw
            SET pw.status = 'I',
                pw.status_message = 'INTERFACED',
                pw.TEMPLATE = l_item_int_tbl (j).template_name
          WHERE pw.item_code = l_item_int_tbl (j).segment1
                AND pw.organization_code =
                      l_item_int_tbl (j).organization_code;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK TO SAVEPOINT xx_item;
            l_error := SUBSTRB ('ERROR: ' || SQLERRM, 1, 4000);

            UPDATE xxdbl.xxdbl_item_master_conv pw
               SET pw.status = 'E', pw.status_message = l_error
             WHERE pw.item_code = l_item_int_tbl (j).segment1
                   AND pw.organization_code =
                         l_item_int_tbl (j).organization_code;
      END;
   END LOOP;

   IF p_commit_level
   THEN
      COMMIT;
   END IF;

   l_item_int_tbl.DELETE;
   l_category_int_tbl.DELETE;
EXCEPTION
   WHEN OTHERS
   THEN
      l_item_int_tbl.DELETE;
      l_category_int_tbl.DELETE;
      RAISE;
END xxdbl_item_conv_prc;
/