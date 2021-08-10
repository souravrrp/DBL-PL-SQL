---Query to fetch legal entity details along with OU details

SELECT DISTINCT hrl.country,
                hroutl_bg.NAME bg,
                hroutl_bg.organization_id,
                lep.legal_entity_id,
                lep.NAME legal_entity,
                hroutl_ou.NAME ou_name,
                hroutl_ou.organization_id org_id,
                hrl.location_id,
                hrl.location_code,
                glev.flex_segment_value
  FROM xle_entity_profiles          lep,
       xle_registrations            reg,
       hr_locations_all             hrl,
       hz_parties                   hzp,
       fnd_territories_vl           ter,
       hr_operating_units           hro,
       hr_all_organization_units_tl hroutl_bg,
       hr_all_organization_units_tl hroutl_ou,
       hr_organization_units        gloperatingunitseo,
       gl_legal_entities_bsvs       glev
 WHERE lep.transacting_entity_flag        = 'Y'
   AND lep.party_id                       = hzp.party_id
   AND lep.legal_entity_id                = reg.source_id
   AND reg.source_table                   = 'XLE_ENTITY_PROFILES'
   AND hrl.location_id                    = reg.location_id
   AND reg.identifying_flag               = 'Y'
   AND ter.territory_code                 = hrl.country
   AND lep.legal_entity_id                = hro.default_legal_context_id
   AND gloperatingunitseo.organization_id = hro.organization_id
   AND hroutl_bg.organization_id          = hro.business_group_id
   AND hroutl_ou.organization_id          = hro.organization_id
   AND glev.legal_entity_id               = lep.legal_entity_id;

---Query to fetch Business group Details  - 1

SELECT business_group_id,
       organization_id,
       NAME,
       date_from,
       date_to,
       internal_address_line,
       location_id,
       comments,
       default_start_time,
       default_end_time,
       working_hours,
       frequency,
       short_name,
       method_of_generation_emp_num,
       method_of_generation_apl_num,
       grade_structure,
       people_group_structure,
       job_structure,
       cost_allocation_structure,
       position_structure,
       legislation_code,
       currency_code,
       security_group_id,
       enabled_flag,
       competence_structure,
       method_of_generation_cwk_num
  FROM per_business_groups;

---Query to fetch Business group Details  - 2
SELECT o.organization_id,
       o.organization_id,
       otl.NAME,
       o.date_from,
       o.date_to,
       o.internal_address_line,
       o.location_id,
       o.comments
  FROM hr_all_organization_units    o,
       hr_all_organization_units_tl otl,
       hr_organization_information  o2,
       hr_organization_information  o3,
       hr_organization_information  o4
 WHERE o.organization_id = otl.organization_id
   AND o.organization_id = o2.organization_id(+)
   AND o.organization_id = o3.organization_id
   AND o.organization_id = o4.organization_id
   AND o3.org_information_context = 'Business Group Information'
   AND o2.org_information_context(+) = 'Work Day Information'
   AND o4.org_information_context = 'CLASS'
   AND o4.org_information1 = 'HR_BG'
   AND o4.org_information2 = 'Y';

---Query to fetch Legal Entity Details

SELECT xle_firstpty.NAME,
       xle_firstpty.activity_code,
       xle_firstpty.sub_activity_code,
       xle_firstpty.registration_number,
       xle_firstpty.effective_from,
       xle_firstpty.location_id,
       xle_firstpty.address_line_1,
       xle_firstpty.address_line_2,
       xle_firstpty.address_line_3,
       xle_firstpty.town_or_city,
       xle_firstpty.region_1,
       xle_firstpty.region_2,
       xle_firstpty.region_3,
       xle_firstpty.postal_code,
       xle_firstpty.country,
       xle_firstpty.address_style,
       xle_cont.contact_name,
       xle_cont.contact_legal_id,
       xle_cont.title,
       xle_cont.job_title,
       xle_cont.role
  FROM apps.xle_firstparty_information_v xle_firstpty,
       apps.xle_legal_contacts_v         xle_cont
 WHERE 1 = 1
   AND XLE_FIRSTPTY.LEGAL_ENTITY_ID = C_REP_ENTITY_ID
   AND xle_firstpty.legal_entity_id = xle_cont.entity_id(+);



