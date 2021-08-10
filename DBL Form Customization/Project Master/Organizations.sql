--Existing Record_Group
SELECT ou.name operating_unit, ou.organization_id org_id
  FROM hr_operating_units ou  
UNION ALL
SELECT description, TO_NUMBER (lookup_code) org_id--,val.*
  FROM fnd_lookup_values val
 WHERE lookup_type = 'XXCPM_OU'
 
 --Updated Record_Group
SELECT ou.name operating_unit, ood.organization_id org_id
  FROM hr_operating_units ou, org_organization_definitions ood
  where ou.organization_id = ood.operating_unit and upper(ood.organization_name) like '% CON%'
UNION ALL
SELECT description, TO_NUMBER (lookup_code) org_id--,val.*
  FROM fnd_lookup_values val
 WHERE lookup_type = 'XXCPM_OU'
 
 -------------------------------------------------------------------------------
 select
 *
 from
 all_project_info_master 
 
 SELECT ou.name operating_unit, ou.organization_id org_id
  FROM hr_operating_units ou
 
 select
 *
 from
 org_organization_definitions
 
 SELECT description, TO_NUMBER (lookup_code) org_id--,val.*
  FROM fnd_lookup_values val
 WHERE lookup_type = 'XXCPM_OU'
 
 SELECT ou.name operating_unit, ood.organization_id org_id
  FROM hr_operating_units ou, org_organization_definitions ood
  where ou.organization_id = ood.operating_unit and (UPPER(ood.organization_name) like UPPER('% CON-%') or ood.organization_name like UPPER('% CON %'))
  order by ou.name
  
  SELECT ou.name operating_unit, ood.organization_id org_id
  FROM hr_operating_units ou, org_organization_definitions ood
  where ou.organization_id = ood.operating_unit and upper(ood.organization_name) like '% CON%'
  order by ou.name
  
   SELECT ou.unit_name operating_unit, ood.organization_id org_id
  FROM XXDBL_COMPANY_LE_MAPPING_V ou, org_organization_definitions ood
  where ou.org_id = ood.operating_unit