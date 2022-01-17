SELECT --DISTINCT
       fcpl.user_concurrent_program_name              "Concurrent Program Name",
       fcp.concurrent_program_name                    "Short Name",
       fav.application_name,
       fl.meaning                                     execution_method,
       fe.execution_file_name,
       '$' || fav.basepath || '/' || 'reports/US'     reports_path,
       fcp.output_file_type,
       fdfcuv.column_seq_num                          "Column Seq Number",
       fdfcuv.end_user_column_name                    "Parameter Name",
       fdfcuv.form_left_prompt                        "Prompt",
       fdfcuv.enabled_flag                            "Enabled Flag",
       fdfcuv.required_flag                           "Required Flag",
       fdfcuv.display_flag                            "Display Flag",
       fdfcuv.flex_value_set_id                       "Value Set Id",
       ffvs.flex_value_set_name                       "Value Set Name",
       flv.meaning                                    "Default Type",
       fdfcuv.DEFAULT_VALUE                           "Default Value",
       rtf.template_code                              rtf_template_name,
       rtf.default_output_type                        output_type
  FROM apps.fnd_concurrent_programs      fcp,
       apps.fnd_concurrent_programs_vl   fcpl,
       apps.fnd_descr_flex_col_usage_vl  fdfcuv,
       apps.fnd_flex_value_sets          ffvs,
       apps.fnd_lookup_values            flv,
       apps.fnd_lookups                  fl,
       apps.fnd_executables              fe,
       apps.fnd_executables_vl           fev,
       apps.xdo_templates_vl             rtf,
       apps.fnd_application_vl           fav
 WHERE     1 = 1
       AND fcp.concurrent_program_id = fcpl.concurrent_program_id(+)
       AND fcp.enabled_flag = 'Y'
       AND fcp.application_id = fav.application_id(+)
       AND (   :p_concurrent_program_name IS NULL OR (UPPER (fcpl.user_concurrent_program_name) LIKE UPPER ('%' || :p_concurrent_program_name || '%')))
       AND ( ( :p_executable_name is null) or (UPPER (DECODE(fl.meaning,'Oracle Reports',fe.execution_file_name,fcp.concurrent_program_name)) like UPPER ('%' || :p_executable_name || '%')))
       --AND fe.execution_file_name =NVL(:P_EXECUTABLE_NAME,fe.execution_file_name)
       --AND fcpl.user_concurrent_program_name LIKE '%Your Concurrent Program Name%'
       AND '$SRS$.' || fcp.concurrent_program_name = fdfcuv.descriptive_flexfield_name(+)
       AND fdfcuv.flex_value_set_id = ffvs.flex_value_set_id(+)
       AND flv.lookup_type(+) = 'FLEX_DEFAULT_TYPE'
       AND fdfcuv.default_type = flv.lookup_code(+)
       AND flv.language(+) = 'US'
       AND fl.lookup_type(+) = 'CP_EXECUTION_METHOD_CODE'
       AND fcp.execution_method_code = fl.lookup_code(+)
       AND fcp.executable_id = fe.executable_id(+)
       AND fe.executable_id = fev.executable_id(+)
       AND fav.application_id = rtf.application_id(+)
       AND fe.execution_file_name = rtf.template_code(+)
order by fcpl.user_concurrent_program_name,fdfcuv.column_seq_num;

--------------------------------------------------------------------------------rtf

SELECT DISTINCT (xl.file_name)              "Pemplates File Name",
                xddv.data_source_code       "Data Definition Code",
                xddv.data_source_name       "Data Definition",
                xddv.description            "Data Definition Description",
                xtb.template_code           "Template Code",
                xtt.template_name           "Template Name",
                xtt.description             "Template Description",
                xtb.template_type_code      "Type",
                xtb.default_output_type     "Default Output Type"
  FROM apps.xdo_ds_definitions_vl  xddv,
       apps.xdo_templates_b        xtb,
       apps.xdo_templates_tl       xtt,
       apps.xdo_lobs               xl,
       apps.fnd_application_tl     fat,
       apps.fnd_application        fa
 WHERE     xddv.data_source_code LIKE 'XXDBLOINVSTLDGR%' --template rdf/rtf name
       AND xddv.application_short_name = fa.application_short_name
       AND fat.application_id = fa.application_id
       AND xtb.application_short_name = xddv.application_short_name
       AND xddv.data_source_code = xtb.data_source_code
       AND xtt.template_code = xtb.template_code
       AND xl.lob_code = xtb.template_code
       AND xl.xdo_file_type = xtb.template_type_code;
       