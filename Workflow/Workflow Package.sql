/* Formatted on 5/30/2020 1:02:25 PM (QP5 v5.287) */
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
         AND (   :WF_NAME IS NULL OR (UPPER (WIT.NAME) LIKE UPPER ('%' || :WF_NAME || '%')))
ORDER BY wit.display_name,
         wit.name,
         pro.name,
         wpa.instance_label