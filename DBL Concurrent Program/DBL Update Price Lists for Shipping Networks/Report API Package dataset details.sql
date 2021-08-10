/* Formatted on 7/8/2020 5:05:03 PM (QP5 v5.287) */
  SELECT x.org_id,
         x.segment1,
         x.item_id,
         x.unit_price * x.rate unit_price,
         x.approved_date,
         x.uom_code,
         x.unit_meas_lookup_code,
         x.ship_to_organization_id,
         si.segment1 item
    FROM (  SELECT ph.org_id,
                   ph.segment1,
                   pl.item_id,
                   ph.currency_code,
                   NVL (ph.rate, 1) rate,
                   ph.approved_date,
                   pl.unit_price,
                   uom.uom_code,
                   pl.unit_meas_lookup_code,
                   ll.ship_to_organization_id,
                   RANK ()
                   OVER (PARTITION BY pl.item_id, ll.ship_to_organization_id
                         ORDER BY ph.approved_date DESC)
                      rnk
              FROM po_headers_all ph,
                   po_lines_all pl,
                   po_line_locations_all ll,
                   mtl_units_of_measure uom
             WHERE     1 = 1
                   AND TRUNC (ph.approved_date) = TRUNC ( :cp_approve_date)
                   AND pl.unit_meas_lookup_code = uom.unit_of_measure(+)
                   AND NVL (ph.cancel_flag, 'N') = 'N'
                   AND ph.authorization_status = 'APPROVED'
                   AND ph.po_header_id = pl.po_header_id
                   AND NVL (pl.cancel_flag, 'N') = 'N'
                   AND pl.po_line_id = ll.po_line_id
                   AND NVL (ll.cancel_flag, 'N') = 'N'
          ORDER BY pl.item_id, ll.ship_to_organization_id, ph.approved_date) x,
         mtl_system_items si
   WHERE     x.rnk = 1
         AND x.item_id = si.inventory_item_id
         AND x.ship_to_organization_id = si.organization_id
         AND x.ship_to_organization_id = :cp_inv_org_id
ORDER BY x.org_id;


  SELECT DISTINCT
         snv.pricelist_id, qlh.NAME pricelist_name, snv.from_organization_id
    FROM mtl_shipping_network_view snv, qp_list_headers qlh
   WHERE     1 = 1
         AND snv.from_organization_id = :cp_inv_org_id
         AND snv.pricelist_id = qlh.list_header_id
ORDER BY qlh.NAME;

SELECT COUNT (1)
  --INTO l_count
  FROM qp_list_lines_v l
 WHERE     l.list_header_id = :pricelist_id
       AND l.product_attribute_context = 'ITEM'
       AND l.product_attr_value = TO_CHAR ( :item_id)
       AND l.arithmetic_operator = 'UNIT_PRICE';

SELECT l.list_line_id, l.product_uom_code
  FROM qp_list_lines_v l
 WHERE     l.list_header_id = :pricelist_id
       AND l.product_attribute_context = 'ITEM'
       AND l.product_attr_value = TO_CHAR (:item_id)
       AND l.arithmetic_operator = 'UNIT_PRICE';
       
       
select
XXDBL.xxdbl_fnc_get_item_cost (145,4006,'MAR-20') 
from dual;

/*
3/3/2020	--Approve date
145	--organization_id

4006	--item id
9107	--price list id
*/


/* Formatted on 7/8/2020 5:05:03 PM (QP5 v5.287) */
  SELECT x.org_id,
         x.segment1,
         x.item_id,
         NVL((x.unit_price * x.rate ),XXDBL.xxdbl_fnc_get_item_cost (x.ship_to_organization_id,x.item_id,TO_CHAR(X.approved_date,'MON-YY')))unit_price,
         x.approved_date,
         x.uom_code,
         x.unit_meas_lookup_code,
         x.ship_to_organization_id,
         si.segment1 item
    FROM (  SELECT ph.org_id,
                   ph.segment1,
                   pl.item_id,
                   ph.currency_code,
                   NVL (ph.rate, 1) rate,
                   ph.approved_date,
                   pl.unit_price,
                   uom.uom_code,
                   pl.unit_meas_lookup_code,
                   ll.ship_to_organization_id,
                   RANK ()
                   OVER (PARTITION BY pl.item_id, ll.ship_to_organization_id
                         ORDER BY ph.approved_date DESC)
                      rnk
              FROM po_headers_all ph,
                   po_lines_all pl,
                   po_line_locations_all ll,
                   mtl_units_of_measure uom,
                   --apps.gl_period_statuses gps,
                   org_organization_definitions ood
             WHERE     1 = 1
                   AND TRUNC (ph.approved_date) = TRUNC ( :cp_approve_date)
                   and ood.operating_unit  = ph.org_id
                   AND ood.organization_id=ll.ship_to_organization_id
                   --AND OOD.SET_OF_BOOKS_ID=GPS.SET_OF_BOOKS_ID
                   --AND GPS.PERIOD_NAME=TRUNC(:cp_approve_date,'MON-YY')
                   --AND GPS.APPLICATION_ID=ph.PROGRAM_APPLICATION_ID
                   AND pl.unit_meas_lookup_code = uom.unit_of_measure(+)
                   AND NVL (ph.cancel_flag, 'N') = 'N'
                   AND ph.authorization_status = 'APPROVED'
                   AND ph.po_header_id = pl.po_header_id
                   AND NVL (pl.cancel_flag, 'N') = 'N'
                   AND pl.po_line_id = ll.po_line_id
                   AND NVL (ll.cancel_flag, 'N') = 'N'
          ORDER BY pl.item_id, ll.ship_to_organization_id, ph.approved_date) x,
         mtl_system_items si
   WHERE     x.rnk = 1
         AND x.item_id = si.inventory_item_id
         AND x.ship_to_organization_id = si.organization_id
         AND x.ship_to_organization_id = :cp_inv_org_id
ORDER BY x.org_id;