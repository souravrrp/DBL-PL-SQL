SELECT ffv.form_name,
       ffv.user_form_name,
       ffv.description,
       fat.application_name,
          '$'
       || (SELECT basepath
             FROM apps.fnd_application
            WHERE application_id = ffv.application_id)
       || '/forms/US/'
       || ffv.form_name
       || '.fmx'
          basepath,
          '$'
       || 'AU_TOP'
       || '/forms/US/'
       || ffv.form_name
       || '.fmb'
          fmb_path,
       form_id
  FROM apps.fnd_form_vl ffv
       ,apps.fnd_application_tl fat
 WHERE     1 = 1
       AND (form_id >= 0)
       AND ffv.application_id = fat.application_id
       AND (:P_APPLICATION_NAME IS NULL OR (UPPER (fat.application_name) LIKE UPPER ('%' || :P_APPLICATION_NAME || '%')))
       AND (:P_USER_FROM_NAME IS NULL OR (UPPER (user_form_name) LIKE UPPER ('%' || :P_USER_FROM_NAME || '%')))
       AND (:P_FROM_NAME IS NULL OR (UPPER (form_name) LIKE UPPER ('%' || :P_FROM_NAME || '%')))