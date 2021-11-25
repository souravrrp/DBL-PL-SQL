SELECT ph.SEGMENT1 AS PO_NUMBER,
         hou.NAME OPERATING_UNIT_NAME,
         hou.ORGANIZATION_ID AS OPERATING_UNIT_ID,
         APS.VENDOR_NAME,
         APS.VENDOR_ID,
         papf.FULL_NAME AS BUYER_NAME,
         lol.LEGAL_ENTITY_NAME,
         SUM (NVL (pll.UNIT_PRICE, 0) * NVL (pll.QUANTITY, 0)) INVOICE_AMOUNT
    FROM PO_HEADERS_ALL ph,
         PO_LINES_ALL pll,
         HR_OPERATING_UNITS hou,
         APPS.AP_SUPPLIERS APS,
         XLE_LE_OU_LEDGER_V lol,
         apps.PER_PEOPLE_F papf
   WHERE     ph.PO_HEADER_ID = pll.PO_HEADER_ID
         AND ph.ORG_ID = hou.ORGANIZATION_ID
         AND APS.VENDOR_ID = ph.VENDOR_ID
         AND lol.OPERATING_UNIT_ID = hou.ORGANIZATION_ID
         AND papf.PERSON_ID = ph.AGENT_ID
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND (   :XXDBL_INVOICE_TRACKING_SYSTEM.OPERATING_UNIT_ID IS NULL
              OR ph.ORG_ID = :XXDBL_INVOICE_TRACKING_SYSTEM.OPERATING_UNIT_ID)
GROUP BY ph.SEGMENT1,
         hou.NAME,
         hou.ORGANIZATION_ID,
         APS.VENDOR_NAME,
         APS.VENDOR_ID,
         papf.FULL_NAME,
         lol.LEGAL_ENTITY_NAME
ORDER BY ph.SEGMENT1