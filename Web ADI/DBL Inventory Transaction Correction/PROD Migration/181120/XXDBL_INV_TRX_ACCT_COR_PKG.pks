CREATE OR REPLACE PACKAGE APPS.xxdbl_inv_trx_acct_cor_pkg
IS
   PROCEDURE mo_acct_corretion_procedure (p_trx_id NUMBER);

   PROCEDURE import_data_from_web_adi (p_correction_type      VARCHAR2,
                                       p_transaction_id       NUMBER,
                                       p_corrected_gl_code    VARCHAR2);

   PROCEDURE po_account_cor_procedure (l_org_id        NUMBER,
                                       l_po_hdr_id     NUMBER,
                                       l_po_ln_id      NUMBER,
                                       l_po_dist_id    NUMBER);

   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
END xxdbl_inv_trx_acct_cor_pkg;
/