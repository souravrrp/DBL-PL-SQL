SELECT
*
FROM xle_le_ou_ledger_V lol;

SELECT O2.ORGANIZATION_ID OPERATING_UNIT_ID,
          lg.LEDGER_ID,
          lg.NAME LEDGER_NAME,
          lg.SHORT_NAME LEDGER_SHORT_NAME,
          cfgDet.OBJECT_ID LEGAL_ENTITY_ID,
          xlep.name legal_entity_name,
          xlep.legal_entity_identifier,
          xlep.activity_code,
          xlep.sub_activity_code,
          xlep.type_of_company,
          xlep.effective_from le_effective_from,
          xlep.effective_to le_effective_to,
          reg.registration_number,
          hrl.address_line_1,
          hrl.address_line_2,
          hrl.address_line_3,
          hrl.region_1,
          hrl.region_2,
          hrl.region_3,
          hrl.town_or_city,
          hrl.postal_code,
          hrl.country
     FROM GL_LEDGERS primaryLg,
          GL_LEDGERS lg,
          GL_LEDGER_RELATIONSHIPS rs,
          GL_LEDGER_CONFIGURATIONS cfg,
          GL_LEDGER_CONFIG_DETAILS cfgDet,
          XLE_ENTITY_PROFILES xlep,
          XLE_REGISTRATIONS reg,
          HR_LOCATIONS_ALL hrl,
          HR_ORGANIZATION_INFORMATION O2,
          HR_ORGANIZATION_INFORMATION O3
    WHERE     rs.application_id = 101
          AND (   (    rs.target_ledger_category_code = 'SECONDARY'
                   AND rs.relationship_type_code <> 'NONE')
               OR (    rs.target_ledger_category_code = 'PRIMARY'
                   AND rs.relationship_type_code = 'NONE')
               OR (    rs.target_ledger_category_code = 'ALC'
                   AND rs.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')))
          AND lg.ledger_id = rs.target_ledger_id
          AND lg.ledger_category_code = rs.target_ledger_category_code
          AND primaryLg.ledger_id = rs.primary_ledger_id
          AND primaryLg.ledger_category_code = 'PRIMARY'
          AND cfg.configuration_id = primaryLg.configuration_id
          AND cfgDet.configuration_id(+) = cfg.configuration_id
          AND cfgDet.object_type_code(+) = 'LEGAL_ENTITY'
          AND cfgDet.object_id = xlep.legal_entity_id
          AND xlep.legal_entity_id = reg.source_id
          AND reg.source_table = 'XLE_ENTITY_PROFILES'
          AND reg.identifying_flag = 'Y'
          AND reg.location_id = hrl.location_id
          AND O3.ORG_INFORMATION3 = TO_CHAR (lg.LEDGER_ID)
          AND O3.ORGANIZATION_ID = O2.ORGANIZATION_ID
          AND O2.ORG_INFORMATION_CONTEXT = 'CLASS'
          AND O3.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
          AND O2.ORG_INFORMATION1 = 'OPERATING_UNIT'
          AND O2.ORG_INFORMATION2 = 'Y'
          AND xlep.transacting_entity_flag = 'Y';