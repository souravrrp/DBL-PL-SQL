/* Formatted on 2/19/2020 1:25:29 PM (QP5 v5.287) */
SELECT A.PO_NUM,
       Requisition_Number,
       BTB_LC_NO_PHY LC_NUMBER,
       A.VENDOR_NAME,
       AD.FUCV3,
       NVL (TO_CHAR (AD.FUCN1), A.ATTRIBUTE7) FUCN1,
       AD.FUCV5,
       AD.FUCD1,
       FUCD2,
       A.NAME ORG_NAME,
       A.ORGANIZATION_NAME,
       A.ORGANIZATION_ID ORGANIZATION_CODE,
       A.COMMENTS,
       A.APPROVED_DATE,
       A.APPROVED_MONTH,
       A.CONCATENATED_SEGMENTS,
       A.ITEM_DESCRIPTION,
       A.TOTAL_QTY,
       A.QTY_RECVD,
       NVL (A.TOTAL_QTY - A.QTY_RECVD, 0) AS BALANCE,
       A.QTY_due,
       DAYS1,
       A.STATUS,
       delivery_quantity,
       a.buyer,
       a.order_number,
       a.LCM_NUMBER,
       A.CREATION_DATE,
       A.UNIT_PRICE,
       A.CURRENCY_CODE,
       A.CLOSED_CODE
  FROM (  SELECT DISTINCT
                 AP.VENDOR_NAME,
                 pha.CLOSED_CODE,
                 B2B2.BTB_LC_NO_PHY,
                 pha.SEGMENT1 PO_NUM,
                 prha.segment1 Requisition_Number,
                 lcm.LCM_NUMBER,
                 TO_CHAR (pha.APPROVED_DATE, 'DD-Mon-RRRR') APPROVED_DATE,
                 TO_CHAR (pha.CREATION_DATE, 'Month') AS APPROVED_MONTH,
                 TO_CHAR (pha.CREATION_DATE, 'DD-Mon-RRRR') CREATION_DATE,
                 TRUNC (SYSDATE - TO_DATE (pha.CREATION_DATE, 'DD-Mon-RRRR'))
                    DAYS1,
                 OOD.ORGANIZATION_ID,
                 OOD.NAME,
                 OD.ORGANIZATION_NAME,
                 MST.CONCATENATED_SEGMENTS,
                 PLA.ITEM_DESCRIPTION,
                 PHA.CURRENCY_CODE,
                 PLA.UNIT_PRICE,
                 pl.QUANTITY TOTAL_QTY,
                 pl.QUANTITY - pl.QUANTITY_RECEIVED QTY_due,
                 pl.QUANTITY_RECEIVED QTY_RECVD,
                 PHA.COMMENTS,
                 NVL (PHA.AUTHORIZATION_STATUS, 'IN-PROCESS') STATUS,
                 NVL (PHA.ATTRIBUTE7, BTB_REQ_NO) ATTRIBUTE7,
                 delivery_quantity,
                 (SELECT DISTINCT CUSTOMER_NAME
                    FROM xx_ar_customer_site_v
                   WHERE CUSTOMER_ID = pla.attribute5)
                    buyer,
                 pla.attribute6 order_number
            FROM APPS.PO_HEADERS_ALL pha,
                 APPS.PO_LINE_LOCATIONS_ALL pl,
                 APPS.PO_LINES_ALL PLA,
                 apps.po_distributions_all pda,
                 apps.po_req_distributions_all prod,
                 apps.po_requisition_lines_all prol,
                 apps.po_requisition_headers_all prha,
                 APPS.MTL_CATEGORIES_B MCB,
                 APPS.MTL_ITEM_CATEGORIES MIC,
                 APPS.MTL_SYSTEM_ITEMS_B_KFV MST,
                 APPS.HR_OPERATING_UNITS OOD,
                 apps.org_organization_definitions OD,
                 APPS.AP_SUPPLIERS AP,
                 APPS.XX_EXPLC_BTB_REQ_LINK B2B,
                 XX_EXPLC_BTB_MST B2B2,
                 (  SELECT MAX (RT.QUANTITY) AS QUANTITY,
                           MAX (RT.PRIMARY_QUANTITY) AS PRIMARY_QUANTITY,
                           MAX (poha.org_id) AS org_id,
                           MAX (poha.po_header_id) AS po_header_id,
                           MAX (plla.po_line_id) AS po_line_id,
                           MAX (isla.ship_line_source_id) AS ship_line_source_id,
                           LISTAGG (SHIP_NUM, ',')
                              WITHIN GROUP (ORDER BY SHIP_NUM)
                              AS LCM_NUMBER
                      FROM po_line_locations_all plla,
                           inl_ship_lines_all isla,
                           po_headers_all poha,
                           INL_SHIP_HEADERS_all ish,
                           RCV_TRANSACTIONS RT
                     WHERE     poha.po_header_id = plla.po_header_id
                           AND isla.ship_line_source_id = plla.line_location_id
                           AND ish.SHIP_HEADER_ID = isla.SHIP_HEADER_ID
                           AND poha.PO_HEADER_ID = RT.PO_HEADER_ID
                           AND plla.PO_LINE_ID = RT.PO_LINE_ID
                           AND plla.line_location_id = rt.po_line_location_id
                           AND TRANSACTION_TYPE = 'RECEIVE'
                           AND RT.LCM_SHIPMENT_LINE_ID = isla.SHIP_LINE_ID
                  GROUP BY poha.segment1) lcm,
                 (  SELECT po_header_id,
                           po_number,
                           ITEM_CODE,
                           SUM (finishing_weight) delivery_quantity
                      FROM XX_AR_BILLS_LINE_DETAILS_ALL
                  --where po_number='10233000046'
                  GROUP BY po_number, ITEM_CODE, po_header_id) del
           WHERE     1 = 1
                 AND AP.VENDOR_ID = PHA.VENDOR_ID
                 AND pha.PO_HEADER_ID = pl.PO_HEADER_ID
                 AND pha.ORG_ID = OOD.ORGANIZATION_ID
                 AND OD.OPERATING_UNIT = OOD.ORGANIZATION_ID
                 AND PL.SHIP_TO_ORGANIZATION_ID = OD.ORGANIZATION_ID
                 AND PLA.PO_LINE_ID = PL.PO_LINE_ID
                 AND MIC.CATEGORY_ID = MCB.CATEGORY_ID
                 AND PLA.ITEM_ID = MIC.INVENTORY_ITEM_ID
                 AND MST.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                 AND pha.SEGMENT1 = b2b.PO_NUMBER(+)
                 AND B2B.BTB_LC_NO = B2B2.BTB_LC_NO(+)
                 AND pha.po_header_id = del.po_header_id(+)
                 AND MST.CONCATENATED_SEGMENTS = del.ITEM_CODE(+)
                 AND MCB.SEGMENT3 IN ('YARN', 'DYED YARN')
                 AND pha.po_header_id = pda.po_header_id
                 AND pla.po_line_id = pda.po_line_id
                 -- and pha.segment1='10523001993'
                 AND pl.line_location_id = pda.line_location_id
                 AND pda.req_distribution_id = prod.distribution_id(+)
                 AND prod.requisition_line_id = prol.requisition_line_id(+)
                 AND prol.requisition_header_id = prha.requisition_header_id(+)
                 AND pha.PO_HEADER_ID = lcm.PO_HEADER_ID(+)
                 AND PLA.PO_LINE_ID = lcm.PO_LINE_ID(+)
                 AND pha.ORG_ID = lcm.ORG_ID(+)
                 AND NVL (PLA.CANCEL_FLAG, 'N') = 'N'
                 AND OOD.ORGANIZATION_ID NOT IN (208, 130)
                 AND TRUNC (
                          TO_DATE (SYSDATE, 'DD-MM-YYYY')
                        - TRUNC (TO_DATE (pha.APPROVED_DATE, 'DD-MM-YYYY'))) <=
                        90
        ORDER BY MST.CONCATENATED_SEGMENTS) A
       LEFT OUTER JOIN XXDBL.XX_DBL_PO_RECV_ADJUST AD
          ON A.PO_NUM = AD.PO_NO(+) AND AD.FUCN1 > 0