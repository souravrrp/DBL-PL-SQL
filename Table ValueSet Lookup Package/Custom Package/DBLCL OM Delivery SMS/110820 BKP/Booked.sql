/* Formatted on 8/5/2020 3:42:57 PM (QP5 v5.287) */
  SELECT oha.org_id,
         cus.customer_number,
         cus.customer_name,
         oha.order_number,
         oha.booked_date,
         SUM (ola.ordered_quantity) ordered_quantity,
         ola.order_quantity_uom uom,
         SUM (
              (ola.ordered_quantity * ola.unit_selling_price)
            - ABS (NVL (clv.charge_amount, 0)))
            amount,
         hcp.phone_number
    FROM oe_order_headers_all oha,
         oe_order_lines_all ola,
         apps.oe_charge_lines_v clv,
         oe_price_adjustments_v pav,
         ar_customers cus,
         apps.hz_cust_accounts hca,
         apps.hz_party_sites hps,
         apps.hz_cust_acct_sites_all hcasa,
         apps.hz_cust_site_uses_all hcsua,
         ar.hz_contact_points hcp,
         apps.hz_locations hl
   WHERE     oha.header_id = ola.header_id
         AND oha.header_id = clv.header_id(+)
         AND ola.line_id = clv.line_id(+)
         AND oha.header_id = pav.header_id
         AND ola.line_id = pav.line_id
         AND oha.org_id = ola.org_id
         AND pav.adjustment_name = 'SO Header Adhoc Discount'
         AND oha.sold_to_org_id = cus.customer_id
         AND cus.customer_id = hca.cust_account_id
         AND hca.party_id = hps.party_id
         AND cus.customer_id = hca.cust_account_id
         AND hca.status = 'A'
         AND hca.cust_account_id = hcasa.cust_account_id(+)
         AND hcasa.status = 'A'
         AND hcsua.status = 'A'
         AND hcasa.party_site_id = hps.party_site_id
         AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
         AND hcsua.org_id = 126
         AND hps.location_id = hl.location_id
         AND site_use_code = 'BILL_TO'
         AND hps.party_site_id = hcp.owner_table_id(+)
         AND hcp.phone_number IS NOT NULL
         AND oha.org_id = 126
         AND TRUNC (oha.booked_date) > (TRUNC (TO_DATE ('09-JUN-2020')) - 2)
GROUP BY oha.org_id,
         cus.customer_number,
         cus.customer_name,
         oha.order_number,
         oha.booked_date,
         ola.order_quantity_uom,
         hcp.phone_number
ORDER BY BOOKED_DATE DESC;

/* --------------------------------------------------------------------------- */

  SELECT cus.customer_number,
         cus.customer_name,
         oha.order_number,
         oha.booked_date,
         SUM (ola.ordered_quantity) ordered_quantity,
         ola.order_quantity_uom uom,
         SUM (
              (ola.ordered_quantity * ola.unit_selling_price)
            - ABS (NVL (clv.charge_amount, 0)))
            amount,
         hcp.phone_number
    FROM oe_order_headers_all oha,
         oe_order_lines_all ola,
         apps.oe_charge_lines_v clv,
         oe_price_adjustments_v pav,
         ar_customers cus,
         apps.hz_cust_accounts hca,
         apps.hz_party_sites hps,
         apps.hz_cust_acct_sites_all hcasa,
         apps.hz_cust_site_uses_all hcsua,
         ar.hz_contact_points hcp,
         apps.hz_locations hl
   WHERE     oha.header_id = ola.header_id
         AND oha.header_id = clv.header_id(+)
         AND ola.line_id = clv.line_id(+)
         AND oha.header_id = pav.header_id
         AND ola.line_id = pav.line_id
         AND oha.org_id = ola.org_id
         AND pav.adjustment_name = 'SO Header Adhoc Discount'
         AND oha.sold_to_org_id = cus.customer_id
         AND cus.customer_id = hca.cust_account_id
         AND hca.party_id = hps.party_id
         AND cus.customer_id = hca.cust_account_id
         AND hca.status = 'A'
         AND hca.cust_account_id = hcasa.cust_account_id(+)
         AND hcasa.status = 'A'
         AND hcsua.status = 'A'
         AND hcasa.party_site_id = hps.party_site_id
         AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
         AND hcsua.org_id = 126
         AND hps.location_id = hl.location_id
         AND site_use_code = 'BILL_TO'
         AND hps.party_site_id = hcp.owner_table_id(+)
         AND hcp.phone_number IS NOT NULL
         AND oha.org_id = 126
         AND TO_DATE (oha.booked_date, 'DD/MM/RRRR hh12:mi:ssAM') BETWEEN TO_DATE (
                                                                             :p_StartDate,
                                                                             'DD/MM/RRRR hh12:mi:ssAM')
                                                                      AND TO_DATE (
                                                                             :p_EndDate,
                                                                             'DD/MM/RRRR hh12:mi:ssAM')
GROUP BY cus.customer_number,
         cus.customer_name,
         oha.order_number,
         oha.booked_date,
         ola.order_quantity_uom,
         hcp.phone_number
ORDER BY BOOKED_DATE                                          --, ORDER_NUMBER