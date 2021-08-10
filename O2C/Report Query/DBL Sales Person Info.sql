/* Formatted on 8/27/2020 12:46:33 PM (QP5 v5.354) */
-----------------------------****CCL2****-------------------------------------------

/* Formatted on 8/27/2020 4:06:02 PM (QP5 v5.287) */
SELECT HOU.ORGANIZATION_ID,
       HOU.NAME ORGANIZATION,
       CA.ACCOUNT_NUMBER,
       HP.PARTY_NAME CUSTOMER_NAME,
       CSUA.SITE_USE_ID PARTY_SITE_NUMBER,
       --APPS.hz_format_pub.format_address (HPS.location_id, NULL, NULL,' ') LOCATION_ADDRESS,
       LOC.ADDRESS1 --|| ', ' || LOC.ADDRESS2 || ', ' || LOC.ADDRESS3 
       ADDRESS,
       SAL.NAME SALESREP_NAME,
       SAL.SALESREP_NUMBER SALESREP_NUMBER,
       NVL (papf.employee_number, papf.NPW_NUMBER) SUPERVISOR_EMP_ID,
       pp.phone_number sr_phone_number
  --,CA.*
  --,CASA.*
  --,CSUA.*
  --,HOU.*
  --,HP.*
  --,HPS.*
  --,LOC.*
  --,SAL.*
  --,RSV.*
  FROM hz_parties hp,
       hz_cust_accounts ca,
       hz_cust_site_uses_all CSUA,
       hz_cust_acct_sites_all CASA,
       APPS.HR_OPERATING_UNITS HOU,
       hz_party_sites Hps,
       hz_locations loc,
       JTF_RS_SALESREPS SAL,
       JTF_RS_DEFRESOURCES_V RSV,
       HR.PER_ALL_ASSIGNMENTS_F PAAF,
       HR.PER_ALL_PEOPLE_F PAPF,
       per_phones pp
 WHERE     1 = 1
       AND ( :P_ORG_ID IS NULL OR CASA.ORG_ID = :P_ORG_ID)
       AND HOU.ORGANIZATION_ID = CASA.ORG_ID
       AND hp.party_id = ca.party_id
       AND CSUA.cust_acct_site_id = CASA.cust_acct_site_id
       AND ca.cust_account_id = CASA.cust_account_id
       AND CASA.party_site_id = Hps.party_site_id
       AND Hps.location_id = loc.location_id
       --AND HPS.IDENTIFYING_ADDRESS_FLAG = 'Y'
       --AND ACCOUNT_NUMBER = '93115'
       AND CSUA.PRIMARY_SALESREP_ID = SAL.SALESREP_ID(+)
       AND SAL.RESOURCE_ID = RSV.RESOURCE_ID
       AND CASA.ORG_ID = SAL.ORG_ID(+)
       AND rsv.source_id = pp.parent_id(+)
       AND pp.phone_type(+) = 'W1'
       AND SYSDATE BETWEEN paaf.EFFECTIVE_START_DATE
                       AND paaf.EFFECTIVE_END_DATE
       AND SAL.PERSON_ID = paaf.PERSON_ID(+)
       AND paaf.SUPERVISOR_ID = papf.PERSON_ID(+)
       --AND LOC.ADDRESS1 LIKE '%Sewing Thread%'
       ;

-----------------------------**** OLD CCL2****-------------------------------------------

  SELECT HOU.ORGANIZATION_ID,
         HOU.NAME
             ORGANIZATION,
         CA.ACCOUNT_NUMBER,
         HP.PARTY_NAME
             CUSTOMER_NAME,
         CSUA.SITE_USE_ID
             PARTY_SITE_NUMBER,
         LOC.ADDRESS1 || ', ' || LOC.ADDRESS2 || ', ' || LOC.ADDRESS3
             ADDRESS,
         SAL.NAME
             SALESREP_NAME,
         SAL.SALESREP_NUMBER
             SALESREP_NUMBER,
         NVL (papf.employee_number, papf.NPW_NUMBER)
             SUPERVISOR_EMP_ID,
         pp.phone_number
             sr_phone_number
    --,CA.*
    --,CASA.*
    --,CSUA.*
    --,HOU.*
    --,HP.*
    --,HPS.*
    --,LOC.*
    --,SAL.*
    --,RSV.*
    FROM APPS.HZ_CUST_ACCOUNTS      CA,
         APPS.HZ_CUST_SITE_USES_ALL CSUA,
         APPS.HZ_CUST_ACCT_SITES_ALL CASA,
         APPS.HR_OPERATING_UNITS    HOU,
         APPS.HZ_PARTIES            HP,
         APPS.HZ_PARTY_SITES        HPS,
         APPS.HZ_LOCATIONS          LOC,
         JTF_RS_SALESREPS           SAL,
         JTF_RS_DEFRESOURCES_V      RSV,
         HR.PER_ALL_ASSIGNMENTS_F   PAAF,
         HR.PER_ALL_PEOPLE_F        PAPF,
         per_phones                 pp
   WHERE     1 = 1
         AND ( :P_ORG_ID IS NULL OR CASA.ORG_ID = :P_ORG_ID)
         AND CSUA.CUST_ACCT_SITE_ID = CASA.CUST_ACCT_SITE_ID
         AND CA.CUST_ACCOUNT_ID = CASA.CUST_ACCOUNT_ID
         AND HOU.ORGANIZATION_ID = CASA.ORG_ID
         --AND CA.STATUS='A'
         --AND CSUA.STATUS='A'
         AND HP.PARTY_ID = CA.PARTY_ID
         AND HPS.PARTY_ID = HP.PARTY_ID
         AND HPS.LOCATION_ID = LOC.LOCATION_ID
         --AND HP.STATUS='A'
         --AND HPS.STATUS='A'
         AND HPS.IDENTIFYING_ADDRESS_FLAG = 'Y'
         --AND SITE_USE_CODE = 'BILL_TO'
         --AND CSUA.BILL_TO_SITE_USE_ID='37644'
         --AND CSUA.SITE_USE_ID='34777'
         --AND CSUA.LOCATION = '93215'
         AND SITE_USE_CODE = 'SHIP_TO'
         --AND CSUA.PRIMARY_SALESREP_ID IS NOT NULL
         AND CSUA.PRIMARY_SALESREP_ID = SAL.SALESREP_ID(+)
         AND SAL.RESOURCE_ID = RSV.RESOURCE_ID
         AND CASA.ORG_ID = SAL.ORG_ID(+)
         AND rsv.source_id = pp.parent_id(+)
         AND pp.phone_type(+) = 'W1'
         --AND pp.phone_number IS NULL
         --AND PRIMARY_FLAG='Y'
         --AND STATUS = 'A'
         --AND UPPER(CA.ACCOUNT_NAME) LIKE UPPER('%'||:P_CUST_NAME||'%')
         --AND ACCOUNT_NUMBER IN ('20072')
         --AND HP.CATEGORY_CODE IS NULL
         AND SYSDATE BETWEEN paaf.EFFECTIVE_START_DATE
                         AND paaf.EFFECTIVE_END_DATE
         AND SAL.PERSON_ID = paaf.PERSON_ID(+)
         AND paaf.SUPERVISOR_ID = papf.PERSON_ID(+)
         AND (   :P_CUSTOMER_NUMBER IS NULL
              OR (CA.ACCOUNT_NUMBER = :P_CUSTOMER_NUMBER))
         AND (   :P_CUST_NAME IS NULL
              OR (UPPER (HP.PARTY_NAME) LIKE UPPER ('%' || :P_CUST_NAME || '%')))
ORDER BY CA.ACCOUNT_NUMBER DESC;


 SELECT sal.name salesrep_name,
       sal.salesrep_number salesrep_number,
       rsv.source_job_title salesrep_job_title,
       SAL.PERSON_ID,
       paaf.SUPERVISOR_ID,
       NVL (papf.employee_number, papf.npw_number) supervisor_emp_id,
       NVL (ppf.employee_number, ppf.npw_number) salesperson_emp_id,
       (ppf.first_name || ' ' || ppf.middle_names || ' ' || ppf.last_name)
          as employee_name
  FROM jtf_rs_salesreps sal,
       jtf_rs_defresources_v rsv,
       hr.per_all_assignments_f paaf,
       hr.per_all_people_f papf,
       hr.per_all_people_f ppf
 WHERE     1 = 1
       --AND csua.primary_salesrep_id = sal.salesrep_id(+)
       --AND casa.org_id = sal.org_id(+)
       AND sal.resource_id = rsv.resource_id
       AND SYSDATE BETWEEN paaf.effective_start_date
                       AND paaf.effective_end_date
                       AND sal.person_id = ppf.person_id(+)
       AND sal.person_id = paaf.person_id(+)
       AND paaf.supervisor_id = papf.person_id(+);