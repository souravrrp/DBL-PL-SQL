  SELECT rt.routing_no,
         a.organization_id,
         ood.organization_code,
         a.batch_no,
         bg.GROUP_DESC,
         a.actual_start_date,
         TO_CHAR (a.actual_start_date, 'MON-YY') START_Period,
                        DECODE (a.batch_status,
                 1, 'Pending',
                 2, 'WIP',
                 3, 'Completed',
                 4, 'Closed',
                 -1, 'Cancelled',
                 'Others')
            AS Batch_status,
         TO_CHAR (a.actual_cmplt_date, 'MON-YY') Com_Period,
         TO_CHAR (a.batch_close_date, 'MON-YY') Close_Period,
         SUM (DECODE (b.line_type, -1, b.actual_qty)) AS ING,
         SUM (DECODE (b.line_type, 1, b.actual_qty)) AS Prod,
         SUM (DECODE (b.line_type, 2, b.actual_qty)) AS BY_prod
    FROM apps.gme_batch_header a,
         apps.gme_material_details b,
         apps.org_organization_definitions ood,
         apps.gmd_routings_b rt,
        (select batch_id , gba.group_id , GROUP_DESC from  gme.gme_batch_groups_association gba,
         gme.gme_batch_groups_tl gbt
         where gba.group_id =gbt.group_id ) bg
   WHERE     a.organization_id =NVL(:P17_ORG_ID,a.organization_id)--158 --IN (145,159,153)
     --    and a.actual_start_date>='31-MAR-2019'
   --     AND to_char(a.actual_start_date,'MON-YY')='JUL-16'
    --       AND to_char(A.actual_cmplt_date,'MON-YY')<>'JUL-16'
    --     and a.actual_start_date<'01-MAY-2019'
    AND a.batch_id=bg.batch_id (+)
         AND a.batch_id= b.batch_id
            AND a.organization_id = b.organization_id
         AND a.organization_id = ood.organization_id
         AND a.routing_id = rt.routing_id
        and a.batch_status not in (1,-1)
        AND trunc (a.actual_start_date) between nvl (:P17_FROM_DATE, a.actual_start_date) and nvl (:P17_TO_DATE,a.actual_start_date)
        AND b.batch_id=NVL(:P17_BATCH_ID,b.batch_id)
--AND b.dtl_um='KG'
GROUP BY a.organization_id,
         ood.organization_code,
         a.batch_no,
         a.attribute4,
         a.actual_start_date,
         a.batch_status,
         a.actual_cmplt_date,
         rt.routing_no,
         a.BATCH_CLOSE_DATE,
         bg.GROUP_DESC
ORDER BY 1 DESC;