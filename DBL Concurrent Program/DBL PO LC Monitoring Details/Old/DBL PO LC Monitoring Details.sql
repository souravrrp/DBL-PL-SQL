/* Formatted on 3/21/2020 11:24:14 AM (QP5 v5.287) */
  SELECT led.UNIT_NAME OU_Name,
         led.legal_entity_id,
         led.legal_entity_name,
         MSI.DESCRIPTION AS "Type",
         sup.vendor_name AS "Party_Name",
         pla.unit_price AS PI_Rate,
         NULL LC_Quntity,
         NULL LC_VALUE,
         NULL Value_Actual,
         NULL LC_NUMBER,
         NULL LC_OPENING_DATE,
         pha.segment1 "PO_NUMBER",
         rsh.receipt_num SHIP_NUM,
         rt.transaction_date SHIP_DATE,
         ROUND (SYSDATE - rsh.CREATION_DATE) AGING_DAY,
         RT.ORGANIZATION_ID,
         MSI.SEGMENT1 INV_ITEM,
         NULL COMPONENT_NAME,
         rt.quantity PRIMARY_QTY,
         rt.uom_code UNIT_OF_MEASURE,
         (pla.unit_price * pla.quantity) PO_AMOUNT,
         NULL ACTUAL_AMT,
         NULL ESTIMATED_AMT,
         NULL EXCESS_ESTIMATION_AMT,
         NULL EXCESS_ESTIMATION_PER,
         TO_CHAR ( :P_DATE_FROM) CP_DATE_FROM,
         TO_CHAR ( :P_DATE_TO) CP_DATE_TO
    FROM po_headers_all pha,
         po_lines_all pla,
         apps.xxdbl_company_le_mapping_v led,
         apps.org_organization_definitions odd,
         apps.hr_operating_units hou,
         po_distributions_all pda,
         po_requisition_headers_all prha,
         po_requisition_lines_all prla,
         po_req_distributions_all prda,
         apps.po_line_locations_all pll,
         apps.po_line_types_b plt,
         rcv_transactions rt,
         --rcv_shipment_lines rsl,
         rcv_shipment_headers rsh,
         apps.mtl_item_categories_v cat,
         apps.ap_suppliers sup,
         apps.ap_supplier_sites_all sups,
         apps.mtl_txn_request_lines mtrl,
         apps.mtl_txn_request_headers mtrh,
         apps.mtl_system_items_b msi
   WHERE     1 = 1
         AND prla.requisition_header_id = prha.requisition_header_id(+)
         AND prda.requisition_line_id = prla.requisition_line_id(+)
         AND pda.req_distribution_id = prda.distribution_id(+)
         AND pla.po_line_id = pda.po_line_id(+)
         AND pha.org_id = led.org_id
         AND pda.destination_organization_id = odd.organization_id
         AND pha.org_id = hou.organization_id
         AND pha.po_header_id = pla.po_header_id(+)
         AND pha.po_header_id = pll.po_header_id(+)
         AND pla.po_line_id = pll.po_line_id(+)
         AND pda.line_location_id = pll.line_location_id(+)
         AND pla.line_type_id = plt.line_type_id(+)
         --AND pda.po_distribution_id = rt.po_distribution_id(+)
         AND pha.po_header_id = RT.po_header_id(+)
         AND pla.po_line_id = RT.po_line_id(+)
         AND pha.type_lookup_code = 'STANDARD'
         AND rt.transaction_type = 'RECEIVE'
         AND pha.vendor_id = sup.vendor_id
         AND sup.vendor_id = sups.vendor_id
         AND rt.shipment_header_id = rsh.shipment_header_id(+)
         AND pla.item_id = msi.inventory_item_id(+)
         AND pda.destination_organization_id = msi.organization_id(+)
         AND msi.inventory_item_id = cat.inventory_item_id(+)
         AND msi.organization_id = cat.organization_id(+)
         AND prda.distribution_id = mtrl.attribute14(+)
         AND mtrl.header_id = mtrh.header_id(+)
         AND msi.ORGANIZATION_ID = :P_ORGANIZATION_ID
         AND (   :P_DATE_FROM IS NULL
              OR TRUNC (RT.TRANSACTION_DATE) BETWEEN :P_DATE_FROM
                                                 AND :P_DATE_TO)
         AND NOT EXISTS
                (SELECT 1
                   FROM XX_LC_DETAILS LC
                  WHERE pha.segment1 = lc.po_number AND lc_status = 'Y')
         AND NOT EXISTS
                (SELECT 1
                   FROM xxdbl.xx_explc_btb_req_link b2b,
                        xxdbl.xx_explc_btb_mst b2b2
                  WHERE     pha.segment1 = b2b.po_number
                        AND b2b.btb_lc_no = b2b2.btb_lc_no)
GROUP BY led.UNIT_NAME,
         led.legal_entity_id,
         led.legal_entity_name,
         MSI.DESCRIPTION,
         sup.vendor_name,
         pla.unit_price,
         pha.segment1,
         rsh.receipt_num,
         rt.transaction_date,
         ROUND (SYSDATE - rsh.CREATION_DATE),
         RT.ORGANIZATION_ID,
         MSI.SEGMENT1,
         rt.quantity,
         rt.uom_code,
         (pla.unit_price * pla.quantity)
UNION ALL
  SELECT                                    --x.ship_header_id ship_header_id,
         --    x.adjustment_num adjustment_num,
         led.UNIT_NAME OU_Name,
         led.legal_entity_id,
         led.legal_entity_name,
         X.DESCRIPTION AS "Type",
         X.SUPPLIER_NAME AS "Party_Name",
         X.LC_Quntity,
         X.PI_Rate,
         X.LC_VALUE AS "LC_VALUE",
         X.VALUE_ACTUAL,
         -------------------------------------
         X.LC_NUMBER,
         X.LC_OPENING_DATE,
         X.PO_NUMBER,
         X.SHIP_NUM,
         X.CREATION_DATE SHIP_DATE,
         ROUND (SYSDATE - X.CREATION_DATE) AGING_DAY,
         --    x.ship_line_group_id ship_line_group_id,
         -- x.ship_line_id ship_line_id,
         -- x.parent_ship_line_id parent_ship_line_id,
         --    x.ship_line_num ship_line_num,
         X.ORGANIZATION_ID ORGANIZATION_ID,
         --    x.inventory_item_id inventory_item_id,
         --   x.inv_item inv_item,
         --       x.description,
         --    x.primary_qty primary_qty,
         --     x.unit_of_measure unit_of_measure,
         --    x.component_type component_type,
         --  x.component_code component_code,
         X.INV_ITEM,
         X.COMPONENT_NAME,
         X.PRIMARY_QTY,
         X.UNIT_OF_MEASURE,
         X.PO_AMOUNT,
         --   x.charge_line_type_id charge_line_type_id,
         ROUND (SUM (X.ALLOCATED_AMT), 0) ACTUAL_AMT,
         --         RATIO_TO_REPORT(SUM (x.allocated_amt))
         --            OVER (
         --               PARTITION BY x.ship_header_id, x.ship_line_id, x.adjustment_num)
         --         * 100
         --            allocation_percent,
         ROUND (SUM (X.ESTIMATED_ALLOCATED_AMT), 0) ESTIMATED_AMT,
         ROUND (SUM (X.ALLOCATED_AMT) - SUM (X.ESTIMATED_ALLOCATED_AMT), 0)
            EXCESS_ESTIMATION_AMT,
           ROUND ( (SUM (X.ALLOCATED_AMT) - SUM (X.ESTIMATED_ALLOCATED_AMT)),
                  0)
         / ROUND (SUM (X.ESTIMATED_ALLOCATED_AMT), 0)
         * 100
            EXCESS_ESTIMATION_PER,
         TO_CHAR ( :P_DATE_FROM) CP_DATE_FROM,
         TO_CHAR ( :P_DATE_TO) CP_DATE_TO
    FROM (SELECT ALLOC.SHIP_HEADER_ID,
                 ALLOC.ADJUSTMENT_NUM,
                 LC.LC_NUMBER,
                 LC.LC_OPENING_DATE,
                 LC.SUPPLIER_NAME,
                 lc.LC_VALUE AS "LC_VALUE",
                 (lc.LC_VALUE * POHA.rate) Value_Actual,
                 pla.quantity AS LC_Quntity,
                 pla.unit_price AS PI_Rate,
                 POHA.SEGMENT1 PO_NUMBER,
                 POHA.ORG_ID,
                 SH.SHIP_NUM,
                 SH.CREATION_DATE,
                 SL.SHIP_LINE_GROUP_ID,
                 SL.SHIP_LINE_ID,
                 SL.PARENT_SHIP_LINE_ID,
                 SL.SHIP_LINE_NUM,
                 SH.ORGANIZATION_ID,
                 SL.INVENTORY_ITEM_ID,
                 MSI.CONCATENATED_SEGMENTS INV_ITEM,
                 MSI.DESCRIPTION,
                 'ITEM' COMPONENT_NAME,
                 SL.PRIMARY_QTY,
                 UOM.UNIT_OF_MEASURE,
                 LC.FUNCTIONAL_AMOUNT PO_AMOUNT,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_CHARGE_LINES', 'CHARGE',
                         'INL_TAX_LINES', 'TAX',
                         'ITEM PRICE')
                    COMPONENT_TYPE,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_SHIP_HEADERS', 'OTHERS',
                         'INL_SHIP_LINES', 'OTHERS',
                         'INL_CHARGE_LINES', PE.PRICE_ELEMENT_CODE,
                         'INL_TAX_LINES', TL.TAX_CODE,
                         MSI.CONCATENATED_SEGMENTS)
                    COMPONENT_CODE,
                 CL.CHARGE_LINE_TYPE_ID,
                 ALLOC.ALLOCATION_AMT ALLOCATED_AMT,
                 ALLOC.ESTIMATED_AMT ESTIMATED_ALLOCATED_AMT
            FROM MTL_UNITS_OF_MEASURE UOM,
                 PON_PRICE_ELEMENT_TYPES_VL PE,
                 MTL_SYSTEM_ITEMS_KFV MSI,
                 INL_CHARGE_LINES CL,
                 INL_TAX_LINES TL,
                 INL_ASSOCIATIONS ASSOC,
                 INL_SHIP_HEADERS_ALL SH,
                 INL_SHIP_LINES_ALL SL2,
                 INL_SHIP_LINES_ALL SL,
                 INL_ALLOCATIONS_V ALLOC,
                 PO_LINE_LOCATIONS_ALL PLLA,
                 PO_HEADERS_ALL POHA,
                 apps.po_lines_all pla,
                 XX_LC_DETAILS LC
           WHERE     UOM.UOM_CODE = SL.PRIMARY_UOM_CODE
                 AND PE.PRICE_ELEMENT_TYPE_ID(+) = CL.CHARGE_LINE_TYPE_ID
                 AND MSI.ORGANIZATION_ID = SH.ORGANIZATION_ID
                 AND MSI.INVENTORY_ITEM_ID = SL.INVENTORY_ITEM_ID
                 AND POHA.PO_HEADER_ID = PLLA.PO_HEADER_ID
                 AND POHA.po_header_id = pla.po_header_id
                 AND POHA.org_id = pla.org_id
                 AND pla.po_line_id = PLLA.po_line_id
                 AND SL.SHIP_LINE_SOURCE_ID = PLLA.LINE_LOCATION_ID
                 AND SL2.SHIP_LINE_ID(+) =
                        DECODE (ALLOC.FROM_PARENT_TABLE_NAME,
                                'INL_SHIP_LINES', ALLOC.FROM_PARENT_TABLE_ID,
                                NULL)
                 AND CL.CHARGE_LINE_ID(+) =
                        DECODE (ALLOC.FROM_PARENT_TABLE_NAME,
                                'INL_CHARGE_LINES', ALLOC.FROM_PARENT_TABLE_ID,
                                NULL)
                 AND TL.TAX_LINE_ID(+) =
                        DECODE (ALLOC.FROM_PARENT_TABLE_NAME,
                                'INL_TAX_LINES', ALLOC.FROM_PARENT_TABLE_ID,
                                NULL)
                 AND SL2.SHIP_HEADER_ID(+) = ALLOC.SHIP_HEADER_ID
                 AND ASSOC.ASSOCIATION_ID(+) = ALLOC.ASSOCIATION_ID
                 AND SH.SHIP_HEADER_ID = SL.SHIP_HEADER_ID
                 AND SH.SHIP_HEADER_ID = ALLOC.SHIP_HEADER_ID
                 AND SL.SHIP_HEADER_ID = ALLOC.SHIP_HEADER_ID
                 AND SL.SHIP_LINE_ID = ALLOC.SHIP_LINE_ID
                 AND POHA.PO_HEADER_ID = LC.PO_HEADER_ID
                 AND LC.LC_STATUS = 'Y'
                 AND SH.SHIP_STATUS_CODE <> 'CLOSED'
                 AND ALLOC.ADJUSTMENT_NUM =
                        (SELECT MAX (ADJUSTMENT_NUM)
                           FROM INL_ALLOCATIONS_V
                          WHERE     SHIP_HEADER_ID = SL.SHIP_HEADER_ID
                                AND SHIP_LINE_ID = SL.SHIP_LINE_ID
                                AND PARENT_SHIP_LINE_ID =
                                       SL.PARENT_SHIP_LINE_ID)
                 AND DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                             'INL_CHARGE_LINES', 'CHARGE',
                             'INL_TAX_LINES', 'TAX',
                             'ITEM PRICE') = 'ITEM PRICE'
          UNION
          SELECT ALLOC.SHIP_HEADER_ID,
                 ALLOC.ADJUSTMENT_NUM,
                 LC.LC_NUMBER,
                 LC.LC_OPENING_DATE,
                 LC.SUPPLIER_NAME,
                 lc.LC_VALUE AS "LC_VALUE",
                 (lc.LC_VALUE * POHA.rate) Value_Actual,
                 pla.quantity AS LC_Quntity,
                 pla.unit_price AS PI_Rate,
                 POHA.SEGMENT1 PO_NUMBER,
                 POHA.ORG_ID,
                 SH.SHIP_NUM,
                 SH.CREATION_DATE,
                 SL.SHIP_LINE_GROUP_ID,
                 SL.SHIP_LINE_ID,
                 SL.PARENT_SHIP_LINE_ID,
                 SL.SHIP_LINE_NUM,
                 SH.ORGANIZATION_ID,
                 SL.INVENTORY_ITEM_ID,
                 MSI.CONCATENATED_SEGMENTS INV_ITEM,
                 MSI.DESCRIPTION,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_SHIP_HEADERS', 'OTHERS',
                         'INL_SHIP_LINES', 'OTHERS',
                         'INL_CHARGE_LINES', PE.NAME,
                         'INL_TAX_LINES', TL.TAX_CODE)
                    COMPONENT_NAME,
                 SL.PRIMARY_QTY,
                 UOM.UNIT_OF_MEASURE,
                 LC.FUNCTIONAL_AMOUNT PO_AMOUNT,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_CHARGE_LINES', 'CHARGE',
                         'INL_TAX_LINES', 'TAX',
                         'ITEM PRICE')
                    COMPONENT_TYPE,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_SHIP_HEADERS', 'OTHERS',
                         'INL_SHIP_LINES', 'OTHERS',
                         'INL_CHARGE_LINES', PE.PRICE_ELEMENT_CODE,
                         'INL_TAX_LINES', TL.TAX_CODE,
                         MSI.CONCATENATED_SEGMENTS)
                    COMPONENT_CODE,
                 CL.CHARGE_LINE_TYPE_ID,
                 ALLOC.ALLOCATION_AMT ALLOCATED_AMT,
                 ALLOC.ESTIMATED_AMT ESTIMATED_ALLOCATED_AMT
            FROM MTL_UNITS_OF_MEASURE UOM,
                 PON_PRICE_ELEMENT_TYPES_VL PE,
                 MTL_SYSTEM_ITEMS_KFV MSI,
                 INL_CHARGE_LINES CL,
                 INL_TAX_LINES TL,
                 INL_ASSOCIATIONS ASSOC,
                 INL_SHIP_HEADERS_ALL SH,
                 INL_SHIP_LINES_ALL SL2,
                 INL_SHIP_LINES_ALL SL,
                 INL_ALLOCATIONS_V ALLOC,
                 PO_LINE_LOCATIONS_ALL PLLA,
                 PO_HEADERS_ALL POHA,
                 apps.po_lines_all pla,
                 XX_LC_DETAILS LC
           WHERE     UOM.UOM_CODE = SL.PRIMARY_UOM_CODE
                 AND PE.PRICE_ELEMENT_TYPE_ID(+) = CL.CHARGE_LINE_TYPE_ID
                 AND MSI.ORGANIZATION_ID = SH.ORGANIZATION_ID
                 AND MSI.INVENTORY_ITEM_ID = SL.INVENTORY_ITEM_ID
                 AND POHA.PO_HEADER_ID = PLLA.PO_HEADER_ID
                 AND POHA.po_header_id = pla.po_header_id
                 AND POHA.org_id = pla.org_id
                 AND pla.po_line_id = PLLA.po_line_id
                 AND SL.SHIP_LINE_SOURCE_ID = PLLA.LINE_LOCATION_ID
                 AND SL2.SHIP_LINE_ID(+) =
                        DECODE (ALLOC.FROM_PARENT_TABLE_NAME,
                                'INL_SHIP_LINES', ALLOC.FROM_PARENT_TABLE_ID,
                                NULL)
                 AND CL.CHARGE_LINE_ID(+) =
                        DECODE (ALLOC.FROM_PARENT_TABLE_NAME,
                                'INL_CHARGE_LINES', ALLOC.FROM_PARENT_TABLE_ID,
                                NULL)
                 AND TL.TAX_LINE_ID(+) =
                        DECODE (ALLOC.FROM_PARENT_TABLE_NAME,
                                'INL_TAX_LINES', ALLOC.FROM_PARENT_TABLE_ID,
                                NULL)
                 AND SL2.SHIP_HEADER_ID(+) = ALLOC.SHIP_HEADER_ID
                 AND ASSOC.ASSOCIATION_ID(+) = ALLOC.ASSOCIATION_ID
                 AND SH.SHIP_HEADER_ID = SL.SHIP_HEADER_ID
                 AND SH.SHIP_HEADER_ID = ALLOC.SHIP_HEADER_ID
                 AND SL.SHIP_HEADER_ID = ALLOC.SHIP_HEADER_ID
                 AND SL.SHIP_LINE_ID = ALLOC.SHIP_LINE_ID
                 AND POHA.PO_HEADER_ID = LC.PO_HEADER_ID
                 AND SH.SHIP_STATUS_CODE <> 'CLOSED'
                 AND LC.LC_STATUS = 'Y'
                 AND ALLOC.ADJUSTMENT_NUM =
                        (SELECT MAX (ADJUSTMENT_NUM)
                           FROM INL_ALLOCATIONS_V
                          WHERE     SHIP_HEADER_ID = SL.SHIP_HEADER_ID
                                AND SHIP_LINE_ID = SL.SHIP_LINE_ID
                                AND PARENT_SHIP_LINE_ID =
                                       SL.PARENT_SHIP_LINE_ID)
                 AND DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                             'INL_CHARGE_LINES', 'CHARGE',
                             'INL_TAX_LINES', 'TAX',
                             'ITEM PRICE') = 'CHARGE') X,
         ORG_ORGANIZATION_DEFINITIONS OOD,
         XXDBL_COMPANY_LE_MAPPING_V LED
   WHERE     X.ORGANIZATION_ID = :P_ORGANIZATION_ID
         AND OOD.OPERATING_UNIT = LED.ORG_ID
         AND X.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         AND (   :P_DATE_FROM IS NULL
              OR TRUNC (X.CREATION_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO)
GROUP BY X.LC_NUMBER,
         X.LC_OPENING_DATE,
         X.PO_NUMBER,
         X.SHIP_NUM,
         X.PRIMARY_QTY,
         X.UNIT_OF_MEASURE,
         X.PO_AMOUNT,
         X.CREATION_DATE,
         X.COMPONENT_NAME,
         X.INV_ITEM,
         X.COMPONENT_TYPE,
         X.ORGANIZATION_ID,
         led.UNIT_NAME,
         led.legal_entity_id,
         led.legal_entity_name,
         X.DESCRIPTION,
         X.SUPPLIER_NAME,
         X.LC_Quntity,
         X.LC_VALUE,
         X.VALUE_ACTUAL,
         X.PI_Rate