/* Formatted on 12/12/2019 4:33:03 PM (QP5 v5.287) */
  SELECT SID, USERNAME, ROUND (100 * TOTAL_USER_IO / TOTAL_IO, 2) TOT_IO_PCT
    FROM (  SELECT B.SID SID,
                   NVL (B.USERNAME, P.NAME) USERNAME,
                   SUM (VALUE) TOTAL_USER_IO
              FROM SYS.V_$STATNAME C,
                   SYS.V_$SESSTAT A,
                   SYS.V_$SESSION B,
                   SYS.V_$BGPROCESS P
             WHERE     A.STATISTIC# = C.STATISTIC#
                   AND P.PADDR(+) = B.PADDR
                   AND B.SID = A.SID
                   AND C.NAME IN ('physical reads',
                                  'physical writes',
                                  'physical writes direct',
                                  'physical reads direct',
                                  'physical writes direct (lob)',
                                  'physical reads direct (lob)')
          GROUP BY B.SID, NVL (B.USERNAME, P.NAME)),
         (SELECT SUM (VALUE) TOTAL_IO
            FROM SYS.V_$STATNAME C, SYS.V_$SESSTAT A
           WHERE     A.STATISTIC# = C.STATISTIC#
                 AND C.NAME IN ('physical reads',
                                'physical writes',
                                'physical writes direct',
                                'physical reads direct',
                                'physical writes direct (lob)',
                                'physical reads direct (lob)'))
ORDER BY 3 DESC;