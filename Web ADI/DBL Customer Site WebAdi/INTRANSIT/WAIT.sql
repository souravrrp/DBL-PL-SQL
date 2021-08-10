/* Formatted on 5/19/2021 3:45:20 PM (QP5 v5.287) */
/**************************************************************************
 *    PURPOSE: To find out information about a Concurrent Request         *
 **************************************************************************/

SELECT fcrs.request_id
  FROM fnd_conc_req_summary_v fcrs
 WHERE fcrs.program_short_name = 'ARHDQMSS';

SELECT fcrs.request_id
  FROM fnd_conc_req_summary_v fcrs, apps.fnd_user fu
 WHERE     fcrs.requestor = FU.USER_NAME
       AND FU.USER_ID = p_user_id
       AND fcrs.program_short_name = 'ARHDQMSS'
       AND fcrs.phase_code IN ('P', 'R');



/**************************************************************************
 *    PURPOSE: To find out information about a Concurrent Request         *
 **************************************************************************/

  SELECT fcrs.request_id, fcrs.responsibility_id
    --,fcrs.*
    FROM fnd_conc_req_summary_v fcrs, apps.fnd_user fu
   WHERE     fcrs.request_id = 18497663
         AND fcrs.responsibility_id = 50191
         AND fcrs.requestor = FU.USER_NAME
         AND fcrs.program_short_name = 'ARHDQMSS'
--AND FU.USER_ID=p_user_id
--and fcrs.phase_code = 'R'
ORDER BY fcrs.actual_start_date DESC;


BEGIN
   SELECT fcrs.request_id
     INTO ln_req_id
     FROM fnd_conc_req_summary_v fcrs
    WHERE     fcrs.program_short_name = 'ARHDQMSS'
          AND fcrs.phase_code IN ('P', 'R');

   IF ln_req_id > 0
   THEN
      LOOP
         lv_req_return_status :=
            fnd_concurrent.wait_for_request (ln_req_id,
                                             60,
                                             0,
                                             lv_req_phase,
                                             lv_req_status,
                                             lv_req_dev_phase,
                                             lv_req_dev_status,
                                             lv_req_message);
         EXIT WHEN    UPPER (lv_req_phase) = 'COMPLETED'
                   OR UPPER (lv_req_status) IN
                         ('CANCELLED', 'ERROR', 'TERMINATED');
      END LOOP;

      DBMS_OUTPUT.PUT_LINE ('Request Phase  : ' || lv_req_dev_phase);
      DBMS_OUTPUT.PUT_LINE ('Request Status : ' || lv_req_dev_status);
      DBMS_OUTPUT.PUT_LINE ('Request id     : ' || ln_req_id);
      Fnd_File.PUT_LINE (
         Fnd_File.LOG,
         'The Customer Site Program Completion Phase: ' || lv_req_dev_phase);
      Fnd_File.PUT_LINE (
         Fnd_File.LOG,
         'The Customer Site Program Completion Status: ' || lv_req_dev_status);

      CASE
         WHEN     UPPER (lv_req_phase) = 'COMPLETED'
              AND UPPER (lv_req_status) = 'ERROR'
         THEN
            fnd_file.put_line (
               fnd_file.LOG,
               'The Customer Site prog completed in error. See log for request id');
            fnd_file.put_line (fnd_file.LOG, SQLERRM);
         WHEN    (    UPPER (lv_req_phase) = 'COMPLETED'
                  AND UPPER (lv_req_status) = 'NORMAL')
              OR (    UPPER (lv_req_phase) = 'COMPLETED'
                  AND UPPER (lv_req_status) = 'WARNING')
         THEN
            BEGIN
               l_return_val :=
                  create_customer_site_contact (p_cust_id, ln_party_site_id);
               Fnd_File.PUT_LINE (
                  Fnd_File.LOG,
                     'The contact successfully Assigned to the respected Customer site for request id: '
                  || ln_req_id);
            END;

            Fnd_File.PUT_LINE (
               Fnd_File.LOG,
                  'The Customer Site successfully completed for request id: '
               || ln_req_id);
         ELSE
            Fnd_File.PUT_LINE (
               Fnd_File.LOG,
               'The Customer Site request failed.Review log for Oracle request id ');
            Fnd_File.PUT_LINE (Fnd_File.LOG, SQLERRM);
      END CASE;
   END IF;
END;