/* Formatted on 11/14/2020 9:52:55 AM (QP5 v5.354) */
  SELECT DISTINCT af.app_short_name,
                  af.filename,
                  afv.version,
                  afv.creation_date
    FROM apps.ad_file_versions afv, apps.ad_files af
   WHERE     afv.file_id = af.file_id
         AND UPPER (af.filename) LIKE UPPER ('CSTLCADB.pls') || '%'
ORDER BY 2, 4 DESC;