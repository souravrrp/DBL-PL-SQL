/* Formatted on 11/15/2021 12:01:52 PM (QP5 v5.365) */
  SELECT DISTINCT TL.ORG_ID,
                  WND.DELIVERY_ID,
                  (TL.DELIVERY_CHALLAN_NUMBER)     DELIVERY_CHALLAN_NUMBER,
                  TL.CUSTOMER_NAME,
                  TL.CUSTOMER_NUMBER,
                  HCP.PHONE_NUMBER,
                  OLV.ORDER_NUMBER,
                  TL.SECONDARY_QUANTITY            SECONDARY_QUANTITY_CTN,
                  TL.PRIMARY_QUANTITY              PRIMARY_QUANTITY_SFT,
                  WND.ATTRIBUTE4                   DRIVER_NAME,
                  WND.ATTRIBUTE5                   DRIVER_CONTACT_NO,
                  WND.ATTRIBUTE2                   VEHICLE_NO,
                  WND.CONFIRM_DATE,
                  TH.TRANSPOTER_CHALLAN_NUMBER,
                  hl.address1                      bill_to_address,
                  hlsh.address1                    ship_to_address,
                  hcp.phone_number                 bill_to_contact,
                  hcph.phone_number                ship_to_contact,
                  pp.phone_number                  sr_phone_number
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
         oe_order_headers_all         oha,
         xxdbl.xxdbl_omshipping_line_v olv,
         wsh_new_deliveries           wnd,
         xxdbl_transpoter_line        tl,
         xxdbl_transpoter_headers     th,
         jtf_rs_salesreps             sal,
         jtf_rs_defresources_v        rsv,
         (SELECT parent_id, phone_type, phone_number
            FROM per_phones
           WHERE phone_type = 'W1') pp,
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
         AND ac.customer_id = oha.sold_to_org_id
         AND hcsua.site_use_id = oha.invoice_to_org_id
         AND hcsuash.site_use_id = oha.ship_to_org_id
         AND hcasa.status = 'A'
         AND hcsua.status = 'A'
         AND hcasash.status = 'A'
         AND hcsuash.status = 'A'
         AND hca.status = 'A'
         AND hca.status = 'A'
         AND hps.status = 'A'
         AND hpsh.status = 'A'
         AND olv.order_number = oha.order_number
         AND olv.delivery_id = wnd.delivery_id
         AND olv.delivery_challan_number = tl.delivery_challan_number
         AND tl.transpoter_header_id = th.transpoter_header_id
         AND hps.party_site_id = hcp.owner_table_id(+)
         AND hpsh.party_site_id = hcph.owner_table_id(+)
         AND tl.customer_number = hca.account_number
         AND tl.org_id = oha.org_id
         AND oha.org_id = hcasa.org_id
         AND hcasa.org_id = hcasash.org_id
         AND tl.org_id = 126
         AND hcp.phone_number IS NOT NULL
         AND oha.salesrep_id = sal.salesrep_id(+)
         AND oha.org_id = sal.org_id(+)
         AND sal.resource_id = rsv.resource_id
         AND rsv.source_id = pp.parent_id(+)
         --AND TO_CHAR (WND.CONFIRM_DATE, 'MON-RRRR') = TO_CHAR ('MAY-2020')
         AND TRUNC (wnd.confirm_date) = (TRUNC (TO_DATE (SYSDATE - 600)))
         AND 'DELIVERY' = NVL ( :SMS_TYPE_PM, 'DELIVERY')
         AND NOT EXISTS
                 (SELECT 1
                    FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                   WHERE     tl.org_id = stg.org_id
                         AND STG.DELIVERY_ID = WND.DELIVERY_ID)
ORDER BY TL.DELIVERY_CHALLAN_NUMBER DESC;