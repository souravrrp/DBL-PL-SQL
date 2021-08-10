/* Formatted on 11/22/2020 4:24:01 PM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION get_dept_name_from_user_name (
   p_user_name   IN VARCHAR2,
   p_user_id     IN NUMBER)
   RETURN VARCHAR2
IS
   v_result   VARCHAR2 (1000);

   CURSOR p_cursor
   IS
      SELECT haou.name
        FROM hr.per_all_people_f papf,
             hr.per_all_assignments_f paaf,
             hr.hr_all_organization_units haou,
             fnd_user fu
       WHERE     SYSDATE BETWEEN papf.effective_start_date
                             AND papf.effective_end_date
             AND SYSDATE BETWEEN paaf.effective_start_date
                             AND paaf.effective_end_date
             AND papf.person_id = paaf.person_id
             AND paaf.organization_id = haou.organization_id
             AND fu.employee_id = papf.person_id(+)
             AND fu.user_name = NVL (p_user_name, fu.user_name)
             AND fu.user_id = NVL (p_user_id, fu.user_id);
BEGIN
   OPEN p_cursor;

   FETCH p_cursor INTO v_result;

   CLOSE p_cursor;

   RETURN v_result;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END;