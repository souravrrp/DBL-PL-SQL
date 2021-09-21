/* Formatted on 9/19/2021 11:17:07 AM (QP5 v5.354) */
SELECT *
  FROM QA_PLANS_V
 WHERE 1 = 1 AND NAME = 'ECO THREAD QUALITY PLAN_FG';


SELECT *
  FROM QA.QA_PLANS QP
 WHERE QP.NAME = 'ECO THREAD QUALITY PLAN_FG';

SELECT * FROM QA_PLAN_CHARS_V;

SELECT *
  FROM QA.QA_RESULTS QR;
  
  SELECT qp.plan_id,
       qp.NAME "Plan Name",
       qp.DESCRIPTION,  
       qp.PLAN_TYPE_CODE "Plan Type",
       qc.NAME "Element Name",
       qpc.PROMPT_SEQUENCE,
       qpc.prompt "Element Prompt",
       qpc.result_column_name "CHARACTER_ID",
       decode(qpc.ENABLED_FLAG,1,'Y', 'N') "ENABLED_FLAG",
       decode(qpc.MANDATORY_FLAG, 1, 'Y', 'N') "MANDATORY_FLAG", 
       decode(qpc.DISPLAYED_FLAG, 1, 'Y', 'N') "DISPLAYED_FLAG", 
       decode(qpc.READ_ONLY_FLAG , 1, 'Y', 'N') "READ_ONLY_FLAG",
       qc.CHAR_TYPE_CODE "Element Type",
       qc.DISPLAY_LENGTH,
       qc.sql_validation_string "Element SQL Statement"
  FROM qa_plans qp,        qa_plan_chars qpc,        qa_chars qc   
 WHERE 1 = 1   
   AND qpc.plan_id = 9100 ---<<<-----------Insert Your PLAN_ID here-------    
   AND qc.char_id = qpc.char_id    
   AND qp.plan_id = qpc.plan_id;

SELECT *
  FROM QA.QA_PLANS QP                                     --, QA.QA_RESULTS QR
 WHERE QP.NAME = 'ECO THREAD QUALITY PLAN_FG'
--AND QP.PLAN_ID = QR.PLAN_ID
