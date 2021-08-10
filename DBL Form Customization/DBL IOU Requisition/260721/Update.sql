/* Formatted on 7/29/2021 5:48:17 PM (QP5 v5.287) */
  SELECT *
    FROM XXDBL.XXDBL_IOU_REQ_DTL IRD
   WHERE 1 = 1 --AND IOU_NUMBER='FFL-RMG/290721/1'
         AND TO_CHAR (IOU_DATE, 'DD-MON-YYYY') = '01-AUG-2021'
--AND IOU_REQ_ID IS NULL
ORDER BY IOU_DATE, IOU_REQ_ID DESC;


ALTER TABLE XXDBL.XXDBL_IOU_REQ_DTL
   ADD (FST_APRV_BY_PERSON NUMBER,
        SND_APRV_BY_PERSON NUMBER,
        PAID_BY_PERSON NUMBER,
        ADJUSTED_BY_PERSON NUMBER,
        REJECTED_BY_PERSON NUMBER);
        
ALTER TABLE XXDBL.XXDBL_IOU_REQ_DTL
   ADD (MAIL_STATUS VARCHAR2(50 BYTE));

CREATE OR REPLACE SYNONYM APPS.XXDBL_IOU_REQ_DTL FOR XXDBL.XXDBL_IOU_REQ_DTL;

CREATE OR REPLACE SYNONYM APPSRO.XXDBL_IOU_REQ_DTL FOR XXDBL.XXDBL_IOU_REQ_DTL;

SELECT NVL (papf.employee_number, papf.npw_number) employee_number,
       (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name)
          AS employee_name,
       fu.user_id
  FROM apps.per_all_assignments_f paaf,
       apps.per_all_people_f papf,
       apps.per_jobs pj,
       apps.hr_all_organization_units haou,
       apps.per_pay_bases ppb,
       apps.pay_people_groups ppg,
       apps.pay_payrolls_f ppf,
       apps.hr_locations_all hla,
       fnd_user fu
 WHERE     1 = 1
       AND paaf.business_group_id = 81
       AND papf.person_id = paaf.person_id(+)
       AND paaf.job_id = pj.job_id(+)
       AND paaf.payroll_id = ppf.payroll_id(+)
       AND paaf.location_id = hla.location_id(+)
       AND paaf.people_group_id = ppg.people_group_id(+)
       AND paaf.organization_id = haou.organization_id(+)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                               AND TRUNC (paaf.effective_end_date)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                               AND TRUNC (papf.effective_end_date)
       AND papf.person_id = fu.employee_id(+)
       AND fu.end_date IS NULL
       AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y';

SELECT NVL (papf.employee_number, papf.npw_number) employee_number,
       (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name)
          AS employee_name,
       fu.user_id
  FROM apps.per_all_assignments_f paaf,
       apps.per_all_people_f papf,
       apps.per_jobs pj,
       apps.hr_all_organization_units haou,
       apps.per_pay_bases ppb,
       apps.pay_people_groups ppg,
       apps.pay_payrolls_f ppf,
       apps.hr_locations_all hla,
       fnd_user fu
 WHERE     1 = 1
       AND paaf.business_group_id = 81
       AND papf.person_id = paaf.person_id(+)
       AND paaf.job_id = pj.job_id(+)
       AND paaf.payroll_id = ppf.payroll_id(+)
       AND paaf.location_id = hla.location_id(+)
       AND paaf.people_group_id = ppg.people_group_id(+)
       AND paaf.organization_id = haou.organization_id(+)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                               AND TRUNC (paaf.effective_end_date)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                               AND TRUNC (papf.effective_end_date)
       AND papf.person_id = fu.employee_id(+)
       AND NVL (papf.employee_number, papf.npw_number) <>
              :XXDBL_IOU_REQ_DTL.FST_APVR
       AND fu.end_date IS NULL
       AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y';

SELECT NVL (PAPF.EMPLOYEE_NUMBER, PAPF.NPW_NUMBER) EMPLOYEE_NUMBER
  FROM APPS.PER_ALL_ASSIGNMENTS_F PAAF,
       APPS.PER_ALL_PEOPLE_F PAPF,
       APPS.PER_JOBS PJ,
       APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
       APPS.PER_PAY_BASES PPB,
       APPS.PAY_PEOPLE_GROUPS PPG,
       APPS.PAY_PAYROLLS_F PPF,
       APPS.HR_LOCATIONS_ALL HLA,
       FND_USER FU
 WHERE     1 = 1
       AND PAAF.BUSINESS_GROUP_ID = 81
       AND PAPF.PERSON_ID = PAAF.PERSON_ID(+)
       AND PAAF.JOB_ID = PJ.JOB_ID(+)
       AND PAAF.PAYROLL_ID = PPF.PAYROLL_ID(+)
       AND PAAF.LOCATION_ID = HLA.LOCATION_ID(+)
       AND PAAF.PEOPLE_GROUP_ID = PPG.PEOPLE_GROUP_ID(+)
       AND PAAF.ORGANIZATION_ID = HAOU.ORGANIZATION_ID(+)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                               AND TRUNC (PAAF.EFFECTIVE_END_DATE)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                               AND TRUNC (PAPF.EFFECTIVE_END_DATE)
       AND PAPF.PERSON_ID = FU.EMPLOYEE_ID(+)