/* Formatted on 8/16/2020 11:10:07 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_om_sms_delivery_pkg
IS
   PROCEDURE upload_data_to_sms_stg_tbl (ERRBUF          OUT VARCHAR2,
                                         RETCODE         OUT VARCHAR2,
                                         SMS_TYPE_NAME       VARCHAR2);

   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;


   PROCEDURE om_sms_response_into_stg_tbl (sms_text    VARCHAR2,
                                           ord_no      NUMBER,
                                           phone_no    VARCHAR2,
                                           L_RETURN  OUT  NUMBER);
END xxdbl_om_sms_delivery_pkg;
/