/* Formatted on 10/3/2020 11:53:12 AM (QP5 v5.354) */

SELECT ood.organization_code, ood.ORGANIZATION_NAME,p.PERIOD_NAME, p.STATUS
  FROM ORG_ACCT_PERIODS_V p, apps.org_organization_definitions ood
 WHERE     ood.organization_id = p.organization_id
       --AND p.PERIOD_NAME = 'APR-21'
       AND p.status = 'Open'
       AND ood.ORGANIZATION_CODE='101';
       
--------------------------------------------------------------------------------CHECK 
       
SELECT ood.organization_id, ood.organization_code, ood.ORGANIZATION_NAME, pn.STATUS
  FROM apps.org_organization_definitions ood, ORG_ACCT_PERIODS_V pn, hr_operating_units hou
 WHERE     1 = 1
       AND ood.organization_id = pn.organization_id
       AND hou.organization_id = ood.operating_unit
       AND (   :p_ou_name IS NULL OR (hou.name = :p_ou_name))
       AND pn.PERIOD_NAME = 'JUL-21'
       AND pn.status = 'Open'
       AND NOT EXISTS
               (SELECT 1
                  FROM ORG_ACCT_PERIODS_V p
                 WHERE     1 = 1
                       AND ood.organization_id = p.organization_id
                       AND p.PERIOD_NAME = 'APR-21'
                       AND p.status = 'Open')
       ORDER BY ood.organization_code;
       
--------------------------------------------------------------------------------CHECK WITH NEXT MONTH


SELECT ood.organization_code, ood.ORGANIZATION_NAME, p.STATUS
  FROM ORG_ACCT_PERIODS_V                 p,
       apps.org_organization_definitions  ood,
       ORG_ACCT_PERIODS_V                 pn
 WHERE     ood.organization_id = p.organization_id(+)
       AND ood.organization_id = pn.organization_id
       AND pn.PERIOD_NAME = 'JAN-21'
       AND pn.status = 'Open'
       AND p.PERIOD_NAME = 'FEB-21'
       AND p.status != 'Open';

--------------------------------------------------------------------------------

SELECT ood.organization_code, ood.ORGANIZATION_NAME, p.STATUS
  FROM ORG_ACCT_PERIODS_V p, apps.org_organization_definitions ood
 WHERE     ood.organization_id = p.organization_id
       AND p.PERIOD_NAME = 'SEP-20'
       AND p.status = 'Open';

SELECT ood.organization_code, ood.ORGANIZATION_NAME, p.STATUS
  FROM ORG_ACCT_PERIODS_V p, apps.org_organization_definitions ood
 WHERE     ood.organization_id = p.organization_id
       AND p.PERIOD_NAME = 'OCT-20'
       AND p.status = 'Open'