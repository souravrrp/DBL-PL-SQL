/* Formatted on 2/7/2021 4:10:43 PM (QP5 v5.354) */
  SELECT sob.name              "Set of Books",
         ps.period_name        "Period Name",
         ps.start_date         "Period Start Date",
         ps.end_date           "Period End Date",
         DECODE (ps.closing_status,
                 'O', 'O - Open',
                 'N', 'N - Never Opened',
                 'F', 'F - Future Enterable',
                 'C', 'C - Closed',
                 'Unknown')    "Period Status"
    FROM gl_period_statuses ps, gl_sets_of_books sob, fnd_application_vl fnd
   WHERE     ps.application_id = '201'
         AND ps.period_name = 'FEB-21'
         AND sob.set_of_books_id = ps.set_of_books_id
         AND fnd.application_id = ps.application_id
         AND ps.adjustment_period_flag = 'N'
         AND (TRUNC (SYSDATE) BETWEEN TRUNC (ps.start_date)
                                  AND TRUNC (ps.end_date))
ORDER BY ps.set_of_books_id, ps.start_date;