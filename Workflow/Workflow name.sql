/* Formatted on 2/12/2020 6:03:01 PM (QP5 v5.287) */
SELECT *
  FROM WF_ITEM_TYPES_TL
 WHERE NAME = 'TEST_BPM';

  SELECT CASE
            WHEN ROW_NUMBER ()
                 OVER (
                    PARTITION BY wit.display_name || ' (' || wit.name || ')'
                    ORDER BY
                       pro.name,
                       wpa.instance_label,
                       wpa.activity_name NULLS LAST) = 1
            THEN
               wit.display_name || ' (' || wit.name || ')'
            ELSE
               NULL
         END
            "Item Type",
         CASE
            WHEN ROW_NUMBER ()
                 OVER (
                    PARTITION BY wit.display_name || ' (' || wit.name || ')',
                                 pro.name
                    ORDER BY wpa.instance_label, wpa.activity_name NULLS LAST) =
                    1
            THEN
               pro.name
            ELSE
               NULL
         END
            "Process",
         wpa.instance_label || ' (' || wpa.activity_name || ')'
            "Process Activity",
         CASE
            WHEN act.FUNCTION IS NOT NULL THEN 'Function: ' || act.function
            WHEN act.MESSAGE IS NOT NULL THEN 'Message: ' || act.MESSAGE
            ELSE NULL
         END
            "Activity Detail"
    FROM wf_item_types_tl wit,
         wf_activities pro,
         wf_process_activities wpa,
         wf_activities act
   WHERE     wit.name = pro.item_type
         AND pro.TYPE = 'PROCESS'
         AND pro.end_date IS NULL
         AND wit.language = 'US'
         AND pro.item_type = wpa.process_item_type
         AND pro.VERSION = wpa.process_version
         AND wpa.process_name = pro.name
         AND wpa.activity_name = act.name
         AND wpa.process_item_type = act.item_type
         AND act.end_date IS NULL
         AND UPPER(wit.name)         = :P_WORKFLOW_NAME
ORDER BY wit.display_name,
         wit.name,
         pro.name,
         wpa.instance_label

--Select all workflow items for a given item type
SELECT item_type,
       item_key,
       to_char(begin_date,
               'DD-MON-RR HH24:MI:SS') begin_date,
       to_char(end_date,
               'DD-MON-RR HH24:MI:SS') end_date,
       root_activity activity
  FROM apps.wf_items
 WHERE 1=1 --item_type = '&item_type'
   AND end_date IS NULL
 ORDER BY to_date(begin_date,
                  'DD-MON-YYYY hh24:mi:ss') DESC;

-- notifications sent by a given workflow
select  wn.notification_id nid, 
        wn.context, 
        wn.group_id, 
        wn.status, 
        wn.mail_status, 
        wn.message_type, 
        wn.message_name, 
        wn.access_key, 
        wn.priority, 
        wn.begin_date, 
        wn.end_date, 
        wn.due_date, 
        wn.callback, 
        wn.recipient_role, 
        wn.responder, 
        wn.original_recipient, 
        wn.from_user, 
        wn.to_user, 
        wn.subject 
from    wf_notifications wn, wf_item_activity_statuses wias 
where  wn.group_id = wias.notification_id 
and  wias.item_type = 'XXDBLREQ'
--and  wias.item_key = '1234-XXTEST'
;
 
--prompt **** Find the Activity Statuses for all workflow activities of a given item type and item key
SELECT execution_time,
       to_char(ias.begin_date,
               'DD-MON-RR HH24:MI:SS') begin_date,
       ap.display_name || '/' || ac.display_name activity,
       ias.activity_status status,
       ias.activity_result_code RESULT,
       ias.assigned_user ass_user
  FROM wf_item_activity_statuses ias,
       wf_process_activities     pa,
       wf_activities_vl          ac,
       wf_activities_vl          ap,
       wf_items                  i
 WHERE ias.item_type = '&item_type'
   AND ias.item_key = '&item_key'
   AND ias.process_activity = pa.instance_id
   AND pa.activity_name = ac.name
   AND pa.activity_item_type = ac.item_type
   AND pa.process_name = ap.name
   AND pa.process_item_type = ap.item_type
   AND pa.process_version = ap.version
   AND i.item_type = '&item_type'
   AND i.item_key = ias.item_key
   AND i.begin_date >= ac.begin_date
   AND i.begin_date < nvl(ac.end_date,
                          i.begin_date + 1)
UNION ALL
SELECT execution_time,
       to_char(ias.begin_date,
               'DD-MON-RR HH24:MI:SS') begin_date,
       ap.display_name || '/' || ac.display_name activity,
       ias.activity_status status,
       ias.activity_result_code RESULT,
       ias.assigned_user ass_user
  FROM wf_item_activity_statuses_h ias,
       wf_process_activities       pa,
       wf_activities_vl            ac,
       wf_activities_vl            ap,
       wf_items                    i
 WHERE ias.item_type = '&item_type'
   AND ias.item_key = '&item_key'
   AND ias.process_activity = pa.instance_id
   AND pa.activity_name = ac.name
   AND pa.activity_item_type = ac.item_type
   AND pa.process_name = ap.name
   AND pa.process_item_type = ap.item_type
   AND pa.process_version = ap.version
   AND i.item_type = '&item_type'
   AND i.item_key = ias.item_key
   AND i.begin_date >= ac.begin_date
   AND i.begin_date < nvl(ac.end_date,
                          i.begin_date + 1)
 ORDER BY 2,
          1
;

--Get a list of all Errored Workflow Activities for a given item type/ item key
SELECT ac.display_name          activity,
       ias.activity_result_code RESULT,
       ias.error_name           error_name,
       ias.error_message        error_message,
       ias.error_stack          error_stack
  FROM wf_item_activity_statuses ias,
       wf_process_activities     pa,
       wf_activities_vl          ac,
       wf_activities_vl          ap,
       wf_items                  i
 WHERE ias.item_type = '&item_type'
   AND ias.item_key = '&item_key'
   AND ias.activity_status = 'ERROR'
   AND ias.process_activity = pa.instance_id
   AND pa.activity_name = ac.name
   AND pa.activity_item_type = ac.item_type
   AND pa.process_name = ap.name
   AND pa.process_item_type = ap.item_type
   AND pa.process_version = ap.version
   AND i.item_type = '&item_type'
   AND i.item_key = ias.item_key
   AND i.begin_date >= ac.begin_date
   AND i.begin_date < nvl(ac.end_date,
                          i.begin_date + 1)
 ORDER BY ias.execution_time
;

--prompt *** Error Process Activity Statuses
SELECT execution_time,
       to_char(ias.begin_date,
               'DD-MON-RR HH24:MI:SS') begin_date,
       ap.display_name || '/' || ac.display_name activity,
       ias.activity_status status,
       ias.activity_result_code RESULT,
       ias.assigned_user ass_user
  FROM wf_item_activity_statuses ias,
       wf_process_activities     pa,
       wf_activities_vl          ac,
       wf_activities_vl          ap,
       wf_items                  i
 WHERE ias.item_type = i.item_type
   AND ias.item_key = i.item_key
   AND ias.process_activity = pa.instance_id
   AND pa.activity_name = ac.name
   AND pa.activity_item_type = ac.item_type
   AND pa.process_name = ap.name
   AND pa.process_item_type = ap.item_type
   AND pa.process_version = ap.version
   AND i.parent_item_type = '&item_type'
   AND i.parent_item_key = '&item_key'
   AND i.begin_date >= ac.begin_date
   AND i.begin_date < nvl(ac.end_date,
                          i.begin_date + 1)
UNION ALL
SELECT execution_time,
       to_char(ias.begin_date,
               'DD-MON-RR HH24:MI:SS') begin_date,
       ap.display_name || '/' || ac.display_name activity,
       ias.activity_status status,
       ias.activity_result_code RESULT,
       ias.assigned_user ass_user
  FROM wf_item_activity_statuses_h ias,
       wf_process_activities       pa,
       wf_activities_vl            ac,
       wf_activities_vl            ap,
       wf_items                    i
 WHERE ias.item_type = i.item_type
   AND ias.item_key = i.item_key
   AND ias.process_activity = pa.instance_id
   AND pa.activity_name = ac.name
   AND pa.activity_item_type = ac.item_type
   AND pa.process_name = ap.name
   AND pa.process_item_type = ap.item_type
   AND pa.process_version = ap.version
   AND i.parent_item_type = '&item_type'
   AND i.parent_item_key = '&item_key'
   AND i.begin_date >= ac.begin_date
   AND i.begin_date < nvl(ac.end_date,
                          i.begin_date + 1)
 ORDER BY 2,
          1
;

prompt **** Error Process Errored Activities
SELECT ac.display_name          activity,
       ias.activity_result_code RESULT,
       ias.error_name           error_name,
       ias.error_message        error_message,
       ias.error_stack          error_stack
  FROM wf_item_activity_statuses ias,
       wf_process_activities     pa,
       wf_activities_vl          ac,
       wf_activities_vl          ap,
       wf_items                  i
 WHERE ias.item_type = i.item_type
   AND ias.item_key = i.item_key
   AND ias.activity_status = 'ERROR'
   AND ias.process_activity = pa.instance_id
   AND pa.activity_name = ac.name
   AND pa.activity_item_type = ac.item_type
   AND pa.process_name = ap.name
   AND pa.process_item_type = ap.item_type
   AND pa.process_version = ap.version
   AND i.parent_item_type = '&item_type'
   AND i.parent_item_key = '&item_key'
   AND i.begin_date >= ac.begin_date
   AND i.begin_date < nvl(ac.end_date,
                          i.begin_date + 1)
 ORDER BY ias.execution_time
;

prompt **** Attribute Values
SELECT NAME attr_name,
       nvl(text_value,
           nvl(to_char(number_value),
               to_char(date_value))) VALUE
  FROM wf_item_attribute_values
 WHERE item_type = upper('&item_type')
   AND item_key = nvl('&item_key',
                      item_key)
/
--Count of all workflow deferred activities based
SELECT COUNT(1),
       was.item_type
  FROM apps.wf_items                  wi,
       apps.wf_item_activity_statuses was,
       apps.wf_process_activities     pra
 WHERE wi.item_type = was.item_type
   AND wi.item_key = was.item_key
   AND wi.end_date IS NULL
   AND was.end_date IS NULL
   AND was.activity_status = 'DEFERRED'
      --AND was.item_type = 'REQAPPRV'
   AND was.item_type = wi.item_type
   AND pra.instance_id(+) = was.process_activity
 GROUP BY was.item_type;

--check the various workflow agent listeners and their statuses
SELECT t.component_name,
       p.owner,
       p.queue_table,
       t.correlation_id
  FROM applsys.fnd_svc_components t,
       applsys.wf_agents          o,
       dba_queues                 p
 WHERE t.inbound_agent_name || t.outbound_agent_name = o.name
   AND p.owner || '.' || p.name = o.queue_name
   AND t.component_type LIKE 'WF_%AGENT%';                          
   
--query to find records that are pending in each of the workflow agent listener queues
SELECT 'select ''' || t.component_name || ' (queue_table: ' || p.queue_table ||
       ')''||'' Count: ''||count(*) c from ' || p.owner || '.' || p.queue_table ||
       ' where deq_time is null and nvl(delay,enq_time)<sysdate-1/24 ' ||
       nvl2(t.correlation_id,
            'and corrid like ''' || t.correlation_id || ''' ',
            NULL) || 'having count(*)>0;'
  FROM applsys.fnd_svc_components t,
       applsys.wf_agents          o,
       dba_queues                 p
 WHERE t.inbound_agent_name || t.outbound_agent_name = o.name
   AND p.owner || '.' || p.name = o.queue_name
   AND t.component_type LIKE 'WF_%AGENT%';

--Look for deferred events in wf_deferred. this can also be used to track the status of notifications/business events that are waiting to be processed/that have errored out
SELECT a.user_data.geteventname(),
       decode(a.state,
              0,
              '0 = Ready',
              1,
              '1 = Delayed',
              2,
              '2 = Retained/Processed',
              3,
              '3 = Exception',
              to_char(a.state)) state,
       a.user_data.PARAMETER_LIST,
       a.user_data.event_data,
       a.user_data.event_key,
       a.*
  FROM apps.wf_deferred a
 WHERE corrid LIKE '%oracle.apps.wsh.sup.ssro'
   AND rownum < 10;   