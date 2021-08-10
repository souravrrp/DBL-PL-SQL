/* Formatted on 6/14/2021 11:51:16 AM (QP5 v5.354) */
SELECT mph.manual_pi_number
           proforma_number,
       mph.status
           proforma_status,
       mph.manual_pi_date
           proforma_date,
       mph.customer_no
           customer_number,
       mph.customer_name,
       (SELECT    hl.address1
               || DECODE (hl.address2, NULL, NULL, ',' || hl.address2)
               || DECODE (hl.address3, NULL, NULL, ',' || hl.address3)
               || DECODE (hl.address4, NULL, NULL, ',' || hl.address4)
               || DECODE (hl.city, NULL, NULL, ',' || hl.city)
               || DECODE (hl.postal_code, NULL, NULL, ',' || hl.postal_code)
               || DECODE (hl.state, NULL, NULL, ',' || hl.state)
               || DECODE (hl.country, NULL, NULL, ',' || hl.country)    customer_address
          FROM hz_cust_accounts_all    hca,
               hz_cust_acct_sites_all  hcas,
               hz_cust_site_uses_all   hcsu,
               hz_party_sites          hps,
               hz_locations            hl
         WHERE     hca.cust_account_id = hcas.cust_account_id
               AND hcas.cust_acct_site_id = hcsu.cust_acct_site_id
               AND hcsu.site_use_code = 'BILL_TO'
               AND hcsu.status = 'A'
               AND hcsu.org_id = '125'
               AND hcas.party_site_id = hps.party_site_id
               AND hps.location_id = hl.location_id
               AND hca.account_number = mph.customer_no)
           customer_address,
       mph.po_number
           customer_po_number,
       mph.style,
       mph.manual_bs_number
           bill_stat_number,
       mph.manual_bs_date
           bs_date,
       mph.merchandiser_name
           m_name,
       mph.payment_terms
           payment_term,
       mph.bank_name,
       mpl.article_name
           article_ticket,
       --mpl.item_code,
       mpl.item_description,
       mpl.quantity,
       mpl.unit_of_measure
           unit,
       mpl.net_weight,
       mpl.gross_weight,
       mpl.unit_price
           price_per_unit,
       mpl.net_value
  --,mph.*
  --,mpl.*
  FROM xxdbl.xxdbl_manual_pi_header mph, xxdbl.xxdbl_manual_pi_line mpl
 WHERE     1 = 1
       AND mph.manual_pi_id = mpl.manual_pi_id
       AND (   :p_proforma_number IS NULL
            OR (mph.manual_pi_number = :p_proforma_number));