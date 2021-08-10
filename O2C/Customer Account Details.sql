/* Formatted on 11/24/2020 3:31:50 PM (QP5 v5.287) */
-----------------------------****Customer****-------------------------------------------

  SELECT hou.organization_id,
         hou.name organization,
         ca.account_number,
         ca.cust_account_id customer_id,
         hp.party_name customer_name,
         ca.status account_status,
         csua.status customer_site_status,
         ca.creation_date "ACCOUNT CREATION DATE",
         casa.creation_date "ACCOUNT SITE CREATION DATE",
         csua.site_use_code,
         csua.site_use_id party_site_number,
         csua.location,
         hp.category_code,
         csua.primary_salesrep_id
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
         --AND csua.primary_salesrep_id IS NOT NULL
         --AND site_use_code = 'BILL_TO'
         --AND CSUA.BILL_TO_SITE_USE_ID='37644'
         --AND CSUA.SITE_USE_ID='34777'
         AND SITE_USE_CODE = 'SHIP_TO'
         --AND PRIMARY_FLAG='Y'
         --AND STATUS = 'A'
         --AND CUSTOMER_TYPE = 'I'
         AND (   :p_customer_number IS NULL OR (ca.account_number = :p_customer_number))
         AND (   :p_cust_name IS NULL OR (UPPER (hp.party_name) LIKE UPPER ('%' || :p_cust_name || '%')))
--AND UPPER(CA.ACCOUNT_NAME) LIKE UPPER('%'||:P_CUST_NAME||'%')
--AND ACCOUNT_NUMBER IN ('20072')
--AND HP.CATEGORY_CODE IS NULL
ORDER BY account_number DESC
;


--------------------------------------------------------------------------------

  SELECT hou.name organization,
         a.customer_id,
         a.customer_number,
         a.customer_name,
         hca.account_name "Account Description",
         a.address1 "Address Line 1",
         a.address2 "Address Line 2",
         a.address3 "Address Line 3",
         a.address4 "Address Line 4",
         a.location "Ship/Bill to Location",
         a.site_use_code,
         a.status,
         a.site_use_status,
         a.acct_use_status,
         a.primary_flag
         --,a.*
    FROM apps.xx_ar_customer_site_v a,
         apps.hz_cust_accounts hca,
         apps.hr_operating_units hou
   WHERE     1 = 1
         AND ( :p_org_id IS NULL OR a.org_id = :p_org_id)
         AND hou.organization_id = a.org_id
         AND a.customer_id = hca.cust_account_id
         --AND SITE_USE_CODE = 'BILL_TO'
         --AND SITE_USE_CODE = 'SHIP_TO'
         --AND SITE_USE_CODE = 'DRAWEE'
         --AND A.SHIP_TO_ORG_ID='34777'
         --AND PRIMARY_FLAG='Y'
         --AND STATUS = 'A'
         AND (   :p_customer_number IS NULL OR (a.customer_number = :p_customer_number))
         --AND CUSTOMER_NUMBER IN ('187056')
         AND (   :p_cust_name IS NULL OR (UPPER (a.customer_name) LIKE UPPER ('%' || :p_cust_name || '%')))
--AND A.CUSTOMER_NAME LIKE '%International%Institute%of%Maritime%Technology%'
ORDER BY 2 DESC;

---------------------------------------***Checking***---------------------------------------


SELECT ar_cust.*
  FROM apps.xx_ar_customer_site_v ar_cust
 WHERE     1 = 1
       --AND ORG_ID = 83
       --AND CUSTOMER_NUMBER in ('2137')
       AND (   :p_customer_number IS NULL OR (ar_cust.customer_number = :p_customer_number))
;

--------------------------------------------------------------------------------

SELECT *
  FROM apps.ar_customers ac
 WHERE     1 = 1
       AND (   :p_customer_number IS NULL OR (ac.customer_number = :p_customer_number))
       AND (   :p_cust_name IS NULL OR (UPPER (ac.customer_name) LIKE UPPER ('%' || :p_cust_name || '%')))
       ORDER BY ac.customer_number DESC;