/* Formatted on 08-Sep-20 10:01:19 (QP5 v5.136.908.31019) */
SELECT                                                                     --*
      hou.name,
       ac.customer_number,
       ac.customer_name,
       ac.customer_id,
       (CASE
           WHEN ac.customer_type = 'R' THEN 'External'
           WHEN ac.customer_type = 'I' THEN 'Internal'
           WHEN ac.customer_type = '' THEN 'N/A'
        END)
          customer_type,
          ptm.name                                  payment_term,
       hcsua.location bill_to_id,
       hl.address1 bill_to_address,
       hl.postal_code bill_to_postal,
       hlsh.postal_code ship_to_postal,
       hcsuash.site_use_code,
       hcsuash.location ship_to_id,
       hlsh.address1 ship_to_address,
          rt.segment1
       || '.'
       || rt.segment2
       || '.'
       || rt.segment3
       || '.'
       || rt.segment4
          territory_combination,
       hcsuash.demand_class_code,
       hcsua.gl_id_rec,
       glc.concatenated_segments gl_code,
       cpa.overall_credit_limit,
       rsv.resource_name sales_person,
       rsv.source_number employee_no,
       decode (hcasa.bill_to_flag, 'P', 'Primary', null) primary_bill_to,
       decode (hcasash.ship_to_flag, 'P', 'Primary', null) primary_ship_to 
  FROM apps.ar_customers ac,
       apps.hz_cust_accounts hca,
       apps.hz_cust_acct_sites_all hcasa,
       apps.hz_cust_acct_sites_all hcasash,
       apps.hz_party_sites hps,
       apps.hz_party_sites hpsh,
       apps.hz_cust_site_uses_all hcsua,
       apps.hz_cust_site_uses_all hcsuash,
       apps.hz_locations hl,
       apps.hz_locations hlsh,
       apps.hr_operating_units hou,
       ra_territories rt,
       ra_terms                     ptm,
       gl_code_combinations_kfv glc,
       hz_cust_profile_amts cpa,
       (SELECT sal.salesrep_id, rsv.resource_name, source_number
          FROM jtf_rs_salesreps sal, jtf_rs_defresources_v rsv
         WHERE sal.resource_id = rsv.resource_id) rsv
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
       AND hcsuash.territory_id = rt.territory_id(+)
       AND hca.cust_account_id = cpa.cust_account_id(+)
       AND hcsua.site_use_id = cpa.site_use_id(+)
       AND hcsuash.primary_salesrep_id = rsv.salesrep_id(+)
       AND hcsua.payment_term_id = ptm.term_id(+)
       AND hcasa.status = 'A'
       AND hcsua.status = 'A'
       AND hcasash.status = 'A'
       AND hcsuash.status = 'A'
       AND hca.status = 'A'
       AND hcsua.gl_id_rec = glc.code_combination_id(+)
       --AND HCSUA.SITE_USE_ID=2864
       AND hca.account_number = '110449'
       AND hou.name = 'CCL2'
--AND AC.CUSTOMER_TYPE = 'I'
--and ac.customer_name like '%DBL%'


/* Formatted on 09-Jul-18 10:49:14 (QP5 v5.136.908.31019) */
SELECT --*
       HCASA.CUST_ACCT_SITE_ID,
       HCASA.CUST_ACCOUNT_ID,
       HCASA.PARTY_SITE_ID,
       HCASA.ORG_ID,
       HCASASH.CUST_ACCT_SITE_ID,
       HCASASH.CUST_ACCOUNT_ID,
       HCASASH.PARTY_SITE_ID,
       HCASASH.ORG_ID,
       HPS.PARTY_SITE_ID,
       HPS.PARTY_ID,
       HPS.LOCATION_ID,
       HPS.PARTY_SITE_NUMBER,
       HPSH.PARTY_SITE_ID,
       HPSH.PARTY_ID,
       HPSH.LOCATION_ID,
       HPSH.PARTY_SITE_NUMBER,
       HCSUA.SITE_USE_ID,
       HCSUA.CUST_ACCT_SITE_ID,
       HCSUA.SITE_USE_CODE,
       HCSUA.LOCATION,
       HCSUASH.SITE_USE_ID,
       HCSUASH.CUST_ACCT_SITE_ID,
       HCSUASH.SITE_USE_CODE,
       HCSUASH.LOCATION,
       HL.LOCATION_ID,
       HL.ADDRESS1,
       HLSH.LOCATION_ID,
       HLSH.ADDRESS1
  FROM APPS.AR_CUSTOMERS AC,
       APPS.HZ_CUST_ACCOUNTS HCA,
       APPS.HZ_CUST_ACCT_SITES_ALL HCASA,
       APPS.HZ_CUST_ACCT_SITES_ALL HCASASH,
       APPS.HZ_PARTY_SITES HPS,
       APPS.HZ_PARTY_SITES HPSH,
       APPS.HZ_CUST_SITE_USES_ALL HCSUA,
       APPS.HZ_CUST_SITE_USES_ALL HCSUASH,
       APPS.HZ_LOCATIONS HL,
       APPS.HZ_LOCATIONS HLSH,
       APPS.HR_OPERATING_UNITS HOU
 WHERE     HCSUA.SITE_USE_ID = HCSUASH.BILL_TO_SITE_USE_ID
       AND AC.CUSTOMER_ID = HCA.CUST_ACCOUNT_ID
       AND HCASA.PARTY_SITE_ID = HPS.PARTY_SITE_ID
       AND HCASASH.PARTY_SITE_ID = HPSH.PARTY_SITE_ID
       AND HCSUA.CUST_ACCT_SITE_ID = HCASA.CUST_ACCT_SITE_ID
       AND HCSUASH.CUST_ACCT_SITE_ID = HCASASH.CUST_ACCT_SITE_ID
       AND HPS.LOCATION_ID = HL.LOCATION_ID
       AND HPSH.LOCATION_ID = HLSH.LOCATION_ID
       AND HOU.ORGANIZATION_ID = HCSUA.ORG_ID
       AND HOU.ORGANIZATION_ID = HCSUASH.ORG_ID
       AND HCA.CUST_ACCOUNT_ID = HCASA.CUST_ACCOUNT_ID(+)
       AND HCA.CUST_ACCOUNT_ID = HCASASH.CUST_ACCOUNT_ID(+)
       AND HCASA.STATUS = 'A'
       AND HCSUA.STATUS = 'A'
       AND HCASASH.STATUS = 'A'
       AND HCSUASH.STATUS = 'A'
       AND HCA.STATUS = 'A'
       --AND HCSUA.SITE_USE_ID=2864
       AND HCA.ACCOUNT_NUMBER = 2210
       AND HOU.NAME = 'DDL'


select * from APPS.AR_CUSTOMERS
where CUSTOMER_NUMBER='2016'

select * from APPS.HZ_CUST_ACCOUNTS
where CUST_ACCOUNT_ID=2056

select * from APPS.HZ_CUST_ACCT_SITES_ALL
where CUST_ACCOUNT_ID=2056
and org_id=125

select * from APPS.HZ_PARTY_SITES
where PARTY_ID=6069
and PARTY_SITE_ID in (4192,4193,4194,131499)
--and org_id=125

select * from APPS.HZ_CUST_SITE_USES_ALL
where org_id=125
and CUST_ACCT_SITE_ID in (2211,
2212,
2213,
101471)
and SITE_USE_CODE in ('BILL_TO','SHIP_TO')

select * from APPS.HZ_LOCATIONS
where LOCATION_ID in (
513,
514,
515,
16830)


select * from APPS.HZ_LOCATIONS HL
where LOCATION_ID=1165