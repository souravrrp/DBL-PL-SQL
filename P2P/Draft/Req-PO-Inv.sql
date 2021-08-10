/* Formatted on 3/11/2020 9:49:43 AM (QP5 v5.287) */
WITH PR
     AS (SELECT DISTINCT
                OOD.OPERATING_UNIT UNIT,
                OOD.ORGANIZATION_ID,
                PRH.ORG_ID,
                TO_CHAR (PRH.CREATION_DATE, 'DD-MON-YYYY') PR_DATE,
                OOD.ORGANIZATION_NAME,
                PRL.DESTINATION_SUBINVENTORY STORE,
                PRH.SEGMENT1 PR_NO,
                PRH.AUTHORIZATION_STATUS PR_STATUS,
                MSIK.CONCATENATED_SEGMENTS ITEM_CODE,
                MSIK.DESCRIPTION,
                MSIK.PRIMARY_UNIT_OF_MEASURE UOM,
                PRL.QUANTITY PR_QTY,
                PRL.LINE_LOCATION_ID,
                MCB.SEGMENT1 MEJ_CAT,
                US.USER_ID,
                US.USER_NAME USRCREATE,
                XEMPV.EMPLOYEE_NAME,
                TRIM (
                      PP.TITLE
                   || ' '
                   || PP.FIRST_NAME
                   || ' '
                   || DECODE (PP.MIDDLE_NAMES,
                              NULL, PP.LAST_NAME,
                              PP.MIDDLE_NAMES || ' ' || PP.LAST_NAME))
                   DONE_BY,
                PP.NAME DEPT_NAME
           FROM APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                APPS.MTL_SYSTEM_ITEMS_B_KFV MSIK,
                APPS.PO_REQUISITION_HEADERS_ALL PRH,
                APPS.PO_REQUISITION_LINES_ALL PRL,
                APPS.MTL_CATEGORIES_B MCB,
                APPS.FND_USER US,
                APPS.XX_EMPLOYEE_INFO_V XEMPV,
                (SELECT q1.*, haou.NAME
                   FROM HR.PER_ALL_PEOPLE_F Q1,
                        hr.per_all_assignments_f paaf,
                        hr.hr_all_organization_units haou
                  WHERE     SYSDATE BETWEEN q1.EFFECTIVE_START_DATE
                                        AND q1.EFFECTIVE_END_DATE
                        AND SYSDATE BETWEEN paaf.EFFECTIVE_START_DATE
                                        AND paaf.EFFECTIVE_END_DATE
                        AND q1.person_id = paaf.person_id
                        AND paaf.organization_id = haou.organization_id) PP
          WHERE     1 = 1
                AND MCB.CATEGORY_ID = PRL.CATEGORY_ID
                AND PRL.DESTINATION_ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND MSIK.INVENTORY_ITEM_ID(+) = PRL.ITEM_ID
                AND PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
                AND NVL (PRL.CANCEL_FLAG, 'N') <> 'Y'
                -- AND TRUNC (PRH.CREATION_DATE) BETWEEN TO_DATE ('04-Mar-2020',
                -- 'DD-Mon-RRRR')
                -- AND TO_DATE ('04-Mar-2020',
                -- 'DD-Mon-RRRR')
                AND US.user_id = PRH.CREATED_BY
                AND PRL.SUGGESTED_BUYER_ID = XEMPV.PERSON_ID(+)
                AND PP.PARTY_ID(+) = NVL (US.PERSON_PARTY_ID, 0)),
     PO
     AS (SELECT DISTINCT PLL.SHIP_TO_ORGANIZATION_ID ORGANIZATION_ID,
                         POH.SEGMENT1 PO_NO,
                         TO_CHAR (POH.CREATION_DATE, 'DD-MON-YYYY') PO_DATE,
                         POH.AUTHORIZATION_STATUS PO_STATUS,
                         POL.ITEM_ID,
                         POL.QUANTITY PO_QTY,
                         PLL.QUANTITY PLL_QTY,
                         POL.UNIT_PRICE,
                         PLL.QUANTITY_RECEIVED GATE_REC,
                         PLL.QUANTITY_ACCEPTED INSPECTION,
                         PLL.QUANTITY_BILLED,
                         PLL.LINE_LOCATION_ID,
                         AP.VENDOR_NAME SUPPLIER,
                         POH.APPROVED_FLAG,
                         LD.LC_NUMBER,
                         LD.LC_OPENING_DATE
           FROM PO_HEADERS_ALL POH,
                PO_LINES_ALL POL,
                PO_LINE_LOCATIONS_ALL PLL,
                AP_SUPPLIERS AP,
                ------------------------------
                XX_LC_DETAILS LD
          ------------------------------
          WHERE     1 = 1
                ---------------------------
                AND POH.PO_HEADER_ID = LD.PO_HEADER_ID
                ---------------------------
                AND AP.VENDOR_ID(+) = POH.VENDOR_ID
                AND POH.PO_HEADER_ID = POL.PO_HEADER_ID
                AND PLL.PO_LINE_ID = POL.PO_LINE_ID
                AND POL.QUANTITY >= PLL.QUANTITY),
     INV
     AS (SELECT DISTINCT RCT.ORGANIZATION_ID,
                         RSL.PO_LINE_LOCATION_ID LINE_LOCATION_ID,
                         PHA.SEGMENT1 PO_NUM,
                         RSH.RECEIPT_NUM,
                         RCT.PO_HEADER_ID,
                         RSL.PO_LINE_ID,
                         RCT.DESTINATION_TYPE_CODE,
                         RSL.ITEM_DESCRIPTION,
                         NVL (RSL.QUANTITY_RECEIVED, 0) INV_QTY
           FROM APPS.RCV_SHIPMENT_LINES RSL,
                APPS.RCV_SHIPMENT_HEADERS_V RSH,
                APPS.PO_HEADERS_ALL PHA,
                APPS.AP_SUPPLIERS AP,
                APPS.RCV_TRANSACTIONS RCT
          WHERE     1 = 1
                AND RCT.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
                AND RCT.SHIPMENT_LINE_ID = RSL.SHIPMENT_LINE_ID
                AND RSL.SHIPMENT_HEADER_ID = RSH.SHIPMENT_HEADER_ID
                AND PHA.PO_HEADER_ID = RCT.PO_HEADER_ID
                AND AP.VENDOR_ID = PHA.VENDOR_ID
                --AND RSL.CATEGORY_ID='7123'
                AND RCT.DESTINATION_TYPE_CODE = 'RECEIVING'
                --AND TRUNC(RCT.TRANSACTION_DATE) BETWEEN '24-aug-14' AND '26-aug-14'
                --AND MCB.SEGMENT2='$type'
                --AND TRUNC(RCT.TRANSACTION_DATE) BETWEEN :P_FROM_DATE AND :P_TO_DATE
                AND RSL.QUANTITY_RECEIVED > 0)
  SELECT DISTINCT R.ORGANIZATION_NAME,
                  R.ORG_ID,
                  R.ORGANIZATION_ID,
                  R.MEJ_CAT,
                  R.EMPLOYEE_NAME,
                  R.UNIT,
                  R.STORE,
                  R.PR_NO,
                  R.PR_DATE,
                  R.PR_STATUS,
                  R.ITEM_CODE,
                  R.DESCRIPTION,
                  R.PR_QTY,
                  R.UOM,
                  P.PO_NO,
                  P.PO_DATE,
                  P.PO_STATUS,
                  P.PLL_QTY PO_QTY,
                  P.UNIT_PRICE,
                  P.GATE_REC,
                  P.INSPECTION,
                  P.QUANTITY_BILLED,
                  P.SUPPLIER,
                  P.APPROVED_FLAG,
                  I.RECEIPT_NUM,
                  R.USER_ID,
                  R.USRCREATE,
                  R.DONE_BY,
                  R.DEPT_NAME,
                  P.LC_NUMBER,
                  P.LC_OPENING_DATE
    FROM PR R, PO P, INV I
   WHERE     1 = 1
         AND R.LINE_LOCATION_ID = P.LINE_LOCATION_ID(+)
         AND R.ORGANIZATION_ID = P.ORGANIZATION_ID(+)
         AND P.LINE_LOCATION_ID = I.LINE_LOCATION_ID(+)
         AND P.ORGANIZATION_ID = I.ORGANIZATION_ID(+)
         AND R.PR_NO = 21111002002
ORDER BY R.PR_NO DESC


--------------------------------------------------------------------------------


/* Formatted on 3/11/2020 10:11:14 AM (QP5 v5.287) */
  SELECT PRH.ORG_ID,
         HOU.NAME "Operating unit",
         PRH.REQUISITION_HEADER_ID REQ_HDR_ID,
         PRH.SEGMENT1 "Requisition Number",
         TO_CHAR (PRH.CREATION_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
            REQ_CREATION_DATE,
         PRH.AUTHORIZATION_STATUS REQ_STATUS,
         TO_CHAR (PRH.APPROVED_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
            REQ_APPROVED_DATE,
         PRL.NEED_BY_DATE REQ_NEED_BY_DATE,
         PHA.SEGMENT1 "PO Number",
         TO_CHAR (PHA.CREATION_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
            PO_CREATION_DATE,
         PHA.AUTHORIZATION_STATUS PO_STATUS,
         TO_CHAR (PHA.APPROVED_DATE, 'DD-MON-RRRR HH12:MI:SS PM')
            PO_APPROVED_DATE,
         PRL.LINE_NUM REQ_LINE_NUM,
         MSI.SEGMENT1 ITEM_CODE,
         NVL (MSI.DESCRIPTION, PRL.ITEM_DESCRIPTION) ITEM_DESCRIPTION,
         PRL.UNIT_MEAS_LOOKUP_CODE UOM,
         PRL.QUANTITY REQ_QTY,
         PLA.QUANTITY PO_QTY,
         PRL.ITEM_ID,
         (SELECT PF.FIRST_NAME || ' ' || PF.MIDDLE_NAMES || ' ' || PF.LAST_NAME
            FROM PER_PEOPLE_F PF
           WHERE     PRL.SUGGESTED_BUYER_ID = PF.PERSON_ID
                 AND SYSDATE BETWEEN PF.EFFECTIVE_START_DATE
                                 AND PF.EFFECTIVE_END_DATE)
            BUYER,
         PRL.SUGGESTED_BUYER_ID,
         PRH.ATTRIBUTE8 PURPOSE,
         PRL.ATTRIBUTE1 BRAND,
         PRL.ATTRIBUTE2 ORGIN,
         PRL.ATTRIBUTE3 MAKE,
         PRL.ATTRIBUTE6 ORDER_NO,
         PRL.ATTRIBUTE7 USE_OF_AREA,
         NVL (SUB.DESCRIPTION, SECONDARY_INVENTORY_NAME) SUBINV,
         LTRIM (
            RTRIM (
                  PPF.FIRST_NAME
               || ' '
               || PPF.MIDDLE_NAMES
               || ' '
               || PPF.LAST_NAME))
            GLOBAL_NAME,
         PRL.DESTINATION_SUBINVENTORY SUBINVENTORY,
         NVL (HRL.DESCRIPTION, HRL.LOCATION_CODE) LOCATION,
         PRL.ATTRIBUTE6 REMARKS,
         rsh.receipt_num GRN_NO,
         rt.transaction_date "RECEIPT DATE",
         rt.quantity "RECEIPT QTY",
         rt.po_unit_price "PO PRICE",
         DECODE (PRL.ATTRIBUTE_CATEGORY,
                 'Item Details', PRL.ATTRIBUTE4,
                 PRL.ATTRIBUTE4)
            BUYER_ID,
         PDA.REQ_DISTRIBUTION_ID
    FROM PO_REQUISITION_HEADERS_ALL PRH,
         PO_REQUISITION_LINES_ALL PRL,
         APPS.PO_REQ_DISTRIBUTIONS_ALL PROD,
         MTL_SYSTEM_ITEMS_B MSI,
         HR_LOCATIONS_ALL HRL,
         FND_USER FU,
         PER_PEOPLE_F PPF,
         APPS.PO_DISTRIBUTIONS_ALL PDA,
         APPS.PO_LINES_ALL PLA,
         APPS.PO_LINE_LOCATIONS_ALL PLL,
         APPS.PO_HEADERS_ALL PHA,
         HR_OPERATING_UNITS HOU,
         ORG_ORGANIZATION_DEFINITIONS OOD,
         rcv_transactions rt,
         --rcv_shipment_lines rsl,
         rcv_shipment_headers rsh,
         MTL_SECONDARY_INVENTORIES SUB
   WHERE     1 = 1
         AND pda.po_distribution_id = rt.po_distribution_id(+)
         AND rt.shipment_header_id = rsh.shipment_header_id(+)
         AND PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
         AND PRL.ITEM_ID = MSI.INVENTORY_ITEM_ID(+)
         AND PRL.DESTINATION_ORGANIZATION_ID = MSI.ORGANIZATION_ID(+)
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
         AND PRH.ORG_ID = HOU.ORGANIZATION_ID
         AND MSI.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         AND PRL.CANCEL_DATE IS NULL
         AND ( :P_REQ_NO IS NULL OR (PRH.SEGMENT1 = :P_REQ_NO))
ORDER BY PRL.LINE_NUM