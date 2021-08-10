/* Formatted on 2/13/2020 1:29:21 PM (QP5 v5.287) */
DECLARE
   l_itemtype   VARCHAR2 (10) := 'TEST_BPM';
   l_process    VARCHAR2 (80) := 'TEST_MESSAGE';
   l_itemkey    VARCHAR2 (20) := '1248-XXTEST';        --this should be unique
   l_user_key   VARCHAR2 (20) := '5492';
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
                              aname      => 'XX_ROLE',
                              avalue     => '103762'     --Recipient user name
                                                    );
   
   --
   --Setting Attribute Value
   --
   wf_engine.setitemattrtext (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'XX_MSG',
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
   DBMS_OUTPUT.put_line ('Done!');
--
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error: ' || SQLERRM);
END;
/