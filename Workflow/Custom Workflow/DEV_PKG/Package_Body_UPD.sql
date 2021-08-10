/* Formatted on 10/6/2020 10:17:05 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_CUSTOM_WORKFLOW
IS
   PROCEDURE XXDBL_REQNOTIFTOBUYER (ERRBUF    OUT VARCHAR2,
                                    RETCODE   OUT VARCHAR2)
   IS
      CURSOR cur_name
      IS
         SELECT DISTINCT user_name
           FROM (SELECT hou.name,
                        ou.legal_entity_name,
                        prha.segment1,
                        prha.description,
                        prha.preparer_id,
                        prha.authorization_status,
                        TO_CHAR (fu.user_name) user_name,
                        (   ppf.first_name
                         || ' '
                         || ppf.middle_names
                         || ' '
                         || ppf.last_name)
                           requestor_name
                   FROM po_requisition_headers_all prha,
                        apps.hr_operating_units hou,
                        xxdbl_company_le_mapping_v ou,
                        po_requisition_lines_all prla,
                        fnd_user fu,
                        apps.per_all_people_f ppf
                  WHERE     prha.requisition_header_id =
                               prla.requisition_header_id
                        AND prha.authorization_status = 'APPROVED'
                        AND fu.employee_id = prla.suggested_buyer_id
                        AND prha.preparer_id = ppf.person_id(+)
                        AND hou.organization_id = prha.org_id
                        AND hou.organization_id = ou.org_id
                        AND prha.segment1 IN ('15311000316', '10321000530'));
   BEGIN
      FOR cur_rec_name IN cur_name
      LOOP
         BEGIN
            NOTIFICATION_TO_BUYER (cur_rec_name.user_name);
         END;
      END LOOP;

      errbuf := '';
      retcode := '0';
   EXCEPTION
      WHEN OTHERS
      THEN
         errbuf := 'Error';
         retcode := '2';
   END XXDBL_REQNOTIFTOBUYER;

   PROCEDURE NOTIFICATION_TO_BUYER (P_BUYER_NAME IN VARCHAR2)
   IS
      l_itemtype    VARCHAR2 (10) := 'TEST_BPM';
      l_process     VARCHAR2 (80) := 'TEST_MESSAGE';
      l_itemkey     VARCHAR2 (20);                     --this should be unique
      l_user_key    VARCHAR2 (20) := '5958';
      l_file_name   VARCHAR2 (100) := 'DBL_PR.xls';
      l_file_id     NUMBER;

      CURSOR c1
      IS
         SELECT DISTINCT name unit_name,
                         legal_entity_name,
                         user_name,
                         segment1 req_no,
                         description,
                         authorization_status requisition_status,
                         requestor_name buyer_name
           FROM (SELECT hou.name,
                        ou.legal_entity_name,
                        prha.segment1,
                        prha.description,
                        prha.preparer_id,
                        prha.authorization_status,
                        fu.user_name,
                        (   ppf.first_name
                         || ' '
                         || ppf.middle_names
                         || ' '
                         || ppf.last_name)
                           requestor_name
                   FROM po_requisition_headers_all prha,
                        apps.hr_operating_units hou,
                        xxdbl_company_le_mapping_v ou,
                        po_requisition_lines_all prla,
                        fnd_user fu,
                        apps.per_all_people_f ppf
                  WHERE     prha.requisition_header_id =
                               prla.requisition_header_id
                        AND prha.authorization_status = 'APPROVED'
                        AND fu.employee_id = prla.suggested_buyer_id
                        AND prha.preparer_id = ppf.person_id(+)
                        AND hou.organization_id = prha.org_id
                        AND hou.organization_id = ou.org_id
                        AND FU.USER_NAME = P_BUYER_NAME
                        --AND prha.segment1 = '25111002544'
                        --AND FU.USER_NAME = '100151'
                        --AND prha.segment1 = '10321006572'--'15511000040'
                        --AND prha.last_update_date >= SYSDATE - INTERVAL '10' MINUTE);
                        --AND prha.last_update_date >= SYSDATE
                        --AND prha.segment1 IN ('10321006572','10231000706')
                        AND prha.segment1 IN ('15311000316', '10321000530'));
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
                                    avalue     => i.req_no);

         -----------------------------------------------------------------------
         wf_engine.setitemattrtext (itemtype   => l_itemtype,
                                    itemkey    => l_itemkey,
                                    aname      => 'XX_UNIT',
                                    avalue     => i.unit_name);

         wf_engine.setitemattrtext (itemtype   => l_itemtype,
                                    itemkey    => l_itemkey,
                                    aname      => 'XX_BUYER',
                                    avalue     => i.buyer_name);

         wf_engine.setitemattrtext (itemtype   => l_itemtype,
                                    itemkey    => l_itemkey,
                                    aname      => 'XX_DESC',
                                    avalue     => i.description);



         wf_engine.startprocess (itemtype => l_itemtype, itemkey => l_itemkey);
      --v_seq_no := 0;
      END LOOP;

      -- Return 0 for successful completion.

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.put_line (
            fnd_file.LOG,
            'Error in getting Uer Name ' || SUBSTR (SQLERRM, 1, 200));
   END NOTIFICATION_TO_BUYER;
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
   END XXDBL_NOTIF_ATTACH_PROCEDURE;

   PROCEDURE xxdbl_create_wf_doc (document_id     IN            VARCHAR2,
                                  display_type    IN            VARCHAR2,
                                  document        IN OUT NOCOPY VARCHAR2,
                                  document_type   IN OUT NOCOPY VARCHAR2)
   IS
      lv_details   VARCHAR2 (32767);
      V_ITEMKEY    VARCHAR2 (100);
      amount       NUMBER;

      CURSOR cur
      IS
         SELECT DISTINCT name unit_name,
                         legal_entity_name,
                         user_name,
                         segment1 req_no,
                         description,
                         authorization_status requisition_status,
                         requestor_name buyer_name
           FROM (SELECT hou.name,
                        ou.legal_entity_name,
                        prha.segment1,
                        prha.description,
                        prha.preparer_id,
                        prha.authorization_status,
                        fu.user_name,
                        (   ppf.first_name
                         || ' '
                         || ppf.middle_names
                         || ' '
                         || ppf.last_name)
                           requestor_name
                   FROM po_requisition_headers_all prha,
                        apps.hr_operating_units hou,
                        xxdbl_company_le_mapping_v ou,
                        po_requisition_lines_all prla,
                        fnd_user fu,
                        apps.per_all_people_f ppf
                  WHERE     prha.requisition_header_id =
                               prla.requisition_header_id
                        AND prha.authorization_status = 'APPROVED'
                        AND fu.employee_id = prla.suggested_buyer_id
                        AND prha.preparer_id = ppf.person_id(+)
                        AND hou.organization_id = prha.org_id
                        AND hou.organization_id = ou.org_id
                        --AND FU.USER_NAME = '103762'
                        --AND prha.segment1 = '25111002544'
                        --AND FU.USER_NAME = '100151'
                        --AND prha.segment1 = '10321006572'--'15511000040'
                        --AND prha.last_update_date >= SYSDATE - INTERVAL '10' MINUTE);
                        --AND prha.last_update_date >= SYSDATE
                        --AND prha.segment1 IN ('10321006572','10231000706')
                        AND prha.segment1 IN ('15311000316', '10321000530'));
   BEGIN
      -----------------------------------------------------------------------
      /* TABLE HEADER*/
      lv_details :=
            lv_details
         || ' <H4> '
         || 'Purchase Requisition Number Information: '
         || '</H4>'
         || '<table border = "1"> <tr>'
         || '<th> '
         || 'Unit Name'
         || '</th>'
         || '<th>'
         || 'Requisition No'
         || '</th>'
         || '<th>'
         || 'Requisition Description'
         || '</th>'
         || '<th>'
         || 'Buyer Name'
         || '</th>'
         ||  '<tr>';

      FOR CUR_REC IN cur
      LOOP
         /*TABLE BODY */
         lv_details :=
               lv_details
            || ' < tr>'
            || '<td>'
            || CUR_REC.unit_name
            || '</td>'
            || '<td>'
            || CUR_REC.req_no
            || '</td>'
            || '<td>'
            || CUR_REC.description
            || '</td>'
            || '<td>'
            || CUR_REC.buyer_name
            || '</td>'
            || '</tr>';
      END LOOP;
      

      document := lv_details;

      document_type := 'text / html';
   EXCEPTION
      WHEN OTHERS
      THEN
         document := ' < H4>Error ' || SQLERRM || '</H4>';
   END xxdbl_create_wf_doc;
END XXDBL_CUSTOM_WORKFLOW;
/