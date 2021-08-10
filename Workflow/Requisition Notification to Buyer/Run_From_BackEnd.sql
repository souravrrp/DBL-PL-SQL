/* Formatted on 7/14/2020 2:32:30 PM (QP5 v5.287) */
DECLARE
   l_itemtype   VARCHAR2 (10) := 'XXDBLREQ';
   l_process    VARCHAR2 (80) := 'XXDBLREQAPPPROC';
   l_itemkey    VARCHAR2 (20);                         --this should be unique
   l_user_key   VARCHAR2 (20) := '5492';

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
                     --AND FU.USER_NAME = '100151'
                     --AND prha.segment1 = '15511000040'--AND prha.last_update_date >= SYSDATE - INTERVAL '10' MINUTE);
                                                      --AND prha.last_update_date >= SYSDATE
             );



   v_seq_no     NUMBER (10);
--
--
BEGIN
   FOR i IN c1
   LOOP
      SELECT APPS.XXDBLREQAPPSEQ_S.NEXTVAL INTO v_seq_no FROM DUAL;
      
      DBMS_OUTPUT.put_line (i.user_name);
      DBMS_OUTPUT.put_line (i.segment1);
      DBMS_OUTPUT.put_line (v_seq_no);

      --
      --Creating Workflow Process
      --
      wf_engine.createprocess (itemtype     => l_itemtype,
                               itemkey      => v_seq_no,
                               process      => l_process,
                               user_key     => l_user_key,
                               owner_role   => 'SYSADMIN');
      --
      --Setting Item attribute for 'Adhoc role'
      --
      wf_engine.setitemattrtext (itemtype   => l_itemtype,
                                 itemkey    => v_seq_no,
                                 aname      => 'XXDBLBUYER',
                                 avalue     => i.user_name --Recipient user name
                                                          );

      --
      --Setting Attribute Value
      --
      wf_engine.setitemattrtext (itemtype   => l_itemtype,
                                 itemkey    => v_seq_no,
                                 aname      => 'XXDBLREQNO',
                                 avalue     => i.segment1);
      /*
      --
      --Setting Attribute Value
      --
      --   wf_engine.setitemattrtext (itemtype   => l_itemtype,
      --                              itemkey    => l_itemkey,
      --                              aname      => 'XX_LOT',
      --                              avalue     => 'IT-090001-LOT');
      --
      --Setting Attribute Value
      --

      wf_engine.setitemattrtext (itemtype   => l_itemtype,
                                 itemkey    => l_itemkey,
                                 aname      => 'XX_ORG',
                                 avalue     => 'M1');
      */
      --
      --Start Process
      --
      wf_engine.startprocess (itemtype => l_itemtype, itemkey => v_seq_no);
      --
      --
      COMMIT;
   END LOOP;

   DBMS_OUTPUT.put_line ('Done!');
--
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error: ' || SQLERRM);
END;
/