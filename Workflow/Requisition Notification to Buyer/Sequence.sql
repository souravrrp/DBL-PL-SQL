/* Formatted on 7/13/2020 10:45:12 AM (QP5 v5.287) */
/* Formatted on 7/7/2020 5:26:00 PM (QP5 v5.287) */
CREATE SEQUENCE APPS.XXDBLREQAPPSEQ_S START WITH 1001
                                      MAXVALUE 9999999999999999999999999999
                                      MINVALUE 0
                                      NOCYCLE
                                      NOCACHE
                                      NOORDER
                                      NOKEEP
                                      GLOBAL;


SELECT APPS.XXDBLREQAPPSEQ_S.NEXTVAL 
--INTO v_seq_no 
FROM DUAL;