/* Formatted on 4/21/2021 10:18:54 AM (QP5 v5.287) */
SELECT *
  FROM (SELECT HzPuiRelationshipsEO.relationship_id,
               HzPuiRelationshipsEO.directional_flag,
               HzPuiRelationshipsEO.subject_id,
               HzPuiRelationshipsEO.subject_type,
               HzPuiRelationshipsEO.subject_table_name,
               HzPuiRelationshipsEO.object_id,
               HzPuiRelationshipsEO.object_type,
               HzPuiRelationshipsEO.object_table_name,
               HzPuiRelationshipsEO.party_id relationship_party_id,
               HzPuiRelationshipsEO.relationship_type,
               HzPuiRelationshipsEO.relationship_code,
               HzPuiRelationshipsEO.start_date,
               DECODE (TO_CHAR (HzPuiRelationshipsEO.end_date, 'DD-MM-YYYY'),
                       '31-12-4712', TO_DATE (NULL), --to_date to avoid xml.17 issue
                       HzPuiRelationshipsEO.end_date)
                  end_date,
               HzPuiRelationshipsEO.comments,
               HzPuiRelationshipsEO.status,
               HzPuiRelationshipsEO.actual_content_source,
               HzPuiRelationshipsEO.object_version_number,
               HzPuiRelationshipsEO.created_by_module,
               HzPuiRelationshipsEO.application_id,
               subjectparty.party_name subject_party_name,
               subjectparty.party_number subject_party_number,
               subjectparty.known_as subject_party_known_as,
               objectparty.party_name object_party_name,
               objectparty.party_number object_party_number,
               objectparty.known_as object_party_known_as,
               reltype.relationship_type_id,
               reltype.role relationship_role,
               subjectpartytypelu.meaning subject_type_meaning,
               objectpartytypelu.meaning object_type_meaning,
               relationshiprolelu.description relationship_role_meaning,
               relparty.object_version_number party_object_version_number,
               'update_image' AS update_image,
               'delete_image' AS delete_image,
               'restore_image' AS restore_image
          FROM hz_relationships HzPuiRelationshipsEO,
               hz_relationship_types reltype,
               hz_parties relparty,
               hz_parties subjectparty,
               hz_parties objectparty,
               fnd_lookup_values subjectpartytypelu,
               fnd_lookup_values objectpartytypelu,
               fnd_lookup_values relationshiprolelu
         WHERE     HzPuiRelationshipsEO.subject_table_name = 'HZ_PARTIES'
               AND HzPuiRelationshipsEO.object_table_name = 'HZ_PARTIES'
               AND HzPuiRelationshipsEO.party_id = relparty.party_id
               AND HzPuiRelationshipsEO.status IN ('A', 'I')
               AND HzPuiRelationshipsEO.subject_id = subjectparty.party_id
               AND HzPuiRelationshipsEO.object_id = objectparty.party_id
               AND HzPuiRelationshipsEO.relationship_type =
                      reltype.relationship_type
               AND HzPuiRelationshipsEO.relationship_code =
                      reltype.forward_rel_code
               AND HzPuiRelationshipsEO.subject_type = reltype.subject_type
               AND HzPuiRelationshipsEO.object_type = reltype.object_type
               AND subjectpartytypelu.view_application_id = 222
               AND subjectpartytypelu.lookup_type = 'PARTY_TYPE'
               AND subjectpartytypelu.language = USERENV ('LANG')
               AND subjectpartytypelu.lookup_code =
                      HzPuiRelationshipsEO.subject_type
               AND objectpartytypelu.view_application_id = 222
               AND objectpartytypelu.lookup_type = 'PARTY_TYPE'
               AND objectpartytypelu.language = USERENV ('LANG')
               AND objectpartytypelu.lookup_code =
                      HzPuiRelationshipsEO.object_type
               AND relationshiprolelu.view_application_id = 222
               AND relationshiprolelu.lookup_type = 'HZ_RELATIONSHIP_ROLE'
               AND relationshiprolelu.language = USERENV ('LANG')
               AND relationshiprolelu.lookup_code = reltype.role) QRSLT
-- WHERE (    object_type = :1
--        AND object_id = :2
--        AND subject_type = :3
--        AND (    status = 'A'
--             AND (end_date IS NULL OR end_date >= TRUNC (SYSDATE))))