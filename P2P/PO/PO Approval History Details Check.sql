/* Formatted on 6/21/2020 11:17:11 AM (QP5 v5.287) */
-------Checking Purchase Order Approval History Checking

  SELECT pah.action_code,
         pah.object_id,
         pah.action_date,
         pah.sequence_num step,
         pah.creation_date,
         pha.segment1 po_num,
         fu.description,
         papf.full_name hr_full_name,
         papf.employee_number emp_no,
         papf.person_id,
         fu.user_name,
         fu.EMAIL_ADDRESS,
         pj.NAME job
    FROM po.po_action_history pah,
         po.po_headers_all pha,
         applsys.fnd_user fu,
         hr.per_all_people_f papf,
         hr.per_all_assignments_f paaf,
         hr.per_jobs pj
   WHERE     object_id = pha.po_header_id
         AND pah.employee_id = fu.employee_id
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND paaf.job_id = pj.job_id
         AND paaf.primary_flag = 'Y'
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND SYSDATE BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date
         AND pah.object_type_code = 'PO'
         --AND pha.authorization_status = 'REQUIRES REAPPROVAL'
         --AND pha.authorization_status = 'INCOMPLETE'
         --AND pha.authorization_status = 'IN PROCESS'
         --AND pha.authorization_status = 'APPROVED'
         ---AND prha.authorization_status = 'REJECTED'
         --AND prha.CREATION_DATE > '15-JUN-2020'
         --AND pah.action_code = 'APPROVE'
         --AND pah.action_code = 'SUBMIT'
         --AND pah.action_code = 'DELEGATE'
         --AND pah.action_code = 'CLOSE'
         --AND pah.action_code = 'IMPORT'
         --AND pah.action_code = 'REJECT'
         --AND pah.action_code = 'CANCEL'
         --AND pah.action_code = 'OPEN'
         --AND pah.action_code = 'FINALLY CLOSE'
         --AND pah.action_code = 'HOLD'
         --AND pah.action_code = 'ANSWER'
         --AND pah.action_code = 'RELEASE HOLD'
         --AND pah.action_code = 'QUESTION'
         --AND pah.action_code = 'FORWARD'
         --AND pah.action_code = 'APPROVE AND FORWARD'
         --AND pah.action_code = 'FREEZE'
         --AND pah.action_code = 'UNFREEZE'
         --AND prha.segment1 = '50313000001'
         AND ( :P_PO_NUMBER IS NULL OR (pha.segment1 = :P_PO_NUMBER))
         AND ( :P_EMP_ID IS NULL OR (papf.EMPLOYEE_NUMBER = :P_EMP_ID))
         AND (   :P_EMP_NAME IS NULL
              OR (UPPER (papf.full_name) LIKE UPPER ('%' || :P_EMP_NAME || '%')))
ORDER BY pah.sequence_num;


-----------Checking Requisition Approval History Path

  SELECT DISTINCT
         poh.creation_date req_creation_date,
         poh.segment1 req_number,
         gl.SEGMENT3 COST_CENTER,
         hp.full_name REQUESTOR,
         hp.EMPLOYEE_NUMBER CREATED_BY,
         hp.full_name PREPARER_NAME,
         --lp.EMPLOYEE_NUMBER CREATED_BY,
         --lp.full_name PREPARER_NAME,
         gl.SEGMENT1 COMPANY,
         cat.segment1 category,
         (pol.unit_price * pol.quantity) requisition_amount,
         poh.AUTHORIZATION_STATUS,
         poh.segment1 po_number,
         pv.vendor_name vendor,
         poh.AUTHORIZATION_STATUS PO_STATUS,
            (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 0)
         || ' BY '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 0)
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 1)
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 1)
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 2)
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 2)
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 3)
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 3)
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 4)
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 4)
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 5)
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     poh.PO_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 5)
            APPROVAL_FLOW
    FROM 
         apps.per_all_people_f hp,
         --apps.per_all_people_f lp,
         apps.po_distributions_all pod,
         apps.po_lines_all pol,
         apps.po_headers_all poh,
         apps.po_vendors pv,
         apps.GL_CODE_COMBINATIONS GL,
         apps.MTL_CATEGORIES CAT
   WHERE     1 = 1
         --AND prh.org_id     = 182
         AND poh.segment1 = NVL ( :PO_NUMBER, poh.segment1)
         AND ( :P_EMP_ID IS NULL OR (hp.EMPLOYEE_NUMBER = :P_EMP_ID))
         AND (   :P_EMP_NAME IS NULL
              OR (UPPER (hp.full_name) LIKE UPPER ('%' || :P_EMP_NAME || '%')))
         --AND prh.creation_date BETWEEN TRUNC(to_date(:P_FROM_DATE, 'YYYY/MM/DD HH24:MI:SS')) AND TRUNC(to_date(:P_TO_DATE, 'YYYY/MM/DD HH24:MI:SS'))
         AND poh.CREATED_BY = NVL ( :CREATED_BY, poh.CREATED_BY)
         AND poh.CREATED_BY = hp.person_id
         --AND poL.to_person_id = lp.person_id
         --AND prd.distribution_id = pod.req_distribution_id(+)
         AND pod.po_line_id = pol.po_line_id(+)
         AND pod.PO_HEADER_ID = poh.PO_HEADER_ID(+)
         AND poh.vendor_id = pv.vendor_id(+)
         AND pod.code_combination_id = gl.code_combination_id
         AND pol.category_id = cat.category_id
         AND poh.AUTHORIZATION_STATUS <> 'SYSTEM_SAVED'
ORDER BY poh.creation_date;



SELECT
*
FROM
apps.po_headers_all pol