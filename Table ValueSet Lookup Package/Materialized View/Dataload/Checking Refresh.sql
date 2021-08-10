/* Formatted on 8/3/2021 11:12:10 AM (QP5 v5.287) */
  SELECT um.mview_name,
         um.refresh_mode,
         um.refresh_method,
         um.last_refresh_type,
         um.last_refresh_date
    --um.*
    FROM user_mviews um
   WHERE um.last_refresh_date IS NOT NULL
ORDER BY um.last_refresh_date DESC;


  SELECT log_owner,
         master,
         log_table,
         dml.*
    FROM dba_mview_logs dml
   WHERE last_purge_date IS NOT NULL
ORDER BY last_purge_date DESC;

SELECT MVIEW_NAME,
       DETAILOBJ_NAME,
       DETAILOBJ_PCT,
       NUM_FRESH_PCT_PARTITIONS,
       NUM_STALE_PCT_PARTITIONS
  FROM USER_MVIEW_DETAIL_RELATIONS
 WHERE MVIEW_NAME = 'XXDBL_GL_DTL_STAT_MV';



BEGIN
   DBMS_MVIEW.REFRESH ('XXDBL_GL_DTL_STAT_MV',
                       'F',
                       '',
                       TRUE,
                       FALSE,
                       0,
                       0,
                       0,
                       FALSE,
                       FALSE);
END;
/

SELECT owner,
       NAME,
       snapshot_site,
       TO_CHAR (current_snapshots, 'mm/dd/yyyy hh24:mi') current_snapshots
  FROM dba_registered_snapshots, dba_snapshot_logs
 WHERE     dba_registered_snapshots.snapshot_id =
              dba_snapshot_logs.snapshot_id(+)
       AND dba_snapshot_logs.MASTER = '&table_name'
/


ALTER MATERIALIZED VIEW XXDBL_GL_DTL_STAT_MV
   REFRESH
      ON DEMAND;

CREATE MATERIALIZED VIEW LOG ON "GL"."GL_JE_LINES"
   WITH ROWID
   INCLUDING NEW VALUES;