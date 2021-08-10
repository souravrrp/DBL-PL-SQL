/* Formatted on 7/14/2020 10:04:29 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_CUSTOM_WORKFLOW
IS
   PROCEDURE XXDBL_REQNOTIFTOBUYER (ERRBUF    OUT VARCHAR2,
                                    RETCODE   OUT VARCHAR2)
   IS
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
                        AND FU.USER_NAME='103762'
                        AND prha.segment1='25111002544'
                        --AND FU.USER_NAME='100151'
                        --AND prha.segment1='15511000040'
                        --AND prha.last_update_date >= SYSDATE - INTERVAL '10' MINUTE);
                        --AND prha.last_update_date >= SYSDATE
                        );



      v_seq_no   NUMBER (10);
   BEGIN
      FOR i IN c1
      LOOP
         SELECT APPS.XXDBLREQAPPSEQ_S.NEXTVAL INTO v_seq_no FROM DUAL;

         wf_engine.createprocess (itemtype   => 'XXDBLREQ',
                                  itemkey    => v_seq_no,
                                  process    => 'XXDBLREQAPPPROC');

         wf_engine.setitemattrtext (itemtype   => 'XXDBLREQ',
                                    itemkey    => v_seq_no,
                                    aname      => 'XXDBLBUYER',
                                    avalue     => i.user_name);

         wf_engine.setitemattrtext (itemtype   => 'XXDBLREQ',
                                    itemkey    => v_seq_no,
                                    aname      => 'XXDBLREQNO',
                                    avalue     => i.segment1);

         wf_engine.startprocess (itemtype => 'XXDBLREQ', itemkey => v_seq_no);

         v_seq_no := 0;
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