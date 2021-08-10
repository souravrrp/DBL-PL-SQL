SELECT A.VENDOR_NAME || '(' || A.SEGMENT1 || ')' SUPPLIER
            FROM (SELECT PHA.SEGMENT1,
                         SUP.VENDOR_NAME,
                         ROW_NUMBER ()
                         OVER (PARTITION BY MSI.SEGMENT1
                               ORDER BY PHA.APPROVED_DATE DESC)
                            CORR
                    FROM PO_HEADERS_ALL PHA,
                         PO_LINES_ALL PLA,
                         AP_SUPPLIERS SUP,
                         PO_LINE_LOCATIONS_ALL PLL,
                         MTL_SYSTEM_ITEMS_B MSI,
                         ORG_ORGANIZATION_DEFINITIONS ORG,
                         HR_OPERATING_UNITS HOU
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
                         AND MSI.INVENTORY_ITEM_ID = '33313'
                         --AND MSI.ORGANIZATION_ID='197'
                         AND PHA.AUTHORIZATION_STATUS = 'APPROVED') A
           WHERE CORR = 1