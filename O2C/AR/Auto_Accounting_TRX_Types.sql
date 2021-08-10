/* Formatted on 7/28/2020 11:10:24 AM (QP5 v5.354) */
SELECT GL_DEFAULT_ID, TYPE
  FROM RA_ACCOUNT_DEFAULTS_ALL
 WHERE     ORG_ID = &orgid
       AND TYPE IN ('FREIGHT',
                    'REC',
                    'REV',
                    'SUSPENSE',
                    'TAX',
                    'UNBILL',
                    'UNEARN');

--------------------------------------------------------------------------------

SELECT RA.GL_DEFAULT_ID, RA.TYPE,RA.*
  FROM RA_ACCOUNT_DEFAULTS_ALL RA, RA_ACCOUNT_DEFAULT_SEGMENTS RS
 WHERE     ORG_ID = &orgid
       AND RA.GL_DEFAULT_ID = RS.GL_DEFAULT_ID
       AND TYPE IN ('FREIGHT'
--                    'REC',
--                    'REV',
--                    'SUSPENSE',
--                    'TAX',
--                    'UNBILL',
--                    'UNEARN'
                    );

--------------------------------------------------------------------------------


SELECT * FROM RA_ACCOUNT_DEFAULTS;


SELECT * FROM RA_ACCOUNT_DEFAULT_SEGMENTS;