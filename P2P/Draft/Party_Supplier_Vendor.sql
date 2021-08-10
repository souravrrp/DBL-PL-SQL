/* Formatted on 6/1/2020 10:48:16 AM (QP5 v5.287) */
SELECT hp.party_name,
       hp.party_id AS party_id,
       hp.duns_number_c AS duns,
       pv.vendor_id,
       pv.vendor_name,
       pv.individual_1099 AS taxpayer_id,
       pv.vat_registration_num AS tax_reg_num,
       pv.segment1,
       pv.VENDOR_NAME_ALT AS alternate_name,
       pv.end_date_active AS end_date_active,
       pv.start_date_active AS start_date_active,
       pv.ONE_TIME_FLAG,
       pv.VENDOR_TYPE_LOOKUP_CODE,
       pv.PARENT_VENDOR_ID,
       parent.vendor_name AS parent_vendor_name,
       pv.PAYMENT_PRIORITY,
       parent.segment1 AS parent_Segment1,
       pv.TAX_REPORTING_NAME,
       pv.terms_id,
       terms.name AS terms_desc,
       pv.FEDERAL_REPORTABLE_FLAG,
       pv.STATE_REPORTABLE_FLAG,
       pv.PAY_GROUP_LOOKUP_CODE,
       pay_group.description AS pay_group_desc,
       aptt.description AS income_tax_type,
       hp.organization_name_phonetic,
       plc.DISPLAYED_FIELD AS VENDOR_TYPE_DISPLAY,
       pv.type_1099 AS income_tax_type_code,
       pv.employee_id AS employee_id,
       pecx.employee_num AS employee_number
       --,apps.xx_vo_extension (pv.vendor_id) xx_address_line1
  FROM hz_parties hp,
       ap_suppliers pv,
       ap_suppliers parent,
       ap_terms_tl terms,
       fnd_lookup_values pay_group,
       AP_INCOME_TAX_TYPES aptt,
       po_lookup_codes plc,
       per_employees_current_x pecx
 WHERE     pv.party_id = hp.party_id
       AND pv.party_id = pecx.party_id(+)
       AND parent.vendor_id(+) = pv.parent_vendor_id
       AND pv.terms_id = terms.term_id(+)
       AND terms.language(+) = USERENV ('LANG')
       AND terms.enabled_flag(+) = 'Y'
       AND pv.pay_group_lookup_code = pay_group.lookup_code(+)
       AND pay_group.lookup_type(+) = 'PAY GROUP'
       AND pay_group.view_application_id(+) = 200
       AND pay_group.language(+) = USERENV ('lang')
       AND pv.type_1099 = aptt.income_tax_type(+)
       AND pv.VENDOR_TYPE_LOOKUP_CODE = plc.LOOKUP_CODE(+)
       AND plc.lookup_type(+) = 'VENDOR TYPE'
       AND pv.organization_type_lookup_code IN
              ('INDIVIDUAL', 'FOREIGN INDIVIDUAL')
UNION ALL
SELECT hp.party_name,
       hp.party_id AS party_id,
       hp.duns_number_c AS duns,
       pv.vendor_id,
       pv.vendor_name,
       pv.num_1099 AS taxpayer_id,
       pv.vat_registration_num AS tax_reg_num,
       pv.segment1,
       pv.VENDOR_NAME_ALT AS alternate_name,
       pv.end_date_active AS end_date_active,
       pv.start_date_active AS start_date_active,
       pv.ONE_TIME_FLAG,
       pv.VENDOR_TYPE_LOOKUP_CODE,
       pv.PARENT_VENDOR_ID,
       parent.vendor_name AS parent_vendor_name,
       pv.PAYMENT_PRIORITY,
       parent.segment1 AS parent_Segment1,
       pv.TAX_REPORTING_NAME,
       pv.terms_id,
       terms.name AS terms_desc,
       pv.FEDERAL_REPORTABLE_FLAG,
       pv.STATE_REPORTABLE_FLAG,
       pv.PAY_GROUP_LOOKUP_CODE,
       pay_group.description AS pay_group_desc,
       aptt.description AS income_tax_type,
       hp.organization_name_phonetic,
       plc.DISPLAYED_FIELD AS VENDOR_TYPE_DISPLAY,
       pv.type_1099 AS income_tax_type_code,
       pv.employee_id AS employee_id,
       pecx.employee_num AS employee_number
       --,apps.xx_vo_extension (pv.vendor_id) xx_address_line1
  FROM hz_parties hp,
       ap_suppliers pv,
       ap_suppliers parent,
       ap_terms_tl terms,
       fnd_lookup_values pay_group,
       AP_INCOME_TAX_TYPES aptt,
       po_lookup_codes plc,
       per_employees_current_x pecx
 WHERE     pv.party_id = hp.party_id
       AND pv.party_id = pecx.party_id(+)
       AND parent.vendor_id(+) = pv.parent_vendor_id
       AND pv.terms_id = terms.term_id(+)
       AND terms.language(+) = USERENV ('LANG')
       AND terms.enabled_flag(+) = 'Y'
       AND pv.pay_group_lookup_code = pay_group.lookup_code(+)
       AND pay_group.lookup_type(+) = 'PAY GROUP'
       AND pay_group.view_application_id(+) = 200
       AND pay_group.language(+) = USERENV ('lang')
       AND pv.type_1099 = aptt.income_tax_type(+)
       AND pv.VENDOR_TYPE_LOOKUP_CODE = plc.LOOKUP_CODE(+)
       AND plc.lookup_type(+) = 'VENDOR TYPE'
       AND (   pv.organization_type_lookup_code NOT IN
                  ('INDIVIDUAL', 'FOREIGN INDIVIDUAL')
            OR pv.organization_type_lookup_code IS NULL)