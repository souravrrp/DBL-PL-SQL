/* Formatted on 1/20/2021 10:16:10 AM (QP5 v5.354) */
WITH
    mains
    AS
        (SELECT msik.organization_id,
                ood.organization_name,
                msik.inventory_item_id,
                msik.concatenated_segments     item_code,
                msik.description               item_name,
                msik.primary_uom_code          uom
           FROM org_organization_definitions ood, mtl_system_items_b_kfv msik
          WHERE     msik.organization_id = ood.organization_id
                AND ( :p_org_id IS NULL OR msik.organization_id = :p_org_id)
                AND msik.organization_id = ood.organization_id
                AND (   :p_item_id IS NULL
                     OR msik.inventory_item_id = :p_item_id)),
    trx_details
    AS
        (  SELECT organization_id,
                  inventory_item_id,
                  trx_month,
                  SUM (opn_qty)
                      opn_qty,
                  SUM (opn_val)
                      opn_val,
                  SUM (rcv_qty)
                      rcv_qty,
                  SUM (rcv_val)
                      rcv_val,
                  SUM (lc_qty)
                      lc_qty,
                  SUM (lc_val)
                      lc_val,
                  SUM (rcv_qty) - SUM (lc_qty)
                      other_rcv_qty,
                  SUM (rcv_val) - SUM (lc_val)
                      other_rcv_val,
                  SUM (isu_qty)
                      isu_qty,
                  SUM (isu_val)
                      isu_val,
                  SUM (prd_qty)
                      prd_qty,
                  SUM (prd_val)
                      prd_val,
                  SUM (isu_qty) - SUM (prd_qty)
                      other_isu_qty,
                  SUM (isu_val) - SUM (prd_val)
                      other_isu_val,
                  (SUM (opn_qty) + SUM (rcv_qty) + SUM (isu_qty))
                      closing_qty,
                  (SUM (opn_val) + SUM (rcv_val) + SUM (isu_val))
                      closing_val,
                  SUM (pr_qty)
                      pr_qty,
                  SUM (pr_val)
                      pr_val,
                  SUM (onhand_qty)
                      onhand_qty
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                                trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity)
                                opn_qty,
                            SUM (apps.xx_inv_tran_val (inventory_item_id,
                                                       organization_id,
                                                       'O',
                                                       '01-JAN-1950',
                                                       :p_date_fr - 1))
                                opn_val,
                            TO_NUMBER (0)
                                rcv_qty,
                            TO_NUMBER (0)
                                rcv_val,
                            TO_NUMBER (0)
                                lc_qty,
                            TO_NUMBER (0)
                                lc_val,
                            TO_NUMBER (0)
                                isu_qty,
                            TO_NUMBER (0)
                                isu_val,
                            TO_NUMBER (0)
                                prd_qty,
                            TO_NUMBER (0)
                                prd_val,
                            TO_NUMBER (0)
                                pr_qty,
                            TO_NUMBER (0)
                                pr_val,
                            apps.xxdbl_fnc_get_onhand_qty (mmt.inventory_item_id,
                                                           mmt.organization_id,
                                                           'OHQ')
                                onhand_qty
                       FROM mtl_material_transactions mmt
                      WHERE     (   :p_org_id IS NULL
                                 OR mmt.organization_id = :p_org_id)
                            AND (   :p_item_id IS NULL
                                 OR mmt.inventory_item_id = :p_item_id)
                            AND TRUNC (mmt.transaction_date) < :p_date_fr
                            AND SIGN (primary_quantity) = 1
                   GROUP BY mmt.organization_id,
                            mmt.inventory_item_id,
                            mmt.actual_cost,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                   UNION ALL
                     SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                                trx_month,
                            mmt.inventory_item_id,
                            TO_NUMBER (0)
                                opn_qty,
                            TO_NUMBER (0)
                                opn_val,
                            SUM (mmt.primary_quantity)
                                rcv_qty,
                            SUM (mmt.primary_quantity) * mmt.actual_cost
                                rcv_val,
                            TO_NUMBER (0)
                                lc_qty,
                            TO_NUMBER (0)
                                lc_val,
                            TO_NUMBER (0)
                                isu_qty,
                            TO_NUMBER (0)
                                isu_val,
                            TO_NUMBER (0)
                                prd_qty,
                            TO_NUMBER (0)
                                prd_val,
                            TO_NUMBER (0)
                                pr_qty,
                            TO_NUMBER (0)
                                pr_val,
                            TO_NUMBER (0)
                                onhand_qty
                       FROM mtl_material_transactions mmt
                      WHERE     (   :p_org_id IS NULL
                                 OR mmt.organization_id = :p_org_id)
                            AND (   :p_item_id IS NULL
                                 OR mmt.inventory_item_id = :p_item_id)
                            AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                                 AND :p_date_to
                            AND SIGN (primary_quantity) = 1
                   GROUP BY mmt.organization_id,
                            mmt.inventory_item_id,
                            mmt.actual_cost,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                   UNION ALL
                     SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                                trx_month,
                            mmt.inventory_item_id,
                            TO_NUMBER (0)
                                opn_qty,
                            TO_NUMBER (0)
                                opn_val,
                            TO_NUMBER (0)
                                rcv_qty,
                            TO_NUMBER (0)
                                rcv_val,
                            SUM (mmt.primary_quantity)
                                lc_qty,
                            SUM (mmt.primary_quantity) * mmt.actual_cost
                                lc_val,
                            TO_NUMBER (0)
                                isu_qty,
                            TO_NUMBER (0)
                                isu_val,
                            TO_NUMBER (0)
                                prd_qty,
                            TO_NUMBER (0)
                                prd_val,
                            TO_NUMBER (0)
                                pr_qty,
                            TO_NUMBER (0)
                                pr_val,
                            TO_NUMBER (0)
                                onhand_qty
                       FROM mtl_material_transactions mmt
                      WHERE     (   :p_org_id IS NULL
                                 OR mmt.organization_id = :p_org_id)
                            AND (   :p_item_id IS NULL
                                 OR mmt.inventory_item_id = :p_item_id)
                            AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                                 AND :p_date_to
                            AND SIGN (primary_quantity) = 1
                            AND mmt.transaction_type_id = 18
                   GROUP BY mmt.organization_id,
                            mmt.inventory_item_id,
                            mmt.actual_cost,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                   UNION ALL
                     SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                                trx_month,
                            mmt.inventory_item_id,
                            TO_NUMBER (0)
                                opn_qty,
                            TO_NUMBER (0)
                                opn_val,
                            TO_NUMBER (0)
                                rcv_qty,
                            TO_NUMBER (0)
                                rcv_val,
                            TO_NUMBER (0)
                                lc_qty,
                            TO_NUMBER (0)
                                lc_val,
                            SUM (mmt.primary_quantity)
                                isu_qty,
                            SUM (mmt.primary_quantity) * mmt.actual_cost
                                isu_val,
                            TO_NUMBER (0)
                                prd_qty,
                            TO_NUMBER (0)
                                prd_val,
                            TO_NUMBER (0)
                                pr_qty,
                            TO_NUMBER (0)
                                pr_val,
                            TO_NUMBER (0)
                                onhand_qty
                       FROM mtl_material_transactions mmt
                      WHERE     (   :p_org_id IS NULL
                                 OR mmt.organization_id = :p_org_id)
                            AND (   :p_item_id IS NULL
                                 OR mmt.inventory_item_id = :p_item_id)
                            AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                                 AND :p_date_to
                            AND SIGN (primary_quantity) = -1
                   GROUP BY mmt.organization_id,
                            mmt.inventory_item_id,
                            mmt.actual_cost,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                   UNION ALL
                     SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                                trx_month,
                            mmt.inventory_item_id,
                            TO_NUMBER (0)
                                opn_qty,
                            TO_NUMBER (0)
                                opn_val,
                            TO_NUMBER (0)
                                rcv_qty,
                            TO_NUMBER (0)
                                rcv_val,
                            TO_NUMBER (0)
                                lc_qty,
                            TO_NUMBER (0)
                                lc_val,
                            TO_NUMBER (0)
                                isu_qty,
                            TO_NUMBER (0)
                                isu_val,
                            SUM (mmt.primary_quantity)
                                prd_qty,
                            SUM (mmt.primary_quantity) * mmt.actual_cost
                                prd_val,
                            TO_NUMBER (0)
                                pr_qty,
                            TO_NUMBER (0)
                                pr_val,
                            TO_NUMBER (0)
                                onhand_qty
                       FROM mtl_material_transactions mmt
                      WHERE     (   :p_org_id IS NULL
                                 OR mmt.organization_id = :p_org_id)
                            AND (   :p_item_id IS NULL
                                 OR mmt.inventory_item_id = :p_item_id)
                            AND mmt.transaction_type_id = 35
                            AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                                 AND :p_date_to
                            AND SIGN (primary_quantity) = -1
                   GROUP BY mmt.organization_id,
                            mmt.inventory_item_id,
                            mmt.actual_cost,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                   UNION ALL
                     SELECT prl.destination_organization_id
                                organization_id,
                            TO_CHAR (prh.approved_date, 'MON-YY')
                                trx_month,
                            prl.item_id
                                inventory_item_id,
                            TO_NUMBER (0)
                                opn_qty,
                            TO_NUMBER (0)
                                opn_val,
                            TO_NUMBER (0)
                                rcv_qty,
                            TO_NUMBER (0)
                                rcv_val,
                            TO_NUMBER (0)
                                lc_qty,
                            TO_NUMBER (0)
                                lc_val,
                            TO_NUMBER (0)
                                isu_qty,
                            TO_NUMBER (0)
                                isu_val,
                            TO_NUMBER (0)
                                prd_qty,
                            TO_NUMBER (0)
                                prd_val,
                            SUM (prl.quantity)
                                pr_qty,
                            SUM (prl.quantity) * prl.unit_price
                                pr_val,
                            TO_NUMBER (0)
                                onhand_qty
                       FROM apps.po_requisition_headers_all prh,
                            apps.po_requisition_lines_all prl
                      WHERE     prh.requisition_header_id =
                                prl.requisition_header_id
                            AND TRUNC (prh.approved_date) BETWEEN :p_date_fr
                                                              AND :p_date_to
                   GROUP BY prl.destination_organization_id,
                            TO_CHAR (prh.approved_date, 'MON-YY'),
                            prl.item_id,
                            prl.unit_price)
         GROUP BY organization_id, inventory_item_id, trx_month)
  SELECT m.organization_id,
         m.organization_name,
         t.trx_month,
         SUM (opn_qty)                                       opn_qty,
         SUM (opn_val)                                       opn_val,
         SUM (rcv_qty)                                       rcv_qty,
         SUM (rcv_val)                                       rcv_val,
         SUM (lc_qty)                                        lc_qty,
         SUM (lc_val)                                        lc_val,
         SUM (rcv_qty) - SUM (lc_qty)                        other_rcv_qty,
         SUM (rcv_val) - SUM (lc_val)                        other_rcv_val,
         SUM (isu_qty)                                       isu_qty,
         SUM (isu_val)                                       isu_val,
         SUM (prd_qty)                                       prd_qty,
         SUM (prd_val)                                       prd_val,
         SUM (isu_qty) - SUM (prd_qty)                       other_isu_qty,
         SUM (isu_val) - SUM (prd_val)                       other_isu_val,
         (SUM (opn_qty) + SUM (rcv_qty) + SUM (isu_qty))     closing_qty,
         (SUM (opn_val) + SUM (rcv_val) + SUM (isu_val))     closing_val,
         SUM (pr_qty)                                        pr_qty,
         SUM (pr_val)                                        pr_val,
         SUM (onhand_qty)                                    onhand_qty
    FROM mains m, trx_details t
   WHERE     1 = 1
         AND m.organization_id = t.organization_id
         AND m.inventory_item_id = t.inventory_item_id
         AND (t.opn_qty > 0 OR t.isu_qty <> 0 OR t.rcv_qty > 0 OR t.pr_qty <> 0)
GROUP BY m.organization_id, m.organization_name, t.trx_month;