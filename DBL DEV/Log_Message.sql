/* Formatted on 9/23/2020 11:27:01 AM (QP5 v5.287) */
SELECT MAX (LOG_SEQUENCE) before_seq FROM FND_LOG_MESSAGES;

--BEFORE_SEQ : 114536417

SELECT MAX (LOG_SEQUENCE) after_seq FROM FND_LOG_MESSAGES;

--AFTER_SEQ  : 115684609

  SELECT module, MESSAGE_TEXT
    FROM fnd_log_messages
   WHERE log_sequence BETWEEN &before_seq AND &after_seq
ORDER BY log_sequence;

   --Output given by Excel:1.Query.xls

  SELECT *
    FROM fnd_log_messages
   WHERE log_sequence BETWEEN &before_seq AND &after_seq
ORDER BY log_sequence;

    --Output given by Excel.:2.Query.xls