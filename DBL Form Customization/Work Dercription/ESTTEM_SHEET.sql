SELECT DISTINCT
          p.project_id,
          pb.building_id,
          bl.building_level_id,
          pa.appartment_id,
          AL.UNIT_LOCATION_ID,
          estimation_date,
          p.company_id org_id,
          operating_unit,
          pem.revision_num,
          INITCAP (p.project_name) project_name,
          INITCAP (project_type) project_type,
          INITCAP (pb.building_name) building_name,
          INITCAP (bl.building_level_lookup_code) building_level_name,
          pa.alloted_size,
          noj.nature_of_job_id,
          INITCAP (nature_of_job_name) nature_of_job_name,
          wd.work_description_id,
          INITCAP (work_description) work_description,
          swd.sub_work_description_id,
          INITCAP (swd.sub_work_description) sub_work_description,
          pwq.other_specification,
          pwq.sub_work_unit,
          pwq.sub_work_qty,
          labor_rate,
          NVL (pwq.sub_work_qty, 0) * NVL (labor_rate, 0) labor_cost,
          pwq.start_date work_start_date,
          pwq.end_date work_end_date,
          pwq.start_date_actual,
          pwc.comp_work_qty,
          pwc.complete_date,
          CASE
             WHEN     NVL (pwq.sub_work_qty, 0) > 0
                  AND NVL (pwc.comp_work_qty, 0) > 0
             THEN
                NVL (pwc.comp_work_qty, 0) / pwq.sub_work_qty * 100
             ELSE
                NULL
          END
             comp_work_percent,
          material_cost,
          pwq.project_work_qty_id
     FROM all_project_info_master p,
          project_building_info pb,
          project_building_level bl,
          project_appartment_info pa,
          project_appart_location al,
          --APPARTMENT_LOCATION L,
          (SELECT *
             FROM project_estimation_master p
            WHERE revision_num =
                     (SELECT MAX (revision_num)
                        FROM project_estimation_master
                       WHERE     project_id = p.project_id
                             AND building_id = p.building_id)) pem,
          nature_of_job noj,
          work_description wd,
          sub_work_description swd,
          project_wise_work_qnt_mst pwm,
          project_wise_work_qnt pwq,
          (  SELECT project_work_qty_id,
                    SUM (NVL (comp_work_qty, 0)) comp_work_qty,
                    MAX (complete_date) complete_date
               FROM project_wise_work_monitor
           GROUP BY project_work_qty_id) pwc,
          (  SELECT project_work_qty_id,
                    SUM (NVL (quantity, 0) * NVL (unit_price, 0)) material_cost
               FROM project_wise_material_qnt
           GROUP BY project_work_qty_id) pmq
    WHERE     p.project_id = pb.project_id(+)
          AND pb.project_id = bl.project_id(+)
          AND pwm.nature_of_job_id = noj.nature_of_job_id(+)
          AND pwm.nature_of_job_id = wd.nature_of_job_id(+)
          AND pwm.work_description_id = wd.work_description_id(+)
          AND pwq.nature_of_job_id = swd.nature_of_job_id(+)
          AND pwq.work_description_id = swd.work_description_id(+)
          AND pwq.sub_work_description_id = swd.sub_work_description_id(+)
          AND pb.building_id = bl.building_id(+)
          AND bl.project_id = pa.project_id(+)
          AND bl.building_id = pa.building_id(+)
          AND bl.building_level_id = pa.building_level_id(+)
          AND pa.project_id = al.project_id(+)
          AND pa.building_id = al.building_id(+)
          AND pa.building_level_id = al.building_level_id(+)
          AND pa.appartment_id = al.appartment_id(+)
          -- AND AL.UNIT_LOCATION_ID = L.UNIT_LOCATION_ID(+)
          AND pb.project_id = pem.project_id(+)
          AND pb.building_id = pem.building_id(+)
          AND al.project_id = pwm.project_id(+)
          AND al.building_id = pwm.building_id(+)
          AND al.building_level_id = pwm.building_level_id(+)
          AND al.unit_location_id = pwm.unit_location_id(+)
          AND pwm.project_id = pwq.project_id(+)
          AND pwm.building_id = pwq.building_id(+)
          AND pwm.building_level_id = pwq.building_level_id(+)
          AND pwm.unit_location_id = pwq.unit_location_id(+)
          AND pwm.nature_of_job_id = pwq.nature_of_job_id(+)
          AND pwm.work_description_id = pwq.work_description_id(+)
          AND pwq.project_work_qty_id = pwc.project_work_qty_id(+)
          AND pwq.project_work_qty_id = pmq.project_work_qty_id(+)
          AND pwq.project_id=182
          AND pwq.sub_work_description_id =1204
          
          
          PROJECT_WISE_MATERIAL_QNT

select
*
from
xx_project_progress_vu

SELECT
*
FROM
project_wise_work_qnt pwq
WHERE PROJECT_ID=182
AND SUB_WORK_DESCRIPTION_ID=1204

select
*
from
PROJECT_WISE_MATERIAL_QNT
WHERE 1=1
AND ORGANIZATION_ID IS NULL
--AND PROJECT_ID=119
--AND SUB_WORK_DESCRIPTION_ID=1002


SELECT
*
FROM
ORG_ORGANIZATION_DEFINITIONS
--WHERE OPERATING_UNIT=157