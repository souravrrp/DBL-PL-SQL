/* Formatted on 6/1/2019 11:59:11 AM (QP5 v5.136.908.31019) */
  SELECT PHA.ORG_ID,
         HOU.NAME,
         PPF.EMPLOYEE_NUMBER,
         LTRIM(RTRIM(   PPF.FIRST_NAME
                     || ' '
                     || PPF.MIDDLE_NAMES
                     || ' '
                     || PPF.LAST_NAME))
            "Created By",
         PHA.SEGMENT1 SEGMENT1,
         PHA.AUTHORIZATION_STATUS,
         PHA.APPROVED_DATE,
         PRHA.SEGMENT1 "Requisition Number",
         SUP.VENDOR_NAME,
         MSI.SEGMENT1 "Item Code",
         NVL (MSI.DESCRIPTION, PLA.ITEM_DESCRIPTION) DESCRIPTION,
         MSI.ITEM_CATG,
         PLA.UNIT_MEAS_LOOKUP_CODE UOM,
         PLL.NEED_BY_DATE,
         PLA.UNIT_PRICE,
         PHA.CURRENCY_CODE,
         SUM (PDA.QUANTITY_ORDERED) "PO quantity",
         SUM (PLL.QUANTITY_RECEIVED) "Quantity Received",
         SUM (PLL.QUANTITY_BILLED) "quantity Billed",
         SUM (PLL.QUANTITY) - SUM (PLL.QUANTITY_RECEIVED) "Balance Quantity"
    FROM APPS.PO_HEADERS_ALL PHA,
         APPS.AP_SUPPLIERS SUP,
         APPS.AP_SUPPLIER_SITES_ALL SUPS,
         APPS.HR_LOCATIONS_ALL LOC,
         APPS.FND_TERRITORIES FT,
         APPS.PO_LINES_ALL PLA,
         APPS.PO_LINE_LOCATIONS_ALL PLL,
         APPS.PO_DISTRIBUTIONS_ALL PDA,
         APPS.PO_REQ_DISTRIBUTIONS_ALL PROD,
         APPS.PO_REQUISITION_LINES_ALL PROL,
         APPS.PO_REQUISITION_HEADERS_ALL PRHA,
         (SELECT a.inventory_item_id,
                 a.organization_id,
                 a.segment1,
                 a.description,
                 PRIMARY_UOM_CODE,
                 SECONDARY_UOM_CODE,
                 b.segment1 CATG_BUSINESS,
                 b.segment2 ITEM_CATG,
                 b.segment3 ITEM_TYPE
            FROM apps.mtl_system_items_b_kfv A, apps.mtl_item_categories_v b
           WHERE     a.inventory_item_id = b.inventory_item_id
                 AND a.organization_id = b.organization_id
                 AND CATEGORY_SET_ID = 1
                 AND a.organization_id != 138) MSI,
         APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
         APPS.HR_OPERATING_UNITS HOU,
         FND_USER FU,
         PER_PEOPLE_F PPF
   WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
         AND PHA.ORG_ID = PLA.ORG_ID
         AND PHA.ORG_ID = HOU.ORGANIZATION_ID
         AND PHA.PO_HEADER_ID = PLL.PO_HEADER_ID
         AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
         AND PHA.PO_HEADER_ID = PDA.PO_HEADER_ID
         AND PLA.PO_LINE_ID = PDA.PO_LINE_ID
         AND PLL.LINE_LOCATION_ID = PDA.LINE_LOCATION_ID
         AND PDA.REQ_DISTRIBUTION_ID = PROD.DISTRIBUTION_ID(+)
         AND PROD.REQUISITION_LINE_ID = PROL.REQUISITION_LINE_ID(+)
         AND PROL.REQUISITION_HEADER_ID = PRHA.REQUISITION_HEADER_ID(+)
         AND PLA.ITEM_ID = MSI.INVENTORY_ITEM_ID(+)
         AND PLL.SHIP_TO_ORGANIZATION_ID = MSI.ORGANIZATION_ID(+)
         AND PHA.VENDOR_ID = SUP.VENDOR_ID
         AND SUP.VENDOR_ID = SUPS.VENDOR_ID
         AND PLL.SHIP_TO_ORGANIZATION_ID = ORG.ORGANIZATION_ID
         AND PHA.VENDOR_SITE_ID = SUPS.VENDOR_SITE_ID(+)
         AND PHA.SHIP_TO_LOCATION_ID = LOC.LOCATION_ID(+)
         AND LOC.COUNTRY = FT.TERRITORY_CODE(+)
         AND PHA.TYPE_LOOKUP_CODE = 'STANDARD'
         AND PHA.CREATED_BY = FU.USER_ID
         AND FU.EMPLOYEE_ID = PPF.PERSON_ID(+)
         and trunc (sysdate) between trunc (PPF.effective_start_date) and trunc (PPF.effective_end_date)
         AND NVL (PLA.CANCEL_FLAG, 'N') = 'N'
         AND NVL (PLL.CANCEL_FLAG, 'N') = 'N'
         AND PLL.CANCEL_DATE IS NULL
         AND PDA.QUANTITY_CANCELLED = 0
         AND PLL.QUANTITY - PLL.QUANTITY_RECEIVED <> 0
         AND PHA.AUTHORIZATION_STATUS = 'APPROVED'
         AND PHA.CLOSED_CODE = 'OPEN'
         AND PHA.CREATED_BY != 1130
         AND MSI.SEGMENT1 IS NOT NULL
         AND (PHA.ORG_ID = :P_ORG OR :P_ORG IS NULL)
         AND (PPF.PERSON_ID = :P_CREATED OR :P_CREATED IS NULL)
         AND (PHA.VENDOR_ID = :P_SUPPLIER OR :P_SUPPLIER IS NULL)
         AND (MSI.CATG_BUSINESS = :P_BUSINESS OR :P_BUSINESS IS NULL)
         AND (MSI.ITEM_CATG = :P_ITEM_CATG OR :P_ITEM_CATG IS NULL)
         AND (MSI.ITEM_TYPE = :P_ITEM_TYPE OR :P_ITEM_TYPE IS NULL)
         AND (:P_FROM_PO_DATE IS NULL
              OR TRUNC (PHA.APPROVED_DATE) BETWEEN :P_FROM_PO_DATE
                                               AND  :P_TO_PO_DATE)
GROUP BY PHA.ORG_ID,
         HOU.NAME,
         LTRIM(RTRIM(   PPF.FIRST_NAME
                     || ' '
                     || PPF.MIDDLE_NAMES
                     || ' '
                     || PPF.LAST_NAME)),
         PPF.EMPLOYEE_NUMBER,
         PHA.SEGMENT1,
         PHA.ATTRIBUTE1,
         HOU.SHORT_CODE,
         HOU.NAME,
         PHA.SEGMENT1,
         PHA.AUTHORIZATION_STATUS,
         PHA.APPROVED_DATE,
         PRHA.SEGMENT1,
         SUP.VENDOR_NAME,
         MSI.SEGMENT1,
         MSI.ITEM_CATG,
         NVL (MSI.DESCRIPTION, PLA.ITEM_DESCRIPTION),
         PLA.UNIT_MEAS_LOOKUP_CODE,
         PLL.NEED_BY_DATE,
         PLA.LINE_NUM,
         PLA.UNIT_PRICE,
         PHA.CURRENCY_CODE
ORDER BY SUP.VENDOR_NAME,
         PHA.APPROVED_DATE,
         PHA.SEGMENT1,
         PLA.LINE_NUM