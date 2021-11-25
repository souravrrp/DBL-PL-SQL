/* Formatted on 11/24/2021 12:16:43 PM (QP5 v5.365) */
SELECT apsa.org_id,
       aps.vendor_id,
       aps.segment1
           supplier_number,
       aps.vendor_name
           supplier_name,
       TO_CHAR (aps.start_date_active, 'DD-MON-YYYY HH24:MI:SS')
           supplier_creation_date,
       aps.enabled_flag,
       apsa.vendor_site_id,
       apsa.vendor_site_code
           supplier_site,
       TO_CHAR (aps.start_date_active, 'DD-MON-YYYY HH24:MI:SS')
           site_creation_date,
          apsa.address_line1
       || ','
       || apsa.address_line2
       || ','
       || apsa.address_line3
           address,
       hcp.phone_number,
       aps.*
  --,APSA.*
  FROM apps.ap_suppliers           aps,
       apps.ap_supplier_sites_all  apsa,
       ar.hz_contact_points        hcp
 WHERE     1 = 1
       AND aps.vendor_id = apsa.vendor_id(+)
       --AND APS.VENDOR_ID IN ('2550')
       --AND APSA.VENDOR_SITE_ID IN ('9879')
       AND (( :p_org_id IS NULL) OR (apsa.org_id = :p_org_id))
       AND (( :supplier_id IS NULL) OR (aps.segment1 = :supplier_id))
       AND (   ( :p_supplier_name IS NULL)
            OR (UPPER (aps.vendor_name) LIKE
                    UPPER ('%' || :p_supplier_name || '%')))
       AND apsa.party_site_id = hcp.owner_table_id(+)
       AND hcp.phone_number IS NOT NULL