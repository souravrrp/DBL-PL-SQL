/* Formatted on 12/28/2021 4:06:07 PM (QP5 v5.374) */
SELECT COUNT (*)
  FROM wf_notifications
 WHERE mail_status = 'MAIL' AND status = 'OPEN';

SELECT *
  FROM wf_notifications
 WHERE status = 'OPEN' AND mail_status = 'SENT';

SELECT *
  FROM wf_notifications
 WHERE status = 'OPEN' AND mail_status = 'FAILED';