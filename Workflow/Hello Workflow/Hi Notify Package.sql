/* Formatted on 7/14/2020 5:21:44 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_CUSTOM_WORKFLOW
IS
   PROCEDURE XXDBL_REQNOTIFTOBUYER (ERRBUF    OUT VARCHAR2,
                                    RETCODE   OUT VARCHAR2)
   IS
      l_itemtype   VARCHAR2 (10) := 'TEST_BPM';
      l_process    VARCHAR2 (80) := 'TEST_MESSAGE';
      l_itemkey    VARCHAR2 (20);                      --this should be unique
      l_user_key   VARCHAR2 (20) := '5958';

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
END XXDBL_CUSTOM_WORKFLOW;
/