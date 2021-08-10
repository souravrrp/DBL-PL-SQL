SELECT org.NAME operating_unit, org.organization_id org_id,
       TO_CHAR (lol.ledger_id) ledger_id, fvv.flex_value company_code,
       fvv.description company_name
  FROM xle_le_ou_ledger_v lol,
       gl_legal_entities_bsvs leb,
       hr_all_organization_units org,
       fnd_flex_values_vl fvv
 WHERE lol.legal_entity_id = leb.legal_entity_id
   AND lol.operating_unit_id = org.organization_id
   AND fvv.flex_value_set_id = leb.flex_value_set_id
   AND fvv.flex_value = leb.flex_segment_value
   AND fvv.summary_flag = 'N'
   AND org.organization_id IN (SELECT xou.organization_id
                                 FROM xx_operating_units_v xou
                                WHERE sl = (SELECT MIN (sl)
                                              FROM xx_operating_units_v))
UNION ALL
SELECT lv.meaning operating_unit, TO_NUMBER (lv.lookup_code, 9999) org_id,
       lv.lookup_code ledger_id, lv.lookup_code company_code,
       lv.description company_name
  FROM fnd_lookup_values_vl lv
 WHERE lookup_type = 'XX_VMOP_UNIT'