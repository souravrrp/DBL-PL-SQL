/* Formatted on 17-Dec-19 16:57:55 (QP5 v5.136.908.31019) */
  SELECT                                                        ---    ORG_ID,
        item_code,
         item_description,
         -- P_UOM,
         item_id,
         item_type,
         item_size,
         grade_code grade_num,
         lot_number,
         prod_date,
         NVL (SUM (open_bal_p), 0) puom_opbal,
         NVL (SUM (open_bal_s), 0) suom_opbal,
         NVL (SUM (open_bal_p), 0) * 0.092936803 muom_opbal,
         (NVL (SUM (rcv_qty_prod_p), 0)) rcvq_prod_p,
         (NVL (SUM (rcv_qty_prod_s), 0)) rcvq_prod_s,
         (NVL (SUM (rcv_qty_prod_p), 0)) * 0.092936803 rcvq_prod_sqm,
         (NVL (SUM (rcv_qty_misc_p), 0) + NVL (SUM (rcv_qty_misc_pp), 0))
            rcvq_misc_p,
         (NVL (SUM (rcv_qty_misc_s), 0) + NVL (SUM (rcv_qty_misc_ss), 0))
            rcvq_misc_s,
         (NVL (SUM (rcv_qty_misc_p), 0) + NVL (SUM (rcv_qty_misc_pp), 0))
         * 0.092936803
            rcvq_misc_sqm,
         NVL (SUM (rcv_qty_rma_p), 0) rcv_qty_rma_p,
         NVL (SUM (rcv_qty_rma_s), 0) rcv_qty_rma_s,
         NVL (SUM (rcv_qty_rma_p), 0) * 0.092936803 rcv_qty_rma_sqm,
         NVL (SUM (sales_qty_p), 0) puom_isuq,
         NVL (SUM (sales_qty_s), 0) suom_isuq,
         NVL (SUM (sales_qty_p), 0) * 0.092936803 muom_isuq,
         NVL (SUM (broken_qty_p), 0) puom_broken,
         NVL (SUM (broken_qty_s), 0) suom_broken,
         NVL (SUM (broken_qty_p), 0) * 0.092936803 muom_broken,
         NVL (SUM (issu_qty_misc_p), 0) puom_misc_issu,
         NVL (SUM (issu_qty_misc_s), 0) suom_misc_issu,
         NVL (SUM (issu_qty_misc_p), 0) * 0.092936803 muom_misc_issu,
         NVL (SUM (sample_qty_p), 0) puom_sample,
         NVL (SUM (sample_qty_s), 0) suom_sample,
         NVL (SUM (sample_qty_p), 0) * 0.092936803 muom_sample,
         NVL (SUM (broken_rec_qty_p), 0) puom_broken_rec,
         NVL (SUM (broken_rec_qty_s), 0) suom_broken_rec,
         NVL (SUM (broken_rec_qty_p), 0) * 0.092936803 muom_broken_rec,
         NVL (SUM (close_bal_p), 0) puom_cpbal,
         NVL (SUM (close_bal_s), 0) suom_cpbal,
         NVL (SUM (close_bal_p), 0) * 0.092936803 muom_cpbal
    --         (  NVL (SUM (open_bal_p), 0)
    --          + NVL (SUM (rcv_qty_prod_p), 0)
    --          + NVL (SUM (rcv_qty_misc_p), 0)
    --          + NVL (SUM (rcv_qty_misc_pp), 0)
    --          + NVL (SUM (rcv_qty_rma_p), 0)
    --          + NVL (SUM (sales_qty_p), 0)
    --          + NVL (SUM (broken_qty_p), 0)
    --          + NVL (SUM (issu_qty_misc_p), 0)
    --          + NVL (SUM (sample_qty_p), 0)
    --          + NVL (SUM (broken_rec_qty_p), 0))
    --            p_closing,
    --         (  NVL (SUM (open_bal_s), 0)
    --          + NVL (SUM (rcv_qty_prod_s), 0)
    --          + NVL (SUM (rcv_qty_misc_s), 0)
    --          + NVL (SUM (rcv_qty_misc_ss), 0)
    --          + NVL (SUM (rcv_qty_rma_s), 0)
    --          + NVL (SUM (sales_qty_s), 0)
    --          + NVL (SUM (broken_qty_s), 0)
    --          + NVL (SUM (issu_qty_misc_s), 0)
    --          + NVL (SUM (sample_qty_s), 0)
    --          + NVL (SUM (broken_rec_qty_s), 0))
    --            s_closing,
    --         (  NVL (SUM (open_bal_p), 0)
    --          + NVL (SUM (rcv_qty_prod_p), 0)
    --          + NVL (SUM (rcv_qty_misc_p), 0)
    --          + NVL (SUM (rcv_qty_misc_pp), 0)
    --          + NVL (SUM (rcv_qty_rma_p), 0)
    --          + NVL (SUM (sales_qty_p), 0)
    --          + NVL (SUM (broken_qty_p), 0)
    --          + NVL (SUM (issu_qty_misc_p), 0)
    --          + NVL (SUM (sample_qty_p), 0)
    --          + NVL (SUM (broken_rec_qty_p), 0))
    --         * 0.092936803
    --            m_closing
    FROM (SELECT ood.organization_code,
                 mmt.organization_id org_id,
                 msi.inventory_item_id item_id,
                 mic.segment2 AS item_size,
                 msi.attribute3 AS item_type,
                 msi.concatenated_segments item_code,
                 msi.description item_description,
                 msi.primary_uom_code AS p_uom,
                 mmt.secondary_uom_code AS s_uom,
                 TRUNC (mlt.origination_date) prod_date,
                 mlt.grade_code,
                 mlt.lot_number,
                 CASE SIGN(TRUNC (mmt.transaction_date)
                           - (:p_date_from - .99999))
                    WHEN -1
                    THEN
                       mtln.primary_quantity
                    ELSE
                       0
                 END
                    open_bal_p,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1 THEN mtln.secondary_transaction_quantity
                    ELSE 0
                 END
                    open_bal_s,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mtln.transaction_source_type_id
                          WHEN 5 THEN mtln.primary_quantity
                          ELSE 0
                       END
                 END
                    rcv_qty_prod_p,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mtln.transaction_source_type_id
                          WHEN 5 THEN mtln.secondary_transaction_quantity
                          ELSE 0
                       END
                 END
                    rcv_qty_prod_s,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 42 THEN mtln.primary_quantity
                          ELSE 0
                       END
                 END
                    rcv_qty_misc_p,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 42 THEN mtln.secondary_transaction_quantity
                          ELSE 0
                       END
                 END
                    rcv_qty_misc_s,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 40 THEN mtln.primary_quantity
                          ELSE 0
                       END
                 END
                    rcv_qty_misc_pp,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 40 THEN mtln.secondary_transaction_quantity
                          ELSE 0
                       END
                 END
                    rcv_qty_misc_ss,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 15 THEN mtln.primary_quantity
                          ELSE 0
                       END
                 END
                    rcv_qty_rma_p,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 15 THEN mtln.secondary_transaction_quantity
                          ELSE 0
                       END
                 END
                    rcv_qty_rma_s,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 33 THEN mtln.primary_quantity
                          ELSE 0
                       END
                 END
                    sales_qty_p,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 33 THEN mtln.secondary_transaction_quantity
                          ELSE 0
                       END
                 END
                    sales_qty_s,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_source_id
                          WHEN 864 THEN mtln.primary_quantity
                          ELSE 0
                       END
                 END
                    broken_qty_p,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_source_id
                          WHEN 864 THEN mtln.secondary_transaction_quantity
                          ELSE 0
                       END
                 END
                    broken_qty_s,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 32 THEN mtln.primary_quantity
                          ELSE 0
                       END
                 END
                    issu_qty_misc_p,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_type_id
                          WHEN 32 THEN mtln.secondary_transaction_quantity
                          ELSE 0
                       END
                 END
                    issu_qty_misc_s,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_source_id
                          WHEN 884 THEN mtln.primary_quantity
                          ELSE 0
                       END
                 END
                    sample_qty_p,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_source_id
                          WHEN 884 THEN mtln.secondary_transaction_quantity
                          ELSE 0
                       END
                 END
                    sample_qty_s,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_source_id
                          WHEN 904 THEN mtln.primary_quantity
                          ELSE 0
                       END
                 END
                    broken_rec_qty_p,
                 CASE SIGN (mtln.transaction_date - :p_date_from)
                    WHEN -1
                    THEN
                       0
                    ELSE
                       CASE mmt.transaction_source_id
                          WHEN 904 THEN mtln.secondary_transaction_quantity
                          ELSE 0
                       END
                 END
                    broken_rec_qty_s,
                 CASE SIGN (
                         TRUNC (mmt.transaction_date) - (:p_date_to - .99999))
                    WHEN -1
                    THEN
                       mtln.primary_quantity
                    ELSE
                       0
                 END
                    close_bal_p,
                 CASE SIGN (mtln.transaction_date - :p_date_to)
                    WHEN -1 THEN mtln.secondary_transaction_quantity
                    ELSE 0
                 END
                    close_bal_s
            FROM inv.mtl_material_transactions mmt,
                 inv.mtl_transaction_lot_numbers mtln,
                 inv.mtl_lot_numbers mlt,
                 apps.mtl_system_items_b_kfv msi,
                 apps.mtl_item_categories_v mic,
                 apps.org_organization_definitions ood
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
                 --   AND mmt.transaction_type_id <> 98
                 --        AND (logical_transaction = 2 OR logical_transaction IS NULL)
                 AND mmt.transaction_type_id NOT IN (80, 120, 52, 26, 64)
                 AND mmt.subinventory_code IN
                          ('CEM-REJECT', 'CEM-STAG', 'CEM-SAMPLE')
                 AND msi.concatenated_segments =
                       NVL (:p_item, msi.concatenated_segments)
                 AND mmt.organization_id = 152
                 AND mtln.transaction_date BETWEEN '01-JAN-2010'
                                               AND  :p_date_to + .99999)
GROUP BY                                                  --ORGANIZATION_CODE,
         --    ORG_ID,
         item_id,
         item_type,
         item_code,
         item_description,
         --     P_UOM,
         grade_code,
         lot_number,
         item_size,
         prod_date