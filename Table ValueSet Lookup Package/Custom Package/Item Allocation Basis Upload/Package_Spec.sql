/* Formatted on 11/8/2020 9:45:20 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE apps.xxdbl_cer_item_upld_pkg
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;

   PROCEDURE item_basis_upd (errbuf       OUT NOCOPY NUMBER,
                             retcode      OUT NOCOPY VARCHAR2);

   PROCEDURE gl_aloc_basis_proc;

   PROCEDURE recp_rout_procedure (p_formula_no    IN     VARCHAR2,
                                  x_out_message      OUT VARCHAR2);

   PROCEDURE formula_upload_prc (errbuf              OUT VARCHAR2,
                                 retcode             OUT NUMBER,
                                 p_batch_number   IN     NUMBER);
END xxdbl_cer_item_upld_pkg;
/