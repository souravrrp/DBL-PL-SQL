/* Formatted on 7/2/2020 10:22:13 AM (QP5 v5.287) */
SELECT HOU.NAME,
         OU.LEGAL_ENTITY_NAME,
         H.REQUEST_NUMBER MOVE_ORDER,
         H.CREATION_DATE,
--         (SELECT MSI.DESCRIPTION
--            FROM APPS.MTL_SYSTEM_ITEMS_B MSI
--           WHERE     MSI.INVENTORY_ITEM_ID = L.INVENTORY_ITEM_ID
--                 AND MSI.ORGANIZATION_ID = L.ORGANIZATION_ID)
--            ITEM_NAME,
         (SELECT MIC.SEGMENT2
            FROM APPS.MTL_SYSTEM_ITEMS_B MSI, APPS.MTL_ITEM_CATEGORIES_V MIC
           WHERE     MSI.INVENTORY_ITEM_ID = L.INVENTORY_ITEM_ID
                 AND MSI.ORGANIZATION_ID = L.ORGANIZATION_ID
                 AND MIC.CATEGORY_SET_ID = 1
                 AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                 AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID)
            ITEM_CATEGORY,
             NVL(PAPF.EMPLOYEE_NUMBER,PAPF.NPW_NUMBER) CREATOR_EMP_NO,
            (PAPF.FIRST_NAME || ' ' || PAPF.MIDDLE_NAMES || ' ' || PAPF.LAST_NAME) CREATOR_FULL_NAME,
             HAOU.NAME CREATOR_DEPARTMENT,
             pj.NAME CREATOR_DESIGNATION,
             NVL (PAPFS.EMPLOYEE_NUMBER, PAPFS.NPW_NUMBER) SUPERVISOR_EMPNO,
             (PAPFS.FIRST_NAME || ' ' || PAPFS.MIDDLE_NAMES || ' ' || PAPFS.LAST_NAME) SUPERVISOR_NAME,
             HAOUS.NAME SUPERVISOR_DEPARTMENT,
             PJS.NAME SUPERVISOR_DESIGNATION,
             NVL (PAPFF.EMPLOYEE_NUMBER, PAPFF.NPW_NUMBER) FINAL_SUPERVISOR_EMPNO,
             (PAPFF.FIRST_NAME || ' ' || PAPFF.MIDDLE_NAMES || ' ' || PAPFF.LAST_NAME) FINAL_SUPERVISOR_NAME,
             HAOUF.NAME FINAL_SUPERVISOR_DEPARTMENT,
             PJF.NAME FINAL_SUPERVISOR_DESIGNATION
    --,H.*
    --,L.*
    --,paaf.*
    --,paaf.*
    FROM APPS.MTL_TXN_REQUEST_HEADERS H,
         APPS.MTL_TXN_REQUEST_LINES L,
         HR_OPERATING_UNITS HOU,
         ORG_ORGANIZATION_DEFINITIONS OOD,
         XXDBL_COMPANY_LE_MAPPING_V OU,
         applsys.fnd_user fu
         ,hr.per_all_people_f papf
         ,hr.per_all_assignments_f paaf
         ,hr.per_jobs pj
         ,APPS.HR_ALL_ORGANIZATION_UNITS HAOU
         ,HR.PER_ALL_ASSIGNMENTS_F PAAFS
         ,HR.PER_ALL_PEOPLE_F PAPFS
         ,APPS.HR_ALL_ORGANIZATION_UNITS HAOUS
         ,hr.per_jobs pjS
         ,HR.PER_ALL_ASSIGNMENTS_F PAAFF
         ,HR.PER_ALL_PEOPLE_F PAPFF
         ,APPS.HR_ALL_ORGANIZATION_UNITS HAOUF
         ,hr.per_jobs pjF
   WHERE     1 = 1
         AND HOU.ORGANIZATION_ID = OOD.OPERATING_UNIT
         AND OOD.OPERATING_UNIT = OU.ORG_ID
         AND H.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         AND H.HEADER_ID = L.HEADER_ID
         AND H.ORGANIZATION_ID = L.ORGANIZATION_ID
         AND H.HEADER_STATUS = 3
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND SYSDATE BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date
         AND H.created_by = fu.user_id
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND paaf.job_id = pj.job_id(+)
         AND paaf.primary_flag = 'Y'
         AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
         AND PAAF.SUPERVISOR_ID = PAPFS.PERSON_ID(+)
         AND PAPFS.PERSON_ID = PAAFS.PERSON_ID
         AND SYSDATE BETWEEN PAPFS.effective_start_date
                         AND PAPFS.effective_end_date
         AND SYSDATE BETWEEN PAAFS.effective_start_date
                         AND PAAFS.effective_end_date
         AND HAOUS.ORGANIZATION_ID = PAAFS.ORGANIZATION_ID
         AND PAAFS.JOB_ID = PJS.JOB_ID(+)
         AND PAAFS.SUPERVISOR_ID = PAPFF.PERSON_ID(+)
         AND PAPFF.PERSON_ID = PAAFF.PERSON_ID
         AND SYSDATE BETWEEN PAPFF.effective_start_date
                         AND PAPFF.effective_end_date
         AND SYSDATE BETWEEN PAAFF.effective_start_date
                         AND PAAFF.effective_end_date
         AND HAOUF.ORGANIZATION_ID = PAAFF.ORGANIZATION_ID
         AND PAAFF.JOB_ID = PJF.JOB_ID(+)
         --AND NVL(PAPF.EMPLOYEE_NUMBER,PAPF.NPW_NUMBER)='104284'
         --AND H.REQUEST_NUMBER='696903' --696903 --696771
         --AND L.LINE_ID='31251259'
         --AND H.HEADER_ID='15129101'
         --AND H.CREATION_DATE > '01-JAN-2019'
         --AND H.CREATION_DATE < '30-JUN-2020'
ORDER BY H.REQUEST_NUMBER,H.CREATION_DATE DESC;