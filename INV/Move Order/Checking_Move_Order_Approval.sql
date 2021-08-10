/* Formatted on 12/1/2020 5:16:59 PM (QP5 v5.354) */
SELECT *
  FROM xxdbl_mov_ord_appr_hist
 WHERE 1 = 1 AND mo_header_id = '922501';

SELECT *
  FROM mtl_txn_request_headers
 WHERE 1 = 1 AND REQUEST_NUMBER = '922501';

SELECT *
  FROM mtl_txn_request_lines l
 WHERE l.header_id = 922501;


SELECT '596645' || '_' || xxdbl_wf_key_s.NEXTVAL FROM DUAL;

SELECT user_name, employee_id
  FROM fnd_user
 WHERE user_id = 2029;


SELECT *
  FROM xxdbl_mov_ord_appr_list al
 WHERE 1 = 1 AND al.wf_item_key LIKE '596645_%' AND al.approval_seq = 1;


SELECT usr.user_id              requester_user_id,
       usr.user_name            requester,
       paf.supervisor_id,
       ppf1.full_name           supervisor_name,
       ppf1.employee_number     supervisor_empno,
       usr1.user_id             supervisor_user_id,
       usr1.user_name           supervisor_user,
       pg.NAME                  supervisor_grade
  FROM per_all_assignments_f  paf,
       per_all_people_f       ppf1,
       per_all_assignments_f  paf1,
       per_grades             pg,
       fnd_user               usr,
       fnd_user               usr1
 WHERE     1 = 1
       AND usr.user_id = '2029'
       AND usr.employee_id = paf.person_id
       AND TRUNC (SYSDATE) BETWEEN paf.effective_start_date(+)
                               AND paf.effective_end_date(+)
       AND paf.supervisor_id = ppf1.person_id
       AND TRUNC (SYSDATE) BETWEEN ppf1.effective_start_date
                               AND ppf1.effective_end_date
       AND ppf1.person_id = usr1.employee_id
       AND TRUNC (SYSDATE) BETWEEN paf1.effective_start_date(+)
                               AND paf1.effective_end_date(+)
       AND ppf1.person_id = paf1.person_id(+)
       AND paf1.grade_id = pg.grade_id(+);