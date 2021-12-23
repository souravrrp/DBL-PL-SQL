CREATE OR REPLACE PACKAGE APPS.xxdbl_om_sms_delivery_pkg
IS
    PROCEDURE upload_data_to_sms_stg_tbl (ERRBUF    OUT VARCHAR2,
                                          RETCODE   OUT VARCHAR2);

    p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
    p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
    p_user_id             NUMBER := apps.fnd_global.user_id;
    p_org_id              NUMBER := apps.fnd_global.org_id;
END xxdbl_om_sms_delivery_pkg;
/