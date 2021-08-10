/* Formatted on 11/15/2020 10:24:41 AM (QP5 v5.354) */
SELECT pa.agent_id, papf.employee_number, (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name)
          as employee_name,fu.user_name
  FROM po_agents pa, apps.per_all_people_f papf, fnd_user fu
 WHERE     1 = 1
       AND SYSDATE BETWEEN effective_start_date AND effective_end_date
       --AND b.end_date IS NULL
       AND (   ( :p_emp_id IS NULL) OR (NVL (papf.employee_number, papf.npw_number) = :p_emp_id))
       AND ((:p_employee_name is null) or (upper (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name) like upper ('%' || :p_employee_name || '%'))) 
       --AND pa.end_date_active IS NOT NULL
       AND papf.person_id=fu.employee_id(+)
       AND pa.agent_id = papf.person_id(+);

---------------------------***************************--------------------------

SELECT * FROM po_agents;


SELECT *
  FROM po_agents_v
 WHERE 1 = 1 AND end_date_active IS NOT NULL;


--------No PO Responsibility but Have Buyer ------------------------------------

SELECT b.user_name,
       d.full_name,
       c.responsibility_name,
       a.start_date,
       a.end_date
  FROM apps.fnd_user_resp_groups_direct  a,
       apps.fnd_user                     b,
       apps.fnd_responsibility_tl        c,
       apps.per_all_people_f             d
 WHERE     a.user_id = b.user_id
       AND a.responsibility_id = c.responsibility_id
       AND b.user_name = d.employee_number
       AND SYSDATE BETWEEN effective_start_date AND effective_end_date
       AND c.zd_edition_name = 'SET2'
       AND a.end_date IS NULL
       AND b.end_date IS NULL
       AND c.application_id = 201
       AND EXISTS
               (SELECT 1
                  FROM po_agents pa
                 WHERE     d.person_id = pa.agent_id
                       AND pa.end_date_active IS NULL)
       AND NVL (d.current_emp_or_apl_flag, 'Y') = 'Y'
       AND (   UPPER (c.responsibility_name) LIKE '%PO%'
            OR UPPER (c.responsibility_name) LIKE '%LCM%');


--------Have Buyer but no PO Responsibility-------------------------------------

SELECT b.user_name, d.full_name
  FROM apps.fnd_user b, apps.per_all_people_f d, po_agents pa
 WHERE     1 = 1
       AND b.user_name = d.employee_number
       AND SYSDATE BETWEEN effective_start_date AND effective_end_date
       AND b.end_date IS NULL
       AND d.person_id = pa.agent_id
       AND pa.end_date_active IS NULL
       AND NVL (d.current_emp_or_apl_flag, 'Y') = 'Y'
       AND EXISTS
               (SELECT 1
                  FROM apps.fnd_user_resp_groups_direct  a,
                       apps.fnd_responsibility_tl        c
                 WHERE     a.user_id = b.user_id
                       AND a.responsibility_id = c.responsibility_id
                       AND a.end_date IS NULL
                       AND c.application_id = 201
                       AND c.zd_edition_name = 'SET2'
                       AND (UPPER (c.responsibility_name) NOT LIKE '%PO%'));

            --OR UPPER (c.responsibility_name) NOT LIKE '%LCM%');