/* Formatted on 2/2/2022 6:03:25 PM (QP5 v5.374) */
  SELECT PH.SEGMENT1
             AS PO_NUMBER,
         APS.VENDOR_NAME,
         APS.VENDOR_ID,
         PAPF.FULL_NAME
             AS BUYER_NAME,
         SUM (NVL (PLL.UNIT_PRICE, 0) * NVL (PLL.QUANTITY, 0))
             INVOICE_AMOUNT,
         HCP.PHONE_NUMBER
    --,APSA.*
    FROM PO.PO_HEADERS_ALL         PH,
         PO.PO_LINES_ALL           PLL,
         AP.AP_SUPPLIERS           APS,
         APPS.PER_PEOPLE_F         PAPF,
         APPS.AP_SUPPLIER_SITES_ALL APSA,
         AR.HZ_CONTACT_POINTS      HCP
   WHERE     PH.PO_HEADER_ID = PLL.PO_HEADER_ID
         AND APS.VENDOR_ID = PH.VENDOR_ID
         AND PAPF.PERSON_ID = PH.AGENT_ID
         AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE
                         AND PAPF.EFFECTIVE_END_DATE
         AND APS.VENDOR_ID = APSA.VENDOR_ID
         AND PH.VENDOR_SITE_ID = APSA.VENDOR_SITE_ID
         AND APSA.PARTY_SITE_ID = HCP.OWNER_TABLE_ID(+)
         AND ph.segment1 = '21113005049'
         AND ph.org_id = 127
GROUP BY PH.SEGMENT1,
         APS.VENDOR_NAME,
         APS.VENDOR_ID,
         PAPF.FULL_NAME,
         HCP.PHONE_NUMBER
ORDER BY PH.SEGMENT1