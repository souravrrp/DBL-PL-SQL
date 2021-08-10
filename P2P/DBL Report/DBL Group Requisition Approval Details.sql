/* Formatted on 7/2/2020 12:25:35 PM (QP5 v5.287) */
  SELECT                                                        --prha.ORG_ID,
        HOU.NAME,
         --OU.LEDGER_NAME,
         OU.LEGAL_ENTITY_NAME,
         prha.segment1 req_num,
         --prha.REQUISITION_HEADER_ID,
         --pah.sequence_num,
         --pah.action_code,
         --prha.authorization_status,
         --prl.item_description,
         CAT.SEGMENT2 ITEM_CATEGORY,
         (papf.FIRST_NAME || ' ' || papf.MIDDLE_NAMES || ' ' || papf.LAST_NAME)
            FULL_NAME,
         NVL(papf.employee_number,PAPF.NPW_NUMBER) emp_no,
         HAOU.NAME DEPARTMENT,
         pj.NAME job,
         (SELECT DISTINCT
                 NVL(PAPF.employee_number,PAPF.NPW_NUMBER)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 2)
            FIRST_APPROVER_ID,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 2)
            FIRST_APPROVER,
         (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 2)
            FIRST_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 2)
            FIRST_APPROVER_DESIGNATION,
            (SELECT DISTINCT
                 NVL(PAPF.employee_number,PAPF.NPW_NUMBER)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 3)
            SECOND_APPROVER_ID,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 3)
            SECOND_APPROVER,
            (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 3)
            SECOND_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 3)
            SECOND_APPROVER_DESIGNATION,
            (SELECT DISTINCT
                 NVL(PAPF.employee_number,PAPF.NPW_NUMBER)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 4)
            THIRD_APPROVER_ID,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 4)
            THIRD_APPROVER,
            (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 4)
            THIRD_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 4)
            THIRD_APPROVER_DESIGNATION,
            (SELECT DISTINCT
                 NVL(PAPF.employee_number,PAPF.NPW_NUMBER)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 5)
            FOURTH_APPROVER_ID,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 5)
            FOURTH_APPROVER,
            (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 5)
            FOURTH_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 5)
            FOURTH_APPROVER_DESIGNATION,
            (SELECT DISTINCT
                 NVL(PAPF.employee_number,PAPF.NPW_NUMBER)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 6)
            FIFTH_APPROVER_ID,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 6)
            FIFTH_APPROVER,
            (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 6)
            FIFTH_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 6)
            FIFTH_APPROVER_DESIGNATION,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 7)
            SIXTH_APPROVER,
            (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 7)
            SIXTH_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 7)
            SIXTH_APPROVER_DESIGNATION,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 8)
            SEVENTH_APPROVER,
            (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 8)
            SEVENTH_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 8)
            SEVENTH_APPROVER_DESIGNATION,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 9)
            EIGHTH_APPROVER,
            (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 9)
            EIGHTH_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 9)
            EIGHTH_APPROVER_DESIGNATION,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 10)
            NINTH_APPROVER,
            (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 10)
            NINTH_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 10)
            NINTH_APPROVER_DESIGNATION,
         (SELECT DISTINCT
                 (   PAPF.FIRST_NAME
                  || ' '
                  || PAPF.MIDDLE_NAMES
                  || ' '
                  || PAPF.LAST_NAME)
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 11)
            TENTH_APPROVER,
            (SELECT DISTINCT HAOU.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 11)
            TENTH_APPROVER_DEPT,
         (SELECT DISTINCT
                 pj.NAME
            FROM apps.PO_ACTION_HISTORY PAH,
                 apps.PER_ALL_PEOPLE_F PAPF,
                 apps.PER_ALL_ASSIGNMENTS_F PAAF,
                 HR.PER_JOBS PJ
           WHERE     prha.REQUISITION_HEADER_ID = PAH.object_id(+)
                 AND PAH.employee_id = PAPF.person_id(+)
                 AND PAPF.person_id = PAAF.person_id(+)
                 AND PAH.action_code = 'APPROVE'
                 AND PAH.OBJECT_TYPE_CODE = 'REQUISITION'
                 AND PAAF.job_id = pj.job_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAPF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                         AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                 AND sequence_num = 11)
            TENTH_APPROVER_DESIGNATION,
         (SELECT DISTINCT PAF.employee_number
            FROM apps.PER_ALL_PEOPLE_F PAF
           WHERE PAF.person_id = prl.SUGGESTED_BUYER_ID)
            BUYER,
         (SELECT DISTINCT
                 (   PAF.FIRST_NAME
                  || ' '
                  || PAF.MIDDLE_NAMES
                  || ' '
                  || PAF.LAST_NAME)
            FROM apps.PER_ALL_PEOPLE_F PAF
           WHERE PAF.person_id = prl.SUGGESTED_BUYER_ID
           AND SYSDATE BETWEEN paf.effective_start_date
                         AND paf.effective_end_date)
            BUYER_NAME,
         prl.SUGGESTED_BUYER_ID
    FROM po.po_action_history pah,
         po.po_requisition_headers_all prha,
         po.po_requisition_lines_all prl,
         applsys.fnd_user fu,
         hr.per_all_people_f papf,
         hr.per_all_assignments_f paaf,
         hr.per_jobs pj,
         HR_OPERATING_UNITS HOU,
         XXDBL_COMPANY_LE_MAPPING_V OU,
         APPS.MTL_ITEM_CATEGORIES_V CAT,
         APPS.HR_ALL_ORGANIZATION_UNITS HAOU
   WHERE     object_id = prha.requisition_header_id
         AND pah.employee_id = fu.employee_id
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND prha.requisition_header_id = prl.requisition_header_id
         AND paaf.job_id = pj.job_id(+)
         AND paaf.primary_flag = 'Y'
         AND PRL.CATEGORY_ID = CAT.CATEGORY_ID
         AND PRL.ITEM_ID = CAT.INVENTORY_ITEM_ID
         AND PRL.DESTINATION_ORGANIZATION_ID = CAT.ORGANIZATION_ID
         AND PRL.LINE_TYPE_ID = 1
         --AND PRL.LINE_NUM = 1
         AND pah.sequence_num = 1
         AND HOU.ORGANIZATION_ID = prha.ORG_ID
         AND HOU.ORGANIZATION_ID = OU.ORG_ID
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND SYSDATE BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date
         AND pah.object_type_code = 'REQUISITION'
         AND prha.authorization_status = 'APPROVED'
         --AND PAH.action_code = 'APPROVE'
         AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
         --AND OU.ORG_ID=105
         --AND prl.SUGGESTED_BUYER_ID=352
         --AND pah.action_code = 'APPROVE'
         --AND prha.CREATION_DATE > '01-JUL-2019'
         --AND prha.CREATION_DATE < '30-JUN-2020'
         --AND ((:P_EMPLOYEE_NAME IS NULL) OR (UPPER (PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES || ' ' || PAPF.LAST_NAME) LIKE UPPER ('%' || :P_EMPLOYEE_NAME || '%')))
         AND prha.segment1 = '10321006698'
ORDER BY prha.segment1, pah.sequence_num;