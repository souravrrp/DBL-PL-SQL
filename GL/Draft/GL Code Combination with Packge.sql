/* Formatted on 11/8/2020 11:50:13 AM (QP5 v5.287) */
SELECT gcc.segment1,
       gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, --- chart of account id
                                              1,     ----- Position of segment
                                              gcc.segment1  ---- Segment value
                                                          )
          Segment1_desc,
       gcc.segment2,
       gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, --- chart of account id
                                              2,     ----- Position of segment
                                              gcc.segment2  ---- Segment value
                                                          )
          Segment2_desc,
       gcc.segment3,
       gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, --- chart of account id
                                              3,     ----- Position of segment
                                              gcc.segment3  ---- Segment value
                                                          )
          Segment3_desc,
       gcc.segment4,
       gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, --- chart of account id
                                              4,     ----- Position of segment
                                              gcc.segment4  ---- Segment value
                                                          )
          Segment4_desc,
       gcc.segment5,
       gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, --- chart of account id
                                              5,     ----- Position of segment
                                              gcc.segment5  ---- Segment value
                                                          )
          Segment5_desc,
       gcc.segment6,
       gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, --- chart of account id
                                              6,     ----- Position of segment
                                              gcc.segment6  ---- Segment value
                                                          )
          Segment6_desc,
       gcc.segment7,
       gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, --- chart of account id
                                              7,     ----- Position of segment
                                              gcc.segment7  ---- Segment value
                                                          )
          Segment7_desc,
       gcc.segment8,
       gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, --- chart of account id
                                              8,     ----- Position of segment
                                              gcc.segment8  ---- Segment value
                                                          )
          Segment8_desc,
       gcc.segment9,
       gl_flexfields_pkg.get_description_sql (gcc.chart_of_accounts_id, --- chart of account id
                                              9,     ----- Position of segment
                                              gcc.segment9  ---- Segment value
                                                          )
          Segment8_desc
  FROM gl_code_combinations gcc;


SELECT gl_flexfields_pkg.get_concat_description (chart_of_accounts_id,
                                                 code_combination_id)
  FROM gl_code_combinations
  