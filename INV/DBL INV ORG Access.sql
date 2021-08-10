/* Formatted on 2/2/2021 9:39:28 AM (QP5 v5.287) */
SELECT application_name,
       oa.responsibility_name,
       oa.organization_code,
       oa.organization_name,
       oa.organization_id
  FROM org_access_v oa
 WHERE     1 = 1
       AND (   :p_responsibility_name IS NULL OR (UPPER (oa.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
       AND (   :p_application_name IS NULL OR (UPPER (oa.application_name) LIKE UPPER ('%' || :p_application_name || '%')))
       AND (   :p_organization_code IS NULL OR (oa.organization_code = :p_organization_code))
       AND (   :p_org_name IS NULL OR (UPPER (oa.organization_name) LIKE UPPER ('%' || :p_org_name || '%')))
       AND (   :p_organization_id IS NULL OR (oa.organization_id = :p_organization_id))
       --AND oa.organization_name IN ('JINNAT APPARELS LTD RMG HO - IO')
       ;