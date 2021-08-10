/* Formatted on 10/19/2020 2:24:11 PM (QP5 v5.354) */
--------------------------OPM Receving---------------------------------------

  SELECT xah.LEDGER_ID,
         CC.SEGMENT1                     COMPANY,
         CC.SEGMENT2                     LOCATION,
         CC.SEGMENT3                     PL,
         CC.SEGMENT4                     COST_CENTER,
         CC.SEGMENT5                     ACCOUNT,
         CC.SEGMENT6                     SUB_ACC,
         CC.SEGMENT7                     INTER_PROJECT,
         CC.SEGMENT8                     EXP_TYPE,
         CC.SEGMENT9                     FUTURE,
         CC.CONCATENATED_SEGMENTS,
         FLEX.DESCRIPTION                ACCTDESC,
         ORG.ORGANIZATION_ID,
         ORG.ORGANIZATION_CODE,
         ORG.ORGANIZATION_NAME,
         gxeh.event_type_code,
         --    gxeh.source_line_ID VOUCHER_NUMBER,
         --  XAL.AE_LINE_NUM GL_JE_LINE_NUM,
         --  XAL.ACCOUNTING_DATE VOUCHER_DATE,
         -- NULL PARTICULARS,
         APS.SEGMENT1                    SUPPLIER_CODE,
         APS.VENDOR_NAME                 SUPPLIER_NAME,
         --POH.PO_HEADER_ID,
         POH.SEGMENT1                    PO_NUMBER,
         (SELECT LC_NUMBER
            FROM xxdbl.XX_LC_DETAILS
           WHERE     po_header_id = poh.po_header_id
                 AND LEDGER_ID = xal.LEDGER_ID
                 AND LC_STATUS = 'Y')    LC_NUMBER,
         POH.CURRENCY_CODE,
         RCVH.RECEIPT_NUM                GOODS_RECEIPT_NUM,
         -- MST.INVENTORY_ITEM_ID,
         MST.CONCATENATED_SEGMENTS       CONCAT_ITEM_CODE,
         MST.DESCRIPTION                 INVENTORY_ITEM_NAME,
         RCVT.UOM_CODE,
         MCB.SEGMENT2                    ITEM_CATEGORY,
         MCB.SEGMENT3                    ITEM_TYPE,
         RCVT.PRIMARY_QUANTITY,
         SUM (XAL.ACCOUNTED_DR)          ACCOUNTED_DR,
         SUM (XAL.ACCOUNTED_CR)          ACCOUNTED_CR
    FROM AP_SUPPLIERS                APS,
         RCV_SHIPMENT_HEADERS        RCVH,
         RCV_TRANSACTIONS            RCVT,
         PO_HEADERS_ALL              POH,
         PO_LINES_ALL                PLL,
         gmf_xla_extract_headers     gxeh,
         XLA_AE_LINES                XAL,
         XLA_AE_HEADERS              XAH,
         FND_DOC_SEQUENCE_CATEGORIES CAT,
         gl_code_combinations_kfv    cc,
         FND_FLEX_VALUES_VL          FLEX,
         MTL_SYSTEM_ITEMS_B_KFV      MST,
         ORG_ORGANIZATION_DEFINITIONS ORG,
         MTL_ITEM_CATEGORIES         MIC,
         MTL_CATEGORIES_B            MCB
   WHERE     APS.VENDOR_ID(+) = RCVH.VENDOR_ID
         AND RCVH.SHIPMENT_HEADER_ID(+) = RCVT.SHIPMENT_HEADER_ID
         AND gxeh.source_line_ID = RCVT.TRANSACTION_ID(+)
         AND gxeh.organization_id = rcvt.organization_id(+)
         AND POH.PO_HEADER_ID = PLL.PO_HEADER_ID
         AND RCVT.PO_HEADER_ID = PLL.PO_HEADER_ID
         AND RCVT.PO_LINE_ID = PLL.PO_LINE_ID
         AND XAH.event_id = gxeh.event_id
         AND XAH.LEDGER_ID = gxeh.LEDGER_ID
         AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
         AND xal.code_combination_id = cc.code_combination_id
         AND XAH.JE_CATEGORY_NAME = CAT.CODE
         AND MIC.CATEGORY_SET_ID = 1
         AND CAT.APPLICATION_ID = 101
         AND CC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING
         AND GXEH.ORGANIZATION_ID = MST.ORGANIZATION_ID
         AND GXEH.INVENTORY_ITEM_ID = MST.INVENTORY_ITEM_ID
         AND GXEH.ORGANIZATION_ID = ORG.ORGANIZATION_ID
         AND MIC.INVENTORY_ITEM_ID = MST.INVENTORY_ITEM_ID
         AND MIC.ORGANIZATION_ID = MST.ORGANIZATION_ID
         AND MCB.STRUCTURE_ID = 101
         AND MCB.CATEGORY_ID = MIC.CATEGORY_ID
         AND gxeh.TRANSACTION_DATE BETWEEN '01-JUL-2020' AND '31-JUL-2020'
         AND gxeh.entity_code = 'PURCHASING'
         --  AND (NVL (XAL.ACCOUNTED_DR, 0) <> 0 OR NVL (XAL.ACCOUNTED_CR, 0) <> 0)
         --AND POH.SEGMENT1='20113004933'
         --    AND RCVH.RECEIPT_NUM in ( '15414101008','15414101009')
         --    AND XAL.ACCOUNTING_DATE LIKE '%JUN%'
         --   AND CC.SEGMENT5 = '126117'
         AND xal.ledger_id = 2095
--  AND  MCB.SEGMENT2 ='PACKING MATERIAL'
-- AND POH.SEGMENT1 IN ('15413002015','15413002411')
GROUP BY xah.LEDGER_ID,
         CC.SEGMENT1,
         CC.SEGMENT2,
         CC.SEGMENT3,
         CC.SEGMENT4,
         CC.SEGMENT5,
         CC.SEGMENT6,
         CC.SEGMENT7,
         CC.SEGMENT8,
         CC.SEGMENT9,
         CC.CONCATENATED_SEGMENTS,
         FLEX.DESCRIPTION,
         gxeh.event_type_code,
         --  gxeh.source_line_ID,
         --    XAL.AE_LINE_NUM,
         --   XAL.ACCOUNTING_DATE,
         APS.SEGMENT1,
         APS.VENDOR_NAME,
         RCVH.RECEIPT_NUM,
         POH.PO_HEADER_ID,
         POH.SEGMENT1,
         POH.CURRENCY_CODE,
         RCVT.PRIMARY_QUANTITY,
         ORG.ORGANIZATION_ID,
         ORG.ORGANIZATION_CODE,
         ORG.ORGANIZATION_NAME,
         MST.INVENTORY_ITEM_ID,
         MST.CONCATENATED_SEGMENTS,
         MST.DESCRIPTION,
         RCVT.UOM_CODE,
         MCB.SEGMENT2,
         MCB.SEGMENT3,
         xal.LEDGER_ID
UNION ALL ------------------------Discrete---------------------------------------
SELECT GJH.JE_SOURCE,
       JE_CATEGORY                   JE_CATEGORY,
       XAL.ACCOUNTING_CLASS_CODE,
       GCC.SEGMENT1                  COMPANY,
       GCC.SEGMENT4                  COST_CENTER,
       GCC.SEGMENT5                  ACCOUNT,
       GCC.SEGMENT7                  INTER_PROJECT,
       GCC.SEGMENT9                  FUTURE,
       FLEX.DESCRIPTION              ACCTDESC,
       RCVT.TRANSACTION_ID           VOUCHER_NUMBER,
       XAL.AE_LINE_NUM               GL_JE_LINE_NUM,
       XAL.ACCOUNTING_DATE           VOUCHER_DATE,
       NULL                          PARTICULARS,
       XAL.ENTERED_DR,
       XAL.ENTERED_CR,
       XAL.ACCOUNTED_DR,
       XAL.ACCOUNTED_CR,
       gjh.LEDGER_ID,
       APS.SEGMENT1                  SUPPLIER_CODE,
       APS.VENDOR_NAME               SUPPLIER_NAME,
       RCVH.RECEIPT_NUM              GOODS_RECEIPT_NUM,
       POH.PO_HEADER_ID,
       POH.SEGMENT1                  PO_NUMBER,
       POH.CURRENCY_CODE,
       POL.UNIT_PRICE,
       pol.QUANTITY,
       mmt.PRIMARY_QUANTITY,
       ORG.ORGANIZATION_ID,
       ORG.ORGANIZATION_CODE,
       ORG.ORGANIZATION_NAME,
       msi.INVENTORY_ITEM_ID,
       msi.CONCATENATED_SEGMENTS     CONCAT_ITEM_CODE,
       msi.DESCRIPTION               INVENTORY_ITEM_NAME,
       msi.PRIMARY_UOM_CODE,
       MIC.SEGMENT2                  ITEM_CATEGORY,
       MIC.SEGMENT3                  ITEM_TYPE
  FROM xla_distribution_links        xdl,
       mtl_transaction_accounts      xta,
       mtl_material_transactions     mmt,
       po_headers_all                poh,
       po_lines_all                  pol,
       RCV_SHIPMENT_HEADERS          RCVH,
       RCV_transactions              rcvt,
       AP_SUPPLIERS                  APS,
       xla_ae_lines                  xal,
       gl_import_references          gir,
       gl_je_lines                   gjl,
       gl_je_headers                 gjh,
       gl_je_batches                 gjb,
       gl_code_combinations          gcc,
       FND_FLEX_VALUES_VL            FLEX,
       mtl_system_items_b_KFV        msi,
       mtl_item_categories_v         mic,
       ORG_ORGANIZATION_DEFINITIONS  ORG,
       gl_ledgers                    gl
 WHERE     1 = 1
       AND mmt.transaction_id = xta.transaction_id
       AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
       AND xdl.source_distribution_id_num_1 = xta.inv_sub_ledger_id
       AND xal.ae_header_id = xdl.ae_header_id
       AND xal.ae_line_num = xdl.ae_line_num
       AND gir.gl_sl_link_id = xal.gl_sl_link_id
       --AND gir.gl_sl_link_table = 'MTA'
       AND gir.je_header_id = gjl.je_header_id
       AND gir.je_line_num = gjl.je_line_num
       AND gjl.code_combination_id = gcc.code_combination_id
       AND gir.je_header_id = gjh.je_header_id
       AND GJH.LEDGER_ID = gl.LEDGER_ID
       AND LEDGER_CATEGORY_CODE = 'PRIMARY'
       AND poh.segment1 = '25113000017'
       --  AND GCC.SEGMENT5 = '126117'
       AND gjh.je_batch_id = gjb.je_batch_id
       AND gjh.status = 'P'
       AND mic.category_set_id = 1
       AND poh.po_header_id = mmt.transaction_source_id
       AND APS.VENDOR_ID = RCVH.VENDOR_ID
       AND POL.PO_LINE_ID = RCVT.PO_LINE_ID
       AND POH.PO_HEADER_ID = POL.PO_HEADER_ID
       AND RCVT.PO_HEADER_ID = POL.PO_HEADER_ID
       AND RCVH.SHIPMENT_HEADER_ID = RCVT.SHIPMENT_HEADER_ID
       AND mmt.INVENTORY_ITEM_ID = pol.ITEM_ID
       AND RCVT.transaction_id = mmt.rcv_transaction_id
       AND mmt.inventory_item_id = msi.inventory_item_id
       AND mmt.organization_id = msi.organization_id
       AND MIC.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID
       AND MIC.ORGANIZATION_ID = msi.ORGANIZATION_ID
       AND mmt.ORGANIZATION_ID = ORG.ORGANIZATION_ID
       AND GCC.SEGMENT5 = FLEX.FLEX_VALUE_MEANING