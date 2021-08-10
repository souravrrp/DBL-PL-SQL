 WITH TmpGatePass
     AS (SELECT ROW_NUMBER () OVER (ORDER BY cm.GATE_PASS_MASTER_ID) SL_NO,
                cm.GATE_PASS_MASTER_ID,
                cm.TO_HEAD,
                cm.CHALLAN_NO,
                cm.ADDRESS,
                cm.CHALLAN_DATE,
                cm.DELIVERY_DATE,
                cm.VEHICLE_NO,
                cd.GATE_PASS_DETAIL_ID,
                COALESCE (cd.ITEM_DESCRIPTION, cd.ITEM_DESCRIPTION_MANUAL)
                   ITEM_DESCRIPTION,
                cd.UNIT,
                cd.QUANTITY,
                cd.REMARKS,
                cd.PURPOSE,
                cm.ORGANIZATION_ID,
                cm.CREATED_BY,
                cm.CREATION_DATE,
                :p_ADDRESS As CUSTOM_ADDRESS
           FROM XXDBL.XXDBL_GATE_PASS_MASTER cm, XXDBL.XXDBL_GATE_PASS_DETAIL cd
          WHERE     cm.GATE_PASS_MASTER_ID = cd.GATE_PASS_MASTER_ID
                AND cm.GATE_PASS_MASTER_ID = :p_GATE_PASS_MASTER_ID
               ),
     TmpDepartment
     AS (  SELECT ppf.User_ID,
                  papf.Person_ID,
                  papf.employee_number,
                  UPPER (
                     TRIM (
                           papf.first_name
                        || ' '
                        || papf.middle_names
                        || ' '
                        || papf.last_name))
                     full_name,
                  haou.NAME organization_name,
                  SUBSTR (pj.NAME, 1, INSTR (pj.NAME, '.') - 1) job_category,
                  SUBSTR (pj.NAME, INSTR (pj.NAME, '.') + 1) job_designation,
                  (   SUBSTR (pj.NAME, 1, INSTR (pj.NAME, '.') - 1)
                   || '.'
                   || SUBSTR (pj.NAME, INSTR (pj.NAME, '.') + 1))
                     Designation_Department
             FROM fnd_user ppf,
                  apps.per_people_f papf,
                  per_all_assignments_f paaf,
                  apps.hr_all_organization_units haou,
                  apps.per_jobs pj
            WHERE     1 = 1
                  AND papf.person_id = paaf.person_id
                  AND paaf.organization_id = haou.organization_id(+)
                  AND pj.job_id(+) = paaf.job_id
                  AND SYSDATE BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
                  AND SYSDATE BETWEEN papf.effective_start_date
                                  AND papf.effective_end_date
                  AND NVL (papf.EMPLOYEE_NUMBER, papf.NPW_NUMBER) =
                         ppf.USER_NAME
         --AND NVL (papf.EMPLOYEE_NUMBER, papf.NPW_NUMBER) = '100385'
         GROUP BY ppf.User_ID,
                  papf.Person_ID,
                  papf.employee_number,
                  papf.first_name,
                  papf.middle_names,
                  papf.last_name,
                  haou.NAME,
                  pj.NAME
         ORDER BY papf.employee_number)
  SELECT g.SL_NO,
         g.GATE_PASS_MASTER_ID,
         g.TO_HEAD,
         g.CHALLAN_NO,
         g.ADDRESS,
         g.CHALLAN_DATE,
         g.DELIVERY_DATE,
         g.VEHICLE_NO,
         g.GATE_PASS_DETAIL_ID,
         g.ITEM_DESCRIPTION,
         g.UNIT,
         g.QUANTITY,
         g.REMARKS,
         g.PURPOSE,
         g.CREATED_BY,
         g.CREATION_DATE,
         d.employee_number,
         d.job_category,
         d.Designation_Department,
         g.ORGANIZATION_ID,
         g.CUSTOM_ADDRESS
    FROM TmpGatePass g, TmpDepartment d
   WHERE g.CREATED_BY = d.User_ID
ORDER BY g.SL_NO