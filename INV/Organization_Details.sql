/* Formatted on 11/16/2020 9:59:55 AM (QP5 v5.354) */
  SELECT ood.operating_unit               org_id,
         hou.name                         operating_unit_name,
         hou.short_code                   operating_unit_code,
         ood.organization_name            warehouse_name,
         ood.organization_code            warehouse_org_code,
         ood.organization_id              warehouse_id,
         hou.default_legal_context_id     legal_entity,
         ou.legal_entity_name,
         ood.set_of_books_id              ledger_id,
         ou.ledger_name,
         --msi.secondary_inventory_name subinventory_code,
         --msi.description subinventory_name,
         ood.business_group_id,
         ood.chart_of_accounts_id,
         ou.company_code,
         apps.xx_com_pkg.get_company_name (ou.company_code) company_name
    --,ood.*
    --,msi.*
    --,ou.*
    --,hou.*
    FROM hr_operating_units          hou,
         org_organization_definitions ood,
         xxdbl_company_le_mapping_v  ou
   --,apps.mtl_secondary_inventories msi
   WHERE     1 = 1
         AND hou.organization_id = ood.operating_unit
         AND ood.operating_unit = ou.org_id
         AND (   :p_operating_unit IS NULL OR (ood.operating_unit = :p_operating_unit))
         AND (   :p_ou_name IS NULL OR (hou.name = :p_ou_name))
         AND (   :p_organization_code IS NULL OR (ood.organization_code = :p_organization_code))
         AND (   :p_org_name IS NULL OR (UPPER (ood.organization_name) LIKE UPPER ('%' || :p_org_name || '%')))
         AND (   :p_legal_entity_name IS NULL OR (UPPER (ou.legal_entity_name) LIKE UPPER ('%' || :p_legal_entity_name || '%')))
         AND (   :p_legal_entity IS NULL OR (hou.default_legal_context_id = :p_legal_entity))
         AND (   :p_ledger_id IS NULL OR (ood.set_of_books_id = :p_ledger_id))
         AND (   :p_company IS NULL OR (ou.company_code = :p_company))
         AND (   :p_organization_id IS NULL OR (ood.organization_id = :p_organization_id))
--------------------------------------------------------------------------------
        --AND msi.disable_date is null
        --AND msi.organization_id=ood.organization_id
        --AND ood.organization_id in (835)
        --AND organization_code in ('112')
        --AND ood.operating_unit in (125)
        --AND ou.company_code in (835)
ORDER BY hou.default_legal_context_id,
         ood.operating_unit,
         ood.organization_code;


--------------------------------------------------------------------------------


SELECT ou.*
  FROM apps.xxdbl_company_le_mapping_v ou
--  where LEGAL_ENTITY_ID=:P_LEGAL_ENTITY_ID
;

SELECT * FROM per_org_structure_elements_v;


--------------------------------------------------------------------------------

SELECT *
  FROM hr_operating_units hou
 WHERE 1 = 1 AND name = 'JKL-RMG';


SELECT * FROM org_organization_definitions
--where operating_unit='111'
;

SELECT * FROM hr_all_organization_units;

SELECT * FROM mtl_parameters_view;

--------------------------------------------------------------------------------


SELECT * FROM inv.mtl_parameters
--WHERE ORGANIZATION_ID = 101
;


SELECT * FROM apps.hr_organization_information;

--------------------------------------------------------------------------------


SELECT org_information2         legal_entity,
       org_information1         set_of_books,
       org_information3         org_id,
       pm.organization_code     warehouse_org_code,
       pm.organization_id       warehouse_id,
       secondary_inventory_name,
       description,
       process_enabled_flag
  --,(select ffv.flex_value from apps.fnd_flex_value_sets vset,apps.fnd_flex_values ffv where ffv.flex_value=pm.organization_code and vset.flex_value_set_name='akg_costcentre' and vset.flex_value_set_id=ffv.flex_value_set_id) cost_centre
  --,PM.*
  --,MSI.*
  --,HOI.*
  FROM inv.mtl_parameters                pm,
       apps.mtl_secondary_inventories    msi,
       apps.hr_organization_information  hoi,
       apps.mtl_interorg_parameters      mip
 WHERE     1 = 1
       AND msi.organization_id = pm.organization_id
       AND hoi.organization_id = pm.organization_id
       AND mip.from_organization_id = pm.organization_id
       AND org_information_context = 'Accounting Information'
       --AND secondary_inventory_name='CCL2-ST FG'
       --AND pm.organization_code in ( '185' )
       --AND org_information3 = '126' --:p_org_id
       AND (   :p_organization_code IS NULL OR (pm.organization_code = :p_organization_code))
;