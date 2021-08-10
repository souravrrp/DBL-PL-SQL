/* Formatted on 7/2/2020 9:38:43 AM (QP5 v5.287) */
SELECT DISTINCT pom.agent_id, ASSIGNMENT_NUMBER
  FROM po_headers_merge_v pom, per_all_assignments_f paaf
 WHERE 1 = 1 AND pom.AGENT_ID = paaf.PERSON_ID 
 and AGENT_ID='352'
-- AND paaf.SUPERVISOR_ID = 3028
 
 select
 *
 from
 po_headers_merge_v
 where 1=1
 and AGENT_ID='352'
 
 /* Formatted on 23/01/2020 2:51:55 PM (QP5 v5.136.908.31019) */
  SELECT DISTINCT NVL (papf1.employee_number, papf1.NPW_NUMBER) level1_empno,
                  papf1.full_name leve1_full_name,
                  NVL (papf2.employee_number, papf2.NPW_NUMBER) level2_empno,
                  papf2.full_name leve2_full_name,
                  (SELECT LOCATION_CODE
                     FROM HR_LOCATIONS_V A
                    WHERE paaf1.LOCATION_ID = a.location_id)
                     LOCATION_CODE,papf1.EMAIL_ADDRESS
    FROM per_all_people_f papf1,
         hr.per_all_assignments_f paaf1,
         hr.per_all_assignments_f paaf2,
         hr.per_all_people_f papf2
   WHERE     papf1.person_id = paaf1.person_id
         AND paaf1.supervisor_id = papf2.person_id(+)
         AND papf2.person_id = paaf2.person_id
         AND SYSDATE BETWEEN papf1.effective_start_date
                         AND  papf1.effective_end_date
         AND SYSDATE BETWEEN paaf1.effective_start_date
                         AND  paaf1.effective_end_date
                         AND  papf1.NPW_NUMBER= 'CWK-902414'
ORDER BY leve1_full_name;

 


SELECT DISTINCT NPW_NUMBER FROM per_all_people_f