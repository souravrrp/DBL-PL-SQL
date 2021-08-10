SELECT DISTINCT fcpl.user_concurrent_program_name "Concurrent Program Name",
  fcp.concurrent_program_name "Short Name"                                 ,
  fat.application_name                                                     ,
  fl.meaning execution_method                                              ,
  fe.execution_file_name                                                   ,
  '$' || fav.BASEPATH || '/' || 'reports/US' Reports_Path,
  fcp.output_file_type                                                     ,
  fdfcuv.column_seq_num "Column Seq Number"                                ,
  fdfcuv.end_user_column_name "Parameter Name"                             ,
  fdfcuv.form_left_prompt "Prompt"                                         ,
  fdfcuv.enabled_flag " Enabled Flag"                                      ,
  fdfcuv.required_flag "Required Flag"                                     ,
  fdfcuv.display_flag "Display Flag"                                       ,
  fdfcuv.flex_value_set_id "Value Set Id"                                  ,
  ffvs.flex_value_set_name "Value Set Name"                                ,
  flv.meaning "Default Type"                                               ,
  fdfcuv.default_value "Default Value"
   FROM apps.fnd_concurrent_programs fcp ,
  apps.fnd_concurrent_programs_tl fcpl   ,
  apps.fnd_descr_flex_col_usage_vl fdfcuv,
  apps.fnd_flex_value_sets ffvs          ,
  apps.fnd_lookup_values flv             ,
  apps.fnd_lookups fl                    ,
  apps.fnd_executables fe                ,
  apps.fnd_executables_tl fet            ,
  apps.fnd_application_vl fav,
  apps.fnd_application_tl fat
  WHERE 1                     = 1
AND fcp.concurrent_program_id = fcpl.concurrent_program_id
AND fcp.enabled_flag          = 'Y'
AND fe.execution_file_name ='XXAKGDRIVERBAL'
--AND fcpl.user_concurrent_program_name LIKE 'AKG List of DOs Paid Bill by Pay Date' --<Your Concurrent Program Name>
AND fdfcuv.descriptive_flexfield_name = '$SRS$.'
  || fcp.concurrent_program_name
AND ffvs.flex_value_set_id = fdfcuv.flex_value_set_id
AND flv.lookup_type(+)     = 'FLEX_DEFAULT_TYPE'
AND flv.lookup_code(+)     = fdfcuv.default_type
AND fcpl.LANGUAGE          = 'US'
AND flv.LANGUAGE(+)        = 'US'
AND fl.lookup_type         ='CP_EXECUTION_METHOD_CODE'
AND fl.lookup_code         =fcp.execution_method_code
AND fe.executable_id       = fcp.executable_id
AND fe.executable_id       =fet.executable_id
AND fet.LANGUAGE           = 'US'
and fat.application_id=fav.application_id
AND fat.application_id     =fcp.application_id
AND fat.LANGUAGE           = 'US'
ORDER BY fdfcuv.column_seq_num;

---------------*************RTF**********----------------------------------------

SELECT
*
FROM
APPS.XDO_DS_DEFINITIONS_VL
WHERE 1=1
AND DATA_SOURCE_CODE LIKE '%XXCMNTGHTSTOCK%'
--AND DATA_SOURCE_NAME LIKE '%%'
--AND DESCRIPTION LIKE '%%'


---------------*************Others*********-------------------------------------

SELECT fcpt.user_concurrent_program_name ,
  fcp.concurrent_program_name short_name ,
  fat.application_name program_application_name ,
  fet.executable_name ,
  fat1.application_name executable_application_name ,
  flv.meaning execution_method ,
  fet.execution_file_name ,
  fcp.enable_trace
FROM apps.fnd_concurrent_programs_tl fcpt ,
  apps.fnd_concurrent_programs fcp ,
  apps.fnd_application_tl fat ,
  apps.fnd_executables fet ,
  apps.fnd_application_tl fat1 ,
  apps.FND_LOOKUP_VALUES FLV
WHERE 1=1
--AND fcp.concurrent_program_name ='XXCMNTGHTSTOCK'
AND fcpt.user_concurrent_program_name='AKG List of DOs Paid Bill by Pay Date'
AND fcpt.concurrent_program_id       = fcp.concurrent_program_id
AND fcpt.application_id              = fcp.application_id
AND fcp.application_id               = fat.application_id
AND fcpt.application_id              = fat.application_id
AND fcp.executable_id                = fet.executable_id
AND fcp.executable_application_id    = fet.application_id
AND fet.application_id               = fat1.application_id
AND flv.lookup_code                  = fet.execution_method_code
AND FLV.LOOKUP_TYPE                  ='CP_EXECUTION_METHOD_CODE'

------------------------------------------------------------------------------------------------

SELECT DISTINCT fcpl.user_concurrent_program_name "Concurrent Program Name",
  fcp.concurrent_program_name "Short Name"                                 ,
  fat.application_name                                                     ,
  fl.meaning execution_method                                              ,
  fe.execution_file_name                                                   ,
  fcp.output_file_type                                                     ,
  fdfcuv.column_seq_num "Column Seq Number"                                ,
  fdfcuv.end_user_column_name "Parameter Name"                             ,
  fdfcuv.form_left_prompt "Prompt"                                         ,
  fdfcuv.enabled_flag " Enabled Flag"                                      ,
  fdfcuv.required_flag "Required Flag"                                     ,
  fdfcuv.display_flag "Display Flag"                                       ,
  fdfcuv.flex_value_set_id "Value Set Id"                                  ,
  ffvs.flex_value_set_name "Value Set Name"                                ,
  flv.meaning "Default Type"                                               ,
  fdfcuv.default_value "Default Value"
   FROM apps.fnd_concurrent_programs fcp ,
  apps.fnd_concurrent_programs_tl fcpl   ,
  apps.fnd_descr_flex_col_usage_vl fdfcuv,
  apps.fnd_flex_value_sets ffvs          ,
  apps.fnd_lookup_values flv             ,
  apps.fnd_lookups fl                    ,
  apps.fnd_executables fe                ,
  apps.fnd_executables_tl fet            ,
  apps.fnd_application_tl fat
  WHERE 1                     = 1
AND fcp.concurrent_program_id = fcpl.concurrent_program_id
AND fcp.enabled_flag          = 'Y'
AND fe.execution_file_name ='XXCMNTGHTSTOCK'
--AND fcpl.user_concurrent_program_name LIKE 'AKG List of DOs Paid Bill by Pay Date' --<Your Concurrent Program Name>
AND fdfcuv.descriptive_flexfield_name = '$SRS$.'
  || fcp.concurrent_program_name
AND ffvs.flex_value_set_id = fdfcuv.flex_value_set_id
AND flv.lookup_type(+)     = 'FLEX_DEFAULT_TYPE'
AND flv.lookup_code(+)     = fdfcuv.default_type
AND fcpl.LANGUAGE          = 'US'
AND flv.LANGUAGE(+)        = 'US'
AND fl.lookup_type         ='CP_EXECUTION_METHOD_CODE'
AND fl.lookup_code         =fcp.execution_method_code
AND fe.executable_id       = fcp.executable_id
AND fe.executable_id       =fet.executable_id
AND fet.LANGUAGE           = 'US'
AND fat.application_id     =fcp.application_id
AND fat.LANGUAGE           = 'US'
ORDER BY fdfcuv.column_seq_num;