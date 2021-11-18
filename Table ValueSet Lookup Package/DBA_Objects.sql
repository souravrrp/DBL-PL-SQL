/* Formatted on 11/17/2021 10:56:20 AM (QP5 v5.365) */
SELECT COUNT (*)
  FROM DBA_OBJECTS
 WHERE STATUS = 'INVALID';

--------------------------------------------------------------------------------

SELECT *
  FROM DBA_OBJECTS DO
 WHERE     1 = 1
       AND (   ( UPPER(:P_STATUS) IS NULL AND DO.STATUS IN ('VALID', 'INVALID'))
            OR DO.STATUS IN
                   (CASE
                        WHEN UPPER(:P_STATUS) = 'V' THEN 'VALID'
                        WHEN UPPER(:P_STATUS) = 'I' THEN 'INVALID'
                    END))
       AND (   :P_OBJECT_TYPE IS NULL
            OR (UPPER (DO.OBJECT_TYPE) LIKE
                    UPPER ('%' || :P_OBJECT_TYPE || '%')))
       AND (   :P_OBJECT_NAME IS NULL
            OR (UPPER (DO.OBJECT_NAME) LIKE
                    UPPER ('%' || :P_OBJECT_NAME || '%')))
       AND (   :P_OWNER_NAME IS NULL
            OR (UPPER (DO.OWNER) = UPPER ( :P_OWNER_NAME)));