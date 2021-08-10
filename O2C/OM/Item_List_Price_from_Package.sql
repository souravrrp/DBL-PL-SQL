/* Formatted on 11/18/2020 3:55:16 PM (QP5 v5.287) */
SELECT QLH_TL.NAME "List Price",
       QLH_TL.description "Description",
       QLH_TL.version_no "Version",
       QLH_B.LIST_TYPE_CODE "List Type",
       QLH_B.CURRENCY_CODE "Curr Code",
       msi.segment1 "Item Number",
       msi.description "Item Description",
       MSI.PRIMARY_UNIT_OF_MEASURE "UOM",
       --QPLL.LIST_LINE_ID PRICE_LIST_LINE_ID,
       QPLL.CREATION_DATE,
       -- QPLL.CREATED_BY ,
       -- QPLL.LAST_UPDATE_DATE ,
       -- QPLL.LAST_UPDATED_BY ,
       -- QPLL.LAST_UPDATE_LOGIN ,
       -- QPLL.LIST_HEADER_ID PRICE_LIST_ID,
       -- apps.qp_price_list_pvt.Get_Inventory_item_id(QPLL.LIST_LINE_ID) INVENTORY_ITEM_ID,
       apps.qp_price_list_pvt.get_product_uom_code (QPLL.LIST_LINE_ID)
          UOM_CODE,
       QPLL.ARITHMETIC_OPERATOR METHOD_CODE,
       QPLL.OPERAND LIST_PRICE,
       -- QPLL.GENERATE_USING_FORMULA_ID PRICING_RULE_ID,
      'Y' REPRICE_FLAG,
       -- apps.qp_price_list_pvt.Get_Pricing_Attr_Context(QPLL.LIST_LINE_ID) PRICING_CONTEXT,
       -- apps.qp_price_list_pvt.Get_Pricing_Attribute(QPLL.LIST_LINE_ID, ‘PRICING_ATTRIBUTE1’) ,
       -- apps.qp_price_list_pvt.Get_Pricing_Attribute(QPLL.LIST_LINE_ID, ‘PRICING_ATTRIBUTE2’) ,
       QPLL.START_DATE_ACTIVE,
       QPLL.END_DATE_ACTIVE,
       -- apps.qp_price_list_pvt.Get_Customer_Item_Id(QPLL.LIST_LINE_ID) CUSTOMER_ITEM_ID,
       -- QPLL.PRIMARY_UOM_FLAG,
       QPLL.REVISION_DATE
  FROM apps.MTL_SYSTEM_ITEMS_B MSI,
       apps.QP_LIST_HEADERS_B QLH_B,
       apps.QP_LIST_HEADERS_TL QLH_TL,
       apps.QP_LIST_LINES QPLL
 WHERE     MSI.INVENTORY_ITEM_ID =
              apps.qp_price_list_pvt.Get_Inventory_Item_Id (
                 QPLL.LIST_LINE_ID)
       AND MSI.ORGANIZATION_ID = apps.QP_UTIL.Get_Item_Validation_Org
       AND QPLL.LIST_LINE_TYPE_CODE = 'PLL'
       AND QLH_B.LIST_HEADER_ID = QPLL.LIST_HEADER_ID
       AND QLH_B.LIST_HEADER_ID = QLH_TL.LIST_HEADER_ID
       AND QLH_TL.language = 'US';