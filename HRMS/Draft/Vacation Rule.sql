/* Formatted on 11/23/2020 10:26:53 AM (QP5 v5.354) */
SELECT *
  FROM apps.WF_ROUTING_RULES
 WHERE role = :P_USER_NAME;

---------------------====================================-----------------------

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
         --AND   original_recipient =:P_USER_NAME
         AND wn.begin_date > SYSDATE - 10
ORDER BY original_recipient, wn.begin_date DESC;


  SELECT wfrr.rule_id,
         wfrr.MESSAGE_TYPE,
         wfrr.message_name,
         wfrr.begin_date,
         wfrr.end_date,
         wfrr.action,
         wfrr.action_argument,
         witv.display_name,
         wfmv.display_name,
         wfmv.subject,
         wfl.meaning,
         witv.name,
         wfmv.TYPE,
         wfmv.name,
         wfl.lookup_type,
         wfl.lookup_code
    FROM apps.wf_routing_rules wfrr,
         apps.wf_item_types_vl witv,
         apps.wf_messages_vl  wfmv,
         apps.wf_lookups      wfl
   WHERE     1 = 1
         AND wfrr.MESSAGE_TYPE = witv.name(+)
         AND wfrr.MESSAGE_TYPE = wfmv.TYPE(+)
         AND wfrr.message_name = wfmv.name(+)
         AND wfrr.action = wfl.lookup_code
         AND wfl.lookup_type = 'WFSTD_ROUTING_ACTIONS'
         --AND wfrr.end_date IS NULL
         AND wfrr.MESSAGE_TYPE IN ('POAPPRV',
                                   'REQAPPRV',
                                   'APINV',
                                   'APEXP',
                                   'APCCARD')
--and wfrr.action_argument in ('JCENA','MCGEY')
ORDER BY begin_date;

  SELECT routingruleseo.rule_id,
         routingruleseo.MESSAGE_TYPE,
         routingruleseo.message_name,
         routingruleseo.begin_date,
         routingruleseo.end_date,
         routingruleseo.action,
         routingruleseo.action_argument,
         itemtypeseo.display_name     AS type_display,
         messageseo.display_name      AS msg_display,
         messageseo.subject,
         lookupseo.meaning            AS action_display,
         itemtypeseo.NAME,
         messageseo.TYPE,
         messageseo.NAME              AS name1,
         lookupseo.lookup_type,
         lookupseo.lookup_code
    FROM wf_routing_rules routingruleseo,
         wf_item_types_vl itemtypeseo,
         wf_messages_vl  messageseo,
         wf_lookups      lookupseo
   WHERE     routingruleseo.MESSAGE_TYPE = itemtypeseo.NAME(+)
         AND routingruleseo.MESSAGE_TYPE = messageseo.TYPE(+)
         AND routingruleseo.message_name = messageseo.NAME(+)
         AND routingruleseo.action = lookupseo.lookup_code
         AND lookupseo.lookup_type = 'WFSTD_ROUTING_ACTIONS'
ORDER BY type_display, msg_display, begin_date;