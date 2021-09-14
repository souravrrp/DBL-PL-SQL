/* Formatted on 9/13/2021 1:22:08 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW APPS.XXDBL_INV_ITEM_CST_RPT_MV#
(
    ITEM_CODE,
    DESCRIPTION,
    PRIMARY_UOM_CODE,
    ITEM_TYPE,
    ARTICLE,
    COLOR_GROUP,
    BRAND,
    ORGANIZATION_ID,
    ORGANIZATION_CODE,
    LEGAL_ENTITY_ID,
    PERIOD_ID,
    CMPNT_GROUP,
    PERIOD_DESC,
    COST_CMPNTCLS_DESC,
    COSTCALC_ORIG,
    ITEM_COST
)
AS
      ------------CCL--------------
      SELECT msi.concatenated_segments          AS item_code,
             msi.description,
             msi.primary_uom_code,
             mic.segment1                       AS item_type,
             mic.segment2                       AS article,
             mic.segment3                       AS color_group,
             mic.segment4                       AS brand,
             odd.organization_id,
             odd.organization_code,
             clm.legal_entity_id,
             clm.period_id,
             cm.cmpnt_group,
             clm.period_desc,
             cm.cost_cmpntcls_desc,
             cd.costcalc_orig,
             ROUND (SUM (cd.cmpnt_cost), 2)     AS item_cost
        FROM apps.cm_cmpt_mst                 cm,
             apps.cm_cmpt_dtl                 cd,
             apps.mtl_system_items_kfv        msi,
             apps.cm_cldr_mst_v               clm,
             apps.mtl_item_categories_v       mic,
             apps.org_organization_definitions odd
       WHERE     cd.period_id = clm.period_id
             AND cm.cost_cmpntcls_id = cd.cost_cmpntcls_id
             AND cd.organization_id = odd.organization_id
             AND cd.inventory_item_id = msi.inventory_item_id
             AND cd.organization_id = msi.organization_id
             AND msi.organization_id = mic.organization_id
             AND msi.inventory_item_id = mic.inventory_item_id
             AND mic.category_set_id = 1100000062
             AND odd.organization_id IN (150)
    GROUP BY msi.concatenated_segments,
             msi.description,
             msi.primary_uom_code,
             mic.segment1,
             mic.segment2,
             mic.segment3,
             mic.segment4,
             odd.organization_id,
             odd.organization_code,
             clm.legal_entity_id,
             clm.period_id,
             cm.cmpnt_group,
             clm.period_desc,
             cd.costcalc_orig,
             cm.cost_cmpntcls_desc
    UNION ALL
      ------------CERAMIC--------------
      SELECT msi.concatenated_segments          AS item_code,
             msi.description,
             msi.primary_uom_code,
             mic.segment1                       AS item_type,
             mic.segment2                       AS article,
             mic.segment3                       AS color_group,
             mic.segment4                       AS brand,
             odd.organization_id,
             odd.organization_code,
             clm.legal_entity_id,
             clm.period_id,
             cm.cmpnt_group,
             clm.period_desc,
             cm.cost_cmpntcls_desc,
             cd.costcalc_orig,
             ROUND (SUM (cd.cmpnt_cost), 2)     AS item_cost
        FROM apps.cm_cmpt_mst                 cm,
             apps.cm_cmpt_dtl                 cd,
             apps.mtl_system_items_kfv        msi,
             apps.cm_cldr_mst_v               clm,
             apps.mtl_item_categories_v       mic,
             apps.org_organization_definitions odd
       WHERE     cd.period_id = clm.period_id
             AND cm.cost_cmpntcls_id = cd.cost_cmpntcls_id
             AND cd.organization_id = odd.organization_id
             AND cd.inventory_item_id = msi.inventory_item_id
             AND cd.organization_id = msi.organization_id
             AND msi.organization_id = mic.organization_id
             AND msi.inventory_item_id = mic.inventory_item_id
             AND mic.category_set_id = 1
             AND odd.organization_id IN (152)
    GROUP BY msi.concatenated_segments,
             msi.description,
             msi.primary_uom_code,
             mic.segment1,
             mic.segment2,
             mic.segment3,
             mic.segment4,
             odd.organization_id,
             odd.organization_code,
             clm.legal_entity_id,
             clm.period_id,
             cm.cmpnt_group,
             clm.period_desc,
             cd.costcalc_orig,
             cm.cost_cmpntcls_desc
    UNION ALL
      ------------PHARMA--------------

      SELECT msi.concatenated_segments          AS item_code,
             msi.description,
             msi.primary_uom_code,
             mic.segment1                       AS item_type,
             mic.segment2                       AS article,
             mic.segment3                       AS color_group,
             mic.segment4                       AS brand,
             odd.organization_id,
             odd.organization_code,
             clm.legal_entity_id,
             clm.period_id,
             cm.cmpnt_group,
             clm.period_desc,
             cm.cost_cmpntcls_desc,
             cd.costcalc_orig,
             ROUND (SUM (cd.cmpnt_cost), 2)     AS item_cost
        FROM apps.cm_cmpt_mst                 cm,
             apps.cm_cmpt_dtl                 cd,
             apps.mtl_system_items_kfv        msi,
             apps.cm_cldr_mst_v               clm,
             apps.mtl_item_categories_v       mic,
             apps.org_organization_definitions odd
       WHERE     cd.period_id = clm.period_id
             AND cm.cost_cmpntcls_id = cd.cost_cmpntcls_id
             AND cd.organization_id = odd.organization_id
             AND cd.inventory_item_id = msi.inventory_item_id
             AND cd.organization_id = msi.organization_id
             AND msi.organization_id = mic.organization_id
             AND msi.inventory_item_id = mic.inventory_item_id
             AND mic.category_set_id = 1
             AND odd.organization_id IN (158)
    GROUP BY msi.concatenated_segments,
             msi.description,
             msi.primary_uom_code,
             mic.segment1,
             mic.segment2,
             mic.segment3,
             mic.segment4,
             odd.organization_id,
             odd.organization_code,
             clm.legal_entity_id,
             clm.period_id,
             cm.cmpnt_group,
             clm.period_desc,
             cd.costcalc_orig,
             cm.cost_cmpntcls_desc;



--------------------------------------------------------------------------------
EXEC ad_zd_mview.upgrade('APPS','XXDBL_INV_ITEM_CST_RPT_MV');

SELECT *
  FROM dba_objects
 WHERE object_name LIKE 'XXDBL_INV_ITEM_CST_RPT_MV%';


--------------------------------------------------------------------------------


EXECUTE dbms_mview.refresh('APPS.XXDBL_INV_ITEM_CST_RPT_MV',method =>'C',ATOMIC_REFRESH=>FALSE);

BEGIN
    DBMS_MVIEW.refresh ('APPS.XXDBL_INV_ITEM_CST_RPT_MV',
                        method           => 'C',
                        atomic_refresh   => FALSE);
END;

EXECUTE dbms_mview.refresh('APPS.XXDBL_INV_ITEM_CST_RPT_MV','C', NULL, TRUE,FALSE,1,0,0,FALSE,FALSE,TRUE);


--------------------------------------------------------------------------------


BEGIN
    SYS.DBMS_SCHEDULER.create_job (
        job_name          => 'XXDBL_MVIEW_SCHEDULER',
        job_type          => 'PLSQL_BLOCK',
        job_action        =>
            'BEGIN EXECUTE dbms_mview.refresh(''APPS.XXDBL_INV_ITEM_CST_RPT_MV'',method => ''C'',ATOMIC_REFRESH=>FALSE) END;',
        start_date        => SYSTIMESTAMP,
        repeat_interval   => 'freq=hourly; byminute=0',
        end_date          => NULL,
        enabled           => TRUE,
        comments          =>
            'Job defined entirely by the CREATE JOB procedure.');
END;
/


BEGIN
    SYS.DBMS_SCHEDULER.DROP_JOB (job_name => 'APPS.XXDBL_MVIEW_SCHEDULER');
END;
/


BEGIN
    SYS.DBMS_SCHEDULER.create_job (
        job_name          => 'XXDBL_MVIEW_SCHEDULER',
        job_type          => 'STORED_PROCEDURE',
        job_action        => 'APPS.XXDBL_MVIEW_DTLD_PKG.RUN_MVIEW_DATALOAD_PROC',
        start_date        => SYSTIMESTAMP,
        repeat_interval   => 'freq=minutely; interval=15; bysecond=0;',
        end_date          => NULL,
        enabled           => TRUE,
        comments          =>
            'Job defined entirely by the CREATE JOB procedure.');
END;
/

BEGIN
    SYS.DBMS_SCHEDULER.create_job (
        job_name          => 'XXDBL_MVIEW_SCHEDULER',
        job_type          => 'PLSQL_BLOCK',
        job_action        =>
            'BEGIN APPS.XXDBL_MVIEW_DTLD_PKG.RUN_MVIEW_DATALOAD_PROC; END;',
        start_date        => SYSTIMESTAMP,
        repeat_interval   => 'freq=daily; byhour=1; byminute=0; bysecond=0;',
        end_date          => NULL,
        enabled           => TRUE,
        comments          =>
            'Job Scheduled Created for Update Materialized View.');
END;
/

BEGIN
    DBMS_SCHEDULER.set_attribute (
        name        => 'APPS.XXDBL_MVIEW_SCHEDULER',
        attribute   => 'repeat_interval',
        VALUE       => 'freq=daily; byhour=1,13; byminute=30; bysecond=0;');
END;
/


-- Display job run details.

  SELECT *
    FROM all_scheduler_job_run_details
   WHERE 1 = 1 AND job_name = 'XXDBL_MVIEW_SCHEDULER'
ORDER BY actual_start_date DESC;

--------------------------------------------------------------------------------


SELECT *
  FROM APPS.XXDBL_INV_ITEM_CST_RPT_MV
 WHERE 1 = 1 
 AND PERIOD_DESC = 'JUL-21'
             --AND ORGANIZATION_ID = 195

 --------------------------------------------------------------------------
      ----------XXDBL_INV_ITEM_CST_RPT_MV MVIEW DATALOAD--------------------------
      --------------------------------------------------------------------------
      IF p_mview = 'XXDBL_INV_ITEM_CST_RPT_MV'
      THEN
         BEGIN
            x_mview_name := 'XXDBL_INV_ITEM_CST_RPT_MV';
            DBMS_MVIEW.refresh (  'APPS.XXDBL_INV_ITEM_CST_RPT_MV',
                                METHOD           => 'C',
                                ATOMIC_REFRESH   => FALSE);
COMMIT;
            fnd_file.put_line (
               fnd_file.LOG,
               'Successfully Refresh the Materialized View :' || x_mview_name);
         END;