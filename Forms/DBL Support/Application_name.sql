SELECT fa.application_id           "Application ID",
       fat.application_name        "Application Name",
       fa.application_short_name   "Application Short Name",
       fa.basepath                 "Basepath"
  FROM apps.fnd_application     fa,
       apps.fnd_application_tl  fat
 WHERE fa.application_id = fat.application_id
   AND fat.language      = USERENV('LANG')
   AND fa.application_id =NVL(:p_application_id,fa.application_id)
   --AND fa.application_id in ( 201 )
   and (   :p_application_name is null or (upper (fat.application_name) like upper ('%' || :p_application_name || '%')))
   -- AND fat.application_name in ( 'Payables'  )
 ORDER BY fat.application_name;