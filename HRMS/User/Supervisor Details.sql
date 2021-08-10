/* Formatted on 1/20/2020 5:44:31 PM (QP5 v5.287) */
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
       ,PAPFS2.PERSON_ID SUPERV_PERSON_ID
       ,NVL (PAPFS2.EMPLOYEE_NUMBER, PAPFS2.NPW_NUMBER) SUPERV_EMPNO
       ,(PAPFS2.FIRST_NAME || ' ' || PAPFS2.MIDDLE_NAMES || ' ' || PAPFS2.LAST_NAME)
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
       HR.PER_ALL_PEOPLE_F PAPFS,
       HR.PER_ALL_ASSIGNMENTS_F PAAFS2,
       HR.PER_ALL_PEOPLE_F PAPFS2
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
       -------------------------------------------------------------------------
       AND PAAFS.SUPERVISOR_ID = PAPFS2.PERSON_ID(+)
       AND PAPFS2.PERSON_ID = PAAFS2.PERSON_ID(+)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAFS2.EFFECTIVE_START_DATE) AND TRUNC (PAAFS2.EFFECTIVE_END_DATE)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPFS2.EFFECTIVE_START_DATE) AND TRUNC (PAPFS2.EFFECTIVE_END_DATE)
       --AND NVL(PAPF.CURRENT_EMP_OR_APL_FLAG,'Y') = 'Y'
       --AND PAPF.CURRENT_EMP_OR_APL_FLAG IS NULL
       --AND paaf.primary_flag = 'Y'
       ;



/* Formatted on 8/25/2020 10:19:49 AM (QP5 v5.287) */
  SELECT DISTINCT NVL (papf1.employee_number, papf1.NPW_NUMBER) level1_empno,
                  papf1.full_name leve1_full_name,
                  NVL (papf2.employee_number, papf2.NPW_NUMBER) level2_empno,
                  papf2.full_name leve2_full_name,
                  (SELECT LOCATION_CODE
                     FROM HR_LOCATIONS_V A
                    WHERE paaf1.LOCATION_ID = a.location_id)
                     LOCATION_CODE,
                  papf1.EMAIL_ADDRESS
    FROM per_all_people_f papf1,
         hr.per_all_assignments_f paaf1,
         hr.per_all_assignments_f paaf2,
         hr.per_all_people_f papf2
   WHERE     papf1.person_id = paaf1.person_id
         AND paaf1.supervisor_id = papf2.person_id(+)
         AND papf2.person_id = paaf2.person_id
         AND SYSDATE BETWEEN papf1.effective_start_date
                         AND papf1.effective_end_date
         AND SYSDATE BETWEEN paaf1.effective_start_date
                         AND paaf1.effective_end_date
         AND papf1.NPW_NUMBER = 'CWK-706660'
ORDER BY leve1_full_name;


    SELECT e.*
      FROM (SELECT DISTINCT papf.person_id,
                            papf.employee_number,
                            papf.full_name "EMPLOYEE_FULL_NAME",
                            papf1.employee_number "SUPERVISOR_EMP_NUMBER",
                            papf1.full_name "SUPERVISOR_FULL_NAME",
                            paaf.supervisor_id
              FROM apps.per_all_people_f papf,
                   apps.per_all_assignments_f paaf,
                   apps.per_all_people_f papf1,
                   apps.per_person_types ppt
             WHERE     papf.person_id = paaf.person_id
                   AND papf1.person_id = paaf.supervisor_id
                   AND papf.business_group_id = paaf.business_group_id
                   AND TRUNC (SYSDATE) BETWEEN papf.effective_start_date
                                           AND papf.effective_end_date
                   AND TRUNC (SYSDATE) BETWEEN papf1.effective_start_date
                                           AND papf1.effective_end_date
                   AND TRUNC (SYSDATE) BETWEEN paaf.effective_start_date
                                           AND paaf.effective_end_date
                   AND ppt.person_type_id = papf.person_type_id
                   AND ppt.user_person_type <> 'Ex-employee') e
CONNECT BY PRIOR person_id = supervisor_id
START WITH person_id =
              (SELECT Person_id
                 FROM APPS.PER_ALL_PEOPLE_F P
                WHERE (   ( :P_EMP_ID IS NULL)
                       OR (P.EMPLOYEE_NUMBER = :P_EMP_ID)))      --:Person_id
                       ;
                       



SELECT   PERSON_ID,
             EMPLOYEE_NAME,
             SUPERVISOR_ID,
             SUPERVISOR_NAME,
             (SELECT   NAME
                FROM   APPS.PER_JOBS
               WHERE   JOB_ID = TL.JOB_ID)
                EMP_JOB_NAME,
             TL.JOB_ID,
             LEVEL LVL
      FROM   (SELECT   PAFE.PERSON_ID PERSON_ID,
                       PAFE.SUPERVISOR_ID SUPERVISOR_ID,
                       (SELECT   PPFS2.FULL_NAME
                          FROM   PER_ALL_PEOPLE_F PPFS2
                         WHERE   PPFS2.PERSON_ID = PAFE.SUPERVISOR_ID
                                 AND SYSDATE BETWEEN PPFS2.EFFECTIVE_START_DATE
                                                 AND  PPFS2.EFFECTIVE_END_DATE)
                          SUPERVISOR_NAME,
                       PAFE.JOB_ID,
                       PPFS.FULL_NAME EMPLOYEE_NAME
                FROM   PER_ALL_ASSIGNMENTS_F PAFE,
                       PER_ALL_PEOPLE_F PPFS,
                       PER_PERSON_TYPES_V PPTS,
                       PER_PERSON_TYPE_USAGES_F PPTU
               WHERE   1 = 1
--                PAFE.BUSINESS_GROUP_ID = 0
                       AND TRUNC (SYSDATE) BETWEEN PAFE.EFFECTIVE_START_DATE
                                               AND  PAFE.EFFECTIVE_END_DATE
                       AND PAFE.PRIMARY_FLAG = 'Y'
                       AND PAFE.ASSIGNMENT_TYPE IN ('E', 'C')
                       AND PPFS.PERSON_ID = PAFE.PERSON_ID
                       AND TRUNC (SYSDATE) BETWEEN PPFS.EFFECTIVE_START_DATE
                                               AND  PPFS.EFFECTIVE_END_DATE
                       AND PPTU.PERSON_ID = PPFS.PERSON_ID
                       AND PPTS.PERSON_TYPE_ID = PPTU.PERSON_TYPE_ID
                       AND PPTS.SYSTEM_PERSON_TYPE IN ('EMP', 'EMP_APL', 'CWK'))
             TL
CONNECT BY   TL.PERSON_ID = PRIOR TL.SUPERVISOR_ID
START WITH   TL.PERSON_ID = (SELECT   EMPLOYEE_ID
                               FROM   APPS.FND_USER
                              WHERE   USER_NAME = :EMP_ID);
                              
                              


/* Formatted on 7/2/2020 8:31:11 PM (QP5 v5.287) */
    SELECT fu.user_name "User Name",
           haou.name "Employee BG",
           fu.employee_id "Employee ID @User",
           gl.name "Emp. Ledger Name",
           ppx.full_name "Employee Name",
           ppx.employee_number "Employee Number",
           ppx.person_id "Employee ID @ Person",
           pjv.name "Employee Job Name",
           pjv.approval_authority "Job Level",
           hl.location_code "Employee Location",
           gcc.concatenated_segments "Default Expense Account",
           ppx1.full_name "Supervisor Name",
           ppx1.person_id "Supervisor Emp ID @ Person",
           ppx1.employee_number "SuperVisor Emp Num @ Person",
           haou1.name "Supervisor BG",
           CONNECT_BY_ISCYCLE
      FROM apps.per_people_x ppx,
           apps.per_people_x ppx1,
           apps.per_assignments_x pax,
           apps.per_jobs_v pjv,
           apps.gl_code_combinations_kfv gcc,
           apps.hr_locations hl,
           apps.fnd_user fu,
           apps.gl_ledgers gl,
           apps.hr_all_organization_units haou,
           apps.hr_all_organization_units haou1
     WHERE     1 = 1
           AND ppx.person_id = pax.person_id
           AND ppx.person_id = fu.employee_id(+)
           AND pax.job_id = pjv.job_id
           AND pax.default_code_comb_id = gcc.code_combination_id(+)
           AND pax.location_id = hl.location_id
           AND pax.set_of_books_id = gl.ledger_id(+)
           AND ppx1.person_id = pax.supervisor_id
           AND ppx.business_group_id = haou.organization_id
           AND ppx1.business_group_id = haou1.organization_id
CONNECT BY NOCYCLE PRIOR pax.supervisor_id = pax.person_id
START WITH ppx.employee_number = '103908';