/* Formatted on 1/5/2022 10:24:17 AM (QP5 v5.374) */
---------------------------------*****WORKFLOW MAILER STATUS****----------------

SELECT component_status
  FROM apps.fnd_svc_components
 WHERE component_name = 'Workflow Notification Mailer';

---------------------------------*****WORKFLOW PENDING EMAIL****----------------

SELECT COUNT (*)
  FROM wf_notifications
 WHERE mail_status = 'MAIL' AND status = 'OPEN';

---------------------------------*******************************----------------
SELECT *
  FROM wf_notifications
 WHERE status = 'OPEN' AND mail_status = 'SENT';

SELECT *
  FROM wf_notifications
 WHERE status = 'OPEN' AND mail_status = 'FAILED';