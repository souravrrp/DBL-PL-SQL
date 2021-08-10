SELECT DISTINCT
       a.form_name,
       a.enabled,
       c.user_form_name,
       d.application_name,
       a.trigger_event,
       a.trigger_object,
       a.condition
  FROM fnd_form_custom_rules a,
       fnd_form b,
       fnd_form_vl c,
       fnd_application_vl d,
       fnd_form_custom_actions e
 WHERE     a.enabled = 'Y'
       AND a.form_name = b.form_name
       AND b.form_id = c.form_id
       AND b.application_id = d.application_id
       AND a.id = e.rule_id
       --AND FUNCTION_NAME='AP_APXINWKB'
       --AND DESCRIPTION='Duplicate Move'  -- CLONE6
       --AND DESCRIPTION='Checking Duplicate Move Order
       AND a.FORM_NAME = 'APXINWKB'