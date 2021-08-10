/* Formatted on 7/8/2019 9:27:40 AM (QP5 v5.287) */

--------------------------------------------------------------------------------


SELECT
*
FROM
FND_USER
WHERE 1=1
AND ((:P_EMP_ID IS NULL) OR (USER_NAME = :P_EMP_ID))
AND ((:P_USER_ID IS NULL) OR (USER_ID = :P_USER_ID))
;

--------------------------------------------------------------------------------
SELECT --DISTINCT
      PAPF.PERSON_ID,
      NVL(PAPF.EMPLOYEE_NUMBER,PAPF.NPW_NUMBER) EMPLOYEE_NUMBER,
       (PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES || ' ' || PAPF.LAST_NAME)
          AS EMPLOYEE_NAME,
       SUBSTR (PJ.NAME, INSTR (PJ.NAME, '.') + 1) DESIGNATION,
       PAPF.START_DATE AS DATE_OF_JOINING,
       HAOU.NAME DEPARTMENT,
       PPB.NAME SALARY_BASIS,
       HLA.DESCRIPTION JOB_LOCATION,
       PPF.PAYROLL_NAME AS COMPANY_PAYROLL_NAME
       ,PAPF.CURRENT_EMP_OR_APL_FLAG
       ,paaf.primary_flag
       --,PAAF.*
       --,PAPF.*
       --,PJ.*
       ---,POSE.*
       --,HAOU.*
       --,PPB.*
       --,PPG.*
       --,PPF.*
       --,HLA.*
  FROM APPS.PER_ALL_ASSIGNMENTS_F PAAF,
       APPS.PER_ALL_PEOPLE_F PAPF,
       APPS.PER_JOBS PJ,
       APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
       APPS.PER_PAY_BASES PPB,
       APPS.PAY_PEOPLE_GROUPS PPG,
       APPS.PAY_PAYROLLS_F PPF,
       APPS.HR_LOCATIONS_ALL HLA
 WHERE    1=1 
       AND PAAF.BUSINESS_GROUP_ID = 81
       AND PAPF.PERSON_ID = PAAF.PERSON_ID(+)
       AND PAAF.JOB_ID=PJ.JOB_ID(+)
       AND PAAF.PAYROLL_ID=PPF.PAYROLL_ID(+)
       AND PAAF.LOCATION_ID = HLA.LOCATION_ID(+)
       AND PAAF.PEOPLE_GROUP_ID=PPG.PEOPLE_GROUP_ID(+)
       AND PAAF.ORGANIZATION_ID=HAOU.ORGANIZATION_ID(+)
       AND ((:P_EMP_ID IS NULL) OR (NVL(PAPF.EMPLOYEE_NUMBER,PAPF.NPW_NUMBER) = :P_EMP_ID))
       AND ((:P_EMPLOYEE_NAME IS NULL) OR (UPPER (PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES || ' ' || PAPF.LAST_NAME) LIKE UPPER ('%' || :P_EMPLOYEE_NAME || '%'))) 
       AND ((:P_DESIGNATION IS NULL) OR (UPPER (PJ.NAME) LIKE UPPER ('%' || :P_DESIGNATION || '%')))
       AND ((:P_DEPARTMENT IS NULL) OR (UPPER (HAOU.NAME) LIKE UPPER ('%' || :P_DEPARTMENT || '%'))) 
       --       AND papf.person_id = NVL ( :p_person_id, papf.person_id)
       --and NVL(PAPF.EMPLOYEE_NUMBER,PAPF.NPW_NUMBER) in ('')
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE) AND TRUNC (PAAF.EFFECTIVE_END_DATE)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE) AND TRUNC (PAPF.EFFECTIVE_END_DATE)
       --AND NVL(PAPF.CURRENT_EMP_OR_APL_FLAG,'Y') = 'Y'
       --AND PAPF.CURRENT_EMP_OR_APL_FLAG IS NULL
       --AND paaf.primary_flag = 'Y'
       ;

SELECT
*
FROM
APPS.XX_EMPLOYEE_INFO_V PPF
WHERE 1=1
AND  ((:P_EMP_ID IS NULL) OR (PPF.EMPLOYEE_NUMBER = :P_EMP_ID))
AND  ((:P_EMPLOYEE_NAME IS NULL) OR (UPPER (PPF.EMPLOYEE_NAME) LIKE UPPER ('%' || :P_EMPLOYEE_NAME || '%'))) 
--AND PPF.EMPLOYEE_NUMBER IN ('103908')
;
       
----------------------------------------------------------------------------------- 
SELECT
*
FROM
APPS.PER_ALL_PEOPLE_F PPF
WHERE 1=1
       AND PPF.EMPLOYEE_NUMBER = :P_EMPLOYEE_NUMBER
       AND UPPER (PPF.EMPLOYEE_NAME) LIKE UPPER ('%' || :P_EMPLOYEE_NAME || '%');

SELECT
*
FROM
APPS.PER_PEOPLE_F PPF
WHERE 1=1
       AND PPF.EMPLOYEE_NUMBER = :P_EMPLOYEE_NUMBER
       AND UPPER (PPF.EMPLOYEE_NAME) LIKE UPPER ('%' || :P_EMPLOYEE_NAME || '%');

--------------------------------------------------------------------------------
SELECT 
       FU.USER_ID,
       PPF.PERSON_ID,
       PPF.EMPLOYEE_NUMBER,
       PPF.FULL_NAME EMPLOYEE_NAME,
       PPF.START_DATE APPLICANT_START_DATE,
       PPOS.DATE_START EFFECTIVE_START_DATE,
       PPF.ORIGINAL_DATE_OF_HIRE,
       PPF.MARITAL_STATUS,
       PPF.NATIONAL_IDENTIFIER,
       DECODE (PPF.SEX,  'M', 'MALE',  'F', 'FEMALE',  'OTHERS') GENDER,
       PPF.DATE_OF_BIRTH,
--       APPS.XXAKG_ORACLE_PKG.GET_DATE_DIFF_ALL (CURRENT_DATE,
--                                                PPF.DATE_OF_BIRTH)
--          AGE,
--       APPS.XXAKG_ORACLE_PKG.GET_DATE_YEAR_CAL_YEAR (CURRENT_DATE,
--                                                     PPF.DATE_OF_BIRTH)
--          AGE_YEAR,
       PPF.ATTRIBUTE1 BLOOD_GROUP,
       PPF.ATTRIBUTE2 RELIGN,
       PPF.ATTRIBUTE7 HIGHT,
--       APPS.XXAKG_ORACLE_PKG.GET_HIGHEST_QUALIFICATION (PPF.PERSON_ID)
--          HIGHEST_QUALIFICATION,
--       APPS.XXAKG_ORACLE_PKG.GET_DATE_YEAR_CAL_YEAR (
--          CURRENT_DATE,
--          PPOS.DATE_START)
--          TENURE_YEAR,
--       APPS.XXAKG_ORACLE_PKG.GET_DATE_DIFF_ALL (CURRENT_DATE,
--                                                PPOS.DATE_START)
--          TENURE,
--       APPS.XXAKG_ORACLE_PKG.GET_TOTAL_EXPERIENCE (PPF.PERSON_ID)
--          TOTAL_EXPERIENCE,
--       APPS.XXAKG_ORACLE_PKG.GET_PREVIOUS_JOB_DETAILS (PPF.PERSON_ID)
--          PREVIOUS_JOB_DETAILS,
--       APPS.XXAKG_ORACLE_PKG.GET_PERSON_TYPE (PPF.PERSON_ID) PERSON_TYPE,
--       APPS.XXAKG_ORACLE_PKG.GET_PERSON_NAME (PPF.PERSON_ID) PERSON_NAME,
--       APPS.XXAKG_ORACLE_PKG.GET_ENAME_FRM_ENUM (PPF.EMPLOYEE_NUMBER)
--          GET_ENAME_FRM_ENUM,
       PAAF.SUPERVISOR_ID,
       PPX.EMPLOYEE_NUMBER SUPERVISOR_EMP_NUM,
       NVL (PPX.FULL_NAME, 'NONE') SUPERVISOR_EMP_NAME,
--       (SELECT PPDS.SEGMENT2
--          FROM APPS.PER_POSITION_DEFINITIONS PPDS,
--               APPS.HR_ALL_POSITIONS_F HAPFS,
--               APPS.PER_ALL_ASSIGNMENTS_F PAAFS
--         WHERE     SYSDATE BETWEEN PAAFS.EFFECTIVE_START_DATE
--                               AND PAAFS.EFFECTIVE_END_DATE
--               AND NVL (PAAFS.POSITION_ID, 1) = HAPFS.POSITION_ID(+)
--               AND HAPFS.POSITION_DEFINITION_ID =
--                      PPDS.POSITION_DEFINITION_ID(+)
--               --AND PAAFS.ASSIGNMENT_NUMBER = PPX.EMPLOYEE_NUMBER
--               AND PAAFS.PERSON_ID=PPF.PERSON_ID)
--          SUPERVISOR_DESIGNATION,
--       APPS.XXAKG_ORACLE_PKG.GET_SUPERVISOR_NAME (PPF.PERSON_ID)
--          SUPERVISOR_NAME,
       PJD.SEGMENT1 Department,
       PJD.SEGMENT2 SUB_DEPARTMENT,
       PPSF.PAYROLL_NAME,
       HRL.LOCATION_CODE,
       POU.NAME ORGANIZATION_NAME,
       PPD.SEGMENT2 EMP_DESIGNATION
--       APPS.XXAKG_ORACLE_PKG.GET_CONTACT_NUMBER (PPF.PERSON_ID, 'M')
--          PERSONAL_NUMBER,
--       APPS.XXAKG_ORACLE_PKG.GET_CONTACT_NUMBER (PPF.PERSON_ID, 'C1')
--          OFFICE_NUMBER,
--       APPS.XXAKG_ORACLE_PKG.GET_CONTACT_NUMBER (PPF.PERSON_ID, 'H1')
--          HOME_NUMBER
          --,PPF.*
                     --,PJD.*
                     --,PPSF.*
                     --,HRL.*
                     --,POU.*
                     --,PPD.*
                     --,HAPF.*
                     --,PPOS.*
--       ,APPS.XXAKG_ORACLE_PKG.EMPLOYEE_CREATED_BY (PPF.PERSON_ID) CREATED_USER_ID
  FROM APPS.PER_PEOPLE_F PPF,
       APPS.FND_USER FU,
       APPS.PER_ALL_ASSIGNMENTS_F PAAF,
       APPS.PER_PEOPLE_X PPX,
       APPS.PER_JOBS PJ,
       APPS.PER_JOB_DEFINITIONS PJD,
       APPS.PAY_PAYROLLS_F PPSF,
       APPS.HR_LOCATIONS HRL,
       APPS.PER_ORGANIZATION_UNITS POU,
       APPS.PER_POSITION_DEFINITIONS PPD,
       APPS.HR_ALL_POSITIONS_F HAPF,
       APPS.PER_PERIODS_OF_SERVICE PPOS
 WHERE     1 = 1
       AND PPF.PERSON_ID = PPOS.PERSON_ID
       AND PPF.PERSON_ID=FU.EMPLOYEE_ID
       AND HAPF.LOCATION_ID(+) = HRL.LOCATION_ID
       AND NVL (PAAF.POSITION_ID, 1) = HAPF.POSITION_ID(+)
       AND HAPF.POSITION_DEFINITION_ID = PPD.POSITION_DEFINITION_ID(+)
       AND PAAF.ORGANIZATION_ID = POU.ORGANIZATION_ID
       AND NVL (PAAF.LOCATION_ID, 1) = HRL.LOCATION_ID(+)
       AND NVL (PAAF.PAYROLL_ID, 1) = PPSF.PAYROLL_ID(+)
       AND PJD.JOB_DEFINITION_ID = PJ.JOB_DEFINITION_ID
       AND NVL (PAAF.JOB_ID, 1) = PJ.JOB_ID
       AND PPF.PERSON_ID = PAAF.PERSON_ID
       AND PAAF.SUPERVISOR_ID = PPX.PERSON_ID(+)
       --AND FU.USER_ID=:P_USER_ID
       AND PPF.EMPLOYEE_NUMBER = :P_EMPLOYEE_NUMBER
--       AND UPPER (PPF.FULL_NAME) LIKE UPPER ('%' || :P_EMPLOYEE_NAME || '%')
       --AND UPPER (POU.NAME) LIKE UPPER ('%' || :P_ORGANIZATION_NAME || '%')
       --AND UPPER (PJD.SEGMENT1) LIKE UPPER ('%' || :P_DEPARTMENT_NAME || '%')
       --AND UPPER (PJD.SEGMENT2) LIKE UPPER ('%' || :P_SUB_DEPARTMENT || '%')
       --AND UPPER (PJD.SEGMENT2) LIKE UPPER ('%' || :P_SUB_DEPARTMENT || '%')
       --AND UPPER (HRL.LOCATION_CODE) LIKE UPPER ('%' || :P_LOCATION || '%')
       AND SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
                       AND PPF.EFFECTIVE_END_DATE
       AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE
                       AND PAAF.EFFECTIVE_END_DATE
--AND SYSDATE BETWEEN PPD.START_DATE_ACTIVE AND PPD.END_DATE_ACTIVE



--------------------------------------------------------------------------------

SELECT DISTINCT
          ppf.person_id,
             DECODE (ppf.first_name, NULL, NULL, ppf.first_name)
          || DECODE (ppf.middle_names, NULL, NULL, ' ' || ppf.middle_names)
          || DECODE (ppf.last_name, NULL, NULL, ' ' || ppf.last_name)
             employee_name,
          ppf.employee_number,
          ppf.attribute1 old_emp_number,
          (CASE
              WHEN     LENGTH (ppf.attribute1) = 4
                   AND APPS.xx_com_pkg.is_number (ppf.attribute1) = 1
              THEN
                 'P-' || ppf.attribute1
              WHEN     LENGTH (ppf.attribute1) = 5
                   AND SUBSTR (ppf.attribute1, 1, 1) = 'T'
              THEN
                 REPLACE (ppf.attribute1, 'T', 'T-')
              ELSE
                 ppf.attribute1
           END)
             supplier_number,
          DECODE (ppf.sex,  'M', 'Male',  'F', 'Female') sex,
          ppf.date_of_birth,
          ppf.attribute2 religion,
          INITCAP (pjd.segment1) department,
          INITCAP (ppd.segment2) designation,
          loc.location_code,
          LOWER (ppf.email_address)
     FROM per_people_f ppf,
          per_all_assignments_f paf,
          per_jobs pej,
          per_job_definitions pjd,
          hr_all_positions_f hpf,
          per_position_definitions ppd,
          --  PAY_PAYROLLS_F PAY,
          hr_locations loc
    WHERE     ppf.person_id = paf.person_id
          AND NVL (paf.job_id, 1) = pej.job_id(+)
          AND pej.job_definition_id = pjd.job_definition_id(+)
          -- AND NVL (PAF.PAYROLL_ID, 1) = PAY.PAYROLL_ID(+)
          AND NVL (paf.position_id, 1) = hpf.position_id(+)
          AND hpf.position_definition_id = ppd.position_definition_id(+)
          AND ppd.segment1 = loc.attribute1(+)
          AND paf.primary_flag = 'Y'
          AND paf.assignment_type = 'E'
          AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date
                                  AND ppf.effective_end_date
          AND TRUNC (SYSDATE) BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
   AND ppf.employee_number='103908'