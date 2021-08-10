/* Formatted on 3/11/2020 2:06:22 PM (QP5 v5.287) */
  SELECT user_name,
         application_name,
         responsibility_name,
         security_group_name,
         GREATEST (u.start_date, ur.start_date, r.start_date) start_date,
         DECODE (
            LEAST (NVL (u.end_date, TO_DATE ('01/01/4712', 'DD/MM/YYYY')),
                   NVL (ur.end_date, TO_DATE ('01/01/4712', 'DD/MM/YYYY')),
                   NVL (r.end_date, TO_DATE ('01/01/4712', 'DD/MM/YYYY'))),
            TO_DATE ('01/01/4712', 'DD/MM/YYYY'), '',
            LEAST (NVL (u.end_date, NVL (ur.end_date, r.end_date)),
                   NVL (ur.end_date, NVL (u.end_date, r.end_date)),
                   NVL (r.end_date, NVL (u.end_date, ur.end_date))))
            end_date
    FROM fnd_user u,
         fnd_user_resp_groups_all ur,
         fnd_responsibility_vl r,
         fnd_application_vl a,
         fnd_security_groups_vl s
   WHERE     a.application_id = r.application_id
         AND u.user_id = ur.user_id
         AND r.application_id = ur.responsibility_application_id
         AND r.responsibility_id = ur.responsibility_id
         AND ur.start_date <= SYSDATE
         AND NVL (ur.end_date, SYSDATE + 1) > SYSDATE
         AND u.start_date <= SYSDATE
         AND NVL (u.end_date, SYSDATE + 1) > SYSDATE
         AND r.start_date <= SYSDATE
         AND NVL (r.end_date, SYSDATE + 1) > SYSDATE
         AND ur.security_group_id = s.security_group_id
         AND r.version IN ('4', 'W', 'M')
ORDER BY user_name,
         application_name,
         responsibility_name,
         security_group_name