CREATE OR REPLACE PACKAGE APPS.xxdbl_email_delivery_pkg
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
   p_login_id            NUMBER := apps.fnd_global.login_id;


   PROCEDURE iou_email_status_update (p_mail_status    VARCHAR2,
                                      p_iou_req_id     NUMBER);
END xxdbl_email_delivery_pkg;
/