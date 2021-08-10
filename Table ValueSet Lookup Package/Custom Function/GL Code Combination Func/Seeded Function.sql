/* Formatted on 4/7/2021 11:38:10 AM (QP5 v5.287) */
SELECT gl_flexfields_pkg.get_description_sql (chart_of_accounts_id, --- chart of account id
                                              2,     ----- Position of segment
                                              segment2      ---- Segment value
                                                      )
  FROM gl_code_combinations;

SELECT gl_flexfields_pkg.get_concat_description (chart_of_accounts_id,
                                                 code_combination_id)
  FROM gl_code_combinations;



SELECT gl_code_combinations.segment6,
       gl_flexfields_pkg.get_sd_description_sql (
          gl_code_combinations.chart_of_accounts_id,
          1,
          6,
          gl_code_combinations.segment6)
          description_6
  --,gl_code_combinations.*
  FROM gl_code_combinations
 WHERE 1 = 1                                         --AND segment6 = '511105'
            AND code_combination_id = 87987