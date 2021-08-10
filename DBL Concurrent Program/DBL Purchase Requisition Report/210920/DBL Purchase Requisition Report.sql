/* Formatted on 10/21/2020 5:52:15 PM (QP5 v5.354) */
SELECT MSI.ORGANIZATION_ID,
       PRH.SEGMENT1
           "Requisition Number",
       PHA.SEGMENT1
           "PO Number",
       PRH.REQUISITION_HEADER_ID,
       (SELECT PF.FIRST_NAME || ' ' || PF.MIDDLE_NAMES || ' ' || PF.LAST_NAME
          FROM PER_PEOPLE_F PF
         WHERE     PRL.SUGGESTED_BUYER_ID = PF.PERSON_ID
               AND SYSDATE BETWEEN PF.EFFECTIVE_START_DATE
                               AND PF.EFFECTIVE_END_DATE)
           BUYER,
       PRL.SUGGESTED_BUYER_ID,
       PRH.ORG_ID,
       TO_CHAR (PRH.CREATION_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
           CREATION_DATE,
       PRH.AUTHORIZATION_STATUS,
       PRH.DESCRIPTION,
       PRJT.PROJECT_NAME,
       TO_CHAR (PRH.APPROVED_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
           APPROVED_DATE,
       PRH.ATTRIBUTE8
           PURPOSE,
       PRH.ATTRIBUTE8
           CATEGORIES,
       MSI.SEGMENT1,
       (SELECT DECODE (A.CURRENCY_CODE,
                       'BDT', A.UNIT_PRICE,
                       A.UNIT_PRICE * NVL (RATE, 1))    RATE
          FROM (SELECT PHA.SEGMENT1,
                       PHA.CURRENCY_CODE,
                       PLA.UNIT_PRICE,
                       PHA.RATE,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       AND MSI.SEGMENT1 = MSI.SEGMENT1
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_GRP_PRICE,
       (SELECT DECODE (A.CURRENCY_CODE,
                       'BDT', A.UNIT_PRICE,
                       A.UNIT_PRICE * NVL (RATE, 1))    RATE
          FROM (SELECT PHA.SEGMENT1,
                       PHA.CURRENCY_CODE,
                       PLA.UNIT_PRICE,
                       PHA.RATE,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       AND MSI.SEGMENT1 = MSI.SEGMENT1
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND MSI.ORGANIZATION_ID =
                           PRL.DESTINATION_ORGANIZATION_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_PRICE,
       (SELECT A.VENDOR_NAME || '(' || A.SEGMENT1 || ')'     SUPPLIER
          FROM (SELECT PHA.SEGMENT1,
                       SUP.VENDOR_NAME,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       AP_SUPPLIERS                  SUP,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.VENDOR_ID = SUP.VENDOR_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       -- and MSI.SEGMENT1='SPRECONS000000035426'
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND MSI.ORGANIZATION_ID =
                           PRL.DESTINATION_ORGANIZATION_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_SUPPLIER,
       (SELECT A.VENDOR_NAME || '(' || A.SEGMENT1 || ')'     SUPPLIER
          FROM (SELECT PHA.SEGMENT1,
                       SUP.VENDOR_NAME,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       AP_SUPPLIERS                  SUP,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.VENDOR_ID = SUP.VENDOR_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_GRP_SUPPLIER,
       NVL (MSI.DESCRIPTION, PRL.ITEM_DESCRIPTION)
           DESCRIPTION,
       PRL.UNIT_MEAS_LOOKUP_CODE
           UOM,
       PRL.LINE_NUM,
       NVL (
           (SELECT PRL.QUANTITY - SUM (REQ_LINE_QUANTITY)
              FROM PO_REQUISITION_LINES_ALL       PRL2,
                   APPS.PO_REQ_DISTRIBUTIONS_ALL  PROD2,
                   APPS.PO_DISTRIBUTIONS_ALL      PDA2
             WHERE     1 = 1
                   AND PRL2.REQUISITION_LINE_ID = PROD2.REQUISITION_LINE_ID
                   AND PROD2.DISTRIBUTION_ID = PDA2.REQ_DISTRIBUTION_ID
                   AND PRL2.CANCEL_DATE IS NULL
                   AND PRL2.PARENT_REQ_LINE_ID IS NOT NULL
                   AND PDA2.REQ_DISTRIBUTION_ID IS NOT NULL
                   AND PRL2.ORG_ID = PRL.ORG_ID
                   AND PRL2.ITEM_ID = PRL.ITEM_ID
                   AND PRL2.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID),
           PRL.QUANTITY)
           QUANTITY,
       PRL.ATTRIBUTE1
           BRAND,
       PRL.ATTRIBUTE2
           ORGIN,
       PRL.ATTRIBUTE3
           MAKE,
       PRL.ATTRIBUTE7
           USE_OF_AREA,
       NVL (SUB.DESCRIPTION, SECONDARY_INVENTORY_NAME)
           SUBINV,
       --  prl.attribute5 buyer_id,
       -- prl.attribute6 Order_no,
       PRL.ITEM_ID,
       MOQ.ON_HAND,
       PRL.NEED_BY_DATE,
       LTRIM (
           RTRIM (
                  PPF.FIRST_NAME
               || ' '
               || PPF.MIDDLE_NAMES
               || ' '
               || PPF.LAST_NAME))
           GLOBAL_NAME,
       PRL.DESTINATION_SUBINVENTORY
           SUBINVENTORY,
       NVL (HRL.DESCRIPTION, HRL.LOCATION_CODE)
           LOCATION,
       PRL.ATTRIBUTE6
           REMARKS,
       DECODE (PRL.ATTRIBUTE_CATEGORY,
               'Item Details', PRL.ATTRIBUTE4,
               PRL.ATTRIBUTE4)
           BUYER_ID,
       PRL.ATTRIBUTE5
           ORDER_NO,
       PDA.REQ_DISTRIBUTION_ID,
       PRL.PARENT_REQ_LINE_ID,
       PLL.LINE_LOCATION_ID,
       (SELECT LC.FUNCTIONAL_AMOUNT
          FROM MTL_UNITS_OF_MEASURE        UOM,
               PON_PRICE_ELEMENT_TYPES_VL  PE,
               INL_CHARGE_LINES            CL,
               INL_TAX_LINES               TL,
               INL_ASSOCIATIONS            ASSOC,
               INL_SHIP_HEADERS_ALL        SH,
               INL_SHIP_LINES_ALL          SL2,
               INL_SHIP_LINES_ALL          SL,
               INL_ALLOCATIONS_V           ALLOC,
               XX_LC_DETAILS               LC
         WHERE     UOM.UOM_CODE = SL.PRIMARY_UOM_CODE
               AND PE.PRICE_ELEMENT_TYPE_ID(+) = CL.CHARGE_LINE_TYPE_ID
               AND MSI.ORGANIZATION_ID = SH.ORGANIZATION_ID
               AND MSI.INVENTORY_ITEM_ID = SL.INVENTORY_ITEM_ID
               AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
               AND SL.SHIP_LINE_SOURCE_ID = PLL.LINE_LOCATION_ID
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
               AND PHA.PO_HEADER_ID = LC.PO_HEADER_ID
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
                   'ITEM PRICE')
           LC_VALUE
  FROM PO_REQUISITION_HEADERS_ALL     PRH,
       PO_REQUISITION_LINES_ALL       PRL,
       MTL_SYSTEM_ITEMS_B             MSI,
       ALL_PROJECT_INFO_MASTER        PRJT,
       HR_LOCATIONS_ALL               HRL,
       FND_USER                       FU,
       PER_PEOPLE_F                   PPF,
       (  SELECT INVENTORY_ITEM_ID,
                 ORGANIZATION_ID,
                 SUM (NVL (TRANSACTION_QUANTITY, 0))     ON_HAND
            FROM MTL_ONHAND_QUANTITIES
        GROUP BY INVENTORY_ITEM_ID, ORGANIZATION_ID) MOQ,
       APPS.PO_REQ_DISTRIBUTIONS_ALL  PROD,
       APPS.PO_DISTRIBUTIONS_ALL      PDA,
       APPS.PO_LINES_ALL              PLA,
       APPS.PO_LINE_LOCATIONS_ALL     PLL,
       APPS.PO_HEADERS_ALL            PHA,
       MTL_SECONDARY_INVENTORIES      SUB
 WHERE     PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
       AND PRL.ITEM_ID = MSI.INVENTORY_ITEM_ID(+)
       AND PRL.DESTINATION_ORGANIZATION_ID = MSI.ORGANIZATION_ID(+)
       AND PRL.ITEM_ID = MOQ.INVENTORY_ITEM_ID(+)
       AND PRL.DESTINATION_ORGANIZATION_ID = MOQ.ORGANIZATION_ID(+)
       AND PRH.ATTRIBUTE4 = PRJT.PROJECT_ID(+)
       AND PRL.DELIVER_TO_LOCATION_ID = HRL.LOCATION_ID
       AND PRH.CREATED_BY = FU.USER_ID(+)
       AND PRL.REQUISITION_LINE_ID = PROD.REQUISITION_LINE_ID
       AND PROD.DISTRIBUTION_ID = PDA.REQ_DISTRIBUTION_ID(+)
       AND PDA.PO_LINE_ID = PLA.PO_LINE_ID(+)
       AND PDA.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID(+)
       AND PLL.PO_LINE_ID = PLA.PO_LINE_ID(+)
       AND PLL.PO_HEADER_ID = PHA.PO_HEADER_ID(+)
       AND PDA.PO_HEADER_ID = PHA.PO_HEADER_ID(+)
       AND PLL.PO_LINE_ID = PLA.PO_LINE_ID(+)
       AND FU.EMPLOYEE_ID = PPF.PERSON_ID(+)
       AND PRL.DESTINATION_SUBINVENTORY = SUB.SECONDARY_INVENTORY_NAME(+) ---DESTINATION_SUBINVENTORY
       AND PRL.DESTINATION_ORGANIZATION_ID = SUB.ORGANIZATION_ID(+)
       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                       AND PPF.EFFECTIVE_END_DATE
       AND PRL.CANCEL_DATE IS NULL
       AND PRL.PARENT_REQ_LINE_ID IS NULL
       AND PDA.REQ_DISTRIBUTION_ID IS NULL
       AND PRH.ORG_ID = :P_ORG_ID
       AND PRL.DESTINATION_ORGANIZATION_ID =
           NVL ( :P_DEST_ORG_ID, PRL.DESTINATION_ORGANIZATION_ID)
       AND (   :P_REQUISITION_FROM IS NULL
            OR PRH.REQUISITION_HEADER_ID BETWEEN :P_REQUISITION_FROM
                                             AND :P_REQUISITION_TO)
       AND PRH.AUTHORIZATION_STATUS =
           NVL ( :P_AUTHORIZATION_STATUS, PRH.AUTHORIZATION_STATUS)
       AND (   :P_FROM_CREATION_DATE IS NULL
            OR TRUNC (PRH.CREATION_DATE) BETWEEN :P_FROM_CREATION_DATE
                                             AND :P_TO_CREATION_DATE)
--ORDER BY PRL.LINE_NUM
UNION ALL
SELECT MSI.ORGANIZATION_ID,
       PRH.SEGMENT1
           "Requisition Number",
       PHA.SEGMENT1
           "PO Number",
       PRH.REQUISITION_HEADER_ID,
       (SELECT PF.FIRST_NAME || ' ' || PF.MIDDLE_NAMES || ' ' || PF.LAST_NAME
          FROM PER_PEOPLE_F PF
         WHERE     PRL.SUGGESTED_BUYER_ID = PF.PERSON_ID
               AND SYSDATE BETWEEN PF.EFFECTIVE_START_DATE
                               AND PF.EFFECTIVE_END_DATE)
           BUYER,
       PRL.SUGGESTED_BUYER_ID,
       PRH.ORG_ID,
       TO_CHAR (PRH.CREATION_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
           CREATION_DATE,
       PRH.AUTHORIZATION_STATUS,
       PRH.DESCRIPTION,
       PRJT.PROJECT_NAME,
       TO_CHAR (PRH.APPROVED_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
           APPROVED_DATE,
       PRH.ATTRIBUTE8
           PURPOSE,
       PRH.ATTRIBUTE8
           CATEGORIES,
       MSI.SEGMENT1,
       (SELECT DECODE (A.CURRENCY_CODE,
                       'BDT', A.UNIT_PRICE,
                       A.UNIT_PRICE * NVL (RATE, 1))    RATE
          FROM (SELECT PHA.SEGMENT1,
                       PHA.CURRENCY_CODE,
                       PLA.UNIT_PRICE,
                       PHA.RATE,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       AND MSI.SEGMENT1 = MSI.SEGMENT1
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_GRP_PRICE,
       (SELECT DECODE (A.CURRENCY_CODE,
                       'BDT', A.UNIT_PRICE,
                       A.UNIT_PRICE * NVL (RATE, 1))    RATE
          FROM (SELECT PHA.SEGMENT1,
                       PHA.CURRENCY_CODE,
                       PLA.UNIT_PRICE,
                       PHA.RATE,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       AND MSI.SEGMENT1 = MSI.SEGMENT1
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND MSI.ORGANIZATION_ID =
                           PRL.DESTINATION_ORGANIZATION_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_PRICE,
       (SELECT A.VENDOR_NAME || '(' || A.SEGMENT1 || ')'     SUPPLIER
          FROM (SELECT PHA.SEGMENT1,
                       SUP.VENDOR_NAME,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       AP_SUPPLIERS                  SUP,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.VENDOR_ID = SUP.VENDOR_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       -- and MSI.SEGMENT1='SPRECONS000000035426'
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND MSI.ORGANIZATION_ID =
                           PRL.DESTINATION_ORGANIZATION_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_SUPPLIER,
       (SELECT A.VENDOR_NAME || '(' || A.SEGMENT1 || ')'     SUPPLIER
          FROM (SELECT PHA.SEGMENT1,
                       SUP.VENDOR_NAME,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       AP_SUPPLIERS                  SUP,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.VENDOR_ID = SUP.VENDOR_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_GRP_SUPPLIER,
       NVL (MSI.DESCRIPTION, PRL.ITEM_DESCRIPTION)
           DESCRIPTION,
       PRL.UNIT_MEAS_LOOKUP_CODE
           UOM,
       PRL.LINE_NUM,
       PRL.QUANTITY,
       PRL.ATTRIBUTE1
           BRAND,
       PRL.ATTRIBUTE2
           ORGIN,
       PRL.ATTRIBUTE3
           MAKE,
       PRL.ATTRIBUTE7
           USE_OF_AREA,
       NVL (SUB.DESCRIPTION, SECONDARY_INVENTORY_NAME)
           SUBINV,
       --  prl.attribute5 buyer_id,
       -- prl.attribute6 Order_no,
       PRL.ITEM_ID,
       MOQ.ON_HAND,
       PRL.NEED_BY_DATE,
       LTRIM (
           RTRIM (
                  PPF.FIRST_NAME
               || ' '
               || PPF.MIDDLE_NAMES
               || ' '
               || PPF.LAST_NAME))
           GLOBAL_NAME,
       PRL.DESTINATION_SUBINVENTORY
           SUBINVENTORY,
       NVL (HRL.DESCRIPTION, HRL.LOCATION_CODE)
           LOCATION,
       PRL.ATTRIBUTE6
           REMARKS,
       DECODE (PRL.ATTRIBUTE_CATEGORY,
               'Item Details', PRL.ATTRIBUTE4,
               PRL.ATTRIBUTE4)
           BUYER_ID,
       PRL.ATTRIBUTE5
           ORDER_NO,
       PDA.REQ_DISTRIBUTION_ID,
       PRL.PARENT_REQ_LINE_ID,
       PLL.LINE_LOCATION_ID,
       (SELECT LC.FUNCTIONAL_AMOUNT
          FROM MTL_UNITS_OF_MEASURE        UOM,
               PON_PRICE_ELEMENT_TYPES_VL  PE,
               INL_CHARGE_LINES            CL,
               INL_TAX_LINES               TL,
               INL_ASSOCIATIONS            ASSOC,
               INL_SHIP_HEADERS_ALL        SH,
               INL_SHIP_LINES_ALL          SL2,
               INL_SHIP_LINES_ALL          SL,
               INL_ALLOCATIONS_V           ALLOC,
               XX_LC_DETAILS               LC
         WHERE     UOM.UOM_CODE = SL.PRIMARY_UOM_CODE
               AND PE.PRICE_ELEMENT_TYPE_ID(+) = CL.CHARGE_LINE_TYPE_ID
               AND MSI.ORGANIZATION_ID = SH.ORGANIZATION_ID
               AND MSI.INVENTORY_ITEM_ID = SL.INVENTORY_ITEM_ID
               AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
               AND SL.SHIP_LINE_SOURCE_ID = PLL.LINE_LOCATION_ID
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
               AND PHA.PO_HEADER_ID = LC.PO_HEADER_ID
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
                   'ITEM PRICE')
           LC_VALUE
  FROM PO_REQUISITION_HEADERS_ALL     PRH,
       PO_REQUISITION_LINES_ALL       PRL,
       MTL_SYSTEM_ITEMS_B             MSI,
       ALL_PROJECT_INFO_MASTER        PRJT,
       HR_LOCATIONS_ALL               HRL,
       FND_USER                       FU,
       PER_PEOPLE_F                   PPF,
       (  SELECT INVENTORY_ITEM_ID,
                 ORGANIZATION_ID,
                 SUM (NVL (TRANSACTION_QUANTITY, 0))     ON_HAND
            FROM MTL_ONHAND_QUANTITIES
        GROUP BY INVENTORY_ITEM_ID, ORGANIZATION_ID) MOQ,
       APPS.PO_REQ_DISTRIBUTIONS_ALL  PROD,
       APPS.PO_DISTRIBUTIONS_ALL      PDA,
       APPS.PO_LINES_ALL              PLA,
       APPS.PO_LINE_LOCATIONS_ALL     PLL,
       APPS.PO_HEADERS_ALL            PHA,
       MTL_SECONDARY_INVENTORIES      SUB
 WHERE     PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
       AND PRL.ITEM_ID = MSI.INVENTORY_ITEM_ID(+)
       AND PRL.DESTINATION_ORGANIZATION_ID = MSI.ORGANIZATION_ID(+)
       AND PRL.ITEM_ID = MOQ.INVENTORY_ITEM_ID(+)
       AND PRL.DESTINATION_ORGANIZATION_ID = MOQ.ORGANIZATION_ID(+)
       AND PRH.ATTRIBUTE4 = PRJT.PROJECT_ID(+)
       AND PRL.DELIVER_TO_LOCATION_ID = HRL.LOCATION_ID
       AND PRH.CREATED_BY = FU.USER_ID(+)
       AND PRL.REQUISITION_LINE_ID = PROD.REQUISITION_LINE_ID
       AND PROD.DISTRIBUTION_ID = PDA.REQ_DISTRIBUTION_ID(+)
       AND PDA.PO_LINE_ID = PLA.PO_LINE_ID(+)
       AND PDA.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID(+)
       AND PLL.PO_LINE_ID = PLA.PO_LINE_ID(+)
       AND PLL.PO_HEADER_ID = PHA.PO_HEADER_ID(+)
       AND PDA.PO_HEADER_ID = PHA.PO_HEADER_ID(+)
       AND PLL.PO_LINE_ID = PLA.PO_LINE_ID(+)
       AND FU.EMPLOYEE_ID = PPF.PERSON_ID(+)
       AND PRL.DESTINATION_SUBINVENTORY = SUB.SECONDARY_INVENTORY_NAME(+) ---DESTINATION_SUBINVENTORY
       AND PRL.DESTINATION_ORGANIZATION_ID = SUB.ORGANIZATION_ID(+)
       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                       AND PPF.EFFECTIVE_END_DATE
       AND PRL.CANCEL_DATE IS NULL
       AND PRL.PARENT_REQ_LINE_ID IS NULL
       AND PDA.REQ_DISTRIBUTION_ID IS NOT NULL
       AND PRH.ORG_ID = :P_ORG_ID
       AND PRL.DESTINATION_ORGANIZATION_ID =
           NVL ( :P_DEST_ORG_ID, PRL.DESTINATION_ORGANIZATION_ID)
       AND (   :P_REQUISITION_FROM IS NULL
            OR PRH.REQUISITION_HEADER_ID BETWEEN :P_REQUISITION_FROM
                                             AND :P_REQUISITION_TO)
       AND PRH.AUTHORIZATION_STATUS =
           NVL ( :P_AUTHORIZATION_STATUS, PRH.AUTHORIZATION_STATUS)
       AND (   :P_FROM_CREATION_DATE IS NULL
            OR TRUNC (PRH.CREATION_DATE) BETWEEN :P_FROM_CREATION_DATE
                                             AND :P_TO_CREATION_DATE)
--ORDER BY PRL.LINE_NUM
UNION ALL
SELECT MSI.ORGANIZATION_ID,
       PRH.SEGMENT1
           "Requisition Number",
       PHA.SEGMENT1
           "PO Number",
       PRH.REQUISITION_HEADER_ID,
       (SELECT PF.FIRST_NAME || ' ' || PF.MIDDLE_NAMES || ' ' || PF.LAST_NAME
          FROM PER_PEOPLE_F PF
         WHERE     PRL.SUGGESTED_BUYER_ID = PF.PERSON_ID
               AND SYSDATE BETWEEN PF.EFFECTIVE_START_DATE
                               AND PF.EFFECTIVE_END_DATE)
           BUYER,
       PRL.SUGGESTED_BUYER_ID,
       PRH.ORG_ID,
       TO_CHAR (PRH.CREATION_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
           CREATION_DATE,
       PRH.AUTHORIZATION_STATUS,
       PRH.DESCRIPTION,
       PRJT.PROJECT_NAME,
       TO_CHAR (PRH.APPROVED_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
           APPROVED_DATE,
       PRH.ATTRIBUTE8
           PURPOSE,
       PRH.ATTRIBUTE8
           CATEGORIES,
       MSI.SEGMENT1,
       (SELECT DECODE (A.CURRENCY_CODE,
                       'BDT', A.UNIT_PRICE,
                       A.UNIT_PRICE * NVL (RATE, 1))    RATE
          FROM (SELECT PHA.SEGMENT1,
                       PHA.CURRENCY_CODE,
                       PLA.UNIT_PRICE,
                       PHA.RATE,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       AND MSI.SEGMENT1 = MSI.SEGMENT1
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_GRP_PRICE,
       (SELECT DECODE (A.CURRENCY_CODE,
                       'BDT', A.UNIT_PRICE,
                       A.UNIT_PRICE * NVL (RATE, 1))    RATE
          FROM (SELECT PHA.SEGMENT1,
                       PHA.CURRENCY_CODE,
                       PLA.UNIT_PRICE,
                       PHA.RATE,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       AND MSI.SEGMENT1 = MSI.SEGMENT1
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND MSI.ORGANIZATION_ID =
                           PRL.DESTINATION_ORGANIZATION_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_PRICE,
       (SELECT A.VENDOR_NAME || '(' || A.SEGMENT1 || ')'     SUPPLIER
          FROM (SELECT PHA.SEGMENT1,
                       SUP.VENDOR_NAME,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       AP_SUPPLIERS                  SUP,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.VENDOR_ID = SUP.VENDOR_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       -- and MSI.SEGMENT1='SPRECONS000000035426'
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND MSI.ORGANIZATION_ID =
                           PRL.DESTINATION_ORGANIZATION_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_SUPPLIER,
       (SELECT A.VENDOR_NAME || '(' || A.SEGMENT1 || ')'     SUPPLIER
          FROM (SELECT PHA.SEGMENT1,
                       SUP.VENDOR_NAME,
                       ROW_NUMBER ()
                           OVER (PARTITION BY MSI.SEGMENT1
                                 ORDER BY PHA.APPROVED_DATE DESC)    CORR
                  FROM PO_HEADERS_ALL                PHA,
                       PO_LINES_ALL                  PLA,
                       AP_SUPPLIERS                  SUP,
                       PO_LINE_LOCATIONS_ALL         PLL,
                       MTL_SYSTEM_ITEMS_B            MSI,
                       ORG_ORGANIZATION_DEFINITIONS  ORG,
                       HR_OPERATING_UNITS            HOU
                 WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                       AND PHA.ORG_ID = PLA.ORG_ID
                       AND PHA.VENDOR_ID = SUP.VENDOR_ID
                       AND PHA.ORG_ID = HOU.ORGANIZATION_ID
                       AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
                       AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                       AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID
                       AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
                       AND TYPE_LOOKUP_CODE = 'STANDARD'
                       AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
                       AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
         WHERE CORR = 1)
           LAST_GRP_SUPPLIER,
       NVL (MSI.DESCRIPTION, PRL.ITEM_DESCRIPTION)
           DESCRIPTION,
       PRL.UNIT_MEAS_LOOKUP_CODE
           UOM,
       PRL.LINE_NUM,
       PRL.QUANTITY,
       PRL.ATTRIBUTE1
           BRAND,
       PRL.ATTRIBUTE2
           ORGIN,
       PRL.ATTRIBUTE3
           MAKE,
       PRL.ATTRIBUTE7
           USE_OF_AREA,
       NVL (SUB.DESCRIPTION, SECONDARY_INVENTORY_NAME)
           SUBINV,
       --  prl.attribute5 buyer_id,
       -- prl.attribute6 Order_no,
       PRL.ITEM_ID,
       MOQ.ON_HAND,
       PRL.NEED_BY_DATE,
       LTRIM (
           RTRIM (
                  PPF.FIRST_NAME
               || ' '
               || PPF.MIDDLE_NAMES
               || ' '
               || PPF.LAST_NAME))
           GLOBAL_NAME,
       PRL.DESTINATION_SUBINVENTORY
           SUBINVENTORY,
       NVL (HRL.DESCRIPTION, HRL.LOCATION_CODE)
           LOCATION,
       PRL.ATTRIBUTE6
           REMARKS,
       DECODE (PRL.ATTRIBUTE_CATEGORY,
               'Item Details', PRL.ATTRIBUTE4,
               PRL.ATTRIBUTE4)
           BUYER_ID,
       PRL.ATTRIBUTE5
           ORDER_NO,
       PDA.REQ_DISTRIBUTION_ID,
       PRL.PARENT_REQ_LINE_ID,
       PLL.LINE_LOCATION_ID,
       (SELECT LC.FUNCTIONAL_AMOUNT
          FROM MTL_UNITS_OF_MEASURE        UOM,
               PON_PRICE_ELEMENT_TYPES_VL  PE,
               INL_CHARGE_LINES            CL,
               INL_TAX_LINES               TL,
               INL_ASSOCIATIONS            ASSOC,
               INL_SHIP_HEADERS_ALL        SH,
               INL_SHIP_LINES_ALL          SL2,
               INL_SHIP_LINES_ALL          SL,
               INL_ALLOCATIONS_V           ALLOC,
               XX_LC_DETAILS               LC
         WHERE     UOM.UOM_CODE = SL.PRIMARY_UOM_CODE
               AND PE.PRICE_ELEMENT_TYPE_ID(+) = CL.CHARGE_LINE_TYPE_ID
               AND MSI.ORGANIZATION_ID = SH.ORGANIZATION_ID
               AND MSI.INVENTORY_ITEM_ID = SL.INVENTORY_ITEM_ID
               AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
               AND SL.SHIP_LINE_SOURCE_ID = PLL.LINE_LOCATION_ID
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
               AND PHA.PO_HEADER_ID = LC.PO_HEADER_ID
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
                   'ITEM PRICE')
           LC_VALUE
  FROM PO_REQUISITION_HEADERS_ALL     PRH,
       PO_REQUISITION_LINES_ALL       PRL,
       MTL_SYSTEM_ITEMS_B             MSI,
       ALL_PROJECT_INFO_MASTER        PRJT,
       HR_LOCATIONS_ALL               HRL,
       FND_USER                       FU,
       PER_PEOPLE_F                   PPF,
       (  SELECT INVENTORY_ITEM_ID,
                 ORGANIZATION_ID,
                 SUM (NVL (TRANSACTION_QUANTITY, 0))     ON_HAND
            FROM MTL_ONHAND_QUANTITIES
        GROUP BY INVENTORY_ITEM_ID, ORGANIZATION_ID) MOQ,
       APPS.PO_REQ_DISTRIBUTIONS_ALL  PROD,
       APPS.PO_DISTRIBUTIONS_ALL      PDA,
       APPS.PO_LINES_ALL              PLA,
       APPS.PO_LINE_LOCATIONS_ALL     PLL,
       APPS.PO_HEADERS_ALL            PHA,
       MTL_SECONDARY_INVENTORIES      SUB
 WHERE     PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
       AND PRL.ITEM_ID = MSI.INVENTORY_ITEM_ID(+)
       AND PRL.DESTINATION_ORGANIZATION_ID = MSI.ORGANIZATION_ID(+)
       AND PRL.ITEM_ID = MOQ.INVENTORY_ITEM_ID(+)
       AND PRL.DESTINATION_ORGANIZATION_ID = MOQ.ORGANIZATION_ID(+)
       AND PRH.ATTRIBUTE4 = PRJT.PROJECT_ID(+)
       AND PRL.DELIVER_TO_LOCATION_ID = HRL.LOCATION_ID
       AND PRH.CREATED_BY = FU.USER_ID(+)
       AND PRL.REQUISITION_LINE_ID = PROD.REQUISITION_LINE_ID
       AND PROD.DISTRIBUTION_ID = PDA.REQ_DISTRIBUTION_ID(+)
       AND PDA.PO_LINE_ID = PLA.PO_LINE_ID(+)
       AND PDA.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID(+)
       AND PLL.PO_LINE_ID = PLA.PO_LINE_ID(+)
       AND PLL.PO_HEADER_ID = PHA.PO_HEADER_ID(+)
       AND PDA.PO_HEADER_ID = PHA.PO_HEADER_ID(+)
       AND PLL.PO_LINE_ID = PLA.PO_LINE_ID(+)
       AND FU.EMPLOYEE_ID = PPF.PERSON_ID(+)
       AND PRL.DESTINATION_SUBINVENTORY = SUB.SECONDARY_INVENTORY_NAME(+) ---DESTINATION_SUBINVENTORY
       AND PRL.DESTINATION_ORGANIZATION_ID = SUB.ORGANIZATION_ID(+)
       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                       AND PPF.EFFECTIVE_END_DATE
       AND PRL.CANCEL_DATE IS NULL
       AND PRL.PARENT_REQ_LINE_ID IS NOT NULL
       AND PDA.REQ_DISTRIBUTION_ID IS NOT NULL
       AND PRH.ORG_ID = :P_ORG_ID
       AND PRL.DESTINATION_ORGANIZATION_ID =
           NVL ( :P_DEST_ORG_ID, PRL.DESTINATION_ORGANIZATION_ID)
       AND (   :P_REQUISITION_FROM IS NULL
            OR PRH.REQUISITION_HEADER_ID BETWEEN :P_REQUISITION_FROM
                                             AND :P_REQUISITION_TO)
       AND PRH.AUTHORIZATION_STATUS =
           NVL ( :P_AUTHORIZATION_STATUS, PRH.AUTHORIZATION_STATUS)
       AND (   :P_FROM_CREATION_DATE IS NULL
            OR TRUNC (PRH.CREATION_DATE) BETWEEN :P_FROM_CREATION_DATE
                                             AND :P_TO_CREATION_DATE)
--ORDER BY PRL.LINE_NUM