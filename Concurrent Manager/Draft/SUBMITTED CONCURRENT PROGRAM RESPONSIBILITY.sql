/* Formatted on 7/8/2019 4:12:29 PM (QP5 v5.287) */
  SELECT B.user_concurrent_program_name,
         C.user_name,
         D.responsibility_name,
         A.*
    FROM apps.fnd_concurrent_requests A,
         apps.fnd_concurrent_programs_tl B,
         Apps.fnd_user C,
         apps.fnd_responsibility_tl D
   WHERE     1 = 1
         AND B.user_concurrent_program_name LIKE
                'SCIL Sales Order by Date%Customer (Excel)'
         AND B.concurrent_program_id = A.concurrent_program_id
         AND A.requested_by = C.user_id
         AND A.responsibility_id = D.responsibility_id
         AND b.language = USERENV ('LANG')
         AND d.language = USERENV ('LANG')
ORDER BY request_date DESC;


  SELECT E.FILE_NAME,
         B.USER_CONCURRENT_PROGRAM_NAME,
         C.USER_NAME,
         D.RESPONSIBILITY_NAME,
         A.*
    FROM apps.fnd_concurrent_requests A,
         apps.fnd_concurrent_programs_tl B,
         Apps.fnd_user C,
         apps.fnd_responsibility_tl D,
         apps.FND_CONC_REQ_OUTPUTS_V E
   WHERE     1 = 1
         AND B.user_concurrent_program_name LIKE
                'SCIL Sales Order by Date%(Excel)'
         AND B.concurrent_program_id = A.concurrent_program_id
         AND A.REQUESTED_BY = C.USER_ID
         AND c.user_name = '37163'
         AND A.RESPONSIBILITY_ID = D.RESPONSIBILITY_ID
         AND E.REQUEST_ID(+) = A.REQUEST_ID
         AND b.language = USERENV ('LANG')
         AND d.language = USERENV ('LANG')
ORDER BY request_date;