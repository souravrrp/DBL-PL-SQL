/* Formatted on 11/20/2021 4:01:23 PM (QP5 v5.365) */
PROCEDURE VALIDATE_INVOICE_TRACKING
IS
BEGIN
    IF :XXDBL_INVOICE_TRACKING_SYSTEM.OPERATING_UNIT_NAME IS NOT NULL
    THEN
        BEGIN
            :XXDBL_INVOICE_TRACKING_SYSTEM.RECEIVED_DATE := SYSDATE;
            :XXDBL_INVOICE_TRACKING_SYSTEM.INVOICE_STATUS := 'NEW';

            :XXDBL_INVOICE_TRACKING_SYSTEM.CREATED_BY := fnd_global.user_id;
            :XXDBL_INVOICE_TRACKING_SYSTEM.CREATION_DATE := SYSDATE;
            :XXDBL_INVOICE_TRACKING_SYSTEM.LAST_UPDATED_BY :=
                fnd_global.user_id;
            :XXDBL_INVOICE_TRACKING_SYSTEM.LAST_UPDATE_DATE := SYSDATE;
        END;

        BEGIN
            SELECT    (UPPER (
                           TRIM (
                                  papf.first_name
                               || ' '
                               || papf.middle_names
                               || ' '
                               || papf.last_name)))
                   || ', ID-'
                   || papf.employee_number    AS full_name
              INTO :XXDBL_INVOICE_TRACKING_SYSTEM.DISPATCH_BY
              FROM fnd_user                        ppf,
                   apps.per_people_f               papf,
                   per_all_assignments_f           paaf,
                   apps.hr_all_organization_units  haou,
                   apps.per_jobs                   pj
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
                   AND ppf.user_id = fnd_global.user_id;
        END;

        BEGIN
            SELECT    (UPPER (
                           TRIM (
                                  papf.first_name
                               || ' '
                               || papf.middle_names
                               || ' '
                               || papf.last_name)))
                   || ', ID-'
                   || papf.employee_number                            AS full_name,
                   (SUBSTR (pj.NAME, 1, INSTR (pj.NAME, '.') - 1))    JOB_CATEGORY
              INTO :XXDBL_INVOICE_TRACKING_SYSTEM.PROCESS_BY,
                   :XXDBL_INVOICE_TRACKING_SYSTEM.PROCESS_DEPARTMENT
              FROM fnd_user                        ppf,
                   apps.per_people_f               papf,
                   per_all_assignments_f           paaf,
                   apps.hr_all_organization_units  haou,
                   apps.per_jobs                   pj
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
                   AND ppf.user_id = fnd_global.user_id;
        END;
    END IF;
END;