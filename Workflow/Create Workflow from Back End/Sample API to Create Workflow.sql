/* Formatted on 2/13/2020 10:03:55 AM (QP5 v5.287) */
DECLARE
   v_itemtype   VARCHAR2 (50);
   v_itemkey    VARCHAR2 (50);
   v_process    VARCHAR2 (50);
   v_userkey    VARCHAR2 (50);
BEGIN
   v_itemtype := 'DEMOIT';
   v_itemkey := '1233';
   v_userkey := '1233';
   v_process := 'DEMOPROCESS';
   WF_ENGINE.Threshold := -1;
   WF_ENGINE.CREATEPROCESS (v_itemtype, v_itemkey, v_process);
   wf_engine.setitemuserkey (v_itemtype, v_itemkey, v_userkey);
   wf_engine.setitemowner (v_itemtype, v_itemkey, 'SYSADMIN');
   WF_ENGINE.STARTPROCESS (v_itemtype, v_itemkey);
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM);
END;