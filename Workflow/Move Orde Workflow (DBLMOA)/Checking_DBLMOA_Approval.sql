/* Formatted on 6/1/2020 2:53:40 PM (QP5 v5.287) */
596645

SELECT *
  FROM mtl_txn_request_headers
 WHERE 1 = 1 AND REQUEST_NUMBER = '596645' AND header_id = '596645'
 
 
SELECT COUNT (1)
--        INTO l_line
        FROM mtl_txn_request_lines l
       WHERE l.header_id = 596645;


SELECT '596645' || '_' || xxdbl_wf_key_s.NEXTVAL
--  INTO l_item_key
  FROM DUAL;
  
  SELECT user_name, employee_id
--        INTO l_initiator, l_initiator_emp_id
        FROM fnd_user
       WHERE user_id = 2029;
       

SELECT *
--        INTO l_move_order_wf_rec
        FROM xxdbl_mov_ord_appr_list al
       WHERE 1=1 
       AND al.wf_item_key LIKE '596645_%'--166054' --596645_166052
       AND al.approval_seq = 1;
       
       
       SELECT usr.user_id requester_user_id, usr.user_name requester,
                paf.supervisor_id, ppf1.full_name supervisor_name,
                ppf1.employee_number supervisor_empno,
                usr1.user_id supervisor_user_id,
                usr1.user_name supervisor_user, pg.NAME supervisor_grade
           FROM per_all_assignments_f paf,
                per_all_people_f ppf1,
                per_all_assignments_f paf1,
                per_grades pg,
                fnd_user usr,
                fnd_user usr1
          WHERE 1 = 1
            AND usr.user_id = '2029'--cp_user_id
            AND usr.employee_id = paf.person_id
            AND TRUNC (SYSDATE) BETWEEN paf.effective_start_date(+) AND paf.effective_end_date(+)
            AND paf.supervisor_id = ppf1.person_id
            AND TRUNC (SYSDATE) BETWEEN ppf1.effective_start_date
                                    AND ppf1.effective_end_date
            AND ppf1.person_id = usr1.employee_id
            AND TRUNC (SYSDATE) BETWEEN paf1.effective_start_date(+) AND paf1.effective_end_date(+)
            AND ppf1.person_id = paf1.person_id(+)
            AND paf1.grade_id = pg.grade_id(+);
            
            
            SELECT created_by
--        INTO l_user_id
        FROM mtl_txn_request_headers h
       WHERE h.header_id = '596645'--p_mo_header_id;