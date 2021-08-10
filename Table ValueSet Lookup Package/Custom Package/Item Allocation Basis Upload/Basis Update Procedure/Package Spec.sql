/* Formatted on 8/27/2020 10:49:52 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.XXDBL_ITEM_ALLOC_BASIS_PKG
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;

   PROCEDURE item_basis_upd (ERRBUF       OUT NOCOPY NUMBER,
                             RETCODE      OUT NOCOPY VARCHAR2);

   PROCEDURE gl_aloc_basis_proc;
END XXDBL_ITEM_ALLOC_BASIS_PKG;
/