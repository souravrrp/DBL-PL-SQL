/* Formatted on 10/14/2020 2:28:07 PM (QP5 v5.287) */
DECLARE
   l_itemkey      VARCHAR2 (100);
   v_role_name    VARCHAR2 (100) := 'Anil Passi Testing';
   v_role_email   VARCHAR2 (100) := 'anilpassi@gmail.com';
   n_count_role   INTEGER := 0;
BEGIN
   SELECT COUNT (*)
     INTO n_count_role
     FROM wf_local_roles
    WHERE NAME = v_role_name;

   IF n_count_role = 0
   THEN
      --If the sender does not exist in WF Local Roles, then create one on the fly
      wf_directory.createadhocrole (role_name                 => v_role_name,
                                    role_display_name         => v_role_name,
                                    role_description          => v_role_name,
                                    notification_preference   => 'MAILHTML',
                                    email_address             => v_role_email,
                                    status                    => 'ACTIVE',
                                    expiration_date           => NULL);
      DBMS_OUTPUT.put_line ('Ad Hoc Role Created');
   ELSE
      DBMS_OUTPUT.put_line ('Ad Hoc Role Already Exists');
   END IF;

   SELECT oe_order_headers_s.NEXTVAL INTO l_itemkey FROM DUAL;

   wf_engine.createprocess ('XXTEST', l_itemkey, 'XXTEST');
   wf_engine.setitemuserkey (itemtype   => 'XXTEST',
                             itemkey    => l_itemkey,
                             userkey    => l_itemkey);
   wf_engine.setitemowner (itemtype   => 'XXTEST',
                           itemkey    => l_itemkey,
                           owner      => 'SYSADMIN');

   --The three API calls in bold is what you need.
   wf_engine.setitemattrtext (itemtype   => 'XXTEST',
                              itemkey    => l_itemkey,
                              aname      => '#FROM_ROLE',
                              avalue     => v_role_name);
   wf_engine.setitemattrtext (itemtype   => 'XXTEST',
                              itemkey    => l_itemkey,
                              aname      => '#WFM_FROM',
                              avalue     => v_role_name);
   wf_engine.setitemattrtext (itemtype   => 'XXTEST',
                              itemkey    => l_itemkey,
                              aname      => '#WFM_REPLYTO',
                              avalue     => v_role_email);
   wf_engine.startprocess ('XXTEST', l_itemkey);
   COMMIT;
END;
/