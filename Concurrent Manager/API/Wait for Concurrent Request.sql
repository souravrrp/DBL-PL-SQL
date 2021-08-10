/* Formatted on 7/16/2020 12:23:43 PM (QP5 v5.287) */
DECLARE
   --
   -- +=========================================================================
   -- | Purpose : How to make a Concurrent Program WAIT till completion another Concurrent Program execution?
   -- | Author  : Shailender Thallam
   -- +=========================================================================
   --
   lv_request_id         NUMBER;
   lc_phase              VARCHAR2 (50);
   lc_status             VARCHAR2 (50);
   lc_dev_phase          VARCHAR2 (50);
   lc_dev_status         VARCHAR2 (50);
   lc_message            VARCHAR2 (50);
   l_req_return_status   BOOLEAN;
BEGIN
   --
   --Setting Context
   --
   fnd_global.apps_initialize (
      user_id             => fnd_profile.VALUE ('USER_ID'),
      resp_id             => fnd_profile.VALUE ('RESP_ID'),
      resp_appl_id        => fnd_profile.VALUE ('RESP_APPL_ID'),
      security_group_id   => 0);
   --
   -- Submitting XX_PROGRAM_1;
   --
   lv_request_id :=
      fnd_request.submit_request (application   => 'XXCUST',
                                  program       => 'XX_PROGRAM_1',
                                  description   => 'XX_PROGRAM_1',
                                  start_time    => SYSDATE,
                                  sub_request   => FALSE);
   COMMIT;

   IF lv_request_id = 0
   THEN
      DBMS_OUTPUT.put_line (
         'Request Not Submitted due to "' || fnd_message.get || '".');
   ELSE
      DBMS_OUTPUT.put_line (
            'The Program PROGRAM_1 submitted successfully – Request id :'
         || lv_request_id);
   END IF;

   IF lv_request_id > 0
   THEN
      LOOP
         --
         --To make process execution to wait for 1st program to complete
         --
         l_req_return_status :=
            fnd_concurrent.wait_for_request (request_id   => lv_request_id,
                                             interval     => 5 --interval Number of seconds to wait between checks
                                                              ,
                                             max_wait     => 60 --Maximum number of seconds to wait for the request completion
                                                               -- out arguments
                                             ,
                                             phase        => lc_phase,
                                             status       => lc_status,
                                             dev_phase    => lc_dev_phase,
                                             dev_status   => lc_dev_status,
                                             MESSAGE      => lc_message);
         EXIT WHEN    UPPER (lc_phase) = 'COMPLETED'
                   OR UPPER (lc_status) IN
                         ('CANCELLED', 'ERROR', 'TERMINATED');
      END LOOP;

      --
      --
      IF UPPER (lc_phase) = 'COMPLETED' AND UPPER (lc_status) = 'ERROR'
      THEN
         DBMS_OUTPUT.put_line (
               'The XX_PROGRAM_1 completed in error. Oracle request id: '
            || lv_request_id
            || ' '
            || SQLERRM);
      ELSIF UPPER (lc_phase) = 'COMPLETED' AND UPPER (lc_status) = 'NORMAL'
      THEN
         DBMS_OUTPUT.put_line (
               'The XX_PROGRAM_1 request successful for request id: '
            || lv_request_id);

         --
         --Submitting Second Concurrent Program XX_PROGRAM_2
         --
         BEGIN
            --
            lv_request_id :=
               fnd_request.submit_request (application   => 'XXCUST',
                                           program       => 'XX_PROGRAM_2',
                                           description   => 'XX_PROGRAM_2',
                                           start_time    => SYSDATE,
                                           sub_request   => FALSE);
            --
            COMMIT;
         --
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (
                     'OTHERS exception while submitting XX_PROGRAM_2: '
                  || SQLERRM);
         END;
      ELSE
         DBMS_OUTPUT.put_line (
               'The XX_PROGRAM_1 request failed. Oracle request id: '
            || lv_request_id
            || ' '
            || SQLERRM);
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (
         'OTHERS exception while submitting XX_PROGRAM_1: ' || SQLERRM);
END;



---------------------------------------------------------------------------------------------------

BEGIN
         FND_GLOBAL.APPS_INITIALIZE (2793, 20634, 401);
         MO_GLOBAL.SET_POLICY_CONTEXT ('S', '138');
         FND_GLOBAL.SET_NLS_CONTEXT ('AMERICAN');
         MO_GLOBAL.INIT ('INV');

         fnd_file.put_line (fnd_file.LOG,
                            '--Submitting Item Import Program for Item--');


         v_request_id :=
            Fnd_Request.submit_request (application   => 'INV',
                                        Program       => 'INCOIN',
                                        description   => NULL,
                                        start_time    => SYSDATE,
                                        sub_request   => FALSE,
                                        argument1     => 138,
                                        argument2     => 1,
                                        argument3     => 1, --Group ID option (All)
                                        argument4     => 1,  -- Group ID Dummy
                                        argument5     => 1, -- Delete processed Record
                                        argument6     => vl_set_process_id, -- Set Process id
                                        argument7     => 1      -- Update item
                                                          );
         COMMIT;

         IF (v_request_id = 0)
         THEN
            DBMS_OUTPUT.put_line ('Item Import Program Not Submitted');
            v_sub_status := FALSE;
         ELSE
            v_finished :=
               fnd_concurrent.wait_for_request (
                  request_id   => v_request_id,
                  interval     => 60,
                  max_wait     => 0,
                  phase        => v_phase,
                  status       => v_status,
                  dev_phase    => v_request_phase,
                  dev_status   => v_request_status,
                  MESSAGE      => v_message);
            COMMIT;


            DBMS_OUTPUT.PUT_LINE ('Request Phase  : ' || v_request_phase);
            DBMS_OUTPUT.PUT_LINE ('Request Status : ' || v_request_status);
            DBMS_OUTPUT.PUT_LINE ('Request id     : ' || v_request_id);

            --Testing end statusv_request_id
            IF (UPPER (v_request_status) = 'NORMAL' AND UPPER (v_request_phase) = 'COMPLETED')
            THEN
               L_Retcode := check_error_log_to_assign_data;
               DBMS_OUTPUT.PUT_LINE ('Item Import Status: Sucessful');
            --ELSE
            --DBMS_OUTPUT.PUT_LINE ('Item Import Status: Failed');
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  'Error in Submitting Item Import Program and error is '
               || SUBSTR (SQLERRM, 1, 200));
      END;
      
      ------------------------------------------------------------------------------------------------