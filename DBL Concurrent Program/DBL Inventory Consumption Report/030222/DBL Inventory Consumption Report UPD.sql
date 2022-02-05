/* Formatted on 2/3/2022 2:25:15 PM (QP5 v5.374) */
WITH
    MAIN
    AS
        (SELECT NVL (
                    (SELECT INVENTORY_ITEM_ID
                       FROM mtl_material_transactions MMT
                      WHERE     MMT.ORGANIZATION_ID = ICRM.ORGANIZATION_ID
                            AND ICRM.TRANSACTION_ID = MMT.TRANSACTION_ID),
                    (SELECT INVENTORY_ITEM_ID
                       FROM MTL_SYSTEM_ITEMS_FVL ITM
                      WHERE     ITM.ORGANIZATION_ID = ICRM.ORGANIZATION_ID
                            AND ICRM.ITEM_CODE = ITM.SEGMENT1))
                    INVENTORY_ITEM_ID,                         --addes sahidul
                ICRM.SET_OF_BOOKS_ID,
                ICRM.ORGANIZATION_ID,
                ICRM.ORGANIZATION_NAME,
                ICRM.TR_TYPE,
                ICRM.TRANSACTION_ID,
                ICRM.TRANSACTION_DATE,
                ICRM.MO_NO,
                ICRM.ITEM_CODE,
                ICRM.ITEM_DESCRIPTION,
                ICRM.UOM,
                ICRM.ITEM_CATEGORY,
                ICRM.ITEM_TYPE,
                ICRM.USE_AREA,
                ICRM.LOCATION_DESC,
                ICRM.PRODUCT_LINE_DESC,
                   ICRM.COST_CENTER_DESC
                || ' - '
                || (SELECT DESCRIPTION
                      FROM FND_FLEX_VALUES_VL
                     WHERE     FLEX_VALUE_SET_ID = 1017032
                           AND FLEX_VALUE = ICRM.COST_CENTER_DESC)
                    COST_CENTER_DESC,
                   ICRM.NATURAL_ACCOUNT_DESC
                || ' - '
                || (SELECT DESCRIPTION
                      FROM FND_FLEX_VALUES_VL
                     WHERE     FLEX_VALUE_SET_ID = 1017040
                           AND FLEX_VALUE = ICRM.NATURAL_ACCOUNT_DESC)
                    NATURAL_ACCOUNT_DESC,
                   ICRM.SUB_ACCCOUNT_DESC
                || ' - '
                || (SELECT DESCRIPTION
                      FROM APPS.FND_FLEX_VALUES_TL
                     WHERE FLEX_VALUE_ID =
                           (SELECT FLEX_VALUE_ID
                              FROM APPS.FND_FLEX_VALUES
                             WHERE     FLEX_VALUE_SET_ID =
                                       (SELECT FLEX_VALUE_SET_ID
                                          FROM APPS.FND_FLEX_VALUE_SETS
                                         WHERE FLEX_VALUE_SET_NAME =
                                               'XXDBL_SUB_ACCOUNT_COA')
                                   AND FLEX_VALUE = ICRM.SUB_ACCCOUNT_DESC
                                   AND PARENT_FLEX_VALUE_LOW =
                                       (SELECT FLEX_VALUE
                                          FROM FND_FLEX_VALUES_VL B
                                         WHERE     FLEX_VALUE_SET_ID =
                                                   1017040
                                               AND B.FLEX_VALUE =
                                                   ICRM.NATURAL_ACCOUNT_DESC)))
                    SUB_ACCCOUNT_DESC,
                ICRM.INTER_COMPANY,
                ICRM.EXP_CATEGORY_DESC,
                ICRM.CODE_COMBINATION,
                ICRM.QTY,
                ICRM.UNIT_COST,
                ICRM.TOTAL_COST,
                ICRM.BUYER_NAME,
                ICRM.CUSTOMER_NAME,
                APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (ICRM.CREATED_BY)
                    CREATED_BY,
                APPS.XX_COM_PKG.GET_DEPT_FROM_USER_NAME_ID (NULL,
                                                            ICRM.CREATED_BY)
                    DEPARTMENT,
                ASSET,
                (SELECT DESCRIPTION
                   FROM FA_ADDITIONS
                  WHERE     ASSET_NUMBER = ICRM.ASSET
                        AND ICRM.ASSET_CATEGORY = 'DBL Fixed Asset List')
                    ASSET_DESCRIPTION,
                ICRM.NATURAL_ACC,
                ICRM.COMPANY_CODE,
                ICRM.WORK_ORDER_TYPE
           FROM APPS.XXDBL_INV_CON_RPT_MV# ICRM
          WHERE     (   :P_SET_OF_BOOKS_ID IS NULL
                     OR ICRM.SET_OF_BOOKS_ID = :P_SET_OF_BOOKS_ID)
                AND ( :P_COMPANY IS NULL OR ICRM.COMPANY_CODE = :P_COMPANY)
                AND ( :P_ORG_ID IS NULL OR ICRM.ORGANIZATION_ID = :P_ORG_ID)
                AND ( :P_ACCOUNT IS NULL OR ICRM.NATURAL_ACC = :P_ACCOUNT)
                AND :P_REPORT_TYPE = 'Rawdata'
                AND TRUNC (ICRM.TRANSACTION_DATE) BETWEEN :P_DATE_FROM
                                                      AND :P_DATE_TO),
    LC
    AS
        (SELECT transaction_id,
                inventory_item_id,
                SEGMENT1,
                VENDOR_NAME,
                po_header_id,
                po_number,
                lc_number,
                supplier_name
           FROM (SELECT transaction_id,
                        inventory_item_id,
                        SEGMENT1,
                        VENDOR_NAME,
                        po_header_id,
                        po_number,
                        lc_number,
                        supplier_name,
                        DECODE (LC_STATUS,  '', 'Y',  'Y', 'Y',  'A', 'A')    STATUS
                   FROM (  SELECT MAX (mmt.transaction_id)     transaction_id,
                                  mmt.inventory_item_id,
                                  PHA.SEGMENT1,
                                  AP.VENDOR_NAME,
                                  l.po_header_id,
                                  l.po_number,
                                  l.lc_number,
                                  l.supplier_name,
                                  l.LC_STATUS
                             FROM inv.mtl_material_transactions mmt,
                                  po.po_headers_all            pha,
                                  xx_lc_details                l,
                                  APPS.AP_SUPPLIERS            AP
                            WHERE     1 = 1
                                  AND mmt.transaction_source_id =
                                      pha.po_header_id
                                  AND PHA.VENDOR_ID = AP.VENDOR_ID
                                  AND pha.po_header_id = l.po_header_id(+)
                                  AND (   :P_ORG_ID IS NULL
                                       OR mmt.organization_id = :P_ORG_ID)
                                  AND TRUNC (mmt.transaction_date) < :P_DATE_TO
                                  AND mmt.TRANSACTION_TYPE_ID IN (18)
                                  AND mmt.transaction_id =
                                      (  SELECT MAX (mt.transaction_id)
                                           FROM inv.mtl_material_transactions mt,
                                                po.po_headers_all pha,
                                                xx_lc_details              l
                                          WHERE     1 = 1
                                                AND mt.transaction_source_id =
                                                    pha.po_header_id
                                                AND pha.po_header_id =
                                                    l.po_header_id(+)
                                                AND (   :P_ORG_ID IS NULL
                                                     OR mt.organization_id =
                                                        :P_ORG_ID)
                                                AND TRUNC (mt.transaction_date) <
                                                    :P_DATE_TO
                                                AND MT.TRANSACTION_TYPE_ID IN
                                                        (18)
                                                AND mmt.inventory_item_id =
                                                    mt.inventory_item_id
                                       GROUP BY mt.inventory_item_id)
                         --AND l.LC_STATUS = 'Y'
                         --and l.po_number='20113007491'
                         --AND PHA.SEGMENT1=20113011265
                         GROUP BY mmt.inventory_item_id,
                                  PHA.SEGMENT1,
                                  AP.VENDOR_NAME,
                                  l.po_header_id,
                                  l.po_number,
                                  l.lc_number,
                                  l.supplier_name,
                                  l.LC_STATUS))
          WHERE STATUS = 'Y'),
    expen
    AS
        (  SELECT MAX (RT.TRANSACTION_ID)     transaction_id,
                  pll.ITEM_ID                 INVENTORY_ITEM_ID,
                  PHA.SEGMENT1,
                  AP.VENDOR_NAME,
                  l.po_header_id,
                  l.po_number,
                  l.lc_number,
                  l.supplier_name
             FROM PO_DISTRIBUTIONS_ALL PD,
                  po.po_headers_all   PHA,
                  PO_LINES_ALL        pll,
                  RCV_TRANSACTIONS    RT,
                  APPS.AP_SUPPLIERS   AP,
                  xx_lc_details       l
            WHERE     PD.DESTINATION_TYPE_CODE = 'EXPENSE'
                  AND PD.PO_DISTRIBUTION_ID = RT.PO_DISTRIBUTION_ID
                  AND PD.PO_HEADER_ID = PHA.PO_HEADER_ID
                  AND PD.PO_HEADER_ID = pll.PO_HEADER_ID
                  AND pha.po_header_id = l.po_header_id(+)
                  AND RT.TRANSACTION_ID =
                      (  SELECT MAX (RT.TRANSACTION_ID)     transaction_id
                           FROM PO_DISTRIBUTIONS_ALL PD,
                                po.po_headers_all PHA,
                                PO_LINES_ALL      pl,
                                RCV_TRANSACTIONS  RT,
                                APPS.AP_SUPPLIERS AP,
                                xx_lc_details     l
                          WHERE     PD.DESTINATION_TYPE_CODE = 'EXPENSE'
                                AND PD.PO_DISTRIBUTION_ID = RT.PO_DISTRIBUTION_ID
                                AND PD.PO_HEADER_ID = PHA.PO_HEADER_ID
                                AND PD.PO_HEADER_ID = pl.PO_HEADER_ID
                                AND pha.po_header_id = l.po_header_id(+)
                                AND PHA.VENDOR_ID = AP.VENDOR_ID
                                AND (   :P_ORG_ID IS NULL
                                     OR PD.DESTINATION_ORGANIZATION_ID =
                                        :P_ORG_ID)
                                AND TRUNC (RT.TRANSACTION_DATE) < :P_DATE_TO
                                AND pl.ITEM_ID = pll.ITEM_ID
                       GROUP BY pll.ITEM_ID)
                  AND PHA.VENDOR_ID = AP.VENDOR_ID
                  AND (   :P_ORG_ID IS NULL
                       OR PD.DESTINATION_ORGANIZATION_ID = :P_ORG_ID)
                  AND TRUNC (RT.TRANSACTION_DATE) < :P_DATE_TO
         --AND pll.ITEM_ID ='118261'
         GROUP BY pll.ITEM_ID,
                  PHA.SEGMENT1,
                  AP.VENDOR_NAME,
                  l.po_header_id,
                  l.po_number,
                  l.lc_number,
                  l.supplier_name)
SELECT MAIN.*,
       NVL (LC.SEGMENT1, expen.SEGMENT1)           PO_NUMBER,
       NVL (LC.LC_NUMBER, expen.LC_NUMBER)         LC_NUMBER,
       NVL (LC.VENDOR_NAME, expen.VENDOR_NAME)     VENDOR_NAME
  FROM MAIN, LC, expen
 WHERE     MAIN.INVENTORY_ITEM_ID = LC.INVENTORY_ITEM_ID(+)
       AND MAIN.INVENTORY_ITEM_ID = expen.INVENTORY_ITEM_ID(+)