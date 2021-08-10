/* Formatted on 8/9/2021 12:41:03 PM (QP5 v5.354) */
SELECT DISTINCT concatenated_segments, code_combination_id
  --,gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 || '.' || gcc.segment7 || '.' || gcc.segment8 || '.' || gcc.segment9    acct_code
  FROM apps.gl_code_combinations_kfv gcc
 WHERE     1 = 1
       AND ( :p_gl_code IS NULL OR (gcc.concatenated_segments = :p_gl_code))
       --and concatenated_segments in ('201.101.151.18809.511104.998.999.101.999')
       --AND code_combination_id IN (175910)
       AND (   :p_code_comb_id IS NULL
            OR (gcc.code_combination_id = :p_code_comb_id));

SELECT *
  FROM gl.gl_code_combinations gcc
 WHERE     1 = 1
       AND ( :p_gl_code IS NULL OR (gcc.concatenated_segments = :p_gl_code))
       AND (   :p_code_comb_id IS NULL
            OR (gcc.code_combination_id = :p_code_comb_id));