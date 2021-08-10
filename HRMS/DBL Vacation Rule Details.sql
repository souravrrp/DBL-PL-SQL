/* Formatted on 6/7/2021 3:51:46 PM (QP5 v5.354) */
  SELECT *
    FROM apps.wf_routing_rules wrr
   WHERE     1 = 1
         AND ( :p_user_name IS NULL OR (wrr.role = :p_user_name))
         AND TRUNC (SYSDATE) BETWEEN TRUNC (begin_date) AND TRUNC (end_date)
ORDER BY begin_date DESC;

--------------------------------------------------------------------------------


  SELECT wit.display_name
             workflow_process,
         NVL (
             wi.user_key,
             (SELECT user_key
                FROM apps.wf_items w
               WHERE     w.item_key = wi.parent_item_key
                     AND w.item_type = wi.item_type))
             document_number,
         from_role,
         recipient_role,
         from_user,
         to_user,
         status,
         mail_status,
         original_recipient,
         wias.activity_result_code
             notification_status,
         wn.subject,
         wn.begin_date
             notification_begin_date,
         wn.end_date
             notification_end_date,
         wrr.begin_date
             delegation_start_date,
         wrr.end_date
             delegation_end_date
    FROM apps.wf_notifications         wn,
         apps.wf_routing_rules         wr,
         apps.wf_routing_rules         wrr,
         apps.wf_item_activity_statuses wias,
         apps.wf_items                 wi,
         apps.wf_item_types_vl         wit
   WHERE     wn.from_role = wr.role
         AND wrr.role = wn.from_role
         AND wrr.action_argument = wn.recipient_role
         AND wias.item_key = wn.item_key
         AND wias.notification_id = wn.notification_id
         AND wn.item_key = wi.item_key
         AND wn.MESSAGE_TYPE = wi.item_type
         AND wit.name = wi.item_type
         AND original_recipient = :P_USER_NAME
         AND wn.begin_date > SYSDATE - 10
ORDER BY original_recipient, wn.begin_date DESC;