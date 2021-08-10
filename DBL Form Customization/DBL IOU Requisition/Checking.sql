/* Formatted on 9/27/2020 3:19:33 PM (QP5 v5.287) */
  SELECT *
    FROM XXDBL.XXDBL_IOU_REQ_DTL IRD
   WHERE 1 = 1                              --AND IOU_NUMBER='DBLCL/81120/4'
              --AND TO_CHAR (IOU_DATE, 'DD-MON-YYYY') = '24-SEP-2020'
--AND IOU_REQ_ID IS NULL
ORDER BY IOU_DATE DESC;

  SELECT NVL (COUNT (IRD.IOU_REQ_ID), 1) NUM
    FROM XXDBL.XXDBL_IOU_REQ_DTL IRD
   WHERE 1 = 1 AND TRUNC (IOU_DATE) = TRUNC (SYSDATE) AND IRD.OU_NAME = 'MSML'
GROUP BY IRD.OU_NAME;

  SELECT COUNT (IRD.IOU_REQ_ID) + 1
    FROM XXDBL.XXDBL_IOU_REQ_DTL IRD
   WHERE     1 = 1
         AND TRUNC (IOU_DATE) = TRUNC (SYSDATE)
         AND IRD.OPERATING_UNIT = :XXDBL_IOU_REQ_DTL.OPERATING_UNIT
GROUP BY IRD.OPERATING_UNIT;

SELECT    :XXDBL_IOU_REQ_DTL.OU_NAME
       || '/'
       || v_short_code
       || 'BILL'
       || DECODE (v_short_code, NULL, NULL, '/')
       || v_do_seq
  FROM DUAL;


--------------------------------------------------------------------------------

SELECT NVL (PAPF.EMPLOYEE_NUMBER, PAPF.NPW_NUMBER) EMPLOYEE_NUMBER,
       (PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES || ' ' || PAPF.LAST_NAME)
          AS EMPLOYEE_NAME,
          HLA.DESCRIPTION
       || ', '
       || HLA.ADDRESS_LINE_1
       || DECODE (HLA.ADDRESS_LINE_2, NULL, ' ', ' , ')
       || DECODE (HLA.ADDRESS_LINE_3, NULL, ' ', ' , ')
          LOCATION_NAME
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
       AND NVL (PAPF.EMPLOYEE_NUMBER, PAPF.NPW_NUMBER) = FU.USER_NAME(+);

  SELECT DISTINCT cfu.user_name,
                  NVL (papf1.employee_number, papf1.NPW_NUMBER) level1_empno,
                  papf1.full_name leve1_full_name,
                  NVL (papf2.employee_number, papf2.NPW_NUMBER) level2_empno,
                  papf2.full_name leve2_full_name
    FROM per_all_people_f papf1,
         hr.per_all_assignments_f paaf1,
         hr.per_all_assignments_f paaf2,
         hr.per_all_people_f papf2,
         fnd_user cfu,
         xxdbl.xxdbl_iou_req_dtl ird
   WHERE     papf1.person_id = paaf1.person_id
         AND paaf1.supervisor_id = papf2.person_id(+)
         AND papf2.person_id = paaf2.person_id
         AND SYSDATE BETWEEN papf1.effective_start_date
                         AND papf1.effective_end_date
         AND SYSDATE BETWEEN paaf1.effective_start_date
                         AND paaf1.effective_end_date
         AND NVL (papf1.employee_number, papf1.NPW_NUMBER) = '103908'
         AND NVL (papf1.employee_number, papf1.NPW_NUMBER) = cfu.user_name
         AND cfu.user_id = ird.created_by
ORDER BY leve1_full_name;

SELECT *
  FROM fnd_user cfu
  
  SELECT ird.iou_number, ird.iou_date, ird.creation_date
  FROM xxdbl.xxdbl_iou_req_dtl ird, fnd_user fu
 WHERE status IN ('CREATED')
       AND ird.first_approver = fu.user_name
       AND fu.user_id = apps.fnd_global.user_id
       UNION ALL
       SELECT ird.iou_number, ird.iou_date, ird.creation_date
  FROM xxdbl.xxdbl_iou_req_dtl ird, fnd_user fu
 WHERE status IN ('APPROVED')
       AND ird.second_approver = fu.user_name
       AND fu.user_id = apps.fnd_global.user_id
       
       
       /* Formatted on 11/17/2020 5:37:21 PM (QP5 v5.287) */
SELECT    '/'
       || REGEXP_SUBSTR (IOU_NUMBER,
                         '[^/]+',
                         2,
                         2)
       || '/'
       || REGEXP_SUBSTR (IOU_NUMBER,
                         '[^/]+',
                         1,
                         3)
          IOU_NUMBER_SEQ
  FROM XXDBL.XXDBL_IOU_REQ_DTL IRD