/* Formatted on 9/28/2020 6:00:45 PM (QP5 v5.287) */
SELECT DISTINCT NVL (papf2.employee_number, papf2.NPW_NUMBER) v_emp_no
  FROM per_all_people_f papf1,
       hr.per_all_assignments_f paaf1,
       hr.per_all_assignments_f paaf2,
       hr.per_all_people_f papf2,
       fnd_user cfu,
       xxdbl.xxdbl_iou_req_dtl ird,
       fnd_user fu
 WHERE     papf1.person_id = paaf1.person_id
       AND paaf1.supervisor_id = papf2.person_id(+)
       AND papf2.person_id = paaf2.person_id
       AND SYSDATE BETWEEN papf1.effective_start_date
                       AND papf1.effective_end_date
       AND SYSDATE BETWEEN paaf1.effective_start_date
                       AND paaf1.effective_end_date
       --AND NVL (papf1.employee_number, papf1.NPW_NUMBER) = '103908'
       AND NVL (papf1.employee_number, papf1.NPW_NUMBER) = cfu.user_name
       AND NVL (papf2.employee_number, papf2.NPW_NUMBER) = fu.user_name
       AND fu.user_name = '100277'
       --AND fu.user_id = p_user_id
       AND ird.iou_req_id = 10072              --:XXDBL_IOU_REQ_DTL.IOU_REQ_ID
       AND cfu.user_id = ird.created_by;


SELECT DISTINCT ird.iou_number
  FROM per_all_people_f papf1,
       hr.per_all_assignments_f paaf1,
       hr.per_all_assignments_f paaf2,
       hr.per_all_people_f papf2,
       fnd_user cfu,
       xxdbl.xxdbl_iou_req_dtl ird,
       fnd_user fu
 WHERE     papf1.person_id = paaf1.person_id
       AND paaf1.supervisor_id = papf2.person_id(+)
       AND papf2.person_id = paaf2.person_id
       AND SYSDATE BETWEEN papf1.effective_start_date
                       AND papf1.effective_end_date
       AND SYSDATE BETWEEN paaf1.effective_start_date
                       AND paaf1.effective_end_date
       --AND NVL (papf1.employee_number, papf1.NPW_NUMBER) = '103908'
       AND NVL (papf1.employee_number, papf1.NPW_NUMBER) = cfu.user_name
       AND NVL (papf2.employee_number, papf2.NPW_NUMBER) = fu.user_name
       AND fu.user_name = '100277'
       --AND fu.user_id = p_user_id
       --AND ird.iou_req_id = 10072--:XXDBL_IOU_REQ_DTL.IOU_REQ_ID
       AND cfu.user_id = ird.created_by;

SELECT IOU_NUMBER, IOU_DATE, CREATION_DATE
  FROM XXDBL.XXDBL_IOU_REQ_DTL IRD
 WHERE     1 = 1
       AND STATUS IN ('CREATED', 'APPROVED')
       AND IOU_NUMBER =
              (SELECT DISTINCT ird.iou_number
                 FROM per_all_people_f papf1,
                      hr.per_all_assignments_f paaf1,
                      hr.per_all_assignments_f paaf2,
                      hr.per_all_people_f papf2,
                      fnd_user cfu,
                      xxdbl.xxdbl_iou_req_dtl ird,
                      fnd_user fu
                WHERE     papf1.person_id = paaf1.person_id
                      AND paaf1.supervisor_id = papf2.person_id(+)
                      AND papf2.person_id = paaf2.person_id
                      AND SYSDATE BETWEEN papf1.effective_start_date
                                      AND papf1.effective_end_date
                      AND SYSDATE BETWEEN paaf1.effective_start_date
                                      AND paaf1.effective_end_date
                      --AND NVL (papf1.employee_number, papf1.NPW_NUMBER) = '103908'
                      AND NVL (papf1.employee_number, papf1.NPW_NUMBER) =
                             cfu.user_name
                      AND NVL (papf2.employee_number, papf2.NPW_NUMBER) =
                             fu.user_name
                      --AND fu.user_name='100277'
                      AND fu.user_id = fnd_global.user_id
                      AND cfu.user_id = ird.created_by)