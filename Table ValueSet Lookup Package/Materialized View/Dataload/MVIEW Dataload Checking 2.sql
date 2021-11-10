/* Formatted on 11/8/2021 4:35:37 PM (QP5 v5.365) */
EXEC ad_zd_mview.upgrade('APPS','XXDBL_INV_CON_RPT_MV');

SELECT *
  FROM dba_objects
 WHERE object_name LIKE 'XXDBL_INV_CON_RPT_MV%';

BEGIN
    DBMS_MVIEW.refresh ('APPS.XXDBL_INV_CON_RPT_MV',
                        method           => 'C',
                        ATOMIC_REFRESH   => FALSE);
END;

BEGIN
    DBMS_MVIEW.refresh ('XXDBL_INV_CON_RPT_MV');
END;

SELECT status, object_type
  FROM user_objects
 WHERE     object_name = 'XXDBL_INV_CON_RPT_MV'
       AND object_type = 'MATERIALIZED VIEW';

SELECT mview_name, compile_state
  FROM user_mviews
 WHERE compile_state <> 'VALID';


EXECUTE dbms_mview.refresh('XXDBL_INV_CON_RPT_MV');

ALTER MATERIALIZED VIEW XXDBL_INV_CON_RPT_MV ENABLE QUERY REWRITE;

EXECUTE dbms_stats.gather_table_stats( user, 'XXDBL_INV_CON_RPT_MV' );