CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_CUSTOM_WORKFLOW
IS
   PROCEDURE XXDBL_REQNOTIFTOBUYER (ERRBUF    OUT VARCHAR2,
                                    RETCODE   OUT VARCHAR2)
   IS
      l_itemtype    VARCHAR2 (10) := 'TEST_BPM';
      l_process     VARCHAR2 (80) := 'TEST_MESSAGE';
      l_itemkey     VARCHAR2 (20);                     --this should be unique
      l_user_key    VARCHAR2 (20) := '5958';
      l_file_name   VARCHAR2 (100) := 'DBL_PR.xls';
      l_file_id     NUMBER;

      CURSOR c1
      IS
         SELECT DISTINCT user_name, segment1
           FROM (SELECT prha.segment1,
                        prha.preparer_id,
                        prha.authorization_status,
                        FU.USER_NAME
                   FROM po_requisition_headers_all prha,
                        po_requisition_lines_all prla,
                        FND_USER FU
                  WHERE     prha.requisition_header_id =
                               prla.requisition_header_id
                        AND prha.authorization_status = 'APPROVED'
                        AND FU.EMPLOYEE_ID = prla.suggested_buyer_id
                        --AND FU.USER_NAME = '103762'
                        --AND prha.segment1 = '25111002544'
                        AND FU.USER_NAME = '100151'
                        AND prha.segment1 = '15511000040' --AND prha.last_update_date >= SYSDATE - INTERVAL '10' MINUTE);
                                                         --AND prha.last_update_date >= SYSDATE
                );
   --v_seq_no     NUMBER (10);
   BEGIN
      FOR i IN c1
      LOOP
         SELECT APPS.XXDBLREQAPPSEQ_S.NEXTVAL || '-XXTEST'
           INTO l_itemkey
           FROM DUAL;

         wf_engine.createprocess (itemtype     => l_itemtype,
                                  itemkey      => l_itemkey,
                                  process      => l_process,
                                  user_key     => l_user_key,
                                  owner_role   => 'SYSADMIN');

         wf_engine.setitemattrtext (itemtype   => l_itemtype,
                                    itemkey    => l_itemkey,
                                    aname      => 'XX_ROLE',
                                    avalue     => i.user_name --Recipient user name
                                                             );

         wf_engine.setitemattrtext (itemtype   => l_itemtype,
                                    itemkey    => l_itemkey,
                                    aname      => 'XX_MSG',
                                    avalue     => 'IT-BPM');

         wf_engine.setitemattrdocument (
            itemtype     => l_itemtype,
            itemkey      => l_itemkey,
            aname        => 'ATTACHMENT',
            documentid   =>    'PLSQLBLOB:XXDBL_CUSTOM_WORKFLOW.xxdbl_notif_attach_procedure/'
                            || l_file_id                         --l_file_name
                                        );

         wf_engine.startprocess (itemtype => l_itemtype, itemkey => l_itemkey);
      --v_seq_no := 0;
      END LOOP;

      -- Return 0 for successful completion.
      errbuf := '';
      retcode := '0';
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         errbuf := 'Error';
         retcode := '2';
   END XXDBL_REQNOTIFTOBUYER;

   PROCEDURE XXDBL_NOTIF_ATTACH_PROCEDURE (document_id     IN     VARCHAR2,
                                           display_type    IN     VARCHAR2,
                                           document        IN OUT BLOB,
                                           document_type   IN OUT VARCHAR2) --document_type   IN OUT VARCHAR2
   IS
      l_file_name    VARCHAR2 (100) := document_id;
      lob_id         NUMBER;
      bdoc           BLOB;
      content_type   VARCHAR2 (100);
      filename       VARCHAR2 (300);
   BEGIN
      --document_type := 'Excel' || ';name=' || l_file_name;
      lob_id := TO_NUMBER (document_id);
      Fnd_File.PUT_LINE (
         Fnd_File.LOG,
            'The Document has successfully created for workflow. Document Type : '
         || lob_id);

      -- Obtain the BLOB version of the document
      SELECT file_name, file_content_type, file_data
        INTO filename, content_type, bdoc
        FROM fnd_lobs
       WHERE file_id = lob_id;

      document_type := content_type || ';name=' || filename;
      DBMS_LOB.COPY (document, bdoc, DBMS_LOB.getlength (bdoc));
      Fnd_File.PUT_LINE (
         Fnd_File.LOG,
            'The Document has successfully created for workflow. Document Type : '
         || document_type);
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT ('XXDBL_CUSTOM_WORKFLOW',
                          'XXDBL_NOTIF_ATTACH_PROCEDURE',
                          'document_id',
                          'display_type');
         RAISE;
   END;
END XXDBL_CUSTOM_WORKFLOW;
/