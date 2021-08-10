/* Formatted on 8/18/2020 11:54:06 AM (QP5 v5.287) */
DECLARE
   CURSOR cur
   IS
      SELECT msi.INVENTORY_ITEM_ID,
             msi.segment1,
             msi.attribute28,
             msi.attribute29,
             clog.INVENTORY_ITEM_ID old_INVENTORY_ITEM_ID,
             clog.ELEMENT_NAME,
             clog.ELEMENT_VALUE,
             clog.ELEMENT_SEQUENCE
        FROM (SELECT INVENTORY_ITEM_ID,
                     segment1,
                     attribute28,
                     attribute29
                FROM mtl_system_items
               WHERE     ORGANIZATION_ID = 101
                     AND attribute30 = 'Y'
                     AND attribute29 IS NOT NULL) msi,
             MTL_DESCR_ELEMENT_VALUES clog
       WHERE msi.attribute29 = clog.INVENTORY_ITEM_ID;

   rec_init          mtl_desc_elem_val_interface%ROWTYPE;
   rec_imp           mtl_desc_elem_val_interface%ROWTYPE;
   vset_process_id   NUMBER := 1694;
   vprocess_flag     NUMBER := 1;
   vupd_by           NUMBER := 3314;
   x_errbuf          VARCHAR2 (200) := NULL;
   x_retcode         NUMBER := NULL;
BEGIN
   FOR rec IN cur
   LOOP
      rec_imp := rec_init;
      rec_imp.INVENTORY_ITEM_ID := rec.INVENTORY_ITEM_ID;
      rec_imp.ELEMENT_NAME := rec.ELEMENT_NAME;
      rec_imp.ELEMENT_VALUE := rec.ELEMENT_VALUE;
      rec_imp.ELEMENT_SEQUENCE := rec.ELEMENT_SEQUENCE;
      rec_imp.PROCESS_FLAG := vprocess_flag;
      rec_imp.SET_PROCESS_ID := vset_process_id;
      rec_imp.LAST_UPDATED_BY := vupd_by;

      INSERT INTO mtl_desc_elem_val_interface
           VALUES rec_imp;
   END LOOP;

   COMMIT;

   inv_item_catalog_elem_pub.process_item_catalog_grp_recs (
      errbuf              => x_errbuf,
      retcode             => x_retcode,
      p_rec_set_id        => vset_process_id,
      p_upload_rec_flag   => 1,
      p_delete_rec_flag   => 1,
      p_commit_flag       => 1,
      p_prog_appid        => NULL,
      p_prog_id           => NULL,
      p_request_id        => NULL,
      p_user_id           => NULL,
      p_login_id          => NULL);
   DBMS_OUTPUT.put_line (x_errbuf);
   DBMS_OUTPUT.put_line (TO_CHAR (x_retcode));

   COMMIT;
END;