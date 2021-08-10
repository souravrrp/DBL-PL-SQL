/* Formatted on 1/7/2020 4:01:08 PM (QP5 v5.287) */
select av.application_name
,AV.APPLICATION_SHORT_NAME
,AV.BASEPATH
,FEC.VALUE
--, av.*
--,FEC.*
  from apps.fnd_application_vl av, apps.fnd_env_context fec
 where     1 = 1
       and basepath = variable_name
       and (   :p_application_name is null
            or (upper (av.application_name) like
                   upper ('%' || :p_application_name || '%')))