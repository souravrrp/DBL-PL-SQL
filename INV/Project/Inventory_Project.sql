/* Formatted on 9/21/2020 4:01:44 PM (QP5 v5.354) */
SELECT RCVT.*
  FROM AP_INVOICE_LINES_ALL  AL,RCV_TRANSACTIONS RT, RCV_TRANSACTIONS RCVT
 WHERE     1 = 1
       AND (( :P_PROJECT_ID IS NULL) OR (RT.ATTRIBUTE10 = :P_PROJECT_ID))
       AND RT.ATTRIBUTE_CATEGORY = 'Project Information'
       --AND RT.ATTRIBUTE10 IS NOT NULL
       AND RCVT.SHIPMENT_HEADER_ID=411575
       AND RT.SHIPMENT_HEADER_ID = RCVT.SHIPMENT_HEADER_ID(+)
       --AND RCVT.ATTRIBUTE10 IS NULL
       --AND RCVT.ATTRIBUTE_CATEGORY IS NULL
       AND AL.RCV_TRANSACTION_ID = RCVT.TRANSACTION_ID
       
       
       -------------------------------------------------------------------------
       
       /* Formatted on 9/21/2020 3:40:33 PM (QP5 v5.354) */
  SELECT xxdbl.com.get_project (rt.attribute10)
             PROJECT_NAME,
         xxdbl.com.GET_PROJECT_BUILDING_LEVEL (rt.attribute12)
             BUILDING_LEVEL_NAME,
         aph.DOC_SEQUENCE_VALUE,
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
    FROM AP_INVOICES_ALL       APH,
         AP_SUPPLIERS          SUP,
         RCV_TRANSACTIONS      RT,
         AP_INVOICE_LINES_ALL  AL,
         mtl_system_items_b_kfv ITM
   WHERE     APH.INVOICE_ID = AL.INVOICE_ID
         AND APH.VENDOR_ID = SUP.VENDOR_ID
         AND AL.RCV_TRANSACTION_ID = RT.TRANSACTION_ID
         AND AL.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
         AND RT.ORGANIZATION_ID = ITM.ORGANIZATION_ID
         AND AL.INVENTORY_ITEM_ID IS NOT NULL
         --and rt.SHIPMENT_HEADER_ID=411575
         AND RT.ATTRIBUTE_CATEGORY (+)= 'Project Information'
         --AND RT.ATTRIBUTE10 IS NOT NULL
         AND RT.ATTRIBUTE10 = NVL ( :P_PROJECT_ID, RT.ATTRIBUTE10)
         AND (   :P_FROM_DATE IS NULL
              OR rt.TRANSACTION_DATE BETWEEN :P_FROM_DATE AND :P_TO_DATE)
         AND APH.ORG_ID = NVL ( :P_ORG_ID, APH.ORG_ID)
GROUP BY xxdbl.com.get_project (rt.attribute10),
         xxdbl.com.GET_PROJECT_BUILDING_LEVEL (rt.attribute12),
         aph.DOC_SEQUENCE_VALUE
         
         
         /* Formatted on 9/28/2020 3:39:57 PM (QP5 v5.354) */
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
    FROM ap_invoices_all       aph,
         ap_suppliers          sup,
         ap_invoice_lines_all  al,
         rcv_transactions      rt,
         rcv_transactions      rcvt,
         mtl_system_items_b_kfv itm
   WHERE     1 = 1
         AND (( :p_project_id IS NULL) OR (rt.attribute10 = :p_project_id))
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
         aph.doc_sequence_value