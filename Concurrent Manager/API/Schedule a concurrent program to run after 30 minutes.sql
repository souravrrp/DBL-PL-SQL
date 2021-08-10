/* Formatted on 8/8/2020 12:30:10 PM (QP5 v5.287) */
/*********************************************************
*PURPOSE: To Submit a Concurrent Request from backend    *
*AUTHOR: Sourav Paul                            *
**********************************************************/
--

DECLARE
   l_responsibility_id   NUMBER;
   l_application_id      NUMBER;
   l_user_id             NUMBER;
   l_request_id          NUMBER;
BEGIN
   --
   SELECT DISTINCT fr.responsibility_id, frx.application_id
     INTO l_responsibility_id, l_application_id
     FROM apps.fnd_responsibility frx, apps.fnd_responsibility_tl fr
    WHERE     fr.responsibility_id = frx.responsibility_id
          AND LOWER (fr.responsibility_name) LIKE LOWER ('XXTest Resp');

   --
   SELECT user_id
     INTO l_user_id
     FROM fnd_user
    WHERE user_name = 'STHALLAM';

   --
   --To set environment context.
   --
   apps.fnd_global.apps_initialize (l_user_id,
                                    l_responsibility_id,
                                    l_application_id);
   --
   --Submitting Concurrent Request
   --
   l_request_id :=
      fnd_request.submit_request (
         application   => 'XXCUST',
         program       => 'XXEMP',
         description   => 'XXTest Employee Details',
         start_time    => TO_CHAR (SYSDATE + 30 / 1440,
                                   'DD-MON-YYYY HH24:MI:SS'),
         sub_request   => FALSE,
         argument1     => 'Smith');
   --
   COMMIT;

   --
   IF l_request_id = 0
   THEN
      DBMS_OUTPUT.put_line ('Concurrent request failed to submit');
   ELSE
      DBMS_OUTPUT.put_line ('Successfully Submitted the Concurrent Request');
   END IF;
--
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (
            'Error While Submitting Concurrent Request '
         || TO_CHAR (SQLCODE)
         || '-'
         || SQLERRM);
END;
/

--------------stop program------------------
UPDATE fnd_concurrent_requests
SET phase_code = 'C', status_code = 'X'
WHERE status_code IN ('Q','I')
AND requested_start_date > SYSDATE
AND hold_flag = 'N'
AND CONCURRENT_PROGRAM_ID=&P_CONCURRENT_PROGRAM_ID;

COMMIT;


