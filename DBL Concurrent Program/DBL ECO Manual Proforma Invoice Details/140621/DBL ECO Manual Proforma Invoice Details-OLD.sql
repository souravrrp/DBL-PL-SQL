/* Formatted on 6/14/2021 10:14:39 AM (QP5 v5.354) */
  SELECT ph.customer_number,
         ph.customer_name,
         ph.cutomer_address,                                      --Not Enough
         ph.proforma_number,
         ph.proforma_date,
         ph.proforma_status,
         po_all.customer_po_number,
         sty_all.style,
         bs_no.bill_stat_number                           bill_stat_number,
         bs_dt.bs_date,
         bsl.article_ticket || '-' || bsl.colour_group    article_ticket,
         bsl.item_description                             item_description,
         SUM (bsl.quantity)                               quantity,
         SUM (ola.ordered_quantity2)                      net_weight,
         SUM (ola.ordered_quantity * msi.unit_weight)     gross_weight,
         --ola.order_quantity_uom unit,
         (CASE
              WHEN ola.order_quantity_uom = 'CON' THEN 'CONE'
              WHEN ola.order_quantity_uom = 'KG' THEN 'KG'
          END)                                            unit,
         ola.unit_selling_price                           price_per_unit,
         SUM (bsl.VALUE)                                  net_value,
         ph.attribute1                                    bank_name,
         ph.attribute2                                    bank_details, --Not Enough
         ph.attribute3                                    payment_term,
         bsl.attribute2                                   hs_code, --Not Enough
         mn_all.m_name
    FROM xxdbl_proforma_headers ph,
         xxdbl_proforma_lines   pl,
         xxdbl_bill_stat_headers bsh,
         xxdbl_bill_stat_lines  bsl,
         oe_order_lines_all     ola,
         oe_order_headers_all   oha,
         mtl_system_items       msi,
         (  SELECT proforma_header_id,
                   LISTAGG (bill_stat_number, ',')
                       WITHIN GROUP (ORDER BY bill_stat_number)    AS bill_stat_number
              FROM xxdbl_proforma_lines
          GROUP BY proforma_header_id) bs_no,
         (  SELECT pi_number,
                   LISTAGG (b_date, ',') WITHIN GROUP (ORDER BY b_date)    AS bs_date
              FROM (  SELECT pi_number, bsh.bill_stat_date b_date
                        FROM xxdbl_bill_stat_headers bsh, xxdbl_bill_stat_lines bsl
                       WHERE bsh.bill_stat_header_id = bsl.bill_stat_header_id
                    GROUP BY pi_number, bsh.bill_stat_date) st
          GROUP BY pi_number) bs_dt,
         (  SELECT pi_number,
                   LISTAGG (style, ',') WITHIN GROUP (ORDER BY style)    AS style
              FROM (  SELECT pi_number, bsl.attribute1 style
                        FROM xxdbl_bill_stat_headers bsh, xxdbl_bill_stat_lines bsl
                       WHERE bsh.bill_stat_header_id = bsl.bill_stat_header_id
                    GROUP BY pi_number, bsl.attribute1) st
          GROUP BY pi_number) sty_all,
         (  SELECT pi_number,
                   LISTAGG (customer_po_number, ',')
                       WITHIN GROUP (ORDER BY customer_po_number)    AS customer_po_number
              FROM (  SELECT pi_number, customer_po_number
                        FROM xxdbl_bill_stat_headers bsh, xxdbl_bill_stat_lines bsl
                       WHERE bsh.bill_stat_header_id = bsl.bill_stat_header_id
                    GROUP BY pi_number, customer_po_number) tt
          GROUP BY pi_number) po_all,
         (  SELECT pi_number,
                   LISTAGG (m_name, ',') WITHIN GROUP (ORDER BY m_name)    AS m_name
              FROM (  SELECT pi_number, oha.attribute4 m_name
                        FROM xxdbl_bill_stat_headers bsh,
                             xxdbl_bill_stat_lines bsl,
                             oe_order_headers_all oha
                       WHERE     bsh.bill_stat_header_id = bsl.bill_stat_header_id
                             AND bsl.order_number = oha.order_number
                    GROUP BY pi_number, oha.attribute4) mar
          GROUP BY pi_number) mn_all
   WHERE     ph.proforma_header_id = pl.proforma_header_id
         AND bsh.bill_stat_header_id = bsl.bill_stat_header_id
         AND pl.bill_stat_number = bsh.bill_stat_number
         AND pl.bill_stat_header_id = bsh.bill_stat_header_id
         AND ola.header_id = bsl.order_id
         AND ola.header_id = oha.header_id
         AND ola.line_id = bsl.order_line_id
         AND ola.inventory_item_id = msi.inventory_item_id
         AND ph.proforma_header_id = bs_no.proforma_header_id
         AND ph.proforma_number = bs_dt.pi_number
         AND ph.proforma_number = sty_all.pi_number
         AND ph.proforma_number = po_all.pi_number
         AND ph.proforma_number = mn_all.pi_number
         AND msi.organization_id = 150
         --AND ph.proforma_number = 'PI-42026-000001'
         AND ph.proforma_number = :p_proforma_number
GROUP BY ph.customer_number,
         ph.customer_name,
         ph.cutomer_address,
         ph.proforma_number,
         ph.proforma_date,
         ph.proforma_status,
         ph.attribute1,
         ph.attribute2,
         ph.attribute3,
         bsl.attribute2,
         bsl.article_ticket,
         bsl.colour_group,
         bsl.item_description,
         ola.order_quantity_uom,
         --ola.ordered_quantity,
         --msi.unit_weight,
         --ola.ordered_quantity2,
         ola.unit_selling_price,
         bs_no.bill_stat_number,
         bs_dt.bs_date,
         sty_all.style,
         po_all.customer_po_number,
         mn_all.m_name;