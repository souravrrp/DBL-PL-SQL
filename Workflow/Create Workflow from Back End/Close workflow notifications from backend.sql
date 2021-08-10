DECLARE
  --
  -- +=====================================================
  -- | Purpose  : To close email notification
  -- | Author   : Shailender Thallam
  -- +=====================================================
  --
  CURSOR cur_list_notifications
  IS
  --
  --Modify the below query as per your requirement
  --
    SELECT item_key,
      notification_id,
      recipient_role
    FROM wf_notifications
    WHERE 1          = 1
    AND message_type LIKE 'XX_NOTIF'
    AND STATUS       = 'OPEN';
  --
  --
  l_item_key wf_notifications.item_key%TYPE;
  --
  --
BEGIN
  --
  FOR i IN cur_list_notifications
  LOOP
    BEGIN
      --
      wf_notification.close(i.notification_id,'SYSADMIN');
	  dbms_output.put_line ('Closing Notification ID: '||i.notification_id);
      --
    END;
  END LOOP;
  --
  COMMIT;
  --
END close_sample_creation_notif;