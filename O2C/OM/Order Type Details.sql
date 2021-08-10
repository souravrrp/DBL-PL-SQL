/* Formatted on 7/25/2020 11:50:27 AM (QP5 v5.287) */
  SELECT HAOU.NAME "Operating Unit",
         OTTT_H.NAME "Transaction Type",
         OTTT_H.DESCRIPTION "Description",
         DECODE (OTVL.SALES_DOCUMENT_TYPE_CODE,
                 'O', 'Sales Order',
                 OTVL.SALES_DOCUMENT_TYPE_CODE)
            "Sales Document Type",
         FLV_CAT.MEANING "Order Category",
         OTVL.TRANSACTION_TYPE_CODE "Transaction Type Code",
         WRPV_H.DISPLAY_NAME "Fulfillment Flow",
         NULL "Negotiation Flow",
            TO_CHAR (OTVL.START_DATE_ACTIVE, 'DD-MON-YYYY')
         || ' - '
         || TO_CHAR (OTVL.END_DATE_ACTIVE, 'DD-MON-YYYY')
            "Effective Dates",
         FLV_PHA.MEANING "Default Transaction Phase",
         LAYOUT_TEMPLATE_ID "Layout Template",
         CONTRACT_TEMPLATE_ID "Contract Template",
         OTVL.QUOTE_NUM_AS_ORD_NUM_FLAG "Retain Document Number",
         OTVL.AGREEMENT_TYPE_CODE "Agreement Type",
         OTVL.AGREEMENT_REQUIRED_FLAG "Agreement Required",
         OTVL.PO_REQUIRED_FLAG "Purchase Order Required",
         DECODE (OTVL.DEFAULT_INBOUND_LINE_TYPE_ID, NULL, NULL, OTTT_DEF.NAME)
            "Default Return Line Type",
         DECODE (OTVL.DEFAULT_OUTBOUND_LINE_TYPE_ID, NULL, NULL, OTTT_DEF.NAME)
            "Default Order Line Type",
         OTVL.ENFORCE_LINE_PRICES_FLAG "Enfore List Price",
         (SELECT NAME
            FROM APPS.QP_LIST_HEADERS_TL Q
           WHERE     LIST_HEADER_ID = OTVL.PRICE_LIST_ID
                 AND Q.LANGUAGE = OTTT_H.LANGUAGE)
            "Price List",
         OTVL.MIN_MARGIN_PERCENT "Min. Margin Percent",
         OTVL.ENTRY_CREDIT_CHECK_RULE_ID "Ordering Credit Check",
         OTVL.PICKING_CREDIT_CHECK_RULE_ID "Picking Credit Check",
         OTVL.PACKING_CREDIT_CHECK_RULE_ID "Packing Credit Check",
         OTVL.SHIPPING_CREDIT_CHECK_RULE_ID "Shipping Credit Check",
         (SELECT ORGANIZATION_CODE
            FROM APPS.MTL_PARAMETERS
           WHERE ORGANIZATION_ID = OTVL.WAREHOUSE_ID)
            "Warehouse",
         OTVL.SHIPPING_METHOD_CODE "Shipping Method",
         OTVL.SHIPMENT_PRIORITY_CODE "Shipment Priority",
         OTVL.FREIGHT_TERMS_CODE "Freight Terms",
         OTVL.FOB_POINT_CODE "FOB",
         OTVL.SHIP_SOURCE_TYPE_CODE "Shipping Source Type",
         OTVL.DEMAND_CLASS_CODE "Demand Class",
         OTVL.SCHEDULING_LEVEL_CODE "Scheduling Level",
         OTVL.INSPECTION_REQUIRED_FLAG "Inspection Required",
         OTVL.AUTO_SCHEDULING_FLAG "Auto Schedule",
         OTVL.DEFAULT_LINE_SET_CODE "Line Set",
         OTVL.DEFAULT_FULFILLMENT_SET "Fulfillment Set",
         OTVL.INVOICING_RULE_ID "Invoicing Rule",
         OTVL.ACCOUNTING_RULE_ID "Accouting Rule",
         (SELECT NAME
            FROM APPS.RA_BATCH_SOURCES_ALL
           WHERE     BATCH_SOURCE_ID = OTVL.INVOICE_SOURCE_ID
                 AND ORG_ID = OTVL.ORG_ID)
            "Invoice Source",
         (SELECT NAME
            FROM APPS.RA_BATCH_SOURCES_ALL
           WHERE     BATCH_SOURCE_ID = OTVL.NON_DELIVERY_INVOICE_SOURCE_ID
                 AND ORG_ID = OTVL.ORG_ID)
            "Non Delivery Invoice Source",
         OTVL.INVOICING_CREDIT_METHOD_CODE "Invoices With Rules",
         OTVL.ACCOUNTING_CREDIT_METHOD_CODE "Split Term Invoices",
         (SELECT NAME
            FROM APPS.RA_CUST_TRX_TYPES_ALL
           WHERE     CUST_TRX_TYPE_ID = OTVL.CUST_TRX_TYPE_ID
                 AND ORG_ID = OTVL.ORG_ID)
            "Recv. Trans. Type",
         OTVL.TAX_CALCULATION_EVENT_CODE "Tax Event",
         OTVL.COST_OF_GOODS_SOLD_ACCOUNT "COGS Account",
         OTVL.CURRENCY_CODE "Currency",
         (SELECT UsER_CONVERSION_TYPE
            FROM apps.GL_DAILY_CONVERSION_TYPES
           WHERE CONVERSION_TYPE = OTVL.CONVERSION_TYPE_CODE)
            "Conversion Type",
         OTTT_L.NAME "Line Type",
         OWA_L.ITEM_TYPE_CODE "Item Type",
         WRPV_L.DISPLAY_NAME "Process",
         TO_CHAR (OWA_L.START_DATE_ACTIVE, 'DD-MON-YYYY') "Start Date",
         TO_CHAR (OWA_L.END_DATE_ACTIVE, 'DD-MON-YYYY') "End Date"
    FROM APPS.OE_TRANSACTION_TYPES_ALL OTVL,
         APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
         APPS.OE_TRANSACTION_TYPES_TL OTTT_H,
         APPS.FND_LOOKUP_VALUES FLV_CAT,
         APPS.OE_WORKFLOW_ASSIGNMENTS OWA_H,
         APPS.WF_RUNNABLE_PROCESSES_V WRPV_H,
         APPS.FND_LOOKUP_VALUES FLV_PHA,
         APPS.OE_TRANSACTION_TYPES_TL OTTT_DEF,
         APPS.OE_WORKFLOW_ASSIGNMENTS OWA_L,
         APPS.OE_TRANSACTION_TYPES_TL OTTT_L,
         APPS.WF_RUNNABLE_PROCESSES_V WRPV_L,
         DUAL
   WHERE     1 = 1
         AND OTVL.ORG_ID = HAOU.ORGANIZATION_ID
         AND OTVL.TRANSACTION_TYPE_CODE = 'ORDER'
         AND OTVL.TRANSACTION_TYPE_ID = OTTT_H.TRANSACTION_TYPE_ID
         AND (    OTVL.ORDER_CATEGORY_CODE = FLV_CAT.LOOKUP_CODE
              AND FLV_CAT.LOOKUP_TYPE IN ('ORDER_CATEGORY'))
         AND OTVL.TRANSACTION_TYPE_ID = OWA_H.ORDER_TYPE_ID
         AND (    OWA_H.PROCESS_NAME = WRPV_H.PROCESS_NAME
              AND OWA_H.WF_ITEM_TYPE = WRPV_H.ITEM_TYPE)
         AND (    OTVL.DEF_TRANSACTION_PHASE_CODE = FLV_PHA.LOOKUP_CODE(+)
              AND FLV_PHA.LOOKUP_TYPE(+) IN ('TRANSACTION_PHASE'))
         AND DECODE (
                OTVL.ORDER_CATEGORY_CODE,
                'ORDER', NVL (OTVL.DEFAULT_OUTBOUND_LINE_TYPE_ID,
                              OTVL.TRANSACTION_TYPE_ID),
                'RETURN', NVL (OTVL.DEFAULT_INBOUND_LINE_TYPE_ID,
                               OTVL.TRANSACTION_TYPE_ID)) =
                OTTT_DEF.TRANSACTION_TYPE_ID
         AND OTVL.TRANSACTION_TYPE_ID = OWA_L.ORDER_TYPE_ID
         AND OTTT_L.TRANSACTION_TYPE_ID = OWA_L.LINE_TYPE_ID
         AND (    OWA_L.PROCESS_NAME = WRPV_L.PROCESS_NAME
              AND WRPV_L.ITEM_TYPE = 'OEOL')
         AND OTTT_H.LANGUAGE = 'US'
         AND OTTT_H.LANGUAGE = FLV_CAT.LANGUAGE
         AND OTTT_H.LANGUAGE = OTTT_DEF.LANGUAGE
         AND OTTT_H.LANGUAGE = OTTT_L.LANGUAGE
         AND HAOU.NAME IN
                (SELECT DISTINCT NVL (PARAM_LIST, NAME)
                   FROM (SELECT TRIM (REGEXP_SUBSTR (PARAMETER,
                                                         '[^,]+',
                                                         1,
                                                         LEVEL))
                                       PARAM_LIST,
                                    NULL
                               FROM (SELECT TRIM (
                                               DECODE ('ALL', 'ALL', NULL, 'ALL'))
                                               PARAMETER
                                       FROM DUAL) T
                         CONNECT BY REGEXP_SUBSTR (PARAMETER,
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)
                                       IS NOT NULL) PARAM_TBL,
                        (SELECT NULL, NAME
                           FROM APPS.HR_ALL_ORGANIZATION_UNITS) BASE_TBL)
ORDER BY OTTT_H.NAME,
         OTTT_L.NAME,
         OWA_L.START_DATE_ACTIVE,
         OWA_L.ITEM_TYPE_CODE