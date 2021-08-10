/* Formatted on 03/Dec/20 12:17:47 (QP5 v5.354) */
SELECT                                                                     --*
       ac.customer_number,
       ac.customer_name,
       ac.customer_id,
       ptm.name                                  payment_term,
       hcsua.location                            bill_to_id,
       hl.address2 || '.' || hl.address3         bill_to_address,
       hcp.phone_number                          bill_to_contact,
       hcsuash.site_use_code,
       hcsuash.location                          ship_to_id,
       hlsh.address2 || '.' || hlsh.address3     ship_to_address,
       hcph.phone_number                         ship_to_contact,
       rsv.phone_number                          sr_phon_number,
       rsv.source_number                         employee_number,
       rsv.resource_name
  FROM apps.ar_customers            ac,
       apps.hz_cust_accounts        hca,
       apps.hz_cust_acct_sites_all  hcasa,
       apps.hz_cust_acct_sites_all  hcasash,
       apps.hz_party_sites          hps,
       apps.hz_party_sites          hpsh,
       apps.hz_cust_site_uses_all   hcsua,
       apps.hz_cust_site_uses_all   hcsuash,
       apps.hz_locations            hl,
       apps.hz_locations            hlsh,
       apps.hr_operating_units      hou,
       ra_terms                     ptm,
        (SELECT sal.salesrep_id,
                rsv.resource_name,
                source_number,
                phone_number
           FROM jtf_rs_salesreps       sal,
                jtf_rs_defresources_v  rsv,
                (SELECT parent_id, phone_type, phone_number
                   FROM per_phones
                  WHERE phone_type = 'W1') pp
          WHERE     sal.resource_id = rsv.resource_id
                AND rsv.source_id = pp.parent_id(+)) rsv,
       (SELECT owner_table_id, phone_number
          FROM ar.hz_contact_points
         WHERE contact_point_type = 'PHONE' AND status = 'A') hcp,
       (SELECT owner_table_id, phone_number
          FROM ar.hz_contact_points
         WHERE contact_point_type = 'PHONE' AND status = 'A') hcph
 WHERE     hcsua.site_use_id = hcsuash.bill_to_site_use_id(+)
       AND ac.customer_id = hca.cust_account_id(+)
       AND hcasa.party_site_id = hps.party_site_id(+)
       AND hcasash.party_site_id = hpsh.party_site_id(+)
       AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id(+)
       AND hcsuash.cust_acct_site_id = hcasash.cust_acct_site_id(+)
       AND hps.location_id = hl.location_id(+)
       AND hpsh.location_id = hlsh.location_id(+)
       AND hou.organization_id = hcsua.org_id
       AND hou.organization_id = hcsuash.org_id
       AND hca.cust_account_id = hcasa.cust_account_id(+)
       AND hca.cust_account_id = hcasash.cust_account_id(+)
       AND hcsua.payment_term_id = ptm.term_id(+)
       AND hcasa.status = 'A'
       AND hcsua.status = 'A'
       AND hcasash.status = 'A'
       AND hcsuash.status = 'A'
       AND hca.status = 'A'
       AND hps.party_site_id = hcp.owner_table_id(+)
       AND hpsh.party_site_id = hcph.owner_table_id(+)
       AND hcsuash.primary_salesrep_id = rsv.salesrep_id(+)
       --AND hcp.phone_number IS NOT NULL
       AND hou.name = 'DBLCL'
       AND ac.customer_number in ('100320','130455')