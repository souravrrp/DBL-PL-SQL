/* Formatted on 11/1/2020 5:55:35 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_mo_acct_cor_pkg
IS
   PROCEDURE upload_data_stg_tbl (ERRBUF OUT VARCHAR2, RETCODE OUT VARCHAR2);

   PROCEDURE import_data_from_web_adi (p_transaction_id       NUMBER,
                                       p_corrected_gl_code    VARCHAR2);

   PROCEDURE mo_acct_corretion_procedure (p_trx_id NUMBER);

   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
END xxdbl_mo_acct_cor_pkg;
/