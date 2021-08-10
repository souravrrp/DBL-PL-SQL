
List of All Tables use to track Form Personlizations

SELECT * FROM apps.Fnd_Form_Custom_Actions where 1=1

SELECT * FROM all_tables where table_name like 'FND%FORM%'

SELECT * FROM apps.FND_FORM_CUSTOM_SCOPES

SELECT * FROM apps.FND_FORM_CUSTOM_PARAMS

SELECT * FROM apps.FND_FORM_CUSTOM_RULES

SELECT * FROM apps.FND_FORM_CUSTOM_PROP_VALUES

SELECT * FROM apps.FND_FORM_CUSTOM_PROP_LIST

SELECT * FROM apps.FND_FORM_CUSTOM_ACTIONS

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
          ffca.sequence action_seq,
          decode(ffca.action_type,'P','Property', 'B', 'Builtin', 'M', 'Message', ffca.action_type) action_type,
          ffca.summary action_description,
          ffca.enabled action_enabled,
          ffca.object_type,
          ffca.target_object,
          ffca.property_value,
          decode(ffca.message_type, 'W', 'Warn', 'E', 'Error', 'S', 'Show', ffca.message_type),
          ffca.message_text
     FROM apps.fnd_form_vl             ffv,
          apps.fnd_form_custom_rules   ffcr,
          apps.fnd_form_custom_actions ffca
    WHERE ffv.form_name = ffcr.form_name
      AND ffcr.id = ffca.rule_id
 ORDER BY ffcr.form_name, ffcr.sequence, ffca.sequence;
 
 
 -------------------------------------------------------------------------------
 
 SELECT fcr.id
,      fff.user_function_name
,      FCR.FORM_NAME FORM
,      FCR.SEQUENCE SEQ
,      FCR.DESCRIPTION
,   case when fcr.rule_type = 'F' then 'FORM'
         when fcr.rule_type = 'A' then 'FUNCTION'
         ELSE 'UNKNOWN' END P_LEVEL
,      FCR.ENABLED
,      FU.USER_NAME 
,      FCR.TRIGGER_EVENT
,      FCR.TRIGGER_OBJECT
,      FCR.LAST_UPDATE_DATE
FROM APPLSYS.FND_FORM_CUSTOM_RULES FCR
        ,APPS.FND_USER FU
        ,apps.FND_FORM_FUNCTIONS_VL FFF
where
  fcr.function_name = fff.function_name
  and fcr.last_updated_by = FU.USER_ID
--  AND FCR.ENABLED LIKE :ENABLED
order by form_name, sequence;

--------------------------------------------------------------------------------

Select Distinct
    A.Id,
    A.Form_Name ,
    A.Enabled,
    C.User_Form_Name,
    D.Application_Id,
    D.Application_Name ,
    A.Description,
    Ca.Action_Type,
    Ca.Enabled,
    Ca.Object_Type,
    ca.message_type,
    ca.message_text
from
    apps.FND_FORM_CUSTOM_RULES a,
    apps.FND_FORM b,
    apps.FND_FORM_TL c,
    apps.Fnd_Application_Tl D,
    apps.Fnd_Form_Custom_Actions ca
where a.form_name = b.form_name
    And B.Form_Id = C.Form_Id
    And B.Application_Id = D.Application_Id
    And D.Application_Id = 201 --For Order Management
--    And C.User_Form_Name Like 'Inventory%'  --All the Forms that Start with Sales
    AND A.Id IN ('384','485')
    And A.Enabled ='Y'
    and a.id = ca.rule_id


SELECT
    ffv.form_id          "Form ID",
    ffv.form_name        "Form Name",
    ffv.user_form_name   "User Form Name",
    ffv.description      "Form Description",
    ffcr.sequence        "Sequence",
    ffcr.description     "Personalization Rule Name"
FROM apps.fnd_form_vl             ffv,
       apps.fnd_form_custom_rules   ffcr
WHERE ffv.form_name = ffcr.form_name
ORDER BY ffv.form_name, ffcr.sequence;



SELECT 
    ffcr.SEQUENCE "Seq", ffcr.description "Description",
    DECODE (ffcr.rule_type,
           'F', 'Form',
            'A', 'Function',
            'Other'
           ) "Level",
    ffcr.enabled "Enabled",
    ffcr.trigger_event "Trigger Event",
    ffcr.trigger_object "Trigger Object",
    ffcr.condition "Condition",
    DECODE (ffcr.fire_in_enter_query,
            'Y', 'Both',
            'N', 'Not in Enter-Query Mode',
            'O', 'Only in Enter-Query Mode',
            'Other'
           ) "Processing Mode"
FROM apps.fnd_form_custom_rules ffcr
WHERE ffcr.function_name = 'PO_POXPOEPO'
    AND ffcr.form_name = 'POXPOEPO'
ORDER BY ffcr.SEQUENCE;