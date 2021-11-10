/* Formatted on 5/5/2021 12:05:24 PM (QP5 v5.354) */
SELECT                                                              --DISTINCT
       papf.person_id,
       NVL (papf.employee_number, papf.npw_number) employee_number,
       (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name) AS employee_name,
       SUBSTR (pj.name, INSTR (pj.name, '.') + 1) designation,
       papf.start_date AS date_of_joining,
       haou.name department,
       hla.description job_location,
       papf.current_emp_or_apl_flag,
       paaf.primary_flag,
       fu.user_id superv_user_id,
       sup.superv_person_id,
       sup.superv_empno,
       sup.supervisor_name,
       sup.current_emp_or_apl_flag,
       sup.primary_flag,
       DECODE(fu.end_date,NULL,'Active','Inactive') sup_user_status
  --,PAAF.*
  --,PAPF.*
  --,PJ.*
  ---,POSE.*
  --,HAOU.*
  --,HLA.*
  FROM apps.per_all_assignments_f      paaf,
       apps.per_all_people_f           papf,
       apps.per_jobs                   pj,
       apps.hr_all_organization_units  haou,
       apps.hr_locations_all           hla,
       fnd_user                        fu,
       (SELECT papfs.person_id                                  superv_person_id,
               NVL (papfs.employee_number, papfs.npw_number)    superv_empno,
               (   papfs.first_name || ' ' || papfs.middle_names || ' ' || papfs.last_name) AS supervisor_name,
               papfs.current_emp_or_apl_flag,
               paafs.primary_flag
          FROM hr.per_all_assignments_f paafs, hr.per_all_people_f papfs
         WHERE     papfs.person_id = paafs.person_id(+)
               AND TRUNC (SYSDATE) BETWEEN TRUNC (paafs.effective_start_date) AND TRUNC (paafs.effective_end_date)
               AND TRUNC (SYSDATE) BETWEEN TRUNC (papfs.effective_start_date) AND TRUNC (papfs.effective_end_date)) sup
 WHERE     1 = 1
       AND paaf.business_group_id = 81
       AND papf.person_id = paaf.person_id(+)
       AND paaf.job_id = pj.job_id(+)
       AND paaf.location_id = hla.location_id(+)
       AND paaf.organization_id = haou.organization_id(+)
       AND (   ( :p_emp_id IS NULL) OR (NVL (papf.employee_number, papf.npw_number) = :p_emp_id))
       AND (   ( :p_employee_name IS NULL) OR (UPPER ( papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name) LIKE UPPER ('%' || :p_employee_name || '%')))
       AND (   ( :p_designation IS NULL) OR (UPPER (pj.name) LIKE UPPER ('%' || :p_designation || '%')))
       AND (   ( :p_department IS NULL) OR (UPPER (haou.name) LIKE UPPER ('%' || :p_department || '%')))
       AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date) AND TRUNC (paaf.effective_end_date)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date) AND TRUNC (papf.effective_end_date)
       --AND NVL (papf.employee_number, papf.npw_number) = fu.user_name(+)
       and papf.person_id = fu.employee_id(+)
       --and sup.superv_person_id = fu.employee_id(+)
       --AND papf.person_id = NVL ( :p_person_id, papf.person_id)
       --AND NVL(papf.employee_number,papf.npw_number) IN ('')
       --AND NVL(papfs.employee_number,papfs.npw_number) IN ('101347')
       --AND NVL(papf.current_emp_or_apl_flag,'Y') = 'Y'
       --AND papf.current_emp_or_apl_flag IS NULL
       --AND paaf.primary_flag = 'Y'
       AND paaf.supervisor_id = sup.superv_person_id(+);

--------------------------------------------------------------------------------

SELECT --DISTINCT
      FU.USER_ID,
      PAPF.PERSON_ID,
      NVL(PAPF.EMPLOYEE_NUMBER,PAPF.NPW_NUMBER) EMPLOYEE_NUMBER,
       (PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES || ' ' || PAPF.LAST_NAME)
          AS EMPLOYEE_NAME,
       SUBSTR (PJ.NAME, INSTR (PJ.NAME, '.') + 1) DESIGNATION,
       PAPF.START_DATE AS DATE_OF_JOINING,
       HAOU.NAME DEPARTMENT,
       HLA.DESCRIPTION JOB_LOCATION
       ,PAPF.CURRENT_EMP_OR_APL_FLAG
       ,PAAF.PRIMARY_FLAG
       ,PAPFS.PERSON_ID SUPERV_PERSON_ID
       ,NVL (PAPFS.EMPLOYEE_NUMBER, PAPFS.NPW_NUMBER) SUPERV_EMPNO
       ,(PAPFS.FIRST_NAME || ' ' || PAPFS.MIDDLE_NAMES || ' ' || PAPFS.LAST_NAME)
          AS SUPERVISOR_NAME
       --,PAAF.*
       --,PAPF.*
       --,PJ.*
       ---,POSE.*
       --,HAOU.*
       --,HLA.*
  FROM APPS.PER_ALL_ASSIGNMENTS_F PAAF,
       APPS.PER_ALL_PEOPLE_F PAPF,
       APPS.PER_JOBS PJ,
       APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
       APPS.HR_LOCATIONS_ALL HLA,
       FND_USER FU,
       HR.PER_ALL_ASSIGNMENTS_F PAAFS,
       HR.PER_ALL_PEOPLE_F PAPFS
 WHERE    1=1 
       AND PAAF.BUSINESS_GROUP_ID = 81
       AND PAPF.PERSON_ID = PAAF.PERSON_ID(+)
       AND PAAF.JOB_ID=PJ.JOB_ID(+)
       AND PAAF.LOCATION_ID = HLA.LOCATION_ID(+)
       AND PAAF.ORGANIZATION_ID=HAOU.ORGANIZATION_ID(+)
       AND ((:P_EMP_ID IS NULL) OR (NVL(PAPF.EMPLOYEE_NUMBER,PAPF.NPW_NUMBER) = :P_EMP_ID))
       AND ((:P_EMPLOYEE_NAME IS NULL) OR (UPPER (PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES || ' ' || PAPF.LAST_NAME) LIKE UPPER ('%' || :P_EMPLOYEE_NAME || '%'))) 
       AND ((:P_DESIGNATION IS NULL) OR (UPPER (PJ.NAME) LIKE UPPER ('%' || :P_DESIGNATION || '%')))
       AND ((:P_DEPARTMENT IS NULL) OR (UPPER (HAOU.NAME) LIKE UPPER ('%' || :P_DEPARTMENT || '%'))) 
       --       AND papf.person_id = NVL ( :p_person_id, papf.person_id)
       --and NVL(PAPF.EMPLOYEE_NUMBER,PAPF.NPW_NUMBER) in ('')
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE) AND TRUNC (PAAF.EFFECTIVE_END_DATE)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE) AND TRUNC (PAPF.EFFECTIVE_END_DATE)
       AND NVL(PAPF.EMPLOYEE_NUMBER,PAPF.NPW_NUMBER)= FU.USER_NAME(+)
       --AND NVL(PAPFS.EMPLOYEE_NUMBER,PAPFS.NPW_NUMBER) in ('101347')
       AND PAAF.SUPERVISOR_ID = PAPFS.PERSON_ID(+)
       AND PAPFS.PERSON_ID = PAAFS.PERSON_ID(+)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAFS.EFFECTIVE_START_DATE) AND TRUNC (PAAFS.EFFECTIVE_END_DATE)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPFS.EFFECTIVE_START_DATE) AND TRUNC (PAPFS.EFFECTIVE_END_DATE)
       --AND NVL(PAPF.CURRENT_EMP_OR_APL_FLAG,'Y') = 'Y'
       --AND PAPF.CURRENT_EMP_OR_APL_FLAG IS NULL
       --AND paaf.primary_flag = 'Y'
       ;
       
--------------------------------------------------------------------------------