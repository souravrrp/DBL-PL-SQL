/* Formatted on 22/Oct/20 11:03:09 (QP5 v5.354) */
  SELECT oha.org_id,
         cus.customer_number,
         cus.customer_name,
         oha.header_id,
         oha.order_number,
         oha.booked_date,
         SUM (ola.ordered_quantity)                 ordered_quantity,
         SUM (ola.ordered_quantity2)                ordered_sec_quantity,
         ola.order_quantity_uom                     uom,
         SUM (
               (ola.ordered_quantity * ola.unit_selling_price)
             - ABS (NVL (clv.charge_amount, 0)))    amount,
         hcp.phone_number,
         pp.phone_number                            sr_phone_number
    FROM oe_order_headers_all       oha,
         oe_order_lines_all         ola,
         apps.oe_charge_lines_v     clv,
         oe_price_adjustments_v     pav,
         ar_customers               cus,
         apps.hz_cust_accounts      hca,
         apps.hz_party_sites        hps,
         apps.hz_cust_acct_sites_all hcasa,
         apps.hz_cust_site_uses_all hcsua,
         apps.hz_locations          hl,
         jtf_rs_salesreps           sal,
         jtf_rs_defresources_v      rsv,
         (SELECT parent_id, phone_type, phone_number
            FROM per_phones
           WHERE phone_type = 'W1') pp,
         (SELECT owner_table_id, phone_number
            FROM ar.hz_contact_points
           WHERE contact_point_type = 'PHONE' AND status = 'A') hcp
   WHERE     oha.header_id = ola.header_id
         AND oha.header_id = clv.header_id(+)
         AND ola.line_id = clv.line_id(+)
         AND oha.header_id = pav.header_id
         AND ola.line_id = pav.line_id
         AND oha.org_id = ola.org_id
         AND oha.flow_status_code != 'CANCELLED'
         AND ola.flow_status_code <> 'CANCELLED'
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
         AND oha.salesrep_id = sal.salesrep_id(+)
         AND sal.resource_id = rsv.resource_id
         AND oha.org_id = sal.org_id(+)
         AND rsv.source_id = pp.parent_id(+)
         AND TRUNC (oha.booked_date) = (TRUNC (TO_DATE (SYSDATE)))
         --AND TO_CHAR (oha.booked_date, 'MON-RRRR') = TO_CHAR ('AUG-2020')
         AND 'BOOKED' = NVL (SMS_TYPE_PM, 'BOOKED')
         AND NOT EXISTS
                 (SELECT 1
                    FROM ont.oe_order_holds_all ooha
                   WHERE     oha.header_id = ooha.header_id
                         AND ooha.released_flag <> 'Y')
         AND NOT EXISTS
                 (SELECT 1
                    FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                   WHERE     oha.org_id = stg.org_id
                         AND oha.header_id = stg.ord_header_id)
GROUP BY oha.org_id,
         cus.customer_number,
         cus.customer_name,
         oha.header_id,
         oha.order_number,
         oha.booked_date,
         ola.order_quantity_uom,
         hcp.phone_number,
         pp.phone_number
ORDER BY booked_date DESC;