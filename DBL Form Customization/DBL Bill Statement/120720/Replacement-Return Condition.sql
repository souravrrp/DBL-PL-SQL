SELECT COUNT (1)
           --INTO l_return_order
           FROM oe_order_headers_all d,
                oe_transaction_types_all f,
                oe_transaction_types_tl g
          WHERE 1 = 1
            AND d.header_id = :p_order_header_id
            AND d.order_type_id = f.transaction_type_id
            AND f.transaction_type_id = g.transaction_type_id
            AND g.NAME LIKE '%Replacement%';
            
            
            select --*
            HEADER_ID
            from
            apps.oe_order_headers_all
            where 1=1
            and order_number='1552120000037'
            ;
            
            
            SELECT   line_number l_line_number,
                     NVL (SUM (  NVL (customer_job, 0)
                               * ((1 - NVL (cust_model_serial_number, 0) / 100
                                  )
                                 )
                              ),
                          0
                         ) l_order_original_qty
                FROM oe_order_lines_all
               WHERE header_id = :p_order_header_id
                 AND line_id = :p_order_line_id
            GROUP BY line_number;
            
            SELECT NVL (SUM (quantity), 0)
              --INTO l_total_bs_qty
              FROM xxdbl_bill_stat_lines xbsl, xxdbl_bill_stat_headers xbsh
             WHERE xbsl.bill_stat_header_id = xbsh.bill_stat_header_id
               AND xbsh.bill_stat_status <> 'CANCELLED'
               AND xbsl.order_id = :p_order_header_id
               AND xbsl.order_line_no LIKE :l_line_number || '.' || '%';
               
               
               
               
      SELECT      e.line_number
         || DECODE (e.shipment_number, NULL, NULL, '.' || e.shipment_number)
         || DECODE (e.option_number, NULL, NULL, '.' || e.option_number)
                                                                order_line_no,
         e.cust_po_number customer_po_number, d.order_number,
         c.concatenated_segments item_code, c.description,
         a.segment1 article_ticket, b.segment2 colour_group,
         TO_NUMBER (DECODE (e.line_category_code,
                            'RETURN', -1
                             * e.ordered_quantity /*e.customer_job*/,
                            e.ordered_quantity              /*e.customer_job*/
                           )
                   ) quantity,
         e.unit_list_price price,
           DECODE (e.line_category_code,
                   'RETURN', -1 * e.ordered_quantity,
                   e.ordered_quantity
                  )
         * e.unit_list_price VALUE,
         d.header_id order_id, e.line_id order_line_id, e.inventory_item_id,
         d.packing_instructions style_number, c.attribute5 hs_code
    FROM mtl_item_categories_v a,
         mtl_categories b,
         mtl_system_items_kfv c,
         oe_order_headers_all d,
         oe_order_lines_all e,
         oe_transaction_types_all f,
         oe_transaction_types_tl g
   WHERE a.category_set_name = 'DBL_SALES_CAT_SET'
     --AND a.organization_id IN (SELECT organization_idFROM org_organization_definitions ood WHERE ood.operating_unit = fnd_global.org_id)
     --AND d.order_number='1552120000037'
     AND a.category_id = b.category_id
     AND a.inventory_item_id = c.inventory_item_id
     AND a.organization_id = c.organization_id
     AND d.header_id = e.header_id
     AND e.inventory_item_id = c.inventory_item_id
     AND e.ship_from_org_id = c.organization_id
     AND e.flow_status_code NOT IN ('CANCELLED', 'ENTERED')
     AND d.order_type_id = f.transaction_type_id
     AND f.transaction_type_id = g.transaction_type_id
     AND g.NAME IN
                   ('Return Order Sewing Thd Apprv',
                    'Return Order Yarn Dying Apprv',
                    'Return Order Fiber Dying Apprv')
      --AND ((g.NAME LIKE '%Replacement%') OR (g.NAME IN ('Return Order Sewing Thd Apprv', 'Return Order Yarn Dying Apprv', 'Return Order Fiber Dying Apprv')))
     /*AND e.line_category_code = 'RETURN'*/
     --AND e.org_id = fnd_global.org_id
     --AND d.org_id = fnd_global.org_id
     --AND e.sold_to_org_id = :xxdbl_bill_stat_headers.customer_id
     AND NOT EXISTS (
            SELECT 'X'
              FROM xxdbl_bill_stat_lines xbsl, xxdbl_bill_stat_headers xbsh
             WHERE xbsl.bill_stat_header_id = xbsh.bill_stat_header_id
               AND xbsl.order_line_id = e.line_id
               AND xbsh.bill_stat_status <> 'CANCELLED')
     /*
     AND EXISTS (
            SELECT 'X'
              FROM xxdbl_bill_stat_lines xbsl, xxdbl_bill_stat_headers xbsh
             WHERE xbsl.bill_stat_header_id = xbsh.bill_stat_header_id
               AND xbsl.order_line_id = e.line_id
               AND xbsh.bill_stat_status NOT IN ('NEW', 'CANCELLED'))
     */
     --AND :xxdbl_bill_stat_headers.bill_stat_status NOT IN ('NEW', 'CANCELLED')
     AND xxdbl_shiping_tran_crp_pkg.get_split_line_exists (e.header_id, e.line_id ) = 0
ORDER BY 11, 12;


SELECT
DISTINCT bill_stat_status
FROM
xxdbl_bill_stat_headers
WHERE 1=1;


/* Formatted on 7/12/2020 9:30:33 AM (QP5 v5.287) */
SELECT *
  FROM oe_transaction_types_tl g
 WHERE g.NAME LIKE '%Replacement%';



SELECT *
  FROM oe_transaction_types_tl g
 WHERE g.NAME LIKE '%Return%Order%';


SELECT *
  FROM oe_transaction_types_tl g
 WHERE (   (g.NAME LIKE '%Replacement%')
        OR (g.NAME IN
               ('Return Order Sewing Thd Apprv',
                'Return Order Yarn Dying Apprv',
                'Return Order Fiber Dying Apprv')));



SELECT *
  FROM oe_transaction_types_tl g
 WHERE ( (g.NAME LIKE '%Replacement%') OR (g.NAME LIKE '%Return%Order%'));