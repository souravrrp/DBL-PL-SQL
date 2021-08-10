/* Formatted on 11/12/2020 4:01:45 PM (QP5 v5.354) */
SELECT Requisition_Number,
       FUCN1                     PINO,
       PI_DATE,
       LC_NUMBER,
       LC_DATE,
       SHIP_DATE,
       REMARKS return_receive,
       PO_NUM,
       APPROVED_DATE,
       ORG_NAME                  UNIT,
       ORGANIZATION_NAME,
       ORGANIZATION_CODE,
       VENDOR_NAME,
       CONCATENATED_SEGMENTS     YarnCode,
       ITEM_DESCRIPTION,
       NOTE_TO_VENDOR,
       TOTAL_QTY,
       BUYER,
       ORDER_NUMBER,
       Knitting_Start_TOD,
       Knitting_End_TOD,
       REQ_House_Start,
       REQ_House_End
  FROM (SELECT A.PO_NUM,
               Requisition_Number,
               BTB_LC_NO_PHY                              LC_NUMBER,
               LC_DATE,
               A.VENDOR_NAME,
               AD.FUCV3,
               NVL (TO_CHAR (AD.FUCN1), A.ATTRIBUTE7)     FUCN1,
               AD.transaction_date                        PI_DATE,
               AD.FUCV5,
               AD.FUCD1,
               FUCD2,
               A.NAME                                     ORG_NAME,
               A.ORGANIZATION_NAME,
               A.ORGANIZATION_ID,
               A.ORGANIZATION_CODE,
               A.COMMENTS,
               A.APPROVED_DATE,
               A.CONCATENATED_SEGMENTS,
               A.ITEM_DESCRIPTION,
               A.TOTAL_QTY,
               A.QTY_RECVD,
               A.QTY_due,
               DAYS1,
               A.STATUS,
               delivery_quantity,
               a.buyer,
               a.order_number,
               a.LCM_NUMBER,
               a.SHIP_DATE,
               a.REMARKS,
               a.note_to_vendor,
               A.Knitting_Start_TOD,
               A.Knitting_End_TOD,
               A.REQ_house_Start,
               A.REQ_house_End
          FROM (  SELECT DISTINCT
                         AP.VENDOR_NAME,
                         B2B2.BTB_LC_NO_PHY,
                         B2B2.BTB_OPEN_DT
                             LC_DATE,
                         pha.SEGMENT1
                             PO_NUM,
                         prha.segment1
                             Requisition_Number,
                         lcm.LCM_NUMBER,
                         lcm.SHIP_DATE,
                         del.REMARKS,
                         TO_CHAR (pha.APPROVED_DATE, 'DD-Mon-RRRR')
                             APPROVED_DATE,
                         TRUNC (
                               SYSDATE
                             - TO_DATE (pha.APPROVED_DATE, 'DD-Mon-RRRR'))
                             DAYS1,
                         OOD.ORGANIZATION_ID,
                         OOD.NAME,
                         OD.ORGANIZATION_NAME,
                         OD.ORGANIZATION_CODE,
                         MST.CONCATENATED_SEGMENTS,
                         PLA.ITEM_DESCRIPTION,
                         pl.QUANTITY
                             TOTAL_QTY,
                         pl.QUANTITY - pl.QUANTITY_RECEIVED
                             QTY_due,
                         pl.QUANTITY_RECEIVED
                             QTY_RECVD,
                         PHA.COMMENTS,
                         NVL (PHA.AUTHORIZATION_STATUS, 'IN-PROCESS')
                             STATUS,
                         NVL (PHA.ATTRIBUTE7, BTB_REQ_NO)
                             ATTRIBUTE7,
                         delivery_quantity,
                         (SELECT DISTINCT CUSTOMER_NAME
                            FROM xx_ar_customer_site_v
                           WHERE CUSTOMER_ID = pla.attribute5)
                             buyer,
                         pla.attribute6
                             order_number,
                         pla.note_to_vendor,
                         pda.ATTRIBUTE3
                             AS Knitting_Start_TOD,
                         pda.ATTRIBUTE4
                             AS Knitting_End_TOD,
                         pda.ATTRIBUTE5
                             AS REQ_house_Start,
                         pda.ATTRIBUTE6
                             AS REQ_house_End
                    FROM APPS.PO_HEADERS_ALL              pha,
                         APPS.PO_LINE_LOCATIONS_ALL       pl,
                         APPS.PO_LINES_ALL                PLA,
                         apps.po_distributions_all        pda,
                         apps.po_req_distributions_all    prod,
                         apps.po_requisition_lines_all    prol,
                         apps.po_requisition_headers_all  prha,
                         APPS.MTL_CATEGORIES_B            MCB,
                         APPS.MTL_ITEM_CATEGORIES         MIC,
                         APPS.MTL_SYSTEM_ITEMS_B_KFV      MST,
                         APPS.HR_OPERATING_UNITS          OOD,
                         apps.org_organization_definitions OD,
                         APPS.AP_SUPPLIERS                AP,
                         APPS.XX_EXPLC_BTB_REQ_LINK       B2B,
                         XX_EXPLC_BTB_MST                 B2B2,
                         (SELECT poha.segment1,
                                 poha.org_id,
                                 poha.po_header_id,
                                 plla.po_line_id,
                                 isla.ship_line_source_id,
                                 SHIP_NUM     lcm_number,ish.SHIP_DATE
                            FROM po_line_locations_all plla,
                                 inl_ship_lines_all   isla,
                                 po_headers_all       poha,
                                 INL_SHIP_HEADERS_all ish
                           WHERE     poha.po_header_id = plla.po_header_id
                                 AND isla.ship_line_source_id =
                                     plla.line_location_id
                                 AND ish.SHIP_HEADER_ID = isla.SHIP_HEADER_ID)
                         lcm,
                         (  SELECT po_header_id,
                                   po_number,
                                   ITEM_CODE,
                                   REMARKS,
                                   SUM (finishing_weight)     delivery_quantity
                              FROM XX_AR_BILLS_LINE_DETAILS_ALL
                          GROUP BY po_number, ITEM_CODE, po_header_id,REMARKS) del
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
                         AND MCB.SEGMENT3 = 'YARN'
                         AND pha.po_header_id = pda.po_header_id
                         AND pla.po_line_id = pda.po_line_id
                         AND pl.line_location_id = pda.line_location_id
                         AND pda.req_distribution_id = prod.distribution_id(+)
                         AND prod.requisition_line_id =
                             prol.requisition_line_id(+)
                         AND prol.requisition_header_id =
                             prha.requisition_header_id(+)
                         AND pha.PO_HEADER_ID = lcm.PO_HEADER_ID(+)
                         AND PLA.PO_LINE_ID = lcm.PO_LINE_ID(+)
                         AND pha.ORG_ID = lcm.ORG_ID(+)
                         AND NVL (PLA.CANCEL_FLAG, 'N') = 'N'
                         AND TRUNC (
                                   SYSDATE
                                 - TO_DATE (pha.APPROVED_DATE, 'DD-Mon-RRRR')) <=
                             90
                -- AND pl.QUANTITY - pl.QUANTITY_RECEIVED <> 0
                ORDER BY MST.CONCATENATED_SEGMENTS) A
               LEFT OUTER JOIN XXDBL.XX_DBL_PO_RECV_ADJUST AD
                   ON     A.PO_NUM = AD.PO_NO(+)
                      AND AD.FUCN1 > 0) A