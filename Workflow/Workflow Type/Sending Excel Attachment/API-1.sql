/* Formatted on 7/18/2020 9:42:44 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY RCT_EXAMPLE
IS
   PROCEDURE start_training_wf (unique_id IN VARCHAR2)
   IS
      l_itemtype    VARCHAR2 (30) := 'RCT_ITM1';
      l_itemkey     VARCHAR2 (300);
      l_file_name   VARCHAR2 (100) := 'holidaylist.xls';
      l_unique_id   VARCHAR2 (50) := unique_id;
   BEGIN
      l_itemkey := 'RCT_ITM1 ' || TO_CHAR (SYSDATE, 'dd/mm/yyhh:mm:ss');
      wf_engine.createprocess (l_itemtype, l_itemkey, 'RCT_PROCESS');
      wf_engine.setitemattrdocument (
         itemtype     => l_itemtype,
         itemkey      => l_itemkey,
         aname        => 'ATTACHMENT2',
         documentid   =>    'PLSQLBLOB:RCT_EXAMPLE.xx_notif_attach_procedure/'
                         || l_file_name);
      wf_engine.startprocess (l_itemtype, l_itemkey);
   END;


   PROCEDURE xx_notif_attach_procedure (document_id     IN     VARCHAR2,
                                        display_type    IN     VARCHAR2,
                                        document        IN OUT BLOB,
                                        document_type      OUT VARCHAR2) --document_type   IN OUT VARCHAR2
   IS
      l_file_name   VARCHAR2 (100) := document_id;
      bdoc          BLOB;
   BEGIN
      document_type := 'Excel' || ';name=' || l_file_name;

      SELECT stored_file
        INTO bdoc
        FROM BLOB_TABLE
       WHERE file_name = l_file_name;

      DBMS_LOB.COPY (document, bdoc, DBMS_LOB.getlength (bdoc));
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT ('xx_g4g_package',
                          'xx_notif_attach_procedure',
                          'document_id',
                          'display_type');
         RAISE;
   END;
END RCT_EXAMPLE;