/* Formatted on 10/9/2021 12:24:36 PM (QP5 v5.365) */
  SELECT ood.operating_unit           "Orgainzation Code",
         ood.organization_code        "Orgainzation Code",
         --            gcc.segment1
         --         || '.'
         --         || gcc.segment2
         --         || '.'
         --         || gcc.segment3
         --         || '.'
         --         || gcc.segment4
         --         || '.'
         --         || gcc.segment5
         --         || '.'
         --         || gcc.segment6
         --         || '.'
         --         || gcc.segment7
         --         || '.'
         --         || gcc.segment8
         --         || '.'
         --         || gcc.segment9                                       dist_acc_code,
         gcc.segment5                 "Natural Account",
         mtt.transaction_type_name    "Transaction Type",
         --TO_CHAR (TRUNC (mmt.transaction_date), 'MON-YYYY')    Txn_period,
         (CASE
              WHEN SIGN (SUM (mmt.transaction_quantity)) = 1
              THEN
                  SUM (mmt.transaction_quantity)
              ELSE
                  0
          END)                        "Received - Qty",
         (CASE
              WHEN SIGN (SUM (mmt.transaction_quantity)) = 1
              THEN
                    SUM (mmt.transaction_quantity)
                  * NVL (mmt.transaction_cost, mmt.actual_cost)
              ELSE
                  /* Formatted on 10/9/2021 12:24:54 PM (QP5 v5.365) */
0
          END)                        "Received - Value",
         (CASE
              WHEN SIGN (SUM (mmt.transaction_quantity)) = -1
              THEN
                  SUM (mmt.transaction_quantity)
              ELSE
                  0
          END)                        "Issue - Qty",
         (CASE
              WHEN SIGN (SUM (mmt.transaction_quantity)) = -1
              THEN
                    SUM (mmt.transaction_quantity)
                  * NVL (mmt.transaction_cost, mmt.actual_cost)
              ELSE
                  0
          END)                        "Issue - Value"
    --         SUM (mmt.transaction_quantity)                        trx_qty,
    --         ABS (
    --               SUM (mmt.transaction_quantity)
    --             * NVL (mmt.transaction_cost, mmt.actual_cost))    transaction_value
    --,mmt.*
    --,mtt.*
    FROM inv.mtl_material_transactions    mmt,
         inv.mtl_transaction_types        mtt,
         apps.org_organization_definitions ood,
         gl.gl_code_combinations          gcc
   WHERE     1 = 1
         AND ood.organization_id = mmt.organization_id
         AND mmt.transaction_type_id = mtt.transaction_type_id
         AND mmt.distribution_account_id = gcc.code_combination_id(+)
         AND (logical_transaction = 2 OR logical_transaction IS NULL)
         AND ood.operating_unit IN (123, 125)
         AND mtt.transaction_type_name IN ('Account alias receipt',
                                           'Backflush Transfer',
                                           'Direct Org Transfer',
                                           'Miscellaneous receipt',
                                           'Miscellaneous Recpt(RG Update)',
                                           'Move Order Return',
                                           'PO Receipt',
                                           'RMA Receipt',
                                           'WIP Byproduct Completion',
                                           'WIP Completion',
                                           'WIP Return',
                                           'Account alias issue',
                                           'Backflush Transfer',
                                           'Direct Org Transfer',
                                           'Intransit Shipment',
                                           'Material Issue to Production',
                                           'Miscellaneous issue',
                                           'Move Order Issue',
                                           'Return to Vendor',
                                           'Sales order issue',
                                           'WIP Byproduct Return',
                                           'WIP Completion Return',
                                           'WIP Issue')
         AND (   :p_operating_unit IS NULL
              OR (ood.operating_unit = :p_operating_unit))
         AND (   :p_organization_code IS NULL
              OR (ood.organization_code = :p_organization_code))
         AND TRUNC (mmt.transaction_date) BETWEEN NVL (
                                                      :p_transaction_date_from,
                                                      TRUNC (
                                                          mmt.transaction_date))
                                              AND NVL (
                                                      :p_transaction_date_to,
                                                      TRUNC (
                                                          mmt.transaction_date))
GROUP BY mtt.transaction_type_name,
         ood.operating_unit,
         ood.organization_code,
         --            gcc.segment1
         --         || '.'
         --         || gcc.segment2
         --         || '.'
         --         || gcc.segment3
         --         || '.'
         --         || gcc.segment4
         --         || '.'
         --         || gcc.segment5
         --         || '.'
         --         || gcc.segment6
         --         || '.'
         --         || gcc.segment7
         --         || '.'
         --         || gcc.segment8
         --         || '.'
         --         || gcc.segment9,
         gcc.segment5,
         NVL (mmt.transaction_cost, mmt.actual_cost)
--ORDER BY mmt.transaction_id, mmt.transaction_date;