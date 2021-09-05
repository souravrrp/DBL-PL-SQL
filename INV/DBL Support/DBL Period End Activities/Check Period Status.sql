/* Formatted on 9/4/2021 10:20:26 AM (QP5 v5.354) */
SELECT ood.organization_code,
       ood.organization_name,
       p.period_name,
       p.status
  FROM org_acct_periods_v p, apps.org_organization_definitions ood, hr_operating_units hou
 WHERE     ood.organization_id = p.organization_id
       AND hou.organization_id = ood.operating_unit
       --AND p.period_name = 'APR-21'
       --AND p.status = 'Open'   --Closed
       --AND ood.organization_code='101'
       AND (   :p_ou_name IS NULL OR (hou.name = :p_ou_name))
       AND (   :p_organization_code IS NULL OR (ood.organization_code = :p_organization_code))
       AND (   :p_organization_id IS NULL OR (ood.organization_id = :p_organization_id))
       AND (   :p_period_name IS NULL OR (p.period_name = :p_period_name))
       AND (   :p_period_status IS NULL OR (p.status = :p_period_status));
       
--------------------------------------------------------------------------------CHECK 
       

  SELECT ood.organization_id,
         ood.organization_code,
         ood.organization_name,
         pn.status
    FROM apps.org_organization_definitions ood,
         org_acct_periods_v               pn,
         hr_operating_units               hou
   WHERE     1 = 1
         AND ood.organization_id = pn.organization_id
         AND hou.organization_id = ood.operating_unit
         AND ( :p_ou_name IS NULL OR (hou.name = :p_ou_name))
         AND pn.period_name = 'AUG-21'
         AND pn.status = 'Open'
         AND NOT EXISTS
                 (SELECT 1
                    FROM org_acct_periods_v p
                   WHERE     1 = 1
                         AND ood.organization_id = p.organization_id
                         AND p.period_name = 'SEP-21'
                         AND p.status = 'Open')
ORDER BY ood.organization_code;
       
--------------------------------------------------------------------------------CHECK WITH NEXT MONTH


SELECT ood.organization_code, ood.ORGANIZATION_NAME, p.STATUS
  FROM org_acct_periods_v                 p,
       apps.org_organization_definitions  ood,
       org_acct_periods_v                 pn
 WHERE     ood.organization_id = p.organization_id(+)
       AND ood.organization_id = pn.organization_id
       AND pn.period_name = 'AUG-21'
       AND pn.status = 'Open'
       AND p.period_name = 'SEP-21'
       AND p.status != 'Open';

--------------------------------------------------------------------------------

SELECT ood.organization_code, ood.organization_name, p.STATUS
  FROM org_acct_periods_v p, apps.org_organization_definitions ood
 WHERE     ood.organization_id = p.organization_id
       AND p.period_name = 'SEP-20'
       AND p.status = 'Open';

SELECT ood.organization_code, ood.organization_name, p.STATUS
  FROM org_acct_periods_v p, apps.org_organization_definitions ood
 WHERE     ood.organization_id = p.organization_id
       AND p.period_name = 'OCT-20'
       AND p.status = 'Open'