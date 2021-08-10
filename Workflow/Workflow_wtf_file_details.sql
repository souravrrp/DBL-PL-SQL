/* Formatted on 5/20/2020 6:23:38 PM (QP5 v5.287) */
SELECT *
  FROM (SELECT "Filename",
               "US Subdir",
               "US Version",
               "Created",
               "Last Update"
          FROM (SELECT af1.filename "Filename",
                       af1.subdir "US Subdir",
                       afv1.version "US Version",
                       afv1.creation_date "Created",
                       TO_CHAR (afv1.last_update_date, 'DD-MON-YYYY')
                          "Last Update",
                       RANK ()
                          OVER (PARTITION BY af1.filename
                                ORDER BY
                                   afv1.version_segment1 DESC,
                                   afv1.version_segment2 DESC,
                                   afv1.version_segment3 DESC,
                                   afv1.version_segment4 DESC,
                                   afv1.version_segment5 DESC,
                                   afv1.version_segment6 DESC,
                                   afv1.version_segment7 DESC,
                                   afv1.version_segment8 DESC,
                                   afv1.version_segment9 DESC,
                                   afv1.version_segment10 DESC,
                                   afv1.translation_level DESC)
                          AS rankUS
                  FROM ad_files af1, ad_file_versions afv1
                 WHERE     af1.file_id = afv1.file_id
                       AND af1.filename = 'DBLMOA.wft'
                       AND af1.subdir = 'patch/115/import/US')
         WHERE rankUS = 1);


  SELECT f.FILE_ID,
         f.APP_SHORT_NAME "TOP",
         f.SUBDIR,
         f.FILENAME,
         v.file_version_id,
         v.VERSION,
         v.creation_date,
         v.last_update_date,
         fu.USER_NAME "Updated By"
    FROM ad_files f, ad_file_versions v, fnd_user fu
   WHERE f.FILE_ID = v.FILE_ID AND f.FILENAME = 'DBLMOA.wft' --         AND f.subdir = 'patch/115/import/US'
         AND fu.user_id = v.LAST_UPDATED_BY
ORDER BY v.file_version_id DESC;


  SELECT f.FILE_ID,
         f.APP_SHORT_NAME "TOP",
         f.SUBDIR,
         f.FILENAME,
         v.VERSION,
         v.LAST_UPDATE_DATE
    FROM ad_files f, ad_file_versions v
   WHERE f.FILE_ID = v.FILE_ID AND f.FILENAME = 'dblmoa.wft'
ORDER BY 6 DESC;

