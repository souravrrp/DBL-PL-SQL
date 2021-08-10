SELECT DISTINCT user_name,email
           FROM (SELECT hou.name,
                        ou.legal_entity_name,
                        prha.segment1,
                        prha.description,
                        prha.preparer_id,
                        prha.authorization_status,
                        TO_CHAR (fu.user_name) user_name,
                        (   ppf.first_name
                         || ' '
                         || ppf.middle_names
                         || ' '
                         || ppf.last_name)
                           requestor_name,
                           papf.email_address email
                   FROM po_requisition_headers_all prha,
                        apps.hr_operating_units hou,
                        xxdbl_company_le_mapping_v ou,
                        po_requisition_lines_all prla,
                        fnd_user fu,
                        apps.per_all_people_f ppf,
                        apps.per_all_people_f papf
                  WHERE     prha.requisition_header_id =
                               prla.requisition_header_id
                        --AND prha.authorization_status = 'APPROVED'
                        AND fu.employee_id = prla.suggested_buyer_id
                        AND prha.preparer_id = ppf.person_id(+)
                        AND fu.employee_id = papf.person_id(+)
                        AND hou.organization_id = prha.org_id
                        --AND TRUNC (prha.approved_date) = (TRUNC (TO_DATE (SYSDATE-1)))
                        and prha.segment1 in ('10321006810')
                        AND hou.organization_id = ou.org_id);
                        
                        
                        
           SELECT DISTINCT name unit_name,
                         legal_entity_name,
                         user_name,
                         segment1 req_no,
                         description,
                         authorization_status requisition_status,
                         requestor_name buyer_name
           FROM (SELECT hou.name,
                        ou.legal_entity_name,
                        prha.segment1,
                        prha.description,
                        prha.preparer_id,
                        prha.authorization_status,
                        fu.user_name,
                           (   ppf.first_name
                            || ' '
                            || ppf.middle_names
                            || ' '
                            || ppf.last_name)
                        || '~~'
                        || haou.name
                           requestor_name
                   FROM po_requisition_headers_all prha,
                        apps.hr_operating_units hou,
                        xxdbl_company_le_mapping_v ou,
                        po_requisition_lines_all prla,
                        fnd_user fu,
                        apps.per_all_assignments_f paaf,
                        apps.hr_all_organization_units haou,
                        apps.per_all_people_f ppf
                  WHERE     prha.requisition_header_id =
                               prla.requisition_header_id
                        --AND prha.authorization_status = 'APPROVED'
                        AND fu.employee_id = prla.suggested_buyer_id
                        AND prha.preparer_id = ppf.person_id(+)
                        AND hou.organization_id = prha.org_id
                        AND hou.organization_id = ou.org_id
                        AND paaf.organization_id = haou.organization_id(+)
                        AND ppf.person_id = paaf.person_id(+)
                        --AND FU.USER_NAME = l_user_name
                        and prha.segment1 in ('10321006810')
                        --AND TRUNC (prha.approved_date) = (TRUNC (SYSDATE-1))
                        );


SELECT APPS.XXDBLREQAPPSEQ_S.NEXTVAL || '-XXTEST'
  FROM DUAL;

DROP PACKAGE APPS.XXDBL_CUSTOM_WORKFLOW;

DROP PACKAGE BODY APPS.XXDBL_CUSTOM_WORKFLOW;




xxdbl_mov_ord_appr_pkg.initiate_approval_wf
--xxdbl_mov_ord_appr_pkg.html_body

select 
  regexp_substr('XX0099-X01','[^-]+', 1, 1),
  regexp_substr('XX0099-X01-XXDBL','[^-]+', 1, 1),
  regexp_substr('XX0099-X01','[^-]+', 1, 2)
from dual;

SELECT  RTRIM (REGEXP_SUBSTR ('LINER (KRAFT), GSM-125, REEL-1150', '[^,]*,', 1, 1), ',')    AS part_1
,       RTRIM (REGEXP_SUBSTR ('LINER (KRAFT), GSM-125, REEL-1150', '[^,]*,', 1, 2), ',')    AS part_2
,       RTRIM (REGEXP_SUBSTR ('LINER (KRAFT), GSM-125, REEL-1150', '[^,]*,', 1, 3), ',')    AS part_3
,       LTRIM (REGEXP_SUBSTR ('LINER (KRAFT), GSM-125, REEL-1150', ',[^,]*', 1, 3), ',')    AS part_4
FROM    dual;


SELECT  REGEXP_SUBSTR ('LINER (KRAFT), GSM-125, REEL-1150', '[^,]+', 1, 1)    AS part_1
,       REGEXP_SUBSTR ('LINER (KRAFT), GSM-125, REEL-1150', '[^,]+', 1, 2)    AS part_2
,       REGEXP_SUBSTR ('LINER (KRAFT), GSM-125, REEL-1150', '[^,]+', 1, 3)    AS part_3
FROM    dual;



xxdbl_mov_ord_appr_pkg.initiate_approval_wf
xxdbl_mov_ord_appr_pkg.html_body


/* Formatted on 9/13/2020 10:42:52 AM (QP5 v5.287) */
SELECT DISTINCT user_name
           FROM (SELECT hou.name,
                        ou.legal_entity_name,
                        prha.segment1,
                        prha.description,
                        prha.preparer_id,
                        prha.authorization_status,
                        TO_CHAR (fu.user_name) user_name,
                        (   ppf.first_name
                         || ' '
                         || ppf.middle_names
                         || ' '
                         || ppf.last_name)
                           requestor_name
                   FROM po_requisition_headers_all prha,
                        apps.hr_operating_units hou,
                        xxdbl_company_le_mapping_v ou,
                        po_requisition_lines_all prla,
                        fnd_user fu,
                        apps.per_all_people_f ppf
                  WHERE     prha.requisition_header_id =
                               prla.requisition_header_id
                        AND prha.authorization_status = 'APPROVED'
                        AND fu.employee_id = prla.suggested_buyer_id
                        AND prha.preparer_id = ppf.person_id(+)
                        AND hou.organization_id = prha.org_id
                        AND TRUNC (prha.approved_date) = (TRUNC (TO_DATE (SYSDATE-1)))
                        AND hou.organization_id = ou.org_id);
                        
                        
                        
           SELECT DISTINCT name unit_name,
                         legal_entity_name,
                         user_name,
                         segment1 req_no,
                         description,
                         authorization_status requisition_status,
                         requestor_name buyer_name
           FROM (SELECT hou.name,
                        ou.legal_entity_name,
                        prha.segment1,
                        prha.description,
                        prha.preparer_id,
                        prha.authorization_status,
                        fu.user_name,
                           (   ppf.first_name
                            || ' '
                            || ppf.middle_names
                            || ' '
                            || ppf.last_name)
                        || '~~'
                        || haou.name
                           requestor_name
                   FROM po_requisition_headers_all prha,
                        apps.hr_operating_units hou,
                        xxdbl_company_le_mapping_v ou,
                        po_requisition_lines_all prla,
                        fnd_user fu,
                        apps.per_all_assignments_f paaf,
                        apps.hr_all_organization_units haou,
                        apps.per_all_people_f ppf
                  WHERE     prha.requisition_header_id =
                               prla.requisition_header_id
                        AND prha.authorization_status = 'APPROVED'
                        AND fu.employee_id = prla.suggested_buyer_id
                        AND prha.preparer_id = ppf.person_id(+)
                        AND hou.organization_id = prha.org_id
                        AND hou.organization_id = ou.org_id
                        AND paaf.organization_id = haou.organization_id(+)
                        AND ppf.person_id = paaf.person_id(+)
                        --AND FU.USER_NAME = l_user_name
                        AND TRUNC (prha.approved_date) = (TRUNC (TO_DATE (SYSDATE-1))));