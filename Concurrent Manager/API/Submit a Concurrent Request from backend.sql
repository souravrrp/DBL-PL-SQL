/*********************************************************
*PURPOSE: To Submit a Concurrent Request from backend    *
*AUTHOR: Shailender Thallam                              *
**********************************************************/
--
DECLARE
l_responsibility_id 	NUMBER;
l_application_id    	NUMBER;
l_user_id           	NUMBER;
l_request_id            NUMBER;
BEGIN
  --
  SELECT DISTINCT fr.responsibility_id,
    frx.application_id
     INTO l_responsibility_id,
    l_application_id
     FROM apps.fnd_responsibility frx,
    apps.fnd_responsibility_tl fr
    WHERE fr.responsibility_id = frx.responsibility_id
  AND lower (fr.responsibility_name) LIKE lower('XXTest Resp');
  --
   SELECT user_id INTO l_user_id FROM fnd_user WHERE user_name = 'STHALLAM';
  --
  --To set environment context.
  --
  apps.fnd_global.apps_initialize (l_user_id,l_responsibility_id,l_application_id);
  --
  --Submitting Concurrent Request
  --
  l_request_id := fnd_request.submit_request ( 
                            application   => 'XXCUST', 
                            program       => 'XXEMP', 
                            description   => 'XXTest Employee Details', 
                            start_time    => sysdate, 
                            sub_request   => false,
			    argument1     => 'Smith'
  );
  --
  COMMIT;
  --
  IF l_request_id = 0
  THEN
     dbms_output.put_line ('Concurrent request failed to submit');
  ELSE
     dbms_output.put_line('Successfully Submitted the Concurrent Request');
  END IF;
  --
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line('Error While Submitting Concurrent Request '||TO_CHAR(SQLCODE)||'-'||sqlerrm);
END;
/