/* Formatted on 1/26/2020 1:02:25 PM (QP5 v5.287) */
  SELECT                                    --x.ship_header_id ship_header_id,
         --    x.adjustment_num adjustment_num,
         led.UNIT_NAME OU_Name,
         led.legal_entity_id,
         led.legal_entity_name,
         x.lc_opening_date as "Date",
         X.LC_NUMBER,
         X.LC_OPENING_DATE,
         X.DESCRIPTION as "Type",
         X.SUPPLIER_NAME AS "Party_Name",
         X.LC_Quntity,
         X.PI_Rate,
         X.PRIMARY_QTY  as "Receive_Quantity",
         X.LC_VALUE as "LC_VALUE",
         X.VALUE_ACTUAL,
         X.COMPONENT_NAME,
         X.ORGANIZATION_ID ORGANIZATION_ID,
         ROUND (SUM (X.ALLOCATED_AMT), 0) ACTUAL_AMT,
         ROUND (SUM (X.ESTIMATED_ALLOCATED_AMT), 0) ESTIMATED_AMT
    FROM (SELECT ALLOC.SHIP_HEADER_ID,
                 ALLOC.ADJUSTMENT_NUM,
                 LC.LC_NUMBER,
                 LC.LC_OPENING_DATE,
                 LC.SUPPLIER_NAME,
                 lc.LC_VALUE as "LC_VALUE",
                 (lc.LC_VALUE*POHA.rate) Value_Actual,
                 pla.quantity as LC_Quntity,
                 pla.unit_price as PI_Rate,
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
                 and POHA.po_header_id = pla.po_header_id
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
                 --  AND msi.organization_id = 150
                 --     AND sh.SHIP_NUM = 81
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
                 lc.LC_VALUE as "LC_VALUE",
                 (lc.LC_VALUE*POHA.rate) Value_Actual,
                 pla.quantity as LC_Quntity,
                 pla.unit_price as PI_Rate,
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
                 and POHA.po_header_id = pla.po_header_id
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
                 --   AND msi.organization_id = 150
                 --    AND sh.SHIP_NUM = 81
                 AND DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                             'INL_CHARGE_LINES', 'CHARGE',
                             'INL_TAX_LINES', 'TAX',
                             'ITEM PRICE') = 'CHARGE') X,
         ORG_ORGANIZATION_DEFINITIONS OOD,
         XXDBL_COMPANY_LE_MAPPING_V LED
   WHERE     X.ORGANIZATION_ID = :P_ORGANIZATION_ID
         AND ( :P_LC_NUMBER IS NULL OR X.LC_NUMBER = :P_LC_NUMBER)
         AND ( :P_PO_NUMBER IS NULL OR X.PO_NUMBER = :P_PO_NUMBER)
         AND ( :P_SHIP_NUM_FROM IS NULL OR X.SHIP_NUM >= :P_SHIP_NUM_FROM)
         AND ( :P_SHIP_NUM_TO IS NULL OR X.SHIP_NUM <= :P_SHIP_NUM_TO)
         AND OOD.OPERATING_UNIT = LED.ORG_ID
         AND X.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         --AND X.SHIP_NUM = NVL ( :P_SHIP_NUM, X.SHIP_NUM)
         --AND TRUNC (X.CREATION_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO
         AND (   :P_DATE_FROM IS NULL
              OR TRUNC (X.CREATION_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO)
GROUP BY X.LC_NUMBER,
         X.LC_OPENING_DATE,
         X.PO_NUMBER,
         X.DESCRIPTION,
         X.SUPPLIER_NAME,
         X.SHIP_NUM,
         X.PRIMARY_QTY,
         X.CREATION_DATE,
         X.COMPONENT_NAME,
         X.COMPONENT_TYPE,
         X.ORGANIZATION_ID,
         led.UNIT_NAME,
         led.legal_entity_id,
         led.legal_entity_name
         ,X.LC_VALUE
         ,X.VALUE_ACTUAL,
         X.LC_Quntity,
         X.PI_Rate
ORDER BY 4;

--------------------------------------------------------------------------------

/* Formatted on 1/26/2020 1:02:25 PM (QP5 v5.287) */
  select *
  from
  (SELECT                                    --x.ship_header_id ship_header_id,
         --    x.adjustment_num adjustment_num,
         led.UNIT_NAME OU_Name,
         led.legal_entity_id,
         led.legal_entity_name,
         x.lc_opening_date as "Date",
         X.LC_NUMBER,
         X.LC_OPENING_DATE,
         X.DESCRIPTION as "Type",
         X.SUPPLIER_NAME AS "Party_Name",
         X.LC_Quntity,
         X.PI_Rate,
         X.PRIMARY_QTY  as "Receive_Quantity",
         X.LC_VALUE as "LC_VALUE",
         X.VALUE_ACTUAL,
         X.COMPONENT_NAME,
         X.ORGANIZATION_ID ORGANIZATION_ID,
         ROUND (SUM (X.ALLOCATED_AMT), 0) ACTUAL_AMT,
         ROUND (SUM (X.ESTIMATED_ALLOCATED_AMT), 0) ESTIMATED_AMT
    FROM (SELECT ALLOC.SHIP_HEADER_ID,
                 ALLOC.ADJUSTMENT_NUM,
                 LC.LC_NUMBER,
                 LC.LC_OPENING_DATE,
                 LC.SUPPLIER_NAME,
                 lc.LC_VALUE as "LC_VALUE",
                 (lc.LC_VALUE*POHA.rate) Value_Actual,
                 pla.quantity as LC_Quntity,
                 pla.unit_price as PI_Rate,
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
                 and POHA.po_header_id = pla.po_header_id
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
                 --  AND msi.organization_id = 150
                 --     AND sh.SHIP_NUM = 81
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
                 lc.LC_VALUE as "LC_VALUE",
                 (lc.LC_VALUE*POHA.rate) Value_Actual,
                 pla.quantity as LC_Quntity,
                 pla.unit_price as PI_Rate,
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
                 and POHA.po_header_id = pla.po_header_id
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
                 --   AND msi.organization_id = 150
                 --    AND sh.SHIP_NUM = 81
                 AND DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                             'INL_CHARGE_LINES', 'CHARGE',
                             'INL_TAX_LINES', 'TAX',
                             'ITEM PRICE') = 'CHARGE') X,
         ORG_ORGANIZATION_DEFINITIONS OOD,
         XXDBL_COMPANY_LE_MAPPING_V LED
   WHERE     X.ORGANIZATION_ID = :P_ORGANIZATION_ID
         AND ( :P_LC_NUMBER IS NULL OR X.LC_NUMBER = :P_LC_NUMBER)
         AND ( :P_PO_NUMBER IS NULL OR X.PO_NUMBER = :P_PO_NUMBER)
         AND ( :P_SHIP_NUM_FROM IS NULL OR X.SHIP_NUM >= :P_SHIP_NUM_FROM)
         AND ( :P_SHIP_NUM_TO IS NULL OR X.SHIP_NUM <= :P_SHIP_NUM_TO)
         AND OOD.OPERATING_UNIT = LED.ORG_ID
         AND X.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         --AND X.SHIP_NUM = NVL ( :P_SHIP_NUM, X.SHIP_NUM)
         --AND TRUNC (X.CREATION_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO
         AND (   :P_DATE_FROM IS NULL
              OR TRUNC (X.CREATION_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO)
GROUP BY X.LC_NUMBER,
         X.LC_OPENING_DATE,
         X.PO_NUMBER,
         X.DESCRIPTION,
         X.SUPPLIER_NAME,
         X.SHIP_NUM,
         X.PRIMARY_QTY,
         X.CREATION_DATE,
         X.COMPONENT_NAME,
         X.COMPONENT_TYPE,
         X.ORGANIZATION_ID,
         led.UNIT_NAME,
         led.legal_entity_id,
         led.legal_entity_name
         ,X.LC_VALUE
         ,X.VALUE_ACTUAL,
         X.LC_Quntity,
         X.PI_Rate
ORDER BY 4)
PIVOT
(
  SUM(ESTIMATED_AMT) estd_amt,
  SUM(ACTUAL_AMT) actl_amt
  FOR COMPONENT_NAME IN ('Transport Cost' trans_cst, 'Clearing and Forwarding' candf, 'INSURANCE' insurence,'Bank Charge-LC' bank_charge,'Inspection Charge' inspec_charge,'L/C Opening Commission' lc_open)
)