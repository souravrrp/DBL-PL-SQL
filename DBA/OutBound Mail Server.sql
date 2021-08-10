/* Formatted on 10/31/2020 9:43:10 AM (QP5 v5.287) */
SELECT fscpv.parameter_value, fscpt.display_name, fscpt.description,fscpt.*
  FROM fnd_svc_comp_params_tl fscpt, fnd_svc_comp_param_vals fscpv
 WHERE     1 = 1
       AND fscpt.display_name = 'Outbound Server Name'
       AND fscpt.language = 'US'
       AND fscpt.source_lang = 'US'
       AND fscpv.ZD_EDITION_NAME='SET2'
       AND fscpt.ZD_EDITION_NAME='SET2'
       AND fscpt.parameter_id = fscpv.parameter_id;