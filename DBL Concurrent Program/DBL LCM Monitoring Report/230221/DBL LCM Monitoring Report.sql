/* Formatted on 2/23/2021 12:53:14 PM (QP5 v5.354) */
  SELECT                                    --x.ship_header_id ship_header_id,
         --    x.adjustment_num adjustment_num,
         X.LC_NUMBER,
         X.LC_OPENING_DATE,
         X.PO_NUMBER,
         X.SHIP_NUM,
         X.CREATION_DATE
             SHIP_DATE,
         ROUND (SYSDATE - X.CREATION_DATE)
             AGING_DAY,
         --    x.ship_line_group_id ship_line_group_id,
         -- x.ship_line_id ship_line_id,
         -- x.parent_ship_line_id parent_ship_line_id,
         --    x.ship_line_num ship_line_num,
         X.ORGANIZATION_ID
             ORGANIZATION_ID,
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
         ROUND (SUM (X.ALLOCATED_AMT), 0)
             ACTUAL_AMT,
         --         RATIO_TO_REPORT(SUM (x.allocated_amt))
         --            OVER (
         --               PARTITION BY x.ship_header_id, x.ship_line_id, x.adjustment_num)
         --         * 100
         --            allocation_percent,
         ROUND (SUM (X.ESTIMATED_ALLOCATED_AMT), 0)
             ESTIMATED_AMT,
         ROUND (SUM (X.ALLOCATED_AMT) - SUM (X.ESTIMATED_ALLOCATED_AMT), 0)
             EXCESS_ESTIMATION_AMT,
           ROUND ((SUM (X.ALLOCATED_AMT) - SUM (X.ESTIMATED_ALLOCATED_AMT)), 0)
         / NULLIF (ROUND (SUM (X.ESTIMATED_ALLOCATED_AMT), 0), 0)
         * 100
             EXCESS_ESTIMATION_PER
    --         RATIO_TO_REPORT(SUM (x.estimated_allocated_amt))
    --            OVER (
    --               PARTITION BY x.ship_header_id, x.ship_line_id, x.adjustment_num)
    --         * 100
    --            estimated_allocation_percent
    FROM (SELECT ALLOC.SHIP_HEADER_ID,
                 ALLOC.ADJUSTMENT_NUM,
                 LC.LC_NUMBER,
                 LC.LC_OPENING_DATE,
                 POHA.SEGMENT1                         PO_NUMBER,
                 SH.SHIP_NUM,
                 SH.CREATION_DATE,
                 SL.SHIP_LINE_GROUP_ID,
                 SL.SHIP_LINE_ID,
                 SL.PARENT_SHIP_LINE_ID,
                 SL.SHIP_LINE_NUM,
                 SH.ORGANIZATION_ID,
                 SL.INVENTORY_ITEM_ID,
                 MSI.CONCATENATED_SEGMENTS             INV_ITEM,
                 'ITEM'                                COMPONENT_NAME,
                 SL.PRIMARY_QTY,
                 UOM.UNIT_OF_MEASURE,
                 LC.FUNCTIONAL_AMOUNT                  PO_AMOUNT,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_CHARGE_LINES', 'CHARGE',
                         'INL_TAX_LINES', 'TAX',
                         'ITEM PRICE')                 COMPONENT_TYPE,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_SHIP_HEADERS', 'OTHERS',
                         'INL_SHIP_LINES', 'OTHERS',
                         'INL_CHARGE_LINES', PE.PRICE_ELEMENT_CODE,
                         'INL_TAX_LINES', TL.TAX_CODE,
                         MSI.CONCATENATED_SEGMENTS)    COMPONENT_CODE,
                 CL.CHARGE_LINE_TYPE_ID,
                 ALLOC.ALLOCATION_AMT                  ALLOCATED_AMT,
                 ALLOC.ESTIMATED_AMT                   ESTIMATED_ALLOCATED_AMT
            FROM MTL_UNITS_OF_MEASURE      UOM,
                 PON_PRICE_ELEMENT_TYPES_VL PE,
                 MTL_SYSTEM_ITEMS_KFV      MSI,
                 INL_CHARGE_LINES          CL,
                 INL_TAX_LINES             TL,
                 INL_ASSOCIATIONS          ASSOC,
                 INL_SHIP_HEADERS_ALL      SH,
                 INL_SHIP_LINES_ALL        SL2,
                 INL_SHIP_LINES_ALL        SL,
                 INL_ALLOCATIONS_V         ALLOC,
                 PO_LINE_LOCATIONS_ALL     PLLA,
                 PO_HEADERS_ALL            POHA,
                 XX_LC_DETAILS             LC
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
                 AND SH.SHIP_STATUS_CODE <> 'CLOSED'
                 AND ALLOC.ADJUSTMENT_NUM =
                     (SELECT MAX (ADJUSTMENT_NUM)
                        FROM INL_ALLOCATIONS_V
                       WHERE     SHIP_HEADER_ID = SL.SHIP_HEADER_ID
                             AND SHIP_LINE_ID = SL.SHIP_LINE_ID
                             AND PARENT_SHIP_LINE_ID = SL.PARENT_SHIP_LINE_ID)
                 --  AND msi.organization_id = 150
                 --     AND sh.SHIP_NUM = 81
                 AND DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                             'INL_CHARGE_LINES', 'CHARGE',
                             'INL_TAX_LINES', 'TAX',
                             'ITEM PRICE') =
                     'ITEM PRICE'
          UNION
          SELECT ALLOC.SHIP_HEADER_ID,
                 ALLOC.ADJUSTMENT_NUM,
                 LC.LC_NUMBER,
                 LC.LC_OPENING_DATE,
                 POHA.SEGMENT1                            PO_NUMBER,
                 SH.SHIP_NUM,
                 SH.CREATION_DATE,
                 SL.SHIP_LINE_GROUP_ID,
                 SL.SHIP_LINE_ID,
                 SL.PARENT_SHIP_LINE_ID,
                 SL.SHIP_LINE_NUM,
                 SH.ORGANIZATION_ID,
                 SL.INVENTORY_ITEM_ID,
                 MSI.CONCATENATED_SEGMENTS                INV_ITEM,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_SHIP_HEADERS', 'OTHERS',
                         'INL_SHIP_LINES', 'OTHERS',
                         'INL_CHARGE_LINES', PE.NAME,
                         'INL_TAX_LINES', TL.TAX_CODE)    COMPONENT_NAME,
                 SL.PRIMARY_QTY,
                 UOM.UNIT_OF_MEASURE,
                 LC.FUNCTIONAL_AMOUNT                     PO_AMOUNT,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_CHARGE_LINES', 'CHARGE',
                         'INL_TAX_LINES', 'TAX',
                         'ITEM PRICE')                    COMPONENT_TYPE,
                 DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                         'INL_SHIP_HEADERS', 'OTHERS',
                         'INL_SHIP_LINES', 'OTHERS',
                         'INL_CHARGE_LINES', PE.PRICE_ELEMENT_CODE,
                         'INL_TAX_LINES', TL.TAX_CODE,
                         MSI.CONCATENATED_SEGMENTS)       COMPONENT_CODE,
                 CL.CHARGE_LINE_TYPE_ID,
                 ALLOC.ALLOCATION_AMT                     ALLOCATED_AMT,
                 ALLOC.ESTIMATED_AMT                      ESTIMATED_ALLOCATED_AMT
            FROM MTL_UNITS_OF_MEASURE      UOM,
                 PON_PRICE_ELEMENT_TYPES_VL PE,
                 MTL_SYSTEM_ITEMS_KFV      MSI,
                 INL_CHARGE_LINES          CL,
                 INL_TAX_LINES             TL,
                 INL_ASSOCIATIONS          ASSOC,
                 INL_SHIP_HEADERS_ALL      SH,
                 INL_SHIP_LINES_ALL        SL2,
                 INL_SHIP_LINES_ALL        SL,
                 INL_ALLOCATIONS_V         ALLOC,
                 PO_LINE_LOCATIONS_ALL     PLLA,
                 PO_HEADERS_ALL            POHA,
                 XX_LC_DETAILS             LC
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
                 AND SH.SHIP_STATUS_CODE <> 'CLOSED'
                 AND LC.LC_STATUS = 'Y'
                 AND ALLOC.ADJUSTMENT_NUM =
                     (SELECT MAX (ADJUSTMENT_NUM)
                        FROM INL_ALLOCATIONS_V
                       WHERE     SHIP_HEADER_ID = SL.SHIP_HEADER_ID
                             AND SHIP_LINE_ID = SL.SHIP_LINE_ID
                             AND PARENT_SHIP_LINE_ID = SL.PARENT_SHIP_LINE_ID)
                 --   AND msi.organization_id = 150
                 --    AND sh.SHIP_NUM = 81
                 AND DECODE (ASSOC.FROM_PARENT_TABLE_NAME,
                             'INL_CHARGE_LINES', 'CHARGE',
                             'INL_TAX_LINES', 'TAX',
                             'ITEM PRICE') =
                     'CHARGE') X
   WHERE     X.ORGANIZATION_ID = :P_ORGANIZATION_ID
         AND ( :P_LC_NUMBER IS NULL OR X.LC_NUMBER = :P_LC_NUMBER)
         AND ( :P_PO_NUMBER IS NULL OR X.PO_NUMBER = :P_PO_NUMBER)
         AND ( :P_SHIP_NUM_FROM IS NULL OR X.SHIP_NUM >= :P_SHIP_NUM_FROM)
         AND ( :P_SHIP_NUM_TO IS NULL OR X.SHIP_NUM <= :P_SHIP_NUM_TO)
         --AND X.SHIP_NUM = NVL ( :P_SHIP_NUM, X.SHIP_NUM)
         --AND TRUNC (X.CREATION_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO
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
         X.ORGANIZATION_ID
ORDER BY 4