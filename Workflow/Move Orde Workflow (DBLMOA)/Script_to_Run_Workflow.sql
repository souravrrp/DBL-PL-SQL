/* Formatted on 8/23/2020 10:43:50 AM (QP5 v5.287) */
DECLARE
   l_itemtype      VARCHAR2 (8) := 'REQ_NOTF';
   l_process       VARCHAR2 (80) := 'HTML_PROC';
   l_itemkey       VARCHAR2 (20) := '1234-14';          --this should be unique
   l_user_key      VARCHAR2 (20) := '123';
   l_document_id   CLOB;
--
--
BEGIN
   --
   --Creating Workflow Process
   --
   wf_engine.createprocess (itemtype     => l_itemtype,
                            itemkey      => l_itemkey,
                            process      => l_process,
                            user_key     => l_user_key,
                            owner_role   => 'SYSADMIN');
   --
   --Calling PLSQL document for generating HTML code
   --

   l_document_id := 'PLSQL:XXDBL_PO_REQ_WF_PKG.XXDBL_CREATE_WF_DOC/' || l_itemkey;
   --
   --Setting Value for document type attribute
   --
   wf_engine.setitemattrtext (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MSG_BODY',
                              avalue     => l_document_id);
   --
   --Start Process
   --
   wf_engine.startprocess (itemtype => l_itemtype, itemkey => l_itemkey);
   --
   --
   COMMIT;
   DBMS_OUTPUT.put_line ('Done!');
--
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error: ' || SQLERRM);
END;
/