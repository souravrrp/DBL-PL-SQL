/* Formatted on 11/9/2021 11:02:56 AM (QP5 v5.365) */
SELECT (CASE
            WHEN SUBSTR (column_name, 1, 4) = 'RSIN'
            THEN
                'Resin'
            WHEN     SUBSTR (column_name, 1, 4) = 'GROO'
                 AND SUBSTR (column_name, 1, 4) = 'GROO'
            THEN
                'Grooving'
            ELSE
                'Others'
        END)    column_title
  FROM DUAL