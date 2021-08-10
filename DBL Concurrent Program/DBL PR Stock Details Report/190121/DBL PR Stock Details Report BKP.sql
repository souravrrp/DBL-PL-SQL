/* Formatted on 1/19/2021 4:04:31 PM (QP5 v5.354) */
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
    opening
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')    trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                  opn_qty,
                  apps.xx_inv_tran_val (inventory_item_id,
                                        organization_id,
                                        'O',
                                        '01-JAN-1950',
                                        :p_date_fr - 1)       opn_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) < :p_date_fr
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    receive
    AS
        (  SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  SUM (rcv_qty)     rcv_qty,
                  SUM (rcv_val)     rcv_val,
                  SUM (lc_qty)      lc_qty,
                  SUM (lc_val)      lc_val
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                                trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity)
                                rcv_qty,
                            SUM (mmt.primary_quantity) * mmt.actual_cost
                                rcv_val,
                            TO_NUMBER (0)
                                lc_qty,
                            TO_NUMBER (0)
                                lc_val
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
                                rcv_qty,
                            TO_NUMBER (0)
                                rcv_val,
                            SUM (mmt.primary_quantity)
                                lc_qty,
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
         GROUP BY organization_id, inventory_item_id, trx_month),
    issue
    AS
        (  SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  SUM (isu_qty)     isu_qty,
                  SUM (isu_val)     isu_val,
                  SUM (prd_qty)     prd_qty,
                  SUM (prd_val)     prd_val
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                                trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity)
                                isu_qty,
                            SUM (mmt.primary_quantity) * mmt.actual_cost
                                isu_val,
                            TO_NUMBER (0)
                                prd_qty,
                            TO_NUMBER (0)
                                prd_val
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
                                isu_qty,
                            TO_NUMBER (0)
                                isu_val,
                            SUM (mmt.primary_quantity)
                                prd_qty,
                            SUM (mmt.primary_quantity) * mmt.actual_cost
                                prd_val
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
         GROUP BY organization_id, inventory_item_id, trx_month),
    requisition
    AS
        (SELECT prl.destination_organization_id           organization_id,
                TO_CHAR (prh.approved_date, 'MON-YY')     trx_month,
                prl.item_id                               inventory_item_id,
                prl.quantity                              pr_qty,
                prl.quantity * prl.unit_price             pr_val
           FROM apps.po_requisition_headers_all  prh,
                apps.po_requisition_lines_all    prl
          WHERE     prh.requisition_header_id = prl.requisition_header_id
                AND TRUNC (prh.approved_date) BETWEEN :p_date_fr
                                                  AND :p_date_to)
  SELECT organization_id,
         organization_name,
         trx_month,
         SUM (opn_qty)                                       opn_qty,
         SUM (opn_val)                                       opn_val,
         SUM (rcv_qty)                                       rcv_qty,
         SUM (rcv_val)                                       rcv_val,
         SUM (lc_qty)                                        lc_qty,
         SUM (lc_val)                                        lc_val,
         SUM (isu_qty)                                       isu_qty,
         SUM (isu_val)                                       isu_val,
         SUM (prd_qty)                                       prd_qty,
         SUM (prd_val)                                       prd_val,
         (SUM (opn_qty) + SUM (rcv_qty) + SUM (isu_qty))     closing_qty,
         (SUM (opn_val) + SUM (rcv_val) + SUM (isu_val))     closing_val,
         SUM (pr_qty)                                        pr_qty,
         SUM (pr_val)                                        pr_val,
         SUM (onhand_qty)                                    onhand_qty
    FROM (SELECT m.organization_id,
                 m.organization_name,
                 NULL                                     trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 o.opn_qty,
                 o.opn_val,
                 TO_NUMBER (0)                            rcv_qty,
                 TO_NUMBER (0)                            rcv_val,
                 TO_NUMBER (0)                            lc_qty,
                 TO_NUMBER (0)                            lc_val,
                 TO_NUMBER (0)                            isu_qty,
                 TO_NUMBER (0)                            isu_val,
                 TO_NUMBER (0)                            prd_qty,
                 TO_NUMBER (0)                            prd_val,
                 TO_NUMBER (0)                            pr_qty,
                 TO_NUMBER (0)                            pr_val,
                 apps.xxdbl_fnc_get_onhand_qty (m.inventory_item_id,
                                                m.organization_id,
                                                'OHQ')    onhand_qty
            FROM mains m, opening o
           WHERE     1 = 1
                 AND m.organization_id = o.organization_id
                 AND m.inventory_item_id = o.inventory_item_id
                 AND o.opn_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 r.rcv_qty,
                 r.rcv_val,
                 r.lc_qty,
                 r.lc_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val,
                 TO_NUMBER (0)     prd_qty,
                 TO_NUMBER (0)     prd_val,
                 TO_NUMBER (0)     pr_qty,
                 TO_NUMBER (0)     pr_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, receive r
           WHERE     1 = 1
                 AND m.organization_id = r.organization_id
                 AND m.inventory_item_id = r.inventory_item_id
                 AND r.rcv_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 TO_NUMBER (0)     lc_qty,
                 TO_NUMBER (0)     lc_val,
                 i.isu_qty,
                 i.isu_val,
                 i.prd_qty,
                 i.prd_val,
                 TO_NUMBER (0)     pr_qty,
                 TO_NUMBER (0)     pr_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, issue i
           WHERE     1 = 1
                 AND m.organization_id = i.organization_id
                 AND m.inventory_item_id = i.inventory_item_id
                 AND i.isu_qty <> 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 TO_NUMBER (0)     lc_qty,
                 TO_NUMBER (0)     lc_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val,
                 TO_NUMBER (0)     prd_qty,
                 TO_NUMBER (0)     prd_val,
                 p.pr_qty,
                 p.pr_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, requisition p
           WHERE     1 = 1
                 AND m.organization_id = p.organization_id
                 AND m.inventory_item_id = p.inventory_item_id
                 AND p.pr_qty <> 0)
GROUP BY organization_id, organization_name, trx_month;

--------------------------------------------------------------------------------

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
    opening
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')    trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                  opn_qty,
                  apps.xx_inv_tran_val (inventory_item_id,
                                        organization_id,
                                        'O',
                                        '01-JAN-1950',
                                        :p_date_fr - 1)       opn_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) < :p_date_fr
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    receive
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')         trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                       rcv_qty,
                  SUM (mmt.primary_quantity) * mmt.actual_cost     rcv_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                       AND :p_date_to
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    issue
    AS
        (  SELECT organization_id,
                  trx_month,
                  inventory_item_id,
                  SUM (isu_qty)     isu_qty,
                  SUM (isu_val)     isu_val,
                  SUM (prd_qty)     prd_qty,
                  SUM (prd_val)     prd_val
             FROM (  SELECT mmt.organization_id,
                            TO_CHAR (mmt.transaction_date, 'MON-YY')
                                trx_month,
                            mmt.inventory_item_id,
                            SUM (mmt.primary_quantity)
                                isu_qty,
                            SUM (mmt.primary_quantity) * mmt.actual_cost
                                isu_val,
                            TO_NUMBER (0)
                                prd_qty,
                            TO_NUMBER (0)
                                prd_val
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
                                isu_qty,
                            TO_NUMBER (0)
                                isu_val,
                            SUM (mmt.primary_quantity)
                                prd_qty,
                            SUM (mmt.primary_quantity) * mmt.actual_cost
                                prd_val
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
         GROUP BY organization_id,
                  inventory_item_id,
                  trx_month,
                  isu_qty,
                  isu_val),
    requisition
    AS
        (SELECT prl.destination_organization_id           organization_id,
                TO_CHAR (prh.approved_date, 'MON-YY')     trx_month,
                prl.item_id                               inventory_item_id,
                prl.quantity                              pr_qty,
                prl.quantity * prl.unit_price             pr_val
           FROM apps.po_requisition_headers_all  prh,
                apps.po_requisition_lines_all    prl
          WHERE     prh.requisition_header_id = prl.requisition_header_id
                AND TRUNC (prh.approved_date) BETWEEN :p_date_fr
                                                  AND :p_date_to)
  SELECT organization_id,
         organization_name,
         trx_month,
         SUM (opn_qty)                                       opn_qty,
         SUM (opn_val)                                       opn_val,
         SUM (rcv_qty)                                       rcv_qty,
         SUM (rcv_val)                                       rcv_val,
         SUM (isu_qty)                                       isu_qty,
         SUM (isu_val)                                       isu_val,
         SUM (prd_qty)                                       prd_qty,
         SUM (prd_val)                                       prd_val,
         (SUM (opn_qty) + SUM (rcv_qty) + SUM (isu_qty))     closing_qty,
         (SUM (opn_val) + SUM (rcv_val) + SUM (isu_val))     closing_val,
         SUM (pr_qty)                                        pr_qty,
         SUM (pr_val)                                        pr_val,
         SUM (onhand_qty)                                    onhand_qty
    FROM (SELECT m.organization_id,
                 m.organization_name,
                 NULL                                     trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 o.opn_qty,
                 o.opn_val,
                 TO_NUMBER (0)                            rcv_qty,
                 TO_NUMBER (0)                            rcv_val,
                 TO_NUMBER (0)                            isu_qty,
                 TO_NUMBER (0)                            isu_val,
                 TO_NUMBER (0)                            prd_qty,
                 TO_NUMBER (0)                            prd_val,
                 TO_NUMBER (0)                            pr_qty,
                 TO_NUMBER (0)                            pr_val,
                 apps.xxdbl_fnc_get_onhand_qty (m.inventory_item_id,
                                                m.organization_id,
                                                'OHQ')    onhand_qty
            FROM mains m, opening o
           WHERE     1 = 1
                 AND m.organization_id = o.organization_id
                 AND m.inventory_item_id = o.inventory_item_id
                 AND o.opn_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 r.rcv_qty,
                 r.rcv_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val,
                 TO_NUMBER (0)     prd_qty,
                 TO_NUMBER (0)     prd_val,
                 TO_NUMBER (0)     pr_qty,
                 TO_NUMBER (0)     pr_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, receive r
           WHERE     1 = 1
                 AND m.organization_id = r.organization_id
                 AND m.inventory_item_id = r.inventory_item_id
                 AND r.rcv_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 i.isu_qty,
                 i.isu_val,
                 i.prd_qty,
                 i.prd_val,
                 TO_NUMBER (0)     pr_qty,
                 TO_NUMBER (0)     pr_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, issue i
           WHERE     1 = 1
                 AND m.organization_id = i.organization_id
                 AND m.inventory_item_id = i.inventory_item_id
                 AND i.isu_qty <> 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val,
                 TO_NUMBER (0)     prd_qty,
                 TO_NUMBER (0)     prd_val,
                 p.pr_qty,
                 p.pr_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, requisition p
           WHERE     1 = 1
                 AND m.organization_id = p.organization_id
                 AND m.inventory_item_id = p.inventory_item_id
                 AND p.pr_qty <> 0)
GROUP BY organization_id, organization_name, trx_month;

--------------------------------------------------------------------------------


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
    opening
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')    trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                  opn_qty,
                  apps.xx_inv_tran_val (inventory_item_id,
                                        organization_id,
                                        'O',
                                        '01-JAN-1950',
                                        :p_date_fr - 1)       opn_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) < :p_date_fr
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    receive
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')         trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                       rcv_qty,
                  SUM (mmt.primary_quantity) * mmt.actual_cost     rcv_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                       AND :p_date_to
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    issue
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')         trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                       isu_qty,
                  SUM (mmt.primary_quantity) * mmt.actual_cost     isu_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                       AND :p_date_to
                  AND SIGN (primary_quantity) = -1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    requisition
    AS
        (SELECT prl.destination_organization_id           organization_id,
                TO_CHAR (prh.approved_date, 'MON-YY')     trx_month,
                prl.item_id                               inventory_item_id,
                prl.quantity                              pr_qty,
                prl.quantity * prl.unit_price             pr_val
           FROM apps.po_requisition_headers_all  prh,
                apps.po_requisition_lines_all    prl
          WHERE     prh.requisition_header_id = prl.requisition_header_id
                AND TRUNC (prh.approved_date) BETWEEN :p_date_fr
                                                  AND :p_date_to)
  SELECT organization_id,
         organization_name,
         trx_month,
         SUM (opn_qty)                                       opn_qty,
         SUM (opn_val)                                       opn_val,
         SUM (rcv_qty)                                       rcv_qty,
         SUM (rcv_val)                                       rcv_val,
         SUM (isu_qty)                                       isu_qty,
         SUM (isu_val)                                       isu_val,
         (SUM (opn_qty) + SUM (rcv_qty) + SUM (isu_qty))     closing_qty,
         (SUM (opn_val) + SUM (rcv_val) + SUM (isu_val))     closing_val,
         SUM (pr_qty)                                        pr_qty,
         SUM (pr_val)                                        pr_val,
         SUM (onhand_qty)                                    onhand_qty
    FROM (SELECT m.organization_id,
                 m.organization_name,
                 NULL                                     trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 o.opn_qty,
                 o.opn_val,
                 TO_NUMBER (0)                            rcv_qty,
                 TO_NUMBER (0)                            rcv_val,
                 TO_NUMBER (0)                            isu_qty,
                 TO_NUMBER (0)                            isu_val,
                 TO_NUMBER (0)                            pr_qty,
                 TO_NUMBER (0)                            pr_val,
                 apps.xxdbl_fnc_get_onhand_qty (m.inventory_item_id,
                                                m.organization_id,
                                                'OHQ')    onhand_qty
            FROM mains m, opening o
           WHERE     1 = 1
                 AND m.organization_id = o.organization_id
                 AND m.inventory_item_id = o.inventory_item_id
                 AND o.opn_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 r.rcv_qty,
                 r.rcv_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val,
                 TO_NUMBER (0)     pr_qty,
                 TO_NUMBER (0)     pr_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, receive r
           WHERE     1 = 1
                 AND m.organization_id = r.organization_id
                 AND m.inventory_item_id = r.inventory_item_id
                 AND r.rcv_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 i.isu_qty,
                 i.isu_val,
                 TO_NUMBER (0)     pr_qty,
                 TO_NUMBER (0)     pr_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, issue i
           WHERE     1 = 1
                 AND m.organization_id = i.organization_id
                 AND m.inventory_item_id = i.inventory_item_id
                 AND i.isu_qty <> 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val,
                 p.pr_qty,
                 p.pr_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, requisition p
           WHERE     1 = 1
                 AND m.organization_id = p.organization_id
                 AND m.inventory_item_id = p.inventory_item_id
                 AND p.pr_qty <> 0)
GROUP BY organization_id, organization_name, trx_month;

--------------------------------------------------------------------------------

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
    opening
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')    trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                  opn_qty,
                  apps.xx_inv_tran_val (inventory_item_id,
                                        organization_id,
                                        'O',
                                        '01-JAN-1950',
                                        :p_date_fr - 1)       opn_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) < :p_date_fr
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    receive
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')         trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                       rcv_qty,
                  SUM (mmt.primary_quantity) * mmt.actual_cost     rcv_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                       AND :p_date_to
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    issue
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')         trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                       isu_qty,
                  SUM (mmt.primary_quantity) * mmt.actual_cost     isu_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                       AND :p_date_to
                  AND SIGN (primary_quantity) = -1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY'))
  SELECT organization_id,
         organization_name,
         trx_month,
         SUM (opn_qty)                                       opn_qty,
         SUM (opn_val)                                       opn_val,
         SUM (rcv_qty)                                       rcv_qty,
         SUM (rcv_val)                                       rcv_val,
         SUM (isu_qty)                                       isu_qty,
         SUM (isu_val)                                       isu_val,
         (SUM (opn_qty) + SUM (rcv_qty) + SUM (isu_qty))     closing_qty,
         (SUM (opn_val) + SUM (rcv_val) + SUM (isu_val))     closing_val,
         SUM (onhand_qty)                                    onhand_qty
    FROM (SELECT m.organization_id,
                 m.organization_name,
                 NULL                                     trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 o.opn_qty,
                 o.opn_val,
                 TO_NUMBER (0)                            rcv_qty,
                 TO_NUMBER (0)                            rcv_val,
                 TO_NUMBER (0)                            isu_qty,
                 TO_NUMBER (0)                            isu_val,
                 apps.xxdbl_fnc_get_onhand_qty (m.inventory_item_id,
                                                m.organization_id,
                                                'OHQ')    onhand_qty
            FROM mains m, opening o
           WHERE     1 = 1
                 AND m.organization_id = o.organization_id
                 AND m.inventory_item_id = o.inventory_item_id
                 AND o.opn_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 r.rcv_qty,
                 r.rcv_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, receive r
           WHERE     1 = 1
                 AND m.organization_id = r.organization_id
                 AND m.inventory_item_id = r.inventory_item_id
                 AND r.rcv_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 i.isu_qty,
                 i.isu_val,
                 TO_NUMBER (0)     onhand_qty
            FROM mains m, issue i
           WHERE     1 = 1
                 AND m.organization_id = i.organization_id
                 AND m.inventory_item_id = i.inventory_item_id
                 AND i.isu_qty <> 0)
GROUP BY organization_id, organization_name, trx_month;

--------------------------------------------------------------------------------

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
    opening
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')    trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                  opn_qty,
                  apps.xx_inv_tran_val (inventory_item_id,
                                        organization_id,
                                        'O',
                                        '01-JAN-1950',
                                        :p_date_fr - 1)       opn_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) < :p_date_fr
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    receive
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')         trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                       rcv_qty,
                  SUM (mmt.primary_quantity) * mmt.actual_cost     rcv_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                       AND :p_date_to
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    issue
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')         trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                       isu_qty,
                  SUM (mmt.primary_quantity) * mmt.actual_cost     isu_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                       AND :p_date_to
                  AND SIGN (primary_quantity) = -1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY'))
  SELECT organization_id,
         organization_name,
         trx_month,
         SUM (opn_qty)                                       opn_qty,
         SUM (opn_val)                                       opn_val,
         SUM (rcv_qty)                                       rcv_qty,
         SUM (rcv_val)                                       rcv_val,
         SUM (isu_qty)                                       isu_qty,
         SUM (isu_val)                                       isu_val,
         (SUM (opn_qty) + SUM (rcv_qty) + SUM (isu_qty))     closing_qty,
         (SUM (opn_val) + SUM (rcv_val) + SUM (isu_val))     closing_val
    FROM (SELECT m.organization_id,
                 m.organization_name,
                 NULL              trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 o.opn_qty,
                 o.opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val
            FROM mains m, opening o
           WHERE     1 = 1
                 AND m.organization_id = o.organization_id
                 AND m.inventory_item_id = o.inventory_item_id
                 AND o.opn_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 r.rcv_qty,
                 r.rcv_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val
            FROM mains m, receive r
           WHERE     1 = 1
                 AND m.organization_id = r.organization_id
                 AND m.inventory_item_id = r.inventory_item_id
                 AND r.rcv_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 trx_month,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 i.isu_qty,
                 i.isu_val
            FROM mains m, issue i
           WHERE     1 = 1
                 AND m.organization_id = i.organization_id
                 AND m.inventory_item_id = i.inventory_item_id
                 AND i.isu_qty <> 0)
GROUP BY organization_id, organization_name, trx_month;

--------------------------------------------------------------------------------

WITH
    mains
    AS
        (SELECT msik.organization_id,
                ood.organization_name,
                msik.inventory_item_id,
                msik.concatenated_segments     item_code,
                msik.description               item_name,
                msik.primary_uom_code          uom,
                mic.segment2                   item_mjr_cat,
                mic.segment3                   item_mnr_cat
           FROM org_organization_definitions  ood,
                mtl_system_items_b_kfv        msik,
                mtl_item_categories_v         mic
          WHERE     msik.organization_id = mic.organization_id
                AND msik.organization_id = ood.organization_id
                AND msik.inventory_item_id = mic.inventory_item_id
                AND mic.category_set_id = 1
                AND ( :p_org_id IS NULL OR msik.organization_id = :p_org_id)
                AND msik.organization_id = ood.organization_id
                AND (   :p_item_id IS NULL
                     OR msik.inventory_item_id = :p_item_id)
                AND ( :p_mjr_cat IS NULL OR mic.segment2 = :p_mjr_cat)
                AND ( :p_mnr_cat IS NULL OR mic.segment3 = :p_mnr_cat)),
    opening
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')    trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                  opn_qty,
                  apps.xx_inv_tran_val (inventory_item_id,
                                        organization_id,
                                        'O',
                                        '01-JAN-1950',
                                        :p_date_fr - 1)       opn_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) < :p_date_fr
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    receive
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')         trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                       rcv_qty,
                  SUM (mmt.primary_quantity) * mmt.actual_cost     rcv_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                       AND :p_date_to
                  AND SIGN (primary_quantity) = 1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')),
    issue
    AS
        (  SELECT mmt.organization_id,
                  TO_CHAR (mmt.transaction_date, 'MON-YY')         trx_month,
                  mmt.inventory_item_id,
                  SUM (mmt.primary_quantity)                       isu_qty,
                  SUM (mmt.primary_quantity) * mmt.actual_cost     isu_val
             FROM mtl_material_transactions mmt
            WHERE     ( :p_org_id IS NULL OR mmt.organization_id = :p_org_id)
                  AND (   :p_item_id IS NULL
                       OR mmt.inventory_item_id = :p_item_id)
                  AND TRUNC (mmt.transaction_date) BETWEEN :p_date_fr
                                                       AND :p_date_to
                  AND SIGN (primary_quantity) = -1
         GROUP BY mmt.organization_id,
                  mmt.inventory_item_id,
                  mmt.actual_cost,
                  TO_CHAR (mmt.transaction_date, 'MON-YY'))
  SELECT organization_id,
         organization_name,
         item_mjr_cat,
         item_mnr_cat,
         inventory_item_id,
         item_code,
         item_name,
         uom,
         SUM (opn_qty)                                       opn_qty,
         SUM (opn_val)                                       opn_val,
         SUM (rcv_qty)                                       rcv_qty,
         SUM (rcv_val)                                       rcv_val,
         SUM (isu_qty)                                       isu_qty,
         SUM (isu_val)                                       isu_val,
         (SUM (opn_qty) + SUM (rcv_qty) + SUM (isu_qty))     closing_qty,
         (SUM (opn_val) + SUM (rcv_val) + SUM (isu_val))     closing_val
    FROM (SELECT m.organization_id,
                 m.organization_name,
                 m.item_mjr_cat,
                 m.item_mnr_cat,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 o.opn_qty,
                 o.opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val
            FROM mains m, opening o
           WHERE     1 = 1
                 AND m.organization_id = o.organization_id
                 AND m.inventory_item_id = o.inventory_item_id
                 AND o.opn_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 m.item_mjr_cat,
                 m.item_mnr_cat,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 r.rcv_qty,
                 r.rcv_val,
                 TO_NUMBER (0)     isu_qty,
                 TO_NUMBER (0)     isu_val
            FROM mains m, receive r
           WHERE     1 = 1
                 AND m.organization_id = r.organization_id
                 AND m.inventory_item_id = r.inventory_item_id
                 AND r.rcv_qty > 0
          UNION ALL
          SELECT m.organization_id,
                 m.organization_name,
                 m.item_mjr_cat,
                 m.item_mnr_cat,
                 m.inventory_item_id,
                 m.item_code,
                 m.item_name,
                 m.uom,
                 TO_NUMBER (0)     opn_qty,
                 TO_NUMBER (0)     opn_val,
                 TO_NUMBER (0)     rcv_qty,
                 TO_NUMBER (0)     rcv_val,
                 i.isu_qty,
                 i.isu_val
            FROM mains m, issue i
           WHERE     1 = 1
                 AND m.organization_id = i.organization_id
                 AND m.inventory_item_id = i.inventory_item_id
                 AND i.isu_qty <> 0)
GROUP BY organization_id,
         organization_name,
         item_mjr_cat,
         item_mnr_cat,
         inventory_item_id,
         item_code,
         item_name,
         uom;