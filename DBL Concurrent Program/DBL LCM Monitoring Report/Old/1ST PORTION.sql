SELECT ALLOC.SHIP_HEADER_ID,
                 ALLOC.ADJUSTMENT_NUM,
                 LC.LC_NUMBER,
                 LC.LC_OPENING_DATE,
                 POHA.SEGMENT1 PO_NUMBER,
                 SH.SHIP_NUM,
                 SH.CREATION_DATE,
                 SL.SHIP_LINE_GROUP_ID,
                 SL.SHIP_LINE_ID,
                 SL.PARENT_SHIP_LINE_ID,
                 SL.SHIP_LINE_NUM,
                 SH.ORGANIZATION_ID,
                 SL.INVENTORY_ITEM_ID,
                 MSI.CONCATENATED_SEGMENTS INV_ITEM,
                 'ITEM'
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
                 XX_LC_DETAILS LC
           WHERE     UOM.UOM_CODE = SL.PRIMARY_UOM_CODE
                 AND PE.PRICE_ELEMENT_TYPE_ID(+) = CL.CHARGE_LINE_TYPE_ID
                 AND MSI.ORGANIZATION_ID = SH.ORGANIZATION_ID
                 AND MSI.INVENTORY_ITEM_ID = SL.INVENTORY_ITEM_ID
                 AND POHA.PO_HEADER_ID = PLLA.PO_HEADER_ID
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
                 AND ( :P_LC_NUMBER IS NULL OR LC.LC_NUMBER = :P_LC_NUMBER)
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