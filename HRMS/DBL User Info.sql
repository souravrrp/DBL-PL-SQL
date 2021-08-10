/* Formatted on 10/4/2020 9:58:24 AM (QP5 v5.287) */
SELECT *
  FROM FND_USER
 WHERE     1 = 1
       AND ( ( :P_EMP_ID IS NULL) OR (USER_NAME = :P_EMP_ID))
       AND ( ( :P_USER_ID IS NULL) OR (USER_ID = :P_USER_ID));