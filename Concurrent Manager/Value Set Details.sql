/* Formatted on 1/31/2021 3:15:56 PM (QP5 v5.354) */
  SELECT fcpl.user_concurrent_program_name     "Concurrent Program Name",
         fcp.concurrent_program_name           "Short Name",
         fdfcuv.column_seq_num                 "Column Seq Number",
         fdfcuv.end_user_column_name           "Parameter Name",
         fdfcuv.form_left_prompt               "Prompt",
         fdfcuv.enabled_flag                   " Enabled Flag",
         fdfcuv.required_flag                  "Required Flag",
         fdfcuv.display_flag                   "Display Flag",
         fdfcuv.flex_value_set_id              "Value Set Id",
         ffvs.flex_value_set_name              "Value Set Name",
         flv.meaning                           "Default Type",
         fdfcuv.DEFAULT_VALUE                  "Default Value"
    FROM fnd_concurrent_programs    fcp,
         fnd_concurrent_programs_tl fcpl,
         fnd_descr_flex_col_usage_vl fdfcuv,
         fnd_flex_value_sets        ffvs,
         fnd_lookup_values          flv
   WHERE     fcp.concurrent_program_id = fcpl.concurrent_program_id
         --AND fcpl.user_concurrent_program_name = :conc_prg_name
         AND fdfcuv.descriptive_flexfield_name =
             '$SRS$.' || fcp.concurrent_program_name
         AND ffvs.flex_value_set_id = fdfcuv.flex_value_set_id
         AND flv.lookup_type(+) = 'FLEX_DEFAULT_TYPE'
         AND flv.lookup_code(+) = fdfcuv.default_type
         AND fcpl.LANGUAGE = USERENV ('LANG')
         AND flv.LANGUAGE(+) = USERENV ('LANG')
         AND ffvs.flex_value_set_name LIKE :P_VALU_SET_NAME
ORDER BY fdfcuv.column_seq_num;