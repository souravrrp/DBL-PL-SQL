/* Formatted on 3/22/2021 10:12:52 AM (QP5 v5.287) */
--XXDBL_TEST_XML_GEN_PKG.P_RUN

SELECT TRUNC (FND_DATE.CANONICAL_TO_DATE (SYSDATE)) date1,
       FND_DATE.CANONICAL_TO_DATE (SYSDATE) date2,
       FND_DATE.displaydate_to_date (SYSDATE) date3,
       FND_DATE.displayDT_to_date (SYSDATE) date4
  FROM DUAL;


SELECT NAME || '.@no-reply.com'
  FROM v$database;


SELECT *
  FROM apps.per_all_people_f papf;


SELECT employee_id
  FROM fnd_user fu
 WHERE fu.user_id = apps.fnd_global.user_id;