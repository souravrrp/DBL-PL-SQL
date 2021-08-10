SELECT LINE_NO,
       ALLOC_CODE,
       a.alloc_id,
       a.GL_ALOC_INP_ID,
       PERIOD_CODE,
          cc.segment1
       || '.'
       || cc.segment2
       || '.'
       || cc.segment3
       || '.'
       || cc.segment4
       || '.'
       || cc.segment5
       || '.'
       || cc.segment6
       || '.'
       || cc.segment7
       || '.'
       || cc.segment8
       || '.'
       || cc.segment9
          AS Distribution_Account_Number,
       AMOUNT
  FROM GL_ALOC_INP a, GL_ALOC_MST b, apps.gl_code_combinations cc
 WHERE     a.alloc_id = b.alloc_id
       AND ACCOUNT_KEY_TYPE = 1
       AND cc.code_combination_id = a.account_id
       AND PERIOD_CODE = :P_PERIOD_DESC
       AND LEGAL_ENTITY_ID = :P_LEGAL_ENTITY_ID 
       AND AMOUNT <> 0
       AND A.DELETE_MARK = 0;
       
       -------------------------------------------------------------------------
       
       SELECT LINE_NO,
       ALLOC_CODE,
       a.alloc_id,
       a.GL_ALOC_INP_ID,
       period_id,
       PERIOD_CODE,
          cc.segment1
       || '.'
       || cc.segment2
       || '.'
       || cc.segment3
       || '.'
       || cc.segment4
       || '.'
       || cc.segment5
       || '.'
       || cc.segment6
       || '.'
       || cc.segment7
       || '.'
       || cc.segment8
       || '.'
       || cc.segment9
          AS Distribution_Account_Number,
       AMOUNT
  FROM GL_ALOC_INP a, GL_ALOC_MST b, apps.gl_code_combinations cc
 WHERE     a.alloc_id = b.alloc_id
       AND ACCOUNT_KEY_TYPE = 1
       AND cc.code_combination_id = a.account_id
       AND PERIOD_CODE = :P_PERIOD_DESC --'JAN-20'
       AND LEGAL_ENTITY_ID = :P_LEGAL_ENTITY_ID   --23282
       AND AMOUNT <> 0
       AND A.DELETE_MARK = 0