/* Formatted on 10/11/2020 3:11:18 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.XXDBL_CER_ITEM_UPLD_PKG
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;

   PROCEDURE item_basis_upd (ERRBUF       OUT NOCOPY NUMBER,
                             RETCODE      OUT NOCOPY VARCHAR2);

   PROCEDURE gl_aloc_basis_proc;

   PROCEDURE formula_upload_prc (errbuf              OUT VARCHAR2,
                                 retcode             OUT NUMBER,
                                 p_batch_number   IN     NUMBER);
END XXDBL_CER_ITEM_UPLD_PKG;
/