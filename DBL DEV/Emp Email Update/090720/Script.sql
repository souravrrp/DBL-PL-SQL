/* Formatted on 6/16/2021 5:44:49 PM (QP5 v5.287) */
DECLARE
   -- Local Variables
   -- -----------------------
   ln_object_version_number      PER_ALL_PEOPLE_F.OBJECT_VERSION_NUMBER%TYPE
                                    := 8;
   lc_dt_ud_mode                 VARCHAR2 (100) := NULL;
   ln_assignment_id              PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE := 730;
   lc_employee_number            PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE
                                    := '100497';

   -- Out Variables for Find Date Track Mode API
   -- ----------------------------------------------------------------
   lb_correction                 BOOLEAN;
   lb_update                     BOOLEAN;
   lb_update_override            BOOLEAN;
   lb_update_change_insert       BOOLEAN;

   -- Out Variables for Update Employee API
   -- -----------------------------------------------------------
   ld_effective_start_date       DATE;
   ld_effective_end_date         DATE;
   lc_full_name                  PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
   ln_comment_id                 PER_ALL_PEOPLE_F.COMMENT_ID%TYPE;
   lb_name_combination_warning   BOOLEAN;
   lb_assign_payroll_warning     BOOLEAN;
   lb_orig_hire_warning          BOOLEAN;
BEGIN
   -- Find Date Track Mode
   -- --------------------------------
   dt_api.find_dt_upd_modes (                           -- Input Data Elements
      -- ------------------------------
      p_effective_date         => TO_DATE ('16-JUN-2021'),
      p_base_table_name        => 'PER_ALL_ASSIGNMENTS_F',
      p_base_key_column        => 'ASSIGNMENT_ID',
      p_base_key_value         => ln_assignment_id,
      -- Output data elements
      -- -------------------------------
      p_correction             => lb_correction,
      p_update                 => lb_update,
      p_update_override        => lb_update_override,
      p_update_change_insert   => lb_update_change_insert);

   IF (lb_update_override = TRUE OR lb_update_change_insert = TRUE)
   THEN
      -- UPDATE_OVERRIDE
      -- ---------------------------------
      lc_dt_ud_mode := 'UPDATE_OVERRIDE';
   END IF;

   IF (lb_correction = TRUE)
   THEN
      -- CORRECTION
      -- ----------------------
      lc_dt_ud_mode := 'CORRECTION';
   END IF;

   IF (lb_update = TRUE)
   THEN
      -- UPDATE
      -- --------------
      lc_dt_ud_mode := 'UPDATE';
   END IF;

   -- Update Employee API
   -- ---------------------------------
   hr_person_api.update_person (                        -- Input Data Elements
      -- ------------------------------
      p_effective_date             => TO_DATE ('29-JUN-2021'),
      p_datetrack_update_mode      => lc_dt_ud_mode,
      p_person_id                  => 730,
      p_email_address              => 'abcmizan@dbl-ez.com',
      --p_middle_names               => 'TEST',
      --p_marital_status             => 'M',
      -- Output Data Elements
      -- ----------------------------------
      p_employee_number            => lc_employee_number,
      p_object_version_number      => ln_object_version_number,
      p_effective_start_date       => ld_effective_start_date,
      p_effective_end_date         => ld_effective_end_date,
      p_full_name                  => lc_full_name,
      p_comment_id                 => ln_comment_id,
      p_name_combination_warning   => lb_name_combination_warning,
      p_assign_payroll_warning     => lb_assign_payroll_warning,
      p_orig_hire_warning          => lb_orig_hire_warning);

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      DBMS_OUTPUT.put_line (SQLERRM);
END;
/

SHOW ERR;