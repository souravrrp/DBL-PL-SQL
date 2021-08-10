/* Formatted on 7/4/2020 12:56:58 PM (QP5 v5.287) */
-----------Checking Requisition Approval History Path


  SELECT DISTINCT
         prh.creation_date req_creation_date,
         prh.segment1 req_number,
         gl.SEGMENT3 COST_CENTER,
         hp.full_name REQUESTOR,
         lp.full_name PREPARER_NAME,
         gl.SEGMENT1 COMPANY,
         cat.segment1 category,
         (prl.unit_price * prl.quantity) requisition_amount,
         prh.AUTHORIZATION_STATUS,
         poh.segment1 po_number,
         pv.vendor_name vendor,
         poh.AUTHORIZATION_STATUS PO_STATUS,
            (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 0
                    AND APP.object_type_code = 'REQUISITION')
         || ' CREATED BY '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 0
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 1
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 1
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 2
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 2
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 3
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 3
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 4
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 4
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT app.action_code
               FROM apps.PO_ACTION_HISTORY app
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.sequence_num = 5
                    AND APP.object_type_code = 'REQUISITION')
         || ' -> '
         || (SELECT DISTINCT per.full_name
               FROM apps.PO_ACTION_HISTORY app,
                    apps.PER_PEOPLE_V7 per,
                    apps.PER_ASSIGNMENTS_V7 dep
              WHERE     prh.REQUISITION_HEADER_ID = app.object_id(+)
                    AND app.employee_id = per.person_id(+)
                    AND per.person_id = dep.person_id(+)
                    AND sequence_num = 5
                    AND APP.object_type_code = 'REQUISITION')
            APPROVAL_FLOW
    FROM apps.PO_REQUISITION_HEADERS_ALL prh,
         apps.PO_REQUISITION_LINES_ALL prl,
         apps.PO_REQ_DISTRIBUTIONS_ALL prd,
         apps.per_all_people_f hp,
         apps.per_all_people_f lp,
         --hr.per_all_assignments_f paaf,
         --applsys.fnd_user fu,
         --po.po_action_history pa,
         apps.po_distributions_all pod,
         apps.po_lines_all pol,
         apps.po_headers_all poh,
         apps.po_vendors pv,
         apps.GL_CODE_COMBINATIONS GL,
         apps.MTL_CATEGORIES CAT
   WHERE     1 = 1
         --AND prh.org_id     = 131
         --AND prh.CREATION_DATE > '01-JAN-2020'
         --AND prh.CREATION_DATE < '30-JUN-2020'
         AND prh.segment1 = '10221000107'
         --AND prh.segment1 = NVL(:REQ_NUMBER,prh.segment1)
         --AND prh.creation_date BETWEEN TRUNC(to_date(:P_FROM_DATE,'YYYY/MM/DD HH24:MI:SS')) AND TRUNC(to_date(:P_TO_DATE,'YYYY/MM/DD HH24:MI:SS'))
         AND ( :P_CREATED_BY IS NULL OR (hp.EMPLOYEE_NUMBER = :P_CREATED_BY))
         --AND HP.employee_number IN ('103181')
         --AND prh.preparer_id           = NVL(:CREATED_BY,prh.preparer_id)
         --AND paaf.primary_flag = 'Y'
         AND prh.REQUISITION_HEADER_ID = prl.REQUISITION_HEADER_ID
         AND prl.REQUISITION_LINE_ID = prd.REQUISITION_LINE_ID
         AND prh.preparer_id = hp.person_id
         AND prl.to_person_id = lp.person_id
         AND prd.distribution_id = pod.req_distribution_id(+)
         AND pod.po_line_id = pol.po_line_id(+)
         AND pod.PO_HEADER_ID = poh.PO_HEADER_ID(+)
         AND poh.vendor_id = pv.vendor_id(+)
         AND prd.code_combination_id = gl.code_combination_id
         AND prl.category_id = cat.category_id
         AND prh.AUTHORIZATION_STATUS <> 'SYSTEM_SAVED'
         AND PRL.LINE_TYPE_ID = 1
         --AND pa.employee_id = fu.employee_id
         --AND fu.employee_id = hp.person_id
         --AND pa.action_code = 'IMPORT'
         --AND pa.object_type_code = 'REQUISITION'
         AND EXISTS
                (SELECT 1
                   FROM po.po_action_history pa, applsys.fnd_user fu, hr.per_all_assignments_f paaf
                  WHERE     pa.employee_id = fu.employee_id
                        AND fu.employee_id = hp.person_id
                        AND hp.person_id = paaf.person_id
                        AND paaf.primary_flag = 'Y'
                        AND pa.sequence_num = 1
                        AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                        AND pa.action_code = 'IMPORT'
                        AND pa.object_type_code = 'REQUISITION')
         AND prh.authorization_status = 'APPROVED'
ORDER BY prh.creation_date;


-----------Checking Requisition Approval History Checking

  SELECT pah.action_code,
         pah.object_id,
         pah.action_date,
         pah.sequence_num,
         pah.creation_date,
         prha.segment1 req_num,
         prha.wf_item_key,
         prha.authorization_status,
         fu.description,
         papf.full_name hr_full_name,
         papf.employee_number emp_no,
         fu.EMAIL_ADDRESS,
         pj.NAME job
    FROM po.po_action_history pah,
         po.po_requisition_headers_all prha,
         applsys.fnd_user fu,
         hr.per_all_people_f papf,
         hr.per_all_assignments_f paaf,
         hr.per_jobs pj
   WHERE     object_id = prha.requisition_header_id
         AND pah.employee_id = fu.employee_id
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND paaf.job_id = pj.job_id
         AND paaf.primary_flag = 'Y'
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND SYSDATE BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date
         AND pah.object_type_code = 'REQUISITION'
         AND prha.authorization_status = 'APPROVED' --'APPROVED'  --'REJECTED'
         --AND pah.action_code = 'APPROVE'
         --AND prha.authorization_status = 'REJECTED'
         --AND prha.CREATION_DATE > '15-JUN-2020'
         --AND pah.action_code != 'SUBMIT'
         --AND pah.action_code != 'APPROVE'
         AND pah.action_code = 'IMPORT'
         --AND pah.action_code != 'REJECT'
         --AND pah.action_code != 'QUESTION'
         --AND pah.action_code != 'ANSWER'
         --AND pah.action_code != 'RETURN'
         --AND pah.action_code != 'DELEGATE'
         --AND pah.action_code != 'NO ACTION'
         --AND prha.segment1 IN ('15311002450')
         AND (   :P_EMP_NAME IS NULL
              OR (UPPER (papf.full_name) LIKE UPPER ('%' || :P_EMP_NAME || '%')))
         AND ( :P_EMP_ID IS NULL OR (papf.EMPLOYEE_NUMBER = :P_EMP_ID))
ORDER BY pah.sequence_num;