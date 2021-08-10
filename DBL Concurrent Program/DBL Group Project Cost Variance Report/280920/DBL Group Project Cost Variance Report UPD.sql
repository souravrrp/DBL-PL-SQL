/* Formatted on 9/28/2020 3:42:56 PM (QP5 v5.354) */
  SELECT PROJECT_NAME,
         BUILDING_LEVEL_NAME,
         SUM (NVL (MATERIAL_BUDGET, 0))
             MATERIAL_BUDGET,
         SUM (NVL (LABOR_BUDGET, 0))
             LABOR_BUDGET,
         SUM (NVL (MATERIAL_CONSUMPTION, 0))
             MATERIAL_CONSUMPTION,
         SUM (NVL (LABOR_CONSUMPTION, 0))
             LABOR_CONSUMPTION,
         SUM (NVL (MATERIAL_BUDGET, 0)) - SUM (NVL (MATERIAL_CONSUMPTION, 0))
             MATERIAL_VARIANCE,
         SUM (NVL (LABOR_BUDGET, 0)) - SUM (NVL (LABOR_CONSUMPTION, 0))
             LABOR_VARIANCE,
         SUM (NVL (MATERIAL_PAYABLE, 0))
             MATERIAL_PAYABLE,
         SUM (NVL (MATERIAL_PAYMENT, 0))
             MATERIAL_PAYMENT
    FROM (  SELECT PROJECT_NAME,
                   BUILDING_LEVEL_NAME,
                   NULL                          MATERIAL_BUDGET,
                   SUM (PERIODIC_LABOR_COST)     LABOR_BUDGET,
                   NULL                          MATERIAL_CONSUMPTION,
                   NULL                          LABOR_CONSUMPTION,
                   NULL                          MATERIAL_PAYABLE,
                   NULL                          MATERIAL_PAYMENT
              FROM (  SELECT PROJECT_NAME,
                             xxdbl.com.GET_PROJECT_BUILDING_LEVEL (
                                 building_level_id)
                                 BUILDING_LEVEL_NAME,
                             PROJECT_WORK_QTY_ID,
                             NVL (LABOR_RATE, 0) * NVL (SUB_WORK_QTY, 0)
                                 TOTAL_LABOR_COST,
                             NVL (
                                 ROUND (
                                       (LABOR_RATE * SUB_WORK_QTY)
                                     / ((WORK_END_DATE - WORK_START_DATE) + 1)
                                     * (  (  CASE
                                                 WHEN WORK_end_date >= :P_TO_DATE
                                                 THEN
                                                     :p_to_date
                                                 ELSE
                                                     WORK_end_date
                                             END
                                           - CASE
                                                 WHEN WORK_start_date <=
                                                      :P_FROM_DATE
                                                 THEN
                                                     :p_from_date
                                                 ELSE
                                                     WORK_start_date
                                             END)
                                        + 1),
                                     2),
                                 0)
                                 PERIODIC_LABOR_COST
                        FROM estimation_vu            --PROJECT_WISE_WORK_QNT,
                       WHERE     WORK_START_DATE IS NOT NULL
                             AND (   WORK_START_DATE BETWEEN :P_FROM_DATE
                                                         AND :P_TO_DATE
                                  OR WORK_END_DATE BETWEEN :P_FROM_DATE
                                                       AND :P_TO_DATE
                                  OR (    WORK_START_DATE >= :P_FROM_DATE
                                      AND WORK_END_DATE <= :P_TO_DATE)
                                  OR (    WORK_START_DATE <= :P_FROM_DATE
                                      AND WORK_END_DATE >= :P_TO_DATE))
                             AND PROJECT_ID = NVL ( :P_PROJECT_ID, PROJECT_ID)
                             AND ORG_ID = NVL ( :P_ORG_ID, ORG_ID)
                    GROUP BY PROJECT_NAME,
                             xxdbl.com.GET_PROJECT_BUILDING_LEVEL (
                                 building_level_id),
                             PROJECT_WORK_QTY_ID,
                             WORK_END_DATE,
                             WORK_START_DATE,
                             LABOR_RATE,
                             SUB_WORK_QTY)
          GROUP BY PROJECT_NAME, BUILDING_LEVEL_NAME
          UNION ALL
            SELECT PROJECT_NAME,
                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (building_level_id)
                       BUILDING_LEVEL_NAME,
                   SUM (
                       NVL (
                           ROUND (
                                 (TOTAL_MATERIAL_PRICE)
                               / ((WORK_END_DATE - WORK_START_DATE) + 1)
                               * (  (  CASE
                                           WHEN WORK_end_date >= :P_TO_DATE
                                           THEN
                                               :p_to_date
                                           ELSE
                                               WORK_end_date
                                       END
                                     - CASE
                                           WHEN WORK_start_date <= :P_FROM_DATE
                                           THEN
                                               :p_from_date
                                           ELSE
                                               WORK_start_date
                                       END)
                                  + 1),
                               2),
                           0))
                       MATERIAL_BUDGET,
                   NULL
                       LABOR_BUDGET,
                   NULL
                       MATERIAL_CONSUMPTION,
                   NULL
                       LABOR_CONSUMPTION,
                   NULL
                       MATERIAL_PAYABLE,
                   NULL
                       MATERIAL_PAYMENT
              FROM estimation_vu                      --PROJECT_WISE_WORK_QNT,
             WHERE     WORK_START_DATE IS NOT NULL
                   AND (   WORK_START_DATE BETWEEN :P_FROM_DATE AND :P_TO_DATE
                        OR WORK_END_DATE BETWEEN :P_FROM_DATE AND :P_TO_DATE
                        OR (    WORK_START_DATE >= :P_FROM_DATE
                            AND WORK_END_DATE <= :P_TO_DATE)
                        OR (    WORK_START_DATE <= :P_FROM_DATE
                            AND WORK_END_DATE >= :P_TO_DATE))
                   AND PROJECT_ID = NVL ( :P_PROJECT_ID, PROJECT_ID)
                   AND ORG_ID = NVL ( :P_ORG_ID, ORG_ID)
          GROUP BY PROJECT_NAME,
                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (building_level_id)
            HAVING SUM (NVL (TOTAL_MATERIAL_PRICE, 0)) > 0
          --          UNION ALL
          --            SELECT xxdbl.COM.GET_PROJECT (om.project_id) PROJECT_NAME,
          --                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (BUILDING_LEVEL_ID)
          --                      BUILDING_LEVEL_LOOKUP_CODE,
          --                   NULL MATERIAL_BUDGET,
          --                   NULL LABOR_BUDGET,
          --                   SUM(CASE
          --                          WHEN OPENING_TYPE = 'ITEM CONSUMPTION' THEN TOTAL_VALUE
          --                          ELSE 0
          --                       END)
          --                      MATERIAL_CONSUMPTION,
          --                   SUM(CASE
          --                          WHEN OPENING_TYPE = 'LABOR CONSUMPTION'
          --                          THEN
          --                             TOTAL_VALUE
          --                          ELSE
          --                             0
          --                       END)
          --                      LABOR_CONSUMPTION,
          --                   NULL MATERIAL_PAYABLE,
          --                   NULL MATERIAL_PAYMENT
          --              FROM XXCPMPROJ_OPENING_MST om, XXCPMPROJ_OPENING_DTL od
          --             WHERE     om.project_id = od.project_id
          --                   AND om.opening_id = od.opening_id
          --                   AND OPENING_DATE BETWEEN :p_from_date AND :P_TO_DATE
          --                   AND om.PROJECT_ID = NVL (:P_PROJECT_ID, om.PROJECT_ID)
          --          GROUP BY om.ORG_ID,
          --                   xxdbl.COM.GET_PROJECT (om.project_id),
          --                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (BUILDING_LEVEL_ID)
          UNION ALL
            SELECT xxdbl.COM.GET_PROJECT (AD.ATTRIBUTE1)
                       PROJECT_NAME,
                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (AD.attribute2)
                       BUILDING_LEVEL_LOOKUP_CODE,
                   NULL
                       MATERIAL_BUDGET,
                   NULL
                       LABOR_BUDGET,
                   NULL
                       MATERIAL_CONSUMPTION,
                   SUM (
                       ROUND (
                             AIP.AMOUNT
                           / NVL (APH.BASE_AMOUNT, APH.INVOICE_AMOUNT)
                           * NVL (AD.BASE_AMOUNT, AD.AMOUNT),
                           2))
                       LABOR_CONSUMPTION,
                   NULL
                       MATERIAL_PAYABLE,
                   NULL
                       MATERIAL_PAYMENT
              FROM AP_INVOICES_ALL           APH,
                   AP_CHECKS_ALL             CK,
                   AP_INVOICE_PAYMENTS_ALL   AIP,
                   AP_INVOICE_DISTRIBUTIONS_ALL AD
             WHERE     APH.INVOICE_ID = AD.INVOICE_ID
                   AND CK.CHECK_ID = AIP.CHECK_ID
                   AND AIP.INVOICE_ID = APH.INVOICE_ID
                   AND ad.ATTRIBUTE_CATEGORY = 'Construction Details'
                   AND ad.ATTRIBUTE3 = 'LABOR'
                   AND AD.ATTRIBUTE1 = NVL ( :P_PROJECT_ID, AD.ATTRIBUTE1)
                   AND (   :P_FROM_DATE IS NULL
                        OR CHECK_DATE BETWEEN :P_FROM_DATE AND :P_TO_DATE)
                   AND AD.ORG_ID = NVL ( :P_ORG_ID, AD.ORG_ID)
          GROUP BY xxdbl.COM.GET_PROJECT (AD.ATTRIBUTE1),
                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (AD.attribute2)
          UNION ALL
            SELECT PROJ
                       PROJECT_NAME,
                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (level_id)
                       BUILDING_LEVEL_NAME,
                   NULL
                       MATERIAL_BUDGET,
                   NULL
                       LABOR_BUDGET,
                   SUM (NVL (ISS_VAL, 0)) - SUM (NVL (ADJ_ISS_VAL, 0))
                       MATERIAL_CONSUMPTION,
                   NULL
                       LABOR_CONSUMPTION,
                   NULL
                       MATERIAL_PAYABLE,
                   NULL
                       MATERIAL_PAYMENT
              FROM XX_INV_PROJECT_LEDGER_V LG
             WHERE     LG.PROJECT_ID = NVL ( :P_PROJECT_ID, LG.PROJECT_ID)
                   AND TRUNC (TRANSACTION_DATE) BETWEEN :P_FROM_DATE
                                                    AND :P_TO_DATE
                   AND OPERATING_UNIT = NVL ( :P_ORG_ID, OPERATING_UNIT)
          GROUP BY PROJ, xxdbl.com.GET_PROJECT_BUILDING_LEVEL (level_id)
            HAVING SUM (NVL (ISS_VAL, 0)) - SUM (NVL (ADJ_ISS_VAL, 0)) <> 0
          UNION ALL
            SELECT xxdbl.com.get_project (rt.attribute10)
                       PROJECT_NAME,
                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (rt.attribute12)
                       BUILDING_LEVEL_NAME,
                   NULL
                       MATERIAL_BUDGET,
                   NULL
                       LABOR_BUDGET,
                   NULL
                       MATERIAL_CONSUMPTION,
                   NULL
                       LABOR_CONSUMPTION,
                   SUM (ROUND (NVL (AL.BASE_AMOUNT, AL.AMOUNT), 2))
                       MATERIAL_PAYABLE,
                   NULL
                       MATERIAL_PAYMENT
              FROM AP_INVOICES_ALL     APH,
                   AP_SUPPLIERS        SUP,
                   RCV_TRANSACTIONS    RT,
                   AP_INVOICE_LINES_ALL AL,
                   mtl_system_items_b_kfv ITM
             WHERE     APH.INVOICE_ID = AL.INVOICE_ID
                   AND APH.VENDOR_ID = SUP.VENDOR_ID
                   AND AL.RCV_TRANSACTION_ID = RT.TRANSACTION_ID
                   AND AL.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
                   AND RT.ORGANIZATION_ID = ITM.ORGANIZATION_ID
                   AND AL.INVENTORY_ITEM_ID IS NOT NULL
                   AND RT.ATTRIBUTE_CATEGORY = 'Project Information'
                   AND RT.ATTRIBUTE10 IS NOT NULL
                   AND RT.ATTRIBUTE10 = NVL ( :P_PROJECT_ID, RT.ATTRIBUTE10)
                   AND (   :P_FROM_DATE IS NULL
                        OR APH.GL_DATE BETWEEN :P_FROM_DATE AND :P_TO_DATE)
                   AND APH.ORG_ID = NVL ( :P_ORG_ID, APH.ORG_ID)
          GROUP BY xxdbl.com.get_project (rt.attribute10),
                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (rt.attribute12)
          UNION ALL
            SELECT xxdbl.com.get_project (rt.attribute10)
                       PROJECT_NAME,
                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (rt.attribute12)
                       BUILDING_LEVEL_NAME,
                   NULL
                       MATERIAL_BUDGET,
                   NULL
                       LABOR_BUDGET,
                   NULL
                       MATERIAL_CONSUMPTION,
                   NULL
                       LABOR_CONSUMPTION,
                   NULL
                       MATERIAL_PAYABLE,
                   SUM (
                       ROUND (
                             AIP.AMOUNT
                           / NVL (APH.BASE_AMOUNT, APH.INVOICE_AMOUNT)
                           * NVL (AL.BASE_AMOUNT, AL.AMOUNT),
                           2))
                       MATERIAL_PAYMENT
              FROM AP_INVOICES_ALL      APH,
                   AP_SUPPLIERS         SUP,
                   AP_CHECKS_ALL        CK,
                   AP_INVOICE_PAYMENTS_ALL AIP,
                   RCV_TRANSACTIONS     RT,
                   AP_INVOICE_LINES_ALL AL,
                   mtl_system_items_b_kfv ITM
             WHERE     APH.INVOICE_ID = AL.INVOICE_ID
                   AND APH.VENDOR_ID = SUP.VENDOR_ID
                   AND CK.CHECK_ID = AIP.CHECK_ID
                   AND AIP.INVOICE_ID = APH.INVOICE_ID
                   AND AL.RCV_TRANSACTION_ID = RT.TRANSACTION_ID
                   AND AL.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
                   AND RT.ORGANIZATION_ID = ITM.ORGANIZATION_ID
                   AND AL.INVENTORY_ITEM_ID IS NOT NULL
                   AND RT.ATTRIBUTE_CATEGORY = 'Project Information'
                   AND RT.ATTRIBUTE10 IS NOT NULL
                   AND RT.ATTRIBUTE10 = NVL ( :P_PROJECT_ID, RT.ATTRIBUTE10)
                   AND (   :P_FROM_DATE IS NULL
                        OR CK.CHECK_DATE BETWEEN :P_FROM_DATE AND :P_TO_DATE)
                   AND APH.ORG_ID = NVL ( :P_ORG_ID, APH.ORG_ID)
          GROUP BY xxdbl.com.get_project (rt.attribute10),
                   xxdbl.com.GET_PROJECT_BUILDING_LEVEL (rt.attribute12)
          UNION ALL
            SELECT xxdbl.com.get_project (rt.attribute10)
                       project_name,
                   xxdbl.com.get_project_building_level (rt.attribute12)
                       building_level_name,
                   aph.doc_sequence_value,
                   NULL
                       material_budget,
                   NULL
                       labor_budget,
                   NULL
                       material_consumption,
                   NULL
                       labor_consumption,
                   SUM (ROUND (NVL (al.base_amount, al.amount), 2))
                       material_payable,
                   NULL
                       material_payment
              FROM ap_invoices_all     aph,
                   ap_suppliers        sup,
                   ap_invoice_lines_all al,
                   rcv_transactions    rt,
                   rcv_transactions    rcvt,
                   mtl_system_items_b_kfv itm
             WHERE     1 = 1
                   AND (   ( :p_project_id IS NULL)
                        OR (rt.attribute10 = :p_project_id))
                   AND rt.attribute_category = 'Project Information'
                   AND rt.attribute10 IS NOT NULL
                   --AND rcvt.shipment_header_id = 411575
                   AND rt.shipment_header_id = rcvt.shipment_header_id(+)
                   AND rcvt.attribute10 IS NULL
                   AND rcvt.attribute_category IS NULL
                   AND al.rcv_transaction_id = rcvt.transaction_id
                   AND al.inventory_item_id = itm.inventory_item_id
                   AND rcvt.organization_id = itm.organization_id
                   AND aph.invoice_id = al.invoice_id
                   AND aph.vendor_id = sup.vendor_id
          GROUP BY xxdbl.com.get_project (rt.attribute10),
                   xxdbl.com.get_project_building_level (rt.attribute12),
                   aph.doc_sequence_value)
GROUP BY PROJECT_NAME, BUILDING_LEVEL_NAME
ORDER BY PROJECT_NAME, BUILDING_LEVEL_NAME