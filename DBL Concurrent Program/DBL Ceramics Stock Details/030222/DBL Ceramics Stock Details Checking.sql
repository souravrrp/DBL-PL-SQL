/* Formatted on 2/3/2022 4:57:35 PM (QP5 v5.374) */
SELECT ood.organization_code,
       mmt.organization_id             org_id,
       msi.inventory_item_id           item_id,
       mic.segment2                    AS item_size,
       msi.attribute3                  AS item_type,
       msi.concatenated_segments       item_code,
       msi.description                 item_description,
       msi.primary_uom_code            AS p_uom,
       mmt.secondary_uom_code          AS s_uom,
       TRUNC (mlt.origination_date)    prod_date,
       mmt.subinventory_code,
       mlt.grade_code,
       mlt.lot_number,
       CASE SIGN (TRUNC (mmt.transaction_date) - ( :p_date_from - .99999))
           WHEN -1 THEN mtln.primary_quantity
           ELSE 0
       END                             open_bal_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1 THEN mtln.secondary_transaction_quantity
           ELSE 0
       END                             open_bal_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN mmt.transaction_type_id IN (17, 44)
                   THEN
                       mtln.primary_quantity
                   ELSE
                       0
               END
       END                             rcv_qty_prod_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN mmt.transaction_type_id IN (17, 44)
                   THEN
                       mtln.secondary_transaction_quantity
                   ELSE
                       0
               END
       END                             rcv_qty_prod_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 42 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             rcv_qty_misc_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 42 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             rcv_qty_misc_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 40 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             rcv_qty_misc_pp,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 40 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             rcv_qty_misc_ss,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN     mmt.transaction_type_id = 41
                        AND mmt.transaction_source_id NOT IN (864, 884)
                   THEN
                       mtln.primary_quantity
                   ELSE
                       0
               END
       END                             rcv_qty_misc_ppp,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN     mmt.transaction_type_id = 41
                        AND mmt.transaction_source_id NOT IN (864, 884)
                   THEN
                       mtln.secondary_transaction_quantity
                   ELSE
                       0
               END
       END                             rcv_qty_misc_sss,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 15 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             rcv_qty_rma_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 15 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             rcv_qty_rma_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 33 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             sales_qty_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 33 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             sales_qty_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN     mmt.transaction_type_id = 52
                        AND mmt.transaction_action_id = 28
                        AND mmt.transaction_source_type_id = 2
                   --AND SIGN (mtln.primary_quantity) = -1
                   THEN
                       mtln.primary_quantity
                   ELSE
                       0
               END
       END                             pick_qty_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN     mmt.transaction_type_id = 52
                        AND mmt.transaction_action_id = 28
                        AND mmt.transaction_source_type_id = 2
                   --AND SIGN (mtln.primary_quantity) = -1
                   THEN
                       mtln.secondary_transaction_quantity
                   ELSE
                       0
               END
       END                             pick_qty_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 35 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             wip_issue_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 35 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             wip_issue_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 32 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             issu_qty_misc_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 32 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             issu_qty_misc_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 864 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             broken_qty_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 864 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             broken_qty_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 804 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             r_handle_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 804 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             r_handle_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 884 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             sample_qty_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 884 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             sample_qty_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 904 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             broken_rec_qty_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 904 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             broken_rec_qty_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 1084 THEN mtln.primary_quantity
                   ELSE 0
               END
       END                             write_off_qty_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_source_id
                   WHEN 1084 THEN mtln.secondary_transaction_quantity
                   ELSE 0
               END
       END                             write_off_qty_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN     mmt.transaction_type_id = 41
                        AND mmt.transaction_source_id = 724
                        AND mmt.transaction_action_id = 27
                        AND mmt.transaction_source_type_id = 6
                   THEN
                       mtln.primary_quantity
                   ELSE
                       0
               END
       END                             short_excess_rcv_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN     mmt.transaction_type_id = 41
                        AND mmt.transaction_source_id = 724
                        AND mmt.transaction_action_id = 27
                        AND mmt.transaction_source_type_id = 6
                   THEN
                       mtln.secondary_transaction_quantity
                   ELSE
                       0
               END
       END                             short_excess_rcv_s,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN     mmt.transaction_type_id = 31
                        AND mmt.transaction_source_id = 724
                        AND mmt.transaction_action_id = 1
                        AND mmt.transaction_source_type_id = 6
                   THEN
                       mtln.primary_quantity
                   ELSE
                       0
               END
       END                             short_excess_qty_p,
       CASE SIGN (mtln.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE
                   WHEN     mmt.transaction_type_id = 31
                        AND mmt.transaction_source_id = 724
                        AND mmt.transaction_action_id = 1
                        AND mmt.transaction_source_type_id = 6
                   THEN
                       mtln.secondary_transaction_quantity
                   ELSE
                       0
               END
       END                             short_excess_qty_s,
       CASE SIGN (mmt.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 2 THEN mmt.primary_quantity
                   ELSE 0
               END
       END                             transfer_qty_p,
       CASE SIGN (mmt.transaction_date - :p_date_from)
           WHEN -1
           THEN
               0
           ELSE
               CASE mmt.transaction_type_id
                   WHEN 2 THEN mmt.secondary_transaction_quantity
                   ELSE 0
               END
       END                             transfer_qty_s
  --                 CASE SIGN (
  --                         TRUNC (mmt.transaction_date) - (:p_date_to + .99999))
  --                    WHEN -1
  --                    THEN
  --                       mtln.primary_quantity
  --                    ELSE
  --                       0
  --                 END
  --                    close_bal_p,
  --                 CASE SIGN (
  --                         TRUNC (mmt.transaction_date) - (:p_date_to + .99999))
  --                    WHEN -1
  --                    THEN
  --                       mtln.secondary_transaction_quantity
  --                    ELSE
  --                       0
  --                 END
  --                    close_bal_s
  FROM inv.mtl_material_transactions      mmt,
       inv.mtl_transaction_lot_numbers    mtln,
       inv.mtl_lot_numbers                mlt,
       apps.mtl_system_items_b_kfv        msi,
       apps.mtl_item_categories_v         mic,
       apps.org_organization_definitions  ood
 WHERE     mmt.inventory_item_id = msi.inventory_item_id
       AND mmt.organization_id = msi.organization_id
       AND msi.inventory_item_id = mic.inventory_item_id
       AND msi.organization_id = mic.organization_id
       AND mmt.organization_id = ood.organization_id
       AND mmt.inventory_item_id = mtln.inventory_item_id
       AND mmt.organization_id = mtln.organization_id
       AND mmt.transaction_id = mtln.transaction_id
       AND mlt.inventory_item_id = mtln.inventory_item_id
       AND mlt.organization_id = mtln.organization_id
       AND mlt.lot_number = mtln.lot_number
       AND mic.category_set_id = 1100000061
       AND mmt.transaction_type_id <> 98
       --and mlt.grade_code = 'A'
       AND (logical_transaction = 2 OR logical_transaction IS NULL)
       AND mmt.transaction_type_id NOT IN (80,
                                           120,
                                           --33,
                                           --52,
                                           26,
                                           64)
       AND mmt.subinventory_code IN ('CEM-REJECT',
                                     'CEM-STAG',
                                     'DBLCL-JKL2',
                                     'CEM-SAMPLE')
       AND msi.concatenated_segments =
           NVL ( :p_item, msi.concatenated_segments)
       AND mmt.subinventory_code =
           NVL ( :p_subinventory_code, mmt.subinventory_code)
       AND mmt.organization_id = 152
       AND mtln.transaction_date BETWEEN '01-JAN-2010'
                                     AND :p_date_to + .99999
       AND mmt.transaction_id IN (57137333, 56805410)