/* Formatted on 2/13/2020 1:29:21 PM (QP5 v5.287) */
DECLARE
   l_itemtype   VARCHAR2 (10) := 'XXDBLREQ';
   l_process    VARCHAR2 (80) := 'XXDBLREQAPPPROC';
   l_itemkey    VARCHAR2 (20) := '1256-XXREQB';        --this should be unique
   l_user_key   VARCHAR2 (20) := '5492';    --5492  --5958
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
   --Setting Item attribute for 'Adhoc role'
   --
   wf_engine.setitemattrtext (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'XXDBLBUYER',
                              avalue     => '103762'     --Recipient user name     --103908 --103762
                                                    );
   
   --
   --Setting Attribute Value
   --
   wf_engine.setitemattrtext (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'XXDBLREQNO',
                              avalue     => 'IT-BPM');
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
   wf_engine.startprocess (itemtype => l_itemtype, itemkey => l_itemkey);
   --
   --
   COMMIT;
   DBMS_OUTPUT.put_line (l_itemkey);
   DBMS_OUTPUT.put_line ('Done!');
--
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error: ' || SQLERRM);
END;
/