/* Formatted on 11/7/2020 12:58:00 PM (QP5 v5.354) */
LIST of All Tables use to track Form Personlizations;

SELECT *
  FROM apps.Fnd_Form_Custom_Actions
 WHERE 1 = 1;

SELECT *
  FROM all_tables
 WHERE table_name LIKE 'FND%FORM%';

SELECT * FROM apps.FND_FORM_CUSTOM_SCOPES;

SELECT * FROM apps.FND_FORM_CUSTOM_PARAMS;

SELECT * FROM apps.FND_FORM_CUSTOM_RULES;

SELECT * FROM apps.FND_FORM_CUSTOM_PROP_VALUES;

SELECT * FROM apps.FND_FORM_CUSTOM_PROP_LIST;

SELECT * FROM apps.FND_FORM_CUSTOM_ACTIONS;

--------------------------------------------------------------------------------

  SELECT ffcr.function_name,
         ffcr.form_name,
         ffv.user_form_name,
         ffcr.sequence,
         ffcr.description,
         ffcr.trigger_event,
         ffcr.trigger_object,
         ffcr.condition,
         ffcr.enabled,
         ffca.sequence
             action_seq,
         DECODE (ffca.action_type,
                 'P', 'Property',
                 'B', 'Builtin',
                 'M', 'Message',
                 ffca.action_type)
             action_type,
         ffca.summary
             action_description,
         ffca.enabled
             action_enabled,
         ffca.object_type,
         ffca.target_object,
         ffca.property_value,
         DECODE (ffca.MESSAGE_TYPE,
                 'W', 'Warn',
                 'E', 'Error',
                 'S', 'Show',
                 ffca.MESSAGE_TYPE),
         ffca.MESSAGE_TEXT
    FROM apps.fnd_form_vl            ffv,
         apps.fnd_form_custom_rules  ffcr,
         apps.fnd_form_custom_actions ffca
   WHERE ffv.form_name = ffcr.form_name AND ffcr.id = ffca.rule_id
ORDER BY ffcr.form_name, ffcr.sequence, ffca.sequence;


 -------------------------------------------------------------------------------

  SELECT fcr.id,
         fff.user_function_name,
         FCR.FORM_NAME    FORM,
         FCR.SEQUENCE     SEQ,
         FCR.DESCRIPTION,
         CASE
             WHEN fcr.rule_type = 'F' THEN 'FORM'
             WHEN fcr.rule_type = 'A' THEN 'FUNCTION'
             ELSE 'UNKNOWN'
         END              P_LEVEL,
         FCR.ENABLED,
         FU.USER_NAME,
         FCR.TRIGGER_EVENT,
         FCR.TRIGGER_OBJECT,
         FCR.LAST_UPDATE_DATE
    FROM APPLSYS.FND_FORM_CUSTOM_RULES FCR,
         APPS.FND_USER                FU,
         apps.FND_FORM_FUNCTIONS_VL   FFF
   WHERE     fcr.function_name = fff.function_name
         AND fcr.last_updated_by = FU.USER_ID
--  AND FCR.ENABLED LIKE :ENABLED
ORDER BY form_name, sequence;

--------------------------------------------------------------------------------

SELECT DISTINCT A.Id,
                A.Form_Name,
                A.Enabled,
                C.User_Form_Name,
                D.Application_Id,
                D.Application_Name,
                A.Description,
                Ca.Action_Type,
                Ca.Enabled,
                Ca.Object_Type,
                ca.MESSAGE_TYPE,
                ca.MESSAGE_TEXT
  FROM apps.FND_FORM_CUSTOM_RULES    a,
       apps.FND_FORM                 b,
       apps.FND_FORM_TL              c,
       apps.Fnd_Application_Tl       D,
       apps.Fnd_Form_Custom_Actions  ca
 WHERE     a.form_name = b.form_name
       AND B.Form_Id = C.Form_Id
       AND B.Application_Id = D.Application_Id
       AND D.Application_Id = 201                       --For Order Management
       --    And C.User_Form_Name Like 'Inventory%'  --All the Forms that Start with Sales
       AND A.Id IN ('384', '485')
       AND A.Enabled = 'Y'
       AND a.id = ca.rule_id;


  SELECT ffv.form_id            "Form ID",
         ffv.form_name          "Form Name",
         ffv.user_form_name     "User Form Name",
         ffv.description        "Form Description",
         ffcr.sequence          "Sequence",
         ffcr.description       "Personalization Rule Name"
    FROM apps.fnd_form_vl ffv, apps.fnd_form_custom_rules ffcr
   WHERE ffv.form_name = ffcr.form_name
ORDER BY ffv.form_name, ffcr.sequence;



  SELECT ffcr.SEQUENCE
             "Seq",
         ffcr.description
             "Description",
         DECODE (ffcr.rule_type,  'F', 'Form',  'A', 'Function',  'Other')
             "Level",
         ffcr.enabled
             "Enabled",
         ffcr.trigger_event
             "Trigger Event",
         ffcr.trigger_object
             "Trigger Object",
         ffcr.condition
             "Condition",
         DECODE (ffcr.fire_in_enter_query,
                 'Y', 'Both',
                 'N', 'Not in Enter-Query Mode',
                 'O', 'Only in Enter-Query Mode',
                 'Other')
             "Processing Mode"
    FROM apps.fnd_form_custom_rules ffcr
   WHERE ffcr.function_name = 'PO_POXPOEPO' AND ffcr.form_name = 'POXPOEPO'
ORDER BY ffcr.SEQUENCE;