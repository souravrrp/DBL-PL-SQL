/* Formatted on 12/1/2020 2:14:59 PM (QP5 v5.287) */
  SELECT p.profile_option_name SHORT_NAME,
         n.user_profile_option_name NAME,
         DECODE (
            v.level_id,
            10001, 'Site',
            10002, 'Application',
            10003, 'Responsibility',
            10004, 'User',
            10005, 'Server',
            10006, 'Org',
            10007, DECODE (
                      TO_CHAR (v.level_value2),
                      '-1', 'Responsibility',
                      DECODE (TO_CHAR (v.level_value),
                              '-1', 'Server',
                              'Server+Resp')),
            'UnDef')
            LEVEL_SET,
         DECODE (
            TO_CHAR (v.level_id),
            '10001', '',
            '10002', app.application_short_name,
            '10003', rsp.responsibility_key,
            '10004', usr.user_name,
            '10005', svr.node_name,
            '10006', org.name,
            '10007', DECODE (TO_CHAR (v.level_value2),
                             '-1', rsp.responsibility_key,
                             DECODE (TO_CHAR (v.level_value),
                                     '-1', (SELECT node_name
                                              FROM fnd_nodes
                                             WHERE node_id = v.level_value2),
                                        (SELECT node_name
                                           FROM fnd_nodes
                                          WHERE node_id = v.level_value2)
                                     || '-'
                                     || rsp.responsibility_key)),
            'UnDef')
            "CONTEXT",
         v.profile_option_value VALUE
    FROM fnd_profile_options p,
         fnd_profile_option_values v,
         fnd_profile_options_tl n,
         fnd_user usr,
         fnd_application app,
         fnd_responsibility rsp,
         fnd_nodes svr,
         hr_operating_units org
   WHERE     p.profile_option_id = v.profile_option_id(+)
         AND p.profile_option_name = n.profile_option_name
         AND UPPER (p.profile_option_name) IN
                (SELECT profile_option_name
                   FROM fnd_profile_options_tl
                  WHERE UPPER (user_profile_option_name) LIKE
                           UPPER ('%'||:user_profile_name||'%'))
         AND usr.user_id(+) = v.level_value
         AND rsp.application_id(+) = v.level_value_application_id
         AND rsp.responsibility_id(+) = v.level_value
         AND app.application_id(+) = v.level_value
         AND svr.node_id(+) = v.level_value
         AND org.organization_id(+) = v.level_value
ORDER BY short_name,
         user_profile_option_name,
         level_id,
         level_set;