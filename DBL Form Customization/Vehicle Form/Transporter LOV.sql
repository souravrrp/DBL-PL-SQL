----------------Thread_CCL2------------------------
---existing
SELECT   vendor_name, vendor_id
    FROM ap_suppliers
   WHERE 1 = 1 AND vendor_type_lookup_code IN ('TRANSPORTER', 'TRANSPORTER')
ORDER BY vendor_name

SELECT   ass.vendor_site_code, ass.vendor_site_id
    FROM ap_supplier_sites_all ass
   WHERE 1 = 1
     AND ass.vendor_id = :xxdbl_transpoter_headers.transporter_id
     AND ass.org_id = fnd_global.org_id
ORDER BY vendor_site_code

---Updated
SELECT aps.vendor_name, aps.vendor_id
    FROM ap_suppliers aps, ap_supplier_sites_all ass
   WHERE     1 = 1
         AND aps.vendor_id = ass.vendor_id
         AND ass.org_id = fnd_global.org_id
         AND aps.vendor_type_lookup_code LIKE 'TRANSPOR%'
ORDER BY aps.vendor_name

----------------Work Description------------------------
---existing
Select
 sup.segment1,
 sup.vendor_id,
 vendor_name,
 sups.vendor_site_id
from
 ap_suppliers sup,
 ap_supplier_sites_all sups,
 hr_operating_units hr
where sup.vendor_id=sups.vendor_id
 and sups.org_id=hr.organization_id
 and sups.inactive_date is null
 and sup.vendor_type_lookup_code='TRANSPORT'
 and hr.name=:purch_ou
 union all
 Select
 sup.segment1,
 sup.vendor_id,
 vendor_name,
 sups.vendor_site_id
from
 ap_suppliers sup,
 ap_supplier_sites_all sups,
 hr_operating_units hr
where sup.vendor_id=sups.vendor_id
 and sups.org_id=hr.organization_id
 and sups.inactive_date is null
 and sup.customer_num is not null
 and hr.name=:purch_ou

---Updated
Select
 sup.segment1,
 sup.vendor_id,
 vendor_name,
 sups.vendor_site_id
from
 ap_suppliers sup,
 ap_supplier_sites_all sups,
 hr_operating_units hr
where sup.vendor_id=sups.vendor_id
 and sups.org_id=hr.organization_id
 and sups.inactive_date is null
 and sup.vendor_type_lookup_code LIKE 'TRANSPOR%'
 and hr.name=:purch_ou
 union all
 Select
 sup.segment1,
 sup.vendor_id,
 vendor_name,
 sups.vendor_site_id
from
 ap_suppliers sup,
 ap_supplier_sites_all sups,
 hr_operating_units hr
where sup.vendor_id=sups.vendor_id
 and sups.org_id=hr.organization_id
 and sups.inactive_date is null
 and sup.customer_num is not null
 and hr.name=:purch_ou

       
 -----------------New 
SELECT aps.segment1,
       aps.vendor_id,
       aps.vendor_name,
       ass.vendor_site_id
  FROM ap_suppliers aps, ap_supplier_sites_all ass, hr_operating_units hr
 WHERE     1 = 1
       AND aps.vendor_id = ass.vendor_id
       AND ass.org_id=hr.organization_id
       and hr.name=:purch_ou
       AND aps.vendor_type_lookup_code LIKE 'TRANSPOR%'
UNION ALL
SELECT sup.segment1,
       sup.vendor_id,
       sup.vendor_name,
       sups.vendor_site_id
  FROM ap_suppliers sup, ap_supplier_sites_all sups, hr_operating_units hr
 WHERE     sup.vendor_id = sups.vendor_id
       AND sups.inactive_date IS NULL
       AND sup.customer_num IS NOT NULL
       AND sups.org_id=hr.organization_id
       and hr.name=:purch_ou
       
       
       /* Formatted on 2/15/2020 11:12:00 AM (QP5 v5.287) */
SELECT sup.segment1,
       sup.vendor_id,
       vendor_name,
       sups.vendor_site_id
  FROM ap_suppliers sup, ap_supplier_sites_all sups, hr_operating_units hr
 WHERE     sup.vendor_id = sups.vendor_id
       AND sups.org_id = hr.organization_id
       AND sups.inactive_date IS NULL
       AND sup.vendor_type_lookup_code like 'VEHICLE%'
       AND hr.name = :purch_ou
UNION ALL
SELECT sup.segment1,
       sup.vendor_id,
       vendor_name,
       sups.vendor_site_id
  FROM ap_suppliers sup, ap_supplier_sites_all sups, hr_operating_units hr
 WHERE     sup.vendor_id = sups.vendor_id
       AND sups.org_id = hr.organization_id
       AND sups.inactive_date IS NULL
       AND sup.customer_num IS NOT NULL
       AND hr.name = :purch_ou