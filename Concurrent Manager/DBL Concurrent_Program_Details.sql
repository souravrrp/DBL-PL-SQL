/* Formatted on 11/5/2020 5:54:41 PM (QP5 v5.354) */
  select distinct
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
         fdfcuv.enabled_flag                            " Enabled Flag",
         fdfcuv.required_flag                           "Required Flag",
         fdfcuv.display_flag                            "Display Flag",
         fdfcuv.flex_value_set_id                       "Value Set Id",
         ffvs.flex_value_set_name                       "Value Set Name",
         flv.meaning                                    "Default Type",
         fdfcuv.default_value                           "Default Value",
         rtf.template_code                              rtf_template_name,
         rtf.default_output_type                        output_type
    from apps.fnd_concurrent_programs    fcp,
         apps.fnd_concurrent_programs_vl fcpl,
         apps.fnd_descr_flex_col_usage_vl fdfcuv,
         apps.fnd_flex_value_sets        ffvs,
         apps.fnd_lookup_values          flv,
         apps.fnd_lookups                fl,
         apps.fnd_executables            fe,
         apps.fnd_executables_vl         fev,
         apps.fnd_application_vl         fav,
         apps.xdo_templates_vl           rtf
   where     1 = 1
         and fcp.concurrent_program_id = fcpl.concurrent_program_id
         and fcp.enabled_flag = 'Y'
         and (   ( :p_executable_name is null) or (upper (fe.execution_file_name) like upper ('%' || :p_executable_name || '%')))
         --AND fe.execution_file_name =NVL(:P_EXECUTABLE_NAME,'XXDBLSTOCKDTL')
         and (   :p_concurrent_program_name is null or (upper (fcpl.user_concurrent_program_name) like upper ('%' || :p_concurrent_program_name || '%')))
         --AND fcpl.user_concurrent_program_name LIKE '%AKG List of DOs Paid Bill by Pay Date%' --<Your Concurrent Program Name>
         and fdfcuv.descriptive_flexfield_name = '$SRS$.' || fcp.concurrent_program_name
         and ffvs.flex_value_set_id = fdfcuv.flex_value_set_id
         and flv.lookup_type(+) = 'FLEX_DEFAULT_TYPE'
         and flv.lookup_code(+) = fdfcuv.default_type
         and flv.language(+) = 'US'
         and fl.lookup_type = 'CP_EXECUTION_METHOD_CODE'
         and fl.lookup_code = fcp.execution_method_code
         and fe.executable_id = fcp.executable_id
         and fe.executable_id = fev.executable_id
         and fav.application_id = fev.application_id
         and fav.application_id = rtf.application_id(+)
         and fe.execution_file_name = rtf.template_code(+)
order by fcpl.user_concurrent_program_name,fdfcuv.column_seq_num;

--------------------------------------------------------------------------------rtf

SELECT DISTINCT (XL.file_name)              "Pemplates File Name",
                XDDV.data_source_code       "Data Definition Code",
                XDDV.data_source_name       "Data Definition",
                XDDV.description            "Data Definition Description",
                XTB.template_code           "Template Code",
                XTT.template_name           "Template Name",
                XTT.description             "Template Description",
                XTB.template_type_code      "Type",
                XTB.default_output_type     "Default Output Type"
  FROM apps.XDO_DS_DEFINITIONS_VL  XDDV,
       apps.XDO_TEMPLATES_B        XTB,
       apps.XDO_TEMPLATES_TL       XTT,
       apps.XDO_LOBS               XL,
       apps.FND_APPLICATION_TL     FAT,
       APPS.FND_APPLICATION        FA
 WHERE     XDDV.DATA_SOURCE_CODE LIKE 'XXDBL%' --template rdf/rtf name
       AND XDDV.application_short_name = FA.application_short_name
       AND FAT.application_id = FA.application_id
       AND XTB.application_short_name = XDDV.application_short_name
       AND XDDV.data_source_code = XTB.data_source_code
       AND XTT.template_code = XTB.template_code
       AND XL.LOB_CODE = XTB.TEMPLATE_CODE
       AND XL.XDO_FILE_TYPE = XTB.TEMPLATE_TYPE_CODE;