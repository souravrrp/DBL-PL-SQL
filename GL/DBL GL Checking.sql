/* Formatted on 1/11/2022 5:19:40 PM (QP5 v5.374) */
SELECT *
  FROM gl_ledgers gl
 WHERE 1 = 1 AND gl.name = NVL ( :p_ledger_name, gl.name);

SELECT *
  FROM gl_je_batches GLB
 WHERE     1 = 1
       AND GLB.je_batch_id = NVL ( :p_batch_id, GLB.je_batch_id)
       AND GLB.name = NVL ( :p_journal_name, GLB.name);

SELECT *
  FROM gl_je_headers glh
 WHERE     1 = 1
       AND glh.je_batch_id = NVL ( :p_batch_id, glh.je_batch_id)
       AND glh.je_header_id = NVL ( :p_journal_hdr_id, glh.je_header_id)
       AND glh.name = NVL ( :p_journal_name, glh.name);

SELECT *
  FROM gl_je_lines gjl
 WHERE     1 = 1
       AND gjl.je_header_id = NVL ( :p_journal_hdr_id, gjl.je_header_id);