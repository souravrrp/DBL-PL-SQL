/* Formatted on 5/30/2021 10:09:42 AM (QP5 v5.287) */
  SELECT *
    FROM xxdbl.xxdbl_cust_creation_tbl cct
   WHERE 1 = 1 AND ( :p_cust_id IS NULL OR (cct.cust_id = :p_cust_id))
--AND CUST_ACCOUNT_ID='235444'
--AND cct.status IS NULL
--AND UPPER (cct.customer_name) LIKE UPPER ('%' || :p_customer_name || '%')
ORDER BY cct.cust_id DESC;


--UPDATE xxdbl.xxdbl_cust_creation_tbl cct SET cct.status='Y' WHERE cct.cust_id = :p_cust_id;

--UPDATE xxdbl.xxdbl_cust_creation_tbl cct SET cct.payment_term='1000' WHERE cct.cust_id = :p_cust_id;

--TRUNCATE TABLE xxdbl.xxdbl_cust_creation_tbl;

--SELECT TRIM (LPAD (apps.xxdbl_cust_creation_s.NEXTVAL, 7, '0')) FROM DUAL;

UPDATE xxdbl.xxdbl_cust_creation_tbl
   SET status = 'Y',
       cust_account_id = '242433',
       customer_number = '151456'
 WHERE status IS NULL AND cust_id = 1000079;
COMMIT;

SELECT hou.organization_id, hou.name
  FROM hr_organization_units hou
 WHERE hou.name = :p_unit_name;

SELECT NVL (customer_number, 0), ac.*
  --INTO l_customer_number
  FROM apps.ar_customers ac
 WHERE UPPER (ac.customer_name) LIKE UPPER ('%' || :p_customer_name || '%');

SELECT *
  FROM HZ_CUST_ACCOUNTS hca
 WHERE     1 = 1
       AND (   :p_customer_number IS NULL
            OR (hca.account_number = :p_customer_number))
       --AND ATTRIBUTE_CATEGORY = 'Additional Information'
       --AND CUSTOMER_TYPE = 'I'
       AND UPPER (hca.account_name) LIKE
              UPPER ('%' || :p_customer_name || '%');


SELECT * FROM ra_terms;

SELECT LOOKUP_TYPE,
       LOOKUP_CODE,
       MEANING,
       DESCRIPTION,
       START_DATE_ACTIVE,
       END_DATE_ACTIVE
  --,FLV.*
  FROM FND_LOOKUP_VALUES_VL FLV
 WHERE 1 = 1 AND FLV.LOOKUP_TYPE = 'DEMAND_CLASS' AND ENABLED_FLAG = 'Y';

SELECT LOOKUP_TYPE,
       LOOKUP_CODE,
       MEANING,
       DESCRIPTION,
       START_DATE_ACTIVE,
       END_DATE_ACTIVE
  --,FLV.*
  FROM FND_LOOKUP_VALUES_VL FLV
 WHERE 1 = 1 AND FLV.LOOKUP_TYPE = 'CUSTOMER_CATEGORY' AND ENABLED_FLAG = 'Y';


SELECT LOOKUP_TYPE,
       LOOKUP_CODE,
       MEANING,
       DESCRIPTION,
       START_DATE_ACTIVE,
       END_DATE_ACTIVE
  --,FLV.*
  FROM FND_LOOKUP_VALUES_VL FLV
 WHERE 1 = 1 AND FLV.LOOKUP_TYPE = 'SALES_CHANNEL' AND ENABLED_FLAG = 'Y';

SELECT DISTINCT concatenated_segments, code_combination_id
  --,gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 || '.' || gcc.segment7 || '.' || gcc.segment8 || '.' || gcc.segment9    acct_code
  FROM apps.gl_code_combinations_kfv gcc
 WHERE     1 = 1
       AND ( :p_gl_code IS NULL OR (gcc.concatenated_segments = :p_gl_code))
       --and concatenated_segments in ('201.101.151.18809.511104.998.999.101.999')
       --AND code_combination_id IN (175910)
       AND (   :p_code_comb_id IS NULL
            OR (gcc.code_combination_id = :p_code_comb_id));

SELECT TERRITORY_ID l_TERRITORY, rt.*
  FROM ra_territories rt
 WHERE segment1 || '.' || segment2 || '.' || segment3 || '.' || segment4 =
          'Bangladesh.Area-1.Zone-A.N/A';

SELECT lookup_type,
       lookup_code,
       meaning,
       description,
       start_date_active,
       end_date_active
  --,FLV.*
  FROM fnd_lookup_values_vl flv
 WHERE 1 = 1 AND UPPER (lookup_type) = UPPER ( :p_lookup_type);

SELECT sal.name salesrep_name,
       sal.salesrep_number salesrep_number,
       rsv.source_job_title salesrep_job_title,
       SAL.PERSON_ID,
       paaf.SUPERVISOR_ID,
       NVL (papf.employee_number, papf.npw_number) supervisor_emp_id,
       NVL (ppf.employee_number, ppf.npw_number) salesperson_emp_id
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

SELECT sal.salesrep_id l_l_salesperson, sal.*
  FROM jtf_rs_salesreps sal, hr.per_all_people_f papf
 WHERE     1 = 1
       AND sal.person_id = papf.person_id
       AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                               AND TRUNC (papf.effective_end_date)
       AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
       --AND NVL (papf.employee_number, papf.npw_number)=:P_SALESPERSON
       AND sal.org_id = :l_operating_unit;


SELECT ood.operating_unit,
       ood.organization_id,
       ou.set_of_books_id,
       ou.default_legal_context_id
  --           INTO L_OPERATING_UNIT,
  --                L_ORGANIZATION_ID,
  --                L_SET_OF_BOOKS,
  --                L_LEGAL_ENTITY_ID
  FROM org_organization_definitions ood, hr_operating_units ou
 WHERE     1 = 1
       AND ood.operating_unit = ou.organization_id
       AND ood.organization_code = :p_organization_code;


  SELECT hou.organization_id,
         hou.name organization,
         ca.account_number,
         ca.cust_account_id customer_id,
         --hp.party_name customer_name,
         ca.status account_status,
         csua.status customer_site_status,
         ca.creation_date "ACCOUNT CREATION DATE",
         casa.creation_date "ACCOUNT SITE CREATION DATE",
         csua.site_use_code,
         casa.cust_acct_site_id,
         csua.site_use_id party_site_number,
         csua.site_use_id,
         csua.location
    --hp.category_code
    --,CA.*
    --,CASA.*
    --,CSUA.*
    --,HOU.*
    --,HP.*
    --,HPS.*
    --,LOC.*
    FROM apps.hz_cust_accounts ca,
         apps.hz_cust_site_uses_all csua,
         apps.hz_cust_acct_sites_all casa,
         apps.hr_operating_units hou,
         apps.hz_locations loc
   WHERE     1 = 1
         AND csua.cust_acct_site_id = casa.cust_acct_site_id
         AND ca.cust_account_id = casa.cust_account_id
         AND hou.organization_id = casa.org_id
         AND ca.status = 'A'
         AND csua.status = 'A'
         --AND hps.location_id = loc.location_id
         AND site_use_code = 'SHIP_TO'
         AND CA.STATUS = 'A'
         AND ACCOUNT_NUMBER = :p_customer_number
ORDER BY account_number DESC;

  SELECT hou.organization_id,
         hou.name organization,
         ca.account_number,
         hp.party_id,
         ca.cust_account_id customer_id,
         hp.party_name customer_name,
         ca.status account_status,
         csua.status customer_site_status,
         ca.creation_date "ACCOUNT CREATION DATE",
         casa.creation_date "ACCOUNT SITE CREATION DATE",
         csua.site_use_code,
         casa.cust_acct_site_id,
         csua.site_use_id party_site_number,
         csua.site_use_id,
         csua.location,
         hp.category_code,
         ca.sales_channel_code
    --,CA.*
    --,CASA.*
    --,CSUA.*
    --,HOU.*
    --,HP.*
    --,HPS.*
    --,LOC.*
    FROM apps.hz_cust_accounts ca,
         apps.hz_cust_site_uses_all csua,
         apps.hz_cust_acct_sites_all casa,
         apps.hr_operating_units hou,
         apps.hz_parties hp
   --,APPS.HZ_PARTY_SITES HPS
   --,APPS.HZ_LOCATIONS LOC
   WHERE     1 = 1
         AND ( :p_org_id IS NULL OR casa.org_id = :p_org_id)
         AND csua.cust_acct_site_id = casa.cust_acct_site_id
         AND ca.cust_account_id = casa.cust_account_id
         AND hou.organization_id = casa.org_id
         --AND CA.STATUS='A'
         --AND CSUA.STATUS='A'
         AND hp.party_id = ca.party_id
         --AND HPS.PARTY_ID = HP.PARTY_ID
         --AND HPS.LOCATION_ID = LOC.LOCATION_ID
         --AND HP.STATUS='A'
         --AND HPS.STATUS='A'
         --AND HPS.IDENTIFYING_ADDRESS_FLAG='Y'
         --AND site_use_code = 'BILL_TO'
         --AND CSUA.BILL_TO_SITE_USE_ID='37644'
         --AND CSUA.SITE_USE_ID='34777'
         --AND SITE_USE_CODE = 'SHIP_TO'
         --AND PRIMARY_FLAG='Y'
         --AND STATUS = 'A'
         --AND CUSTOMER_TYPE = 'I'
         AND ca.sales_channel_code IS NOT NULL
         AND (   :p_customer_number IS NULL
              OR (ca.account_number = :p_customer_number))
         AND (   :p_cust_name IS NULL
              OR (UPPER (hp.party_name) LIKE UPPER ('%' || :p_cust_name || '%')))
--AND UPPER(CA.ACCOUNT_NAME) LIKE UPPER('%'||:P_CUST_NAME||'%')
--AND ACCOUNT_NUMBER IN ('20072')
--AND HP.CATEGORY_CODE IS NULL
ORDER BY CA.account_number DESC;


       EXECUTE APPS.xxdbl_cust_upld_webadi_pkg.import_data_from_web_adi('CCL2','Test Customer Upload 2','R','KSDKDSK','SEEW','JDFKFJ','IEWEWN','Test Customer 2, Corporate, Gulshan-1, Dhaka','LAKE','GULSHAN','DHAKA','1212');



  SELECT cust_account_id, cust_account_profile_id
    FROM hz_customer_profiles
   WHERE cust_account_id = 237433
ORDER BY cust_account_id DESC;

  SELECT cust_account_id,
         cust_account_profile_id profile_id,
         cust_acct_profile_amt_id
    FROM hz_cust_profile_amts hcpa
   WHERE 1 = 1 AND cust_account_profile_id = 275377
ORDER BY cust_account_id DESC;

SELECT hcp.cust_account_profile_id profile_id,
       hca.cust_account_id,
       hcp.site_use_id,
       account_number,
       hcas.org_id org_id,
       cust_acct_profile_amt_id
  FROM hz_cust_accounts hca,
       hz_parties hp,
       hz_party_sites hps,
       hz_cust_acct_sites_all hcas,
       hz_cust_site_uses_all hcua,
       hz_customer_profiles hcp,
       hz_cust_profile_amts hcpa
 WHERE     hca.party_id = hp.party_id
       AND hps.party_id = hp.party_id
       AND hcas.cust_account_id = hca.cust_account_id
       AND hcas.party_site_id = hps.party_site_id
       AND hcua.cust_acct_site_id = hcas.cust_acct_site_id
       AND hcp.cust_account_id = hca.cust_account_id
       AND hcp.site_use_id = hcua.site_use_id
       AND hcp.cust_account_profile_id = hcpa.cust_account_profile_id(+)
       AND hcua.site_use_code = 'BILL_TO'
       AND hca.cust_account_id = 242439;