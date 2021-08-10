CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_thd_exp_allocation_pkg
AS
   PROCEDURE writeout (p_text VARCHAR2)
   IS
   BEGIN
      fnd_file.put_line (fnd_file.output, p_text);
   END writeout;

   PROCEDURE writelog (p_text VARCHAR2)
   IS
   BEGIN
      fnd_file.put_line (fnd_file.LOG, p_text);
   END writelog;

   PROCEDURE main (
      x_retcode           OUT NOCOPY      NUMBER,
      x_errbuf            OUT NOCOPY      VARCHAR2,
      p_year              IN              VARCHAR2,
      p_period            IN              VARCHAR2,
      p_organization_id   IN              VARCHAR2,
      p_allocation_code   IN              VARCHAR2
   )
   IS
      l_start_date          DATE;
      l_end_date            DATE;
      l_product_type        VARCHAR2 (240);
      l_size                VARCHAR2 (240);
      l_factor              VARCHAR2 (240);
      l_count               NUMBER;
      l_error               VARCHAR (1000);
      l_organization_id     NUMBER;
      l_final_cost          NUMBER;
      l_item_status         VARCHAR2 (1);
      l_run_id              NUMBER;
      l_tot_amount          NUMBER;
      l_percent             NUMBER;
      l_allocation_id       NUMBER         := 0;
      --
      l_capacity            NUMBER;
      l_capacity_calc       NUMBER;
      --
      l_remain_percent      NUMBER;
      l_tot_fixed_percent   NUMBER;
      l_inventory_item_id   NUMBER;
      -- Added by  Manas on 11-Nov-2020 Starts
      l_user_id             NUMBER;
      l_date                DATE;

      -- Added by  Manas on 11-Nov-2020 Ends
      CURSOR c_all_allocation (
         p_start_date          IN   DATE,
         p_end_date            IN   DATE,
         p_alloc_id                 NUMBER,
         p_alloc_line_number        VARCHAR2
      )
      IS
         SELECT   msi.inventory_item_id, msi.item_code item_no, msi.cat_seg1,
                  msi.cat_seg3, msi.cat_seg4,
                  SUM
                     (DECODE (msi.primary_uom_code,
                              'CON', mmt.secondary_transaction_quantity,
                              mmt.primary_quantity
                             )
                     ) primary_quantity
             FROM ((SELECT *
                      FROM xxdbl_item_details_temp)) msi,
                  mtl_material_transactions mmt,
                  mtl_transaction_types mtt,
                  gme.gme_batch_header ghdr,
                  gme.gme_material_details gdet,
                  mtl_system_items_b msim,
                  gme.gme_batch_groups_association gro,
                  gme_batch_groups_vl gvl
            WHERE 1 = 1
              AND mmt.inventory_item_id = msi.inventory_item_id
              AND mmt.organization_id = msi.organization_id
              AND msi.organization_id = p_organization_id
              AND mtt.transaction_type_id = mmt.transaction_type_id
              AND mtt.transaction_type_name IN
                                  ('WIP Completion', 'WIP Completion Return')
              AND mmt.transaction_source_id = ghdr.batch_id
              AND mmt.trx_source_line_id = gdet.material_detail_id
              AND ghdr.batch_id = gdet.batch_id
              AND ghdr.organization_id = gdet.organization_id
              AND msi.inventory_item_id = msim.inventory_item_id
              AND msi.organization_id = msim.organization_id
              AND TRUNC (mmt.transaction_date) BETWEEN TRUNC (p_start_date)
                                                   AND TRUNC (p_end_date)
              AND EXISTS (
                     SELECT 'X'
                       FROM xxdbl_alloc_inventory_temp xx3
                      WHERE 1 = 1
                        AND xx3.alloc_id = NVL (p_alloc_id, xx3.alloc_id)
                        AND xx3.inventory_item_id = msi.inventory_item_id)
              AND ghdr.batch_id = gro.batch_id
              AND gro.GROUP_ID = gvl.GROUP_ID
              AND gvl.group_name NOT LIKE 'OPEN_WIP_BATCH%'
         GROUP BY msi.inventory_item_id,
                  msi.item_code,
                  msi.cat_seg1,
                  msi.cat_seg3,
                  msi.cat_seg4
                              -- Old
                              /*(SELECT   msi.inventory_item_id, msi.item_code item_no,
                                        msi.cat_seg1, msi.cat_seg3, msi.cat_seg4,
                                        SUM
                                           (DECODE (msi.primary_uom_code,
                                                    'CON', mmt.secondary_transaction_quantity,
                                                    mmt.primary_quantity
                                                   )
                                           ) primary_quantity
                                   FROM ((SELECT msib.segment1 item_code, msib.inventory_item_id,
                                                 msib.organization_id, mc.segment1 cat_seg1,
                                                 mc.segment3 cat_seg3, mc.segment4 cat_seg4,
                                                 msib.primary_uom_code
                                            FROM mtl_system_items_b msib,
                                                 mtl_item_categories mic,
                                                 mtl_categories mc,
                                                 mtl_category_sets mcs
                                           WHERE msib.inventory_item_id = mic.inventory_item_id(+)
                                             AND msib.organization_id = mic.organization_id
                                             AND msib.organization_id = p_organization_id
                                             AND mic.category_id = mc.category_id
                                             AND mic.category_set_id = mcs.category_set_id
                                             AND mcs.category_set_name = 'DBL_SALES_PLAN_CAT')) msi,
                                        mtl_material_transactions mmt,
                                        mtl_transaction_types mtt,
                                        gme.gme_batch_header ghdr,
                                        gme.gme_material_details gdet,
                                        mtl_system_items_b msim,
                                        gme.gme_batch_groups_association gro,
                                        -- added by Mani and Siba on 19-Dec-19
                                        gme_batch_groups_vl gvl
                                  -- added by Mani and Siba on 19-Dec-19
                               WHERE    1 = 1
                                    AND ghdr.batch_id = gdet.batch_id
                                    AND mmt.trx_source_line_id = gdet.material_detail_id
                                    AND mmt.transaction_source_id = ghdr.batch_id
                                    AND mtt.transaction_type_name IN
                                                       ('WIP Completion', 'WIP Completion Return')
                                    AND mtt.transaction_type_id = mmt.transaction_type_id
                                    AND msi.organization_id = p_organization_id
                                    AND mmt.inventory_item_id = msi.inventory_item_id
                                    AND msi.organization_id = mmt.organization_id
                                    AND msi.inventory_item_id = msim.inventory_item_id
                                    AND msi.organization_id = msim.organization_id
                                    AND TRUNC (mmt.transaction_date) BETWEEN TRUNC (p_start_date)
                                                                         AND TRUNC (p_end_date)
                                    AND EXISTS (
                                           SELECT 'X'
                                             FROM gmf.gl_aloc_mst gmst, gmf.gl_aloc_bas gbas
                                            WHERE 1 = 1
                                              AND gbas.alloc_id = gmst.alloc_id
                                              AND gmst.alloc_id = NVL (p_alloc_id, gmst.alloc_id)
                                              AND gbas.inventory_item_id = msi.inventory_item_id)
                                    AND ghdr.batch_id = gro.batch_id
                                    AND gro.GROUP_ID = gvl.GROUP_ID
                                    AND gvl.group_name NOT LIKE 'OPEN_WIP_BATCH%'
                               --- Mani Added on 18-DEC-2019 -- Discussed with Sibu Da and Sanjoy Da ---
                                    --and msi.item_code = 'ES01110-A2326'
                               GROUP BY msi.inventory_item_id,
                                        msi.item_code,
                                        msi.cat_seg1,
                                        msi.cat_seg3,
                                        msi.cat_seg4)*/
      ;
   BEGIN
      SELECT   start_date, end_date
          INTO l_start_date, l_end_date
          FROM gl_periods
         WHERE period_set_name = 'DBL BD Calendar'
           AND UPPER (entered_period_name) NOT LIKE '%ADJ%'
           AND period_year = p_year
           AND period_name = p_period
      ORDER BY period_year, period_num;

      writelog (   'Start Date - '
                || l_start_date
                || ' and End Date - '
                || l_end_date
               );

      SELECT xxdbl_thd_expense_alloc_s.NEXTVAL
        INTO l_run_id
        FROM DUAL;

      writelog ('Sequence Number - ' || l_run_id);

      INSERT INTO xxdbl_gl_aloc_mst_temp
         SELECT alloc_id, attribute1 alloc_line_number, alloc_code
           FROM gmf.gl_aloc_mst
          WHERE alloc_code = NVL (p_allocation_code, alloc_code);

      INSERT INTO xxdbl_item_details_temp
         SELECT msib.segment1 item_code, msib.inventory_item_id,
                msib.organization_id, mc.segment1 cat_seg1,
                mc.segment3 cat_seg3, mc.segment4 cat_seg4,
                msib.primary_uom_code
           FROM mtl_system_items_b msib,
                mtl_item_categories mic,
                mtl_categories mc,
                mtl_category_sets mcs
          WHERE msib.inventory_item_id = mic.inventory_item_id(+)
            AND msib.organization_id = mic.organization_id
            AND msib.organization_id = p_organization_id
            AND mic.category_id = mc.category_id
            AND mic.category_set_id = mcs.category_set_id
            AND mcs.category_set_name = 'DBL_SALES_PLAN_CAT';

      INSERT INTO xxdbl_alloc_inventory_temp
         SELECT   gmst.alloc_id, gbas.inventory_item_id
             FROM gmf.gl_aloc_mst gmst, gmf.gl_aloc_bas gbas
            WHERE 1 = 1 AND gbas.alloc_id = gmst.alloc_id
--AND gmst.alloc_id = NVL (68, gmst.alloc_id)
--AND gbas.inventory_item_id = msi.inventory_item_id
         GROUP BY gmst.alloc_id, gbas.inventory_item_id;

      FOR c1 IN
         (SELECT *
            FROM xxdbl_gl_aloc_mst_temp                                    /*SELECT alloc_id, attribute1 alloc_line_number, alloc_code
                                         FROM gmf.gl_aloc_mst
                                        WHERE alloc_code = NVL (p_allocation_code, alloc_code)*/)
      LOOP
         writelog (   'Allocation ID - '
                   || c1.alloc_id
                   || ' Allocation Code - '
                   || c1.alloc_code
                  );

         FOR r1 IN c_all_allocation (l_start_date,
                                     l_end_date,
                                     c1.alloc_id,
                                     c1.alloc_line_number
                                    )
         LOOP
            writelog ('Item Code - ' || r1.item_no);
            l_factor := NULL;
            l_final_cost := 0;
            l_item_status := 'S';
            l_error := NULL;
            l_capacity := 0;
            l_capacity_calc := 0;

            --Added by Ranjan--START----
            BEGIN
               SELECT qr.character5
                 INTO l_capacity
                 FROM qa_plans pl,
                      qa_results qr,
                      fnd_flex_values_vl ffv1,
                      fnd_flex_values_vl ffv2,
                      fnd_flex_values_vl ffv3
                WHERE 1 = 1
                  AND pl.plan_id = qr.plan_id
                  AND pl.NAME = 'ECO_THREAD_PLANT_CAPACITY'
                  AND qr.character1 = ffv1.attribute1
                  --AND qr.CHARACTER2 =ffv2.attribute1 -- SD 13-Sep-2019 commented
                  AND qr.character2 = ffv2.attribute2  -- SD 13-Sep-2019 added
                  AND qr.character3 = ffv3.attribute1
                  AND ffv1.flex_value_set_id = 1018071
                  -- this got changed in CRP as on 29-Nov-2019
                  AND ffv1.value_category = 'Thread Brand Short Code'
                  --AND ffv2.VALUE_CATEGORY = 'Thread Color Group' -- SD 13-Sep-2019 commented
                  AND ffv2.value_category = 'CCL2_YARN_PROCESS_LOSS'
                  -- SD 13-Sep-2019 addedd
                  AND ffv2.flex_value_set_id = 1017729
                  AND ffv3.value_category = 'Thread Line of Business'
                  AND ffv3.flex_value_set_id = 1018069
                  -- this got changed in CRP as on 29-Nov-2019
                  AND ffv3.flex_value = r1.cat_seg1        -- Line of business
                  AND ffv2.flex_value = r1.cat_seg3             -- Color Group
                  AND ffv1.flex_value = r1.cat_seg4;       -- Brand Short Code
            --Added by Ranjan--END----
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_error :=
                        l_error
                     || ' Capacity not found for Product Line -  '
                     || r1.cat_seg1
                     || ', Group -  '
                     || r1.cat_seg3
                     || ', Brand -  '
                     || r1.cat_seg4;
                  l_item_status := 'E';
                  l_capacity := 0;
            END;

            writelog ('Factor -' || l_capacity);

            IF l_item_status = 'E'
            THEN
               INSERT INTO xxdbl_thd_expense_alloc_status
                    VALUES (l_run_id, '', c1.alloc_code,
                            r1.inventory_item_id, 0, l_item_status, l_error,
                            1, c1.alloc_id, r1.item_no, 0, 0, 0);
            ELSE
               l_factor := l_capacity;                  -- / l_capacity_calc;

               INSERT INTO xxdbl_thd_expense_alloc_status
                    VALUES (l_run_id, '', c1.alloc_code,
                            r1.inventory_item_id,
                            l_factor * r1.primary_quantity, l_item_status,
                            l_error, 1, c1.alloc_id, r1.item_no,
                            l_factor * r1.primary_quantity, l_factor, 0);
            END IF;
         END LOOP;
      END LOOP;

      COMMIT;
      writeout
         ('----------------------------------------------------------------------------------------------------'
         );
      writeout
         ('++++++++++++++++++++++[    DBL Expense Allocation Update Program     ]++++++++++++++++++++++++++++++'
         );
      writeout
         ('----------------------------------------------------------------------------------------------------'
         );
      writeout
         ('                                      SUCCESS REPORT                                                '
         );
      writeout
         ('----------------------------------------------------------------------------------------------------'
         );
      writeout
         ('===================================================================================================='
         );
      writeout
         ('|   Allocation Code                     ||  Message                           '
         );
      writeout
         ('===================================================================================================='
         );
      l_allocation_id := 0;

      FOR r_main IN
         (SELECT   *
              FROM xxdbl_thd_expense_alloc_status
             WHERE run_id = l_run_id
               AND allocation_id NOT IN (
                                      SELECT DISTINCT allocation_id
                                                 FROM xxdbl_thd_expense_alloc_status
                                                WHERE run_id = l_run_id
                                                  AND status = 'E')
          ORDER BY allocation_id)
      LOOP
         l_tot_amount := 0;
         l_percent := 0;

         IF r_main.allocation_id <> l_allocation_id
         THEN
            UPDATE gmf.gl_aloc_bas
               SET fixed_percent = 0
             WHERE alloc_id = r_main.allocation_id;
         END IF;

         l_allocation_id := r_main.allocation_id;

         SELECT SUM (final_cost)
           INTO l_tot_amount
           FROM xxdbl_thd_expense_alloc_status
          WHERE run_id = l_run_id AND allocation_id = r_main.allocation_id;

         l_percent := ROUND (((r_main.final_cost / l_tot_amount) * 100), 10);

         --   l_percent := ((r_main.final_cost / l_tot_amount) * 100);

         --         UPDATE gl_aloc_bas
         --            SET fixed_percent = l_percent
         --          WHERE inventory_item_id = r_main.inventory_item_id
         --            AND alloc_id = r_main.allocation_id
         ----            AND legal_entity_id = r_main.legal_entity_id
         --         ;
         UPDATE xxdbl_thd_expense_alloc_status
            SET fixed_percent = l_percent
          WHERE inventory_item_id = r_main.inventory_item_id
            AND allocation_id = r_main.allocation_id;
      /*writeout (   '  '
                || RPAD (r_main.allocation_code, 20, ' ')
                || '  '
                || ' Item - '
                || r_main.item_no
                || ' Percentage - '
                || l_percent
                || '     '
               );
      writeout
         ('----------------------------------------------------------------------------------------------------'
         );*/
      END LOOP;

      COMMIT;
      /*FOR r1 IN
         (SELECT DISTINCT allocation_id
                     FROM xxdbl_thd_expense_alloc_status
                    WHERE run_id = l_run_id
                      AND allocation_id NOT IN (
                                      SELECT DISTINCT allocation_id
                                                 FROM xxdbl_thd_expense_alloc_status
                                                WHERE run_id = l_run_id
                                                  AND status = 'E')
                 ORDER BY allocation_id)
      LOOP
         l_remain_percent := 0;
         l_tot_fixed_percent := 0;
         l_inventory_item_id := NULL;

         SELECT SUM (fixed_percent)
           INTO l_tot_fixed_percent
           FROM xxdbl_thd_expense_alloc_status
          WHERE run_id = l_run_id AND allocation_id = r1.allocation_id;

         l_remain_percent := 100 - l_tot_fixed_percent;

         IF l_remain_percent <> 0
         THEN
            SELECT inventory_item_id
              INTO l_inventory_item_id
              FROM xxdbl_thd_expense_alloc_status
             WHERE run_id = l_run_id
               AND allocation_id = r1.allocation_id
               AND ROWNUM = 1;

            UPDATE xxdbl_thd_expense_alloc_status
               SET fixed_percent = fixed_percent + NVL (l_remain_percent, 0)
             WHERE inventory_item_id = l_inventory_item_id
               AND allocation_id = r1.allocation_id
               AND run_id = l_run_id;
         END IF;
      END LOOP;

      COMMIT;*/
      l_allocation_id := 0;

      FOR r_final IN
         (SELECT   *
              FROM xxdbl_thd_expense_alloc_status
             WHERE run_id = l_run_id
               AND allocation_id NOT IN (
                                      SELECT DISTINCT allocation_id
                                                 FROM xxdbl_thd_expense_alloc_status
                                                WHERE run_id = l_run_id
                                                  AND status = 'E')
          ORDER BY allocation_id)
      LOOP
         l_percent := r_final.fixed_percent;

         IF l_allocation_id <> r_final.allocation_id
         THEN
            UPDATE gmf.gl_aloc_bas
               SET fixed_percent = 0
             WHERE alloc_id = r_final.allocation_id;
         END IF;

-- Added by  Manas on 11-Nov-2020 Starts
         l_user_id := fnd_profile.VALUE ('USER_ID');
         l_date := SYSDATE;

-- Added by  Manas on 11-Nov-2020 Ends
         UPDATE gmf.gl_aloc_bas
            SET fixed_percent = l_percent,
                last_update_date =    -- Added by  Manas on 11-Nov-2020 Starts
                                                                        l_date,
                                                                   -- SYSDATE,
                -- Added by  Manas on 11-Nov-2020 Ends
                last_updated_by =
                                 -- Added by  Manas on 11-Nov-2020 Starts
                                 l_user_id    -- fnd_profile.VALUE ('USER_ID')
          -- Added by  Manas on 11-Nov-2020 Ends
         WHERE  inventory_item_id = r_final.inventory_item_id
            AND alloc_id = r_final.allocation_id
                                                --            AND legal_entity_id = r_main.legal_entity_id
         ;

         l_allocation_id := r_final.allocation_id;
         writeout (   '  '
                   || RPAD (r_final.allocation_code, 20, ' ')
                   || '  '
                   || ' Item - '
                   || r_final.item_no
                   || ' Percentage - '
                   || l_percent
                   || '     '
                  );
         writeout
            ('----------------------------------------------------------------------------------------------------'
            );
      END LOOP;

      COMMIT;

      FOR r1 IN
         (SELECT DISTINCT allocation_id
                     FROM xxdbl_thd_expense_alloc_status
                    WHERE run_id = l_run_id
                      AND allocation_id NOT IN (
                                      SELECT DISTINCT allocation_id
                                                 FROM xxdbl_thd_expense_alloc_status
                                                WHERE run_id = l_run_id
                                                  AND status = 'E')
                 ORDER BY allocation_id)
      LOOP
         l_remain_percent := 0;
         l_tot_fixed_percent := 0;
         l_inventory_item_id := NULL;

         SELECT SUM (fixed_percent)
           INTO l_tot_fixed_percent
           FROM xxdbl_thd_expense_alloc_status
          WHERE run_id = l_run_id AND allocation_id = r1.allocation_id;

         l_remain_percent := 100 - l_tot_fixed_percent;

         IF l_remain_percent <> 0
         THEN
            SELECT inventory_item_id
              INTO l_inventory_item_id
              FROM xxdbl_thd_expense_alloc_status
             WHERE run_id = l_run_id
               AND allocation_id = r1.allocation_id
               AND ROWNUM = 1;

            UPDATE xxdbl_thd_expense_alloc_status
               SET fixed_percent = fixed_percent + NVL (l_remain_percent, 0)
             WHERE inventory_item_id = l_inventory_item_id
               AND allocation_id = r1.allocation_id
               AND run_id = l_run_id;
         END IF;
      END LOOP;

      COMMIT;
      writeout
         ('----------------------------------------------------------------------------------------------------'
         );
      writeout
         ('                                      ERROR REPORT                                                  '
         );
      writeout
         ('----------------------------------------------------------------------------------------------------'
         );
      writeout
         ('|   Allocation Code                     ||  Error Message                     '
         );
      writeout
         ('===================================================================================================='
         );

      FOR r_error IN
         (SELECT *
            FROM xxdbl_thd_expense_alloc_status
           WHERE run_id = l_run_id
             AND status = 'E'
             AND allocation_code IN (SELECT DISTINCT allocation_code
                                                FROM xxdbl_thd_expense_alloc_status
                                               WHERE run_id = l_run_id
                                                 AND status = 'E'))
      LOOP
         writeout (   '  '
                   || RPAD (r_error.allocation_code, 20, ' ')
                   || '  '
                   || r_error.error_message
                   || '     '
                  );
         writeout
            ('----------------------------------------------------------------------------------------------------'
            );
      END LOOP;

      writeout
         ('===================================================================================================='
         );
   EXCEPTION
      WHEN OTHERS
      THEN
         writelog ('Program in Exception - ' || SQLERRM);
   END;
END xxdbl_thd_exp_allocation_pkg;
/