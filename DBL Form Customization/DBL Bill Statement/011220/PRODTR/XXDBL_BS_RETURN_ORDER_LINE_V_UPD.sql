/* Formatted on 12/1/2020 10:51:23 AM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW APPS.XXDBL_BS_RETURN_ORDER_LINE_V
(
   ORDER_LINE_NO,
   CUSTOMER_PO_NUMBER,
   ORDER_NUMBER,
   ITEM_CODE,
   DESCRIPTION,
   ARTICLE_TICKET,
   COLOUR_GROUP,
   QUANTITY,
   PRICE,
   VALUE,
   ORDER_ID,
   ORDER_LINE_ID,
   INVENTORY_ITEM_ID,
   STYLE_NUMBER,
   HS_CODE,
   SOLD_TO_ORG_ID
)
   BEQUEATH DEFINER
AS
   SELECT    e.line_number
          || DECODE (e.shipment_number, NULL, NULL, '.' || e.shipment_number)
          || DECODE (e.option_number, NULL, NULL, '.' || e.option_number)
             order_line_no,
          e.cust_po_number customer_po_number,
          d.order_number,
          c.concatenated_segments item_code,
          c.description,
          b.segment1 article_ticket,
          b.segment2 colour_group,
          TO_NUMBER (
             DECODE (e.line_category_code,
                     'RETURN', -1 * e.ordered_quantity,
                     e.ordered_quantity))
             quantity,
          e.unit_list_price price,
            DECODE (e.line_category_code,
                    'RETURN', -1 * e.ordered_quantity,
                    e.ordered_quantity)
          * e.unit_list_price
             VALUE,
          d.header_id order_id,
          e.line_id order_line_id,
          e.inventory_item_id,
          d.packing_instructions style_number,
          c.attribute5 hs_code,
          e.sold_to_org_id
     FROM oe_order_lines_all e,
          oe_order_headers_all d,
          mtl_system_items_kfv c,
          inv.mtl_item_categories a,
          oe_transaction_types_all f,
          oe_transaction_types_tl g,
          mtl_categories_b b
    WHERE     1 = 1
          AND d.header_id = e.header_id
          AND d.org_id = e.org_id
          AND e.flow_status_code NOT IN ('CANCELLED', 'ENTERED')
          --          AND EXISTS
          --                 (SELECT 'X'
          --                    FROM xxbl_organization_id_tmp xx
          --                   WHERE 1 = 1 AND xx.org_id = e.org_id)
          --          AND EXISTS
          --                 (SELECT 'X'
          --                    FROM xxbl_organization_id_tmp xx
          --                   WHERE 1 = 1 AND xx.org_id = d.org_id)
          AND NOT EXISTS
                 (SELECT 'X'
                    FROM xxdbl_bill_stat_lines xbsl,
                         xxdbl_bill_stat_headers xbsh
                   WHERE     1 = 1
                         AND xbsl.bill_stat_header_id =
                                xbsh.bill_stat_header_id
                         AND xbsl.order_line_id = e.line_id
                         AND xbsh.bill_stat_status <> 'CANCELLED')
          AND e.inventory_item_id = c.inventory_item_id
          AND e.ship_from_org_id = c.organization_id
          AND a.inventory_item_id = c.inventory_item_id
          AND a.organization_id = c.organization_id
          AND a.category_set_id = 1100000061
          --          AND EXISTS
          --                 (SELECT 'X'
          --                    FROM xxbl_organization_id_tmp xx
          --                   WHERE 1 = 1 AND xx.organization_id = a.organization_id)
          AND d.order_type_id = f.transaction_type_id
          AND f.transaction_type_id = g.transaction_type_id
          AND (   (g.NAME LIKE '%Replacement%')
               OR (g.NAME IN
                      ('Return Order Sewing Thd Apprv',
                       'Return Order Yarn Dying Apprv',
                       'Return Order Fiber Dying Apprv')))
          AND a.category_id = b.category_id;