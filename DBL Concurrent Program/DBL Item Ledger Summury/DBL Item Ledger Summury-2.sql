SELECT mpv.organization_id,
      replace (HOU.NAME, '- MO','. ') ORG,
    --   SUBSTR(HOU.NAME,1,length(NAME)-5) AS org,
       REPLACE (REPLACE (l.address_line_1, CHR (9), ''), CHR (34), '') add1,
       REPLACE (REPLACE (l.address_line_2, CHR (9), ''), CHR (34), '') add2,
       REPLACE (REPLACE (l.address_line_3, CHR (9), ''), CHR (34), '') add3
        FROM HR_ORGANIZATION_UNITS HOU, hr_locations l, MTL_PARAMETERS_VIEW mpv
 WHERE     1 = 1
       AND mpv.organization_id = hou.organization_id
       AND l.location_id = hou.location_id
      and  mpv.organization_id =:org_id