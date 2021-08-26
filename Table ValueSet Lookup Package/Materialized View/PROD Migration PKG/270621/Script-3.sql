/* Formatted on 6/22/2021 10:12:01 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_mview_dtld_pkg
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
   p_login_id            NUMBER := apps.fnd_global.login_id;

   PROCEDURE run_mview_dataload_conc (ERRBUF    OUT VARCHAR2,
                                      RETCODE   OUT VARCHAR2);

   PROCEDURE run_mview_dataload_proc;
END xxdbl_mview_dtld_pkg;
/