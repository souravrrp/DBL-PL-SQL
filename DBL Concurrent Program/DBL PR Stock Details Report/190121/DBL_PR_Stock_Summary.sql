/* Formatted on 06/Mar/21 5:09:03 PM (QP5 v5.227.12220.39754) */
WITH tmpMaster
     AS (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                  mmt.inventory_item_id,
                  1 AS SL_NO,
                  'Opening Stock Qty' AS Value_Type,
                  SUM (mmt.primary_quantity) PR_Value                --opn_qty
             FROM mtl_material_transactions mmt
            WHERE     (:p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (:p_item_id IS NULL OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) < :p_date_fr
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')
         UNION ALL
           SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                  mmt.inventory_item_id,
                  2 AS SL_NO,
                  'Opening Value' AS Value_Type,
                  apps.xx_inv_tran_val (inventory_item_id,
                                        organization_id,
                                        'O',
                                        '01-JAN-1950',
                                        :p_date_fr - 1)
                     PR_Value                                        --opn_val
             FROM mtl_material_transactions mmt
            WHERE     (:p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (:p_item_id IS NULL OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) < :p_date_fr
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  3 AS SL_NO,
                  'Receipt Qty' AS Value_Type,
                  SUM (rcv_qty) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) rcv_qty
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  4 AS SL_NO,
                  'Receipt Value' AS Value_Type,
                  SUM (rcv_val) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) * mmt.actual_cost rcv_val
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  5 AS SL_NO,
                  'LC Receipt' AS Value_Type,
                  SUM (lc_qty) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) lc_qty
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  6 AS SL_NO,
                  'LC Receipt Value' AS Value_Type,
                  SUM (lc_val) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) * mmt.actual_cost lc_val
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  7 AS SL_NO,
                  'Issue Qty' AS Value_Type,
                  SUM (isu_qty) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) isu_qty
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  8 AS SL_NO,
                  'Issue Value' AS Value_Type,
                  SUM (isu_val) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) * mmt.actual_cost isu_val
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  9 AS SL_NO,
                  'Production Issue' AS Value_Type,
                  SUM (prd_qty) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) prd_qty
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  10 AS SL_NO,
                  'Production Value' AS Value_Type,
                  SUM (prd_val) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) * mmt.actual_cost prd_val
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  11 AS SL_NO,
                  'L/C- Stock In Transit' AS Value_Type,
                  SUM (ppo_qty) PR_Value
             FROM (  SELECT pll.ship_to_organization_id organization_id,
                            TO_CHAR (pha.creation_date, 'MON-YY') trx_month,
                            pla.item_id inventory_item_id,
                            SUM (pll.quantity) ppo_qty
                       FROM apps.po_headers_all pha,
                            apps.po_lines_all pla,
                            apps.po_line_locations_all pll
                      WHERE     1 = 1
                            AND (   :p_org_id IS NULL
                                 OR pll.ship_to_organization_id = :p_org_id)
                            AND (:p_item_id IS NULL OR pla.item_id = :p_item_id)
                            AND pha.po_header_id = pla.po_header_id
                            AND pha.po_header_id = pll.po_header_id
                            AND pha.authorization_status = 'IN PROCESS'
                            AND TRUNC (pha.creation_date) BETWEEN :p_date_fr
                                                              AND :p_date_to
                   GROUP BY pll.ship_to_organization_id,
                            pla.item_id,
                            pla.unit_price,
                            TO_CHAR (pha.creation_date, 'MON-YY')
                   UNION ALL
                     SELECT pll.ship_to_organization_id organization_id,
                            TO_CHAR (pha.approved_date, 'MON-YY') trx_month,
                            pla.item_id inventory_item_id,
                            NVL (SUM (pll.quantity - pll.quantity_received), 0)
                               ppo_qty                               --apo_qty
                       FROM apps.po_headers_all pha,
                            apps.po_lines_all pla,
                            apps.po_line_locations_all pll
                      WHERE     1 = 1
                            AND (   :p_org_id IS NULL
                                 OR pll.ship_to_organization_id = :p_org_id)
                            AND (:p_item_id IS NULL OR pla.item_id = :p_item_id)
                            AND pha.po_header_id = pla.po_header_id
                            AND pha.po_header_id = pll.po_header_id
                            AND pha.authorization_status = 'APPROVED'
                            AND TRUNC (pha.creation_date) BETWEEN :p_date_fr
                                                              AND :p_date_to
                   GROUP BY pll.ship_to_organization_id,
                            pla.item_id,
                            pla.unit_price,
                            TO_CHAR (pha.approved_date, 'MON-YY')
                   UNION ALL
                     SELECT prl.destination_organization_id organization_id,
                            TO_CHAR (prh.approved_date, 'MON-YY') trx_month,
                            prl.item_id inventory_item_id,
                            SUM (prl.quantity) ppo_qty                --pr_qty
                       FROM apps.po_requisition_headers_all prh,
                            apps.po_requisition_lines_all prl
                      WHERE     prh.requisition_header_id =
                                   prl.requisition_header_id
                            AND prh.authorization_status = 'APPROVED'
                            AND (   :p_org_id IS NULL
                                 OR prl.destination_organization_id = :p_org_id)
                            AND (:p_item_id IS NULL OR prl.item_id = :p_item_id)
                            AND TRUNC (prh.approved_date) BETWEEN :p_date_fr
                                                              AND :p_date_to
                   GROUP BY prl.destination_organization_id,
                            prl.item_id,
                            prl.unit_price,
                            TO_CHAR (prh.approved_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  12 AS SL_NO,
                  'L/C- Stock In Transit Value' AS Value_Type,
                  SUM (ppo_val) PR_Value
             FROM (  SELECT pll.ship_to_organization_id organization_id,
                            TO_CHAR (pha.creation_date, 'MON-YY') trx_month,
                            pla.item_id inventory_item_id,
                            SUM (pll.quantity) * pla.unit_price ppo_val
                       FROM apps.po_headers_all pha,
                            apps.po_lines_all pla,
                            apps.po_line_locations_all pll
                      WHERE     1 = 1
                            AND (   :p_org_id IS NULL
                                 OR pll.ship_to_organization_id = :p_org_id)
                            AND (:p_item_id IS NULL OR pla.item_id = :p_item_id)
                            AND pha.po_header_id = pla.po_header_id
                            AND pha.po_header_id = pll.po_header_id
                            AND pha.authorization_status = 'IN PROCESS'
                            AND TRUNC (pha.creation_date) BETWEEN :p_date_fr
                                                              AND :p_date_to
                   GROUP BY pll.ship_to_organization_id,
                            pla.item_id,
                            pla.unit_price,
                            TO_CHAR (pha.creation_date, 'MON-YY')
                   UNION ALL
                     SELECT pll.ship_to_organization_id organization_id,
                            TO_CHAR (pha.approved_date, 'MON-YY') trx_month,
                            pla.item_id inventory_item_id,
                              NVL (SUM (pll.quantity - pll.quantity_received), 0)
                            * pla.unit_price
                               ppo_val                               --apo_val
                       FROM apps.po_headers_all pha,
                            apps.po_lines_all pla,
                            apps.po_line_locations_all pll
                      WHERE     1 = 1
                            AND (   :p_org_id IS NULL
                                 OR pll.ship_to_organization_id = :p_org_id)
                            AND (:p_item_id IS NULL OR pla.item_id = :p_item_id)
                            AND pha.po_header_id = pla.po_header_id
                            AND pha.po_header_id = pll.po_header_id
                            AND pha.authorization_status = 'APPROVED'
                            AND TRUNC (pha.creation_date) BETWEEN :p_date_fr
                                                              AND :p_date_to
                   GROUP BY pll.ship_to_organization_id,
                            pla.item_id,
                            pla.unit_price,
                            TO_CHAR (pha.approved_date, 'MON-YY')
                   UNION ALL
                     SELECT prl.destination_organization_id organization_id,
                            TO_CHAR (prh.approved_date, 'MON-YY') trx_month,
                            prl.item_id inventory_item_id,
                            SUM (prl.quantity) * prl.unit_price ppo_val --pr_val
                       FROM apps.po_requisition_headers_all prh,
                            apps.po_requisition_lines_all prl
                      WHERE     prh.requisition_header_id =
                                   prl.requisition_header_id
                            AND prh.authorization_status = 'APPROVED'
                            AND (   :p_org_id IS NULL
                                 OR prl.destination_organization_id = :p_org_id)
                            AND (:p_item_id IS NULL OR prl.item_id = :p_item_id)
                            AND TRUNC (prh.approved_date) BETWEEN :p_date_fr
                                                              AND :p_date_to
                   GROUP BY prl.destination_organization_id,
                            prl.item_id,
                            prl.unit_price,
                            TO_CHAR (prh.approved_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  13 AS SL_NO,
                  'PR Qty' AS Value_Type,
                  SUM (pr_qty) PR_Value
             FROM (  SELECT prl.destination_organization_id organization_id,
                            TO_CHAR (prh.approved_date, 'MON-YY') trx_month,
                            prl.item_id inventory_item_id,
                            SUM (prl.quantity) pr_qty
                       FROM apps.po_requisition_headers_all prh,
                            apps.po_requisition_lines_all prl
                      WHERE     prh.requisition_header_id =
                                   prl.requisition_header_id
                            AND prh.authorization_status = 'APPROVED'
                            AND (   :p_org_id IS NULL
                                 OR prl.destination_organization_id = :p_org_id)
                            AND (:p_item_id IS NULL OR prl.item_id = :p_item_id)
                            AND TRUNC (prh.approved_date) BETWEEN :p_date_fr
                                                              AND :p_date_to
                   GROUP BY prl.destination_organization_id,
                            prl.item_id,
                            prl.unit_price,
                            TO_CHAR (prh.approved_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  14 AS SL_NO,
                  'PR Value' AS Value_Type,
                  SUM (pr_val) PR_Value
             FROM (  SELECT prl.destination_organization_id organization_id,
                            TO_CHAR (prh.approved_date, 'MON-YY') trx_month,
                            prl.item_id inventory_item_id,
                            SUM (prl.quantity) * prl.unit_price pr_val
                       FROM apps.po_requisition_headers_all prh,
                            apps.po_requisition_lines_all prl
                      WHERE     prh.requisition_header_id =
                                   prl.requisition_header_id
                            AND prh.authorization_status = 'APPROVED'
                            AND (   :p_org_id IS NULL
                                 OR prl.destination_organization_id = :p_org_id)
                            AND (:p_item_id IS NULL OR prl.item_id = :p_item_id)
                            AND TRUNC (prh.approved_date) BETWEEN :p_date_fr
                                                              AND :p_date_to
                   GROUP BY prl.destination_organization_id,
                            prl.item_id,
                            prl.unit_price,
                            TO_CHAR (prh.approved_date, 'MON-YY'))
         GROUP BY organization_id, inventory_item_id, trx_month
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  15 AS SL_NO,
                  'Other Receipt' AS Value_Type,
                  SUM (rcv_qty) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) rcv_qty
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            -SUM (mmt.primary_quantity) lc_qty
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
                            TO_CHAR (mmt.transaction_date, 'MON-YY'))
         GROUP BY organization_id, trx_month, inventory_item_id
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  16 AS SL_NO,
                  'Others Receipt Value' AS Value_Type,
                  SUM (rcv_val) PR_Value                       --other_rcv_val
             FROM (  SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            SUM (rcv_val) rcv_val
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      SUM (mmt.primary_quantity) * mmt.actual_cost
                                         rcv_val
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month
                   UNION ALL
                     SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            -SUM (lc_val) rcv_val                     --lc_val
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      SUM (mmt.primary_quantity) * mmt.actual_cost
                                         lc_val
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month)
         GROUP BY organization_id, trx_month, inventory_item_id
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  17 AS SL_NO,
                  'Other Issue' AS Value_Type,
                  SUM (isu_qty) AS PR_Value
             FROM (  SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            SUM (isu_qty) isu_qty
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      SUM (mmt.primary_quantity) isu_qty
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month
                   UNION ALL
                     SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            -SUM (prd_qty) isu_qty                 -- PR_Value
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      SUM (mmt.primary_quantity) prd_qty
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month)
         GROUP BY organization_id, trx_month, inventory_item_id
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  18 AS SL_NO,
                  'Other Issue Value' AS Value_Type,
                  SUM (PR_Value) AS PR_Value
             FROM (  SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            SUM (PR_Value) PR_Value
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      (SUM (mmt.primary_quantity) * mmt.actual_cost)
                                         PR_Value                    --isu_val
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month
                   UNION ALL
                     SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            -SUM (PR_Value) PR_Value                 --prd_val
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      (SUM (mmt.primary_quantity) * mmt.actual_cost)
                                         PR_Value                    --prd_val
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month)
         GROUP BY organization_id, trx_month, inventory_item_id
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  19 AS SL_NO,
                  'Closing Stock Qty' Value_Type,
                  SUM (PR_Value) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity) PR_Value      --opn_qty
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
                     SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            SUM (rcv_qty) PR_Value
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      SUM (mmt.primary_quantity) rcv_qty
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month
                   UNION ALL
                     SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            SUM (isu_qty) PR_Value
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      SUM (mmt.primary_quantity) isu_qty
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month)
         GROUP BY organization_id, trx_month, inventory_item_id
         UNION ALL
           SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  20 AS SL_NO,
                  'Closing Stock Value' Value_Type,
                  SUM (PR_Value) PR_Value
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY') trx_month,
                            mmt.inventory_item_id,
                            apps.xx_inv_tran_val (inventory_item_id,
                                                  organization_id,
                                                  'O',
                                                  '01-JAN-1950',
                                                  :p_date_fr - 1)
                               PR_Value                              --opn_val
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
                     SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            SUM (rcv_val) PR_Value
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      SUM (mmt.primary_quantity) * mmt.actual_cost
                                         rcv_val
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month
                   UNION ALL
                     SELECT organization_id,
                            trx_month,
                            inventory_item_id,
                            SUM (isu_val) PR_Value
                       FROM (  SELECT mmt.organization_id,
                                      TO_CHAR (mmt.transaction_date, 'MON-YY')
                                         trx_month,
                                      mmt.inventory_item_id,
                                      SUM (mmt.primary_quantity) * mmt.actual_cost
                                         isu_val
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
                                      TO_CHAR (mmt.transaction_date, 'MON-YY'))
                   GROUP BY organization_id, inventory_item_id, trx_month)
         GROUP BY organization_id, trx_month, inventory_item_id),
     TmpDetails
     AS (SELECT msik.organization_id,
                ood.organization_name,
                msik.inventory_item_id,
                msik.concatenated_segments item_code,
                msik.description item_name,
                msik.primary_uom_code uom,
                apps.xxdbl_fnc_get_onhand_qty (msik.inventory_item_id,
                                               ood.organization_id,
                                               'OHQ')
                   onhand_qty
           FROM org_organization_definitions ood, mtl_system_items_b_kfv msik
          WHERE     msik.organization_id = ood.organization_id
                AND (:p_org_id IS NULL OR msik.organization_id = :p_org_id)
                AND msik.organization_id = ood.organization_id
                AND (   :p_item_id IS NULL
                     OR msik.inventory_item_id = :p_item_id))
  SELECT                                                  --d.organization_id,
        d.organization_name,
         --d.inventory_item_id,
         d.item_code,
         d.item_name,
         --d.uom,
         --d.onhand_qty,
         m.SL_NO,
         m.trx_month,
         m.Value_Type,
         ROUND (SUM (NVL (m.PR_Value, 0)), 2) PR_Value
    FROM TmpMaster m, TmpDetails d
   WHERE     1 = 1
         AND m.organization_id = d.organization_id         --AND o.opn_qty > 0
         AND m.inventory_item_id = d.inventory_item_id
         AND d.item_code IN ('SPRECONS000000007916', 'SPRECONS000000039496')
GROUP BY d.organization_name,
         d.item_code,
         d.item_name,
         m.SL_NO,
         m.trx_month,
         m.Value_Type
ORDER BY d.item_code, m.SL_NO