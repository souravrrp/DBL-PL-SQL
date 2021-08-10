/* Formatted on 3/29/2021 9:47:07 AM (QP5 v5.287) */
SELECT *
  FROM xxdbl.xxdbl_cust_update_stg_tbl cct
 WHERE     1 = 1
       --AND cct.cust_id = :p_cust_id
       --AND cct.status IS NULL
       --AND UPPER (cct.customer_name) LIKE UPPER ('%' || :p_customer_name || '%');

--UPDATE xxdbl.xxdbl_cust_creation_tbl cct SET cct.status=NULL WHERE cct.cust_id = :p_cust_id;

--TRUNCATE TABLE xxdbl.xxdbl_cust_update_stg_tbl;

--SELECT TRIM (LPAD (apps.xxdbl_cust_creation_s.NEXTVAL, 7, '0')) FROM DUAL;


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


SELECT *
  FROM apps.hz_locations loc
 WHERE 1 = 1 --AND (   :p_location IS NULL OR (UPPER (loc.address1) LIKE UPPER ('%' || :p_location || '%')))
             --AND ACCOUNT_NUMBER IN ('20072')
             --AND HP.CATEGORY_CODE IS NULL
       AND UPPER (loc.address1) = UPPER ( :p_location);

SELECT lookup_type,
       lookup_code,
       meaning,
       description,
       start_date_active,
       end_date_active
  --,FLV.*
  FROM fnd_lookup_values_vl flv
 WHERE 1 = 1 AND UPPER (lookup_type) = UPPER ( :p_lookup_type);

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
         loc.address1,
         loc.location_id
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
         apps.hz_parties hp,
         APPS.HZ_PARTY_SITES HPS,
         APPS.HZ_LOCATIONS LOC
   WHERE     1 = 1
         AND ( :p_org_id IS NULL OR casa.org_id = :p_org_id)
         AND csua.cust_acct_site_id = casa.cust_acct_site_id
         AND ca.cust_account_id = casa.cust_account_id
         AND hou.organization_id = casa.org_id
         AND CA.STATUS = 'A'
         AND CSUA.STATUS = 'A'
         AND hp.party_id = ca.party_id
         AND HPS.PARTY_ID = HP.PARTY_ID
         AND HPS.LOCATION_ID = LOC.LOCATION_ID
         AND HP.STATUS = 'A'
         AND HPS.STATUS = 'A'
         AND HPS.IDENTIFYING_ADDRESS_FLAG = 'Y'
         --AND site_use_code = 'BILL_TO'
         --AND CSUA.BILL_TO_SITE_USE_ID='37644'
         --AND CSUA.SITE_USE_ID='34777'
         AND SITE_USE_CODE = 'SHIP_TO'
         --AND PRIMARY_FLAG='Y'
         --AND STATUS = 'A'
         --AND CUSTOMER_TYPE = 'I'
         AND (   :p_customer_number IS NULL
              OR (ca.account_number = :p_customer_number))
         --AND (   :p_cust_name IS NULL OR (UPPER (hp.party_name) LIKE UPPER ('%' || :p_cust_name || '%')))
         --AND (   :p_location IS NULL OR (UPPER (loc.address1) LIKE UPPER ('%' || :p_location || '%')))
         --AND ACCOUNT_NUMBER IN ('20072')
         --AND HP.CATEGORY_CODE IS NULL
         AND UPPER (loc.address1) = UPPER ( :p_location)
ORDER BY account_number DESC;

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
         casa.cust_acct_site_id,
         csua.site_use_id party_site_number,
         csua.site_use_id,
         csua.location,
         hp.category_code                                              --,CA.*
                         ,
         CASA.*
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
         AND (   :p_customer_number IS NULL
              OR (ca.account_number = :p_customer_number))
         AND (   :p_cust_name IS NULL
              OR (UPPER (hp.party_name) LIKE UPPER ('%' || :p_cust_name || '%')))
--AND UPPER(CA.ACCOUNT_NAME) LIKE UPPER('%'||:P_CUST_NAME||'%')
--AND ACCOUNT_NUMBER IN ('20072')
--AND HP.CATEGORY_CODE IS NULL
ORDER BY account_number DESC;


       EXECUTE APPS.xxdbl_cust_upld_webadi_pkg.import_data_from_web_adi('CCL2','Test Customer Upload 2','R','KSDKDSK','SEEW','JDFKFJ','IEWEWN','Test Customer 2, Corporate, Gulshan-1, Dhaka','LAKE','GULSHAN','DHAKA','1212');