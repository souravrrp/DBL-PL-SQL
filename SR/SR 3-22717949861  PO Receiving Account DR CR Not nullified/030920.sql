/* Formatted on 9/3/2020 10:16:56 AM (QP5 v5.287) */
SELECT *
  FROM cst_lc_adj_transactions lc_txn
 WHERE NOT EXISTS
          (SELECT 1
             FROM rcv_accounting_events rae
            WHERE     rae.event_source = 'LC_ADJUSTMENTS'
                  AND rae.event_source_id = lc_txn.transaction_id
                  AND rae.organization_id = lc_txn.organization_id
                  AND rae.inventory_item_id = lc_txn.inventory_item_id
           UNION ALL
           SELECT 1
             FROM mtl_material_transactions mmt
            WHERE     DECODE (
                         mmt.source_code,
                         'LCMADJ', TO_NUMBER (mmt.transaction_reference),
                         -999) = lc_txn.transaction_id
                  AND mmt.transaction_action_id = 24
                  AND mmt.organization_id = lc_txn.organization_id
                  AND mmt.inventory_item_id = lc_txn.inventory_item_id
                  AND mmt.source_code = 'LCMADJ');


SELECT RT.po_header_id,
       RT.PO_DISTRIBUTION_ID,
       RT.PO_LINE_LOCATION_ID,
       RT.PRIMARY_QUANTITY,
       RT.PO_UNIT_PR ICE,
       RT.SHIPMENT_LINE_ID,
       RT.SHIPMENT_HEADER_ID,
       ABS (MTA.BASE_TRANSACTION_VALUE),
       RT.PRIMARY_QUANTITY * PO_UNIT_PRICE RRSL_ENTERED_DR
  FROM RCV_TRANSACTIONS RT,
       MTL_MATERIAL_TRANSACTIONS MMT,
       MTL_TRANSACTION_ACCOUNTS MTA
 WHERE     RT.TRANSACTION_ID = MMT.RCV_TRANSACTION_ID
       AND MTA.TRANSACTION_ID = MMT.TRANSACTION_ID
       AND RT.DESTINATION_TYPE_CODE = 'INVENTORY'
       AND RT.TRANSACTION_TYPE = 'DELIVER'
       AND MTA.ACCOUNTING_LINE_TYPE = 5
       AND MMT.PRIMARY_QUANTITY = RT.PRIMARY_QUANTITY
       AND MMT.ORGANIZATION_ID = RT.ORGANIZATION_ID
       AND RT.ORGANIZATION_ID = &ORGANIZATION_ID
       AND ABS (MTA.BASE_TRANSACTION_VALUE) >
              (RT.PRIMARY_QUANTITY * RT.PO_UNIT_PRICE);