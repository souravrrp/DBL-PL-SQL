/* Formatted on 2/4/2021 4:09:16 PM (QP5 v5.354) */
           SELECT os.name org_struct_name, ood.organization_code, ood.organization_name
             FROM apps.org_organization_definitions ood,
                  apps.per_org_structure_elements_v pose,
                  apps.per_organization_structures_v os,
                  hr_operating_units       hou
            WHERE     1 = 1
                  AND ood.organization_id = pose.organization_id_child
                  AND os.organization_structure_id = pose.org_structure_version_id
                  --AND os.name IN ('RMG-PROCESS')
                  --AND organization_code in ('112')
                  AND (   :p_org_struct_name IS NULL OR (UPPER (os.name) LIKE UPPER ('%' || :p_org_struct_name || '%')))
                  AND ood.operating_unit = hou.organization_id
                  AND (   :p_organization_code IS NULL OR (ood.organization_code = :p_organization_code))
                  AND (   :p_org_name IS NULL OR (UPPER (ood.organization_name) LIKE UPPER ('%' || :p_org_name || '%')))
       START WITH pose.organization_id_parent = 138
       CONNECT BY PRIOR pose.organization_id_child = pose.organization_id_parent
ORDER SIBLINGS BY ood.organization_code, pose.organization_id_child;