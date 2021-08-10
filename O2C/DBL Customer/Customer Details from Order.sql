SELECT
     h.order_number
    ,h.sold_to_org_id bill_cust_account_id
    ,h.ship_to_org_id ship_to_site_use_id
    ,h.invoice_to_org_id bill_to_site_use_id
    ,hp.party_name "Customer Name"
    ,hca.account_name
    ,hca.org_id
    ,hcasab.orig_system_reference      BILL_TO_ORIG_REF
    ,hpb.status                        BILL_TO_STATUS
    ,'ADDRESS1 - '||bill_loc.address1||','||CHR(10)||
     'ADDRESS2 - '||bill_loc.address2||','||CHR(10)||
     'ADDRESS3 - '||bill_loc.address3||','||CHR(10)||
     'CITY     - '||bill_loc.city||','||CHR(10)||
     'POSTAL CD- '||bill_loc.postal_code||','||CHR(10)||
     'COUNTRY  - '|| bill_loc.country  BILL_TO_ADDRESS
    ,hcasas.orig_system_reference      SHIP_TO_ORIG_REF
    ,hps.status                        SHIP_TO_STATUS
    ,'ADDRESS1 - '||ship_loc.address1||','||CHR(10)||
     'ADDRESS2 - '||ship_loc.address2||','||CHR(10)||
     'ADDRESS3 - '||ship_loc.address3||','||CHR(10)||
     'CITY     - '||ship_loc.city||','||CHR(10)||
     'POSTAL CD- '||ship_loc.postal_code||','||CHR(10)||
     'COUNTRY  - '|| ship_loc.country  SHIP_TO_ADDRESS
FROM oe_order_headers_all h
    ,hz_parties hp
    ,hz_cust_accounts hca
    ,hz_cust_acct_sites_all hcasab
    ,hz_cust_acct_sites_all hcasas
    ,hz_cust_site_uses_all hzsuab
    ,hz_cust_site_uses_all hzsuas
    ,hz_party_sites hps
    ,hz_party_sites hpb
    ,hz_locations bill_loc
    ,hz_locations ship_loc
WHERE 1 =1
AND hp.party_id             = hca.party_id
AND hca.CUST_ACCOUNT_ID     = h.sold_to_org_id
AND hcasab.cust_account_id  = hca.cust_account_id
AND hcasas.cust_account_id  = hca.cust_account_id
AND hpb.location_id         = bill_loc.location_id
AND hps.location_id         = ship_loc.location_id
AND hcasab.party_site_id    = hpb.party_site_id
AND hcasas.party_site_id    = hps.party_site_id
AND hcasab.cust_acct_site_id= hzsuab.cust_acct_site_id
AND hcasas.cust_acct_site_id= hzsuas.cust_acct_site_id
AND h.ship_to_org_id        = hzsuas.site_use_id
AND h.invoice_to_org_id     = hzsuab.site_use_id
AND h.order_number          = '&order_number';