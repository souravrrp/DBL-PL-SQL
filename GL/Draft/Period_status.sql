/* Formatted on 6/3/2019 9:37:27 AM (QP5 v5.287) */
  SELECT fat.application_name application,
         LEDGER_ID,
         gsp.name SETOFBOOK,
         period_name,
         closing_status,
         --  DECODE (gps.closing_status, 'O', 'Open', 'C', 'Closed', 'F', 'Future', 'N', 'Never' ) status,
         DECODE (gps.closing_status,
                 'C', 'Closed',
                 'O', 'Open',
                 'F', 'Future',
                 'W', 'Closed Pending',
                 'N', 'Never Opened',
                 'P', 'Permanently Closed')
            status,
         period_num,
         period_year,
         start_date,
         end_date
    FROM apps.GL_PERIOD_STATUSES GPS,
         apps.gl_sets_of_books gsp,
         apps.fnd_application_tl fat
   WHERE     1 = 1
         AND GSP.SET_OF_BOOKS_ID = GPS.SET_OF_BOOKS_ID
         AND fat.application_id = gps.application_id
         AND PERIOD_YEAR = '2019'
         --and period_name='SEP-19'
         AND gsp.name = 'Cement Ledger'
         AND fat.application_name = 'Receivables'
         AND gps.closing_status = 'O'
ORDER BY period_year DESC, period_num DESC;

---------------------------------INVENTORY PERIOD----------------------------------------

  SELECT OOD.OPERATING_UNIT,
         OOD.ORGANIZATION_NAME,
         OOD.ORGANIZATION_CODE,
         OOD.ORGANIZATION_ID,
         OAP.STATUS,
         OAP.PERIOD_NAME,
         OAP.PERIOD_YEAR
    --,OOD.*
    --,OAP.*
    FROM APPS.ORG_ACCT_PERIODS_V OAP, APPS.ORG_ORGANIZATION_DEFINITIONS OOD
   WHERE     1 = 1
         AND OAP.ORGANIZATION_ID = OOD.ORGANIZATION_ID 
         --AND OOD.ORGANIZATION_ID=:P_ORGANIZATION_ID--101
         --AND ORGANIZATION_CODE = 'CRT' 
         --AND OPERATING_UNIT=:P_OPERATING_UNIT--85
           AND PERIOD_NAME='JUN-20'
         AND PERIOD_YEAR = '2020'
         AND STATUS = 'Open'
ORDER BY OAP.PERIOD_NAME DESC;


---------------------------------PROJECT PERIOD-------------------------------------------

SELECT   --PPA.NAME PROJECT_NAME
      OU.NAME OPERATING_UNITS,
       PA.ORG_ID,
       OU.SHORT_CODE ORG_CODE,
       OU.SET_OF_BOOKS_ID,
       PA.PERIOD_NAME,
       PA.STATUS,
       OOD.ORGANIZATION_ID,
       OOD.ORGANIZATION_CODE,
       OOD.ORGANIZATION_NAME
  --,OOD.*
  FROM APPS.PA_PERIODS_ALL PA,
       --,APPS.PA_PROJECTS_ALL PPA
       APPS.PA_ALL_ORGANIZATIONS PAO,
       APPS.HR_OPERATING_UNITS OU,
       APPS.ORG_ORGANIZATION_DEFINITIONS OOD
 WHERE     1 = 1
       AND PA.ORG_ID = PAO.ORG_ID
       AND PA.ORG_ID = OU.ORGANIZATION_ID
       AND PAO.ORGANIZATION_ID = OOD.ORGANIZATION_ID
       --AND PA.ORG_ID=PPA.ORG_ID
       AND PA.STATUS = 'O'  --'P'   --'O'
       AND PA.ORG_ID = 85
       AND PA.PERIOD_NAME = 'JAN-19';


-----------------------------------------GL PERIOD-------------------------------------------

SELECT *
  FROM apps.GL_PERIOD_STATUSES GPS;

--------------------------------------------------------------------------------
SELECT FAT.APPLICATION_NAME APPLICATION,
         LEDGER_ID,
         GSP.NAME SETOFBOOK,
         PERIOD_NAME,
         DECODE (GPS.CLOSING_STATUS,
                 'C', 'Closed',
                 'O', 'Open',
                 'F', 'Future',
                 'W', 'Closed Pending',
                 'N', 'Never Opened',
                 'P', 'Permanently Closed')
            STATUS,
         PERIOD_NUM,
         PERIOD_YEAR,
         START_DATE,
         END_DATE
    FROM APPS.GL_PERIOD_STATUSES GPS,
         APPS.GL_SETS_OF_BOOKS GSP,
         APPS.FND_APPLICATION_TL FAT
   WHERE     1 = 1
         AND GSP.SET_OF_BOOKS_ID = GPS.SET_OF_BOOKS_ID
         AND FAT.APPLICATION_ID = GPS.APPLICATION_ID
         AND     (:P_PERIOD_NAME IS NULL OR (PERIOD_NAME=:P_PERIOD_NAME))
         AND     (:P_LEDGER_NAME IS NULL OR (GSP.NAME=:P_LEDGER_NAME))
         AND     (:P_MODULE_NAME IS NULL OR (FAT.APPLICATION_NAME=:P_MODULE_NAME))
         AND FAT.APPLICATION_NAME NOT IN ('Inventory')
UNION ALL
SELECT   'Inventory' APPLICATION,
         SET_OF_BOOKS_ID LEDGER_ID,
         OOD.ORGANIZATION_NAME||' ('||OOD.ORGANIZATION_CODE||') ' SETOFBOOK,
         OAP.PERIOD_NAME,
         OAP.STATUS,
         PERIOD_NUMBER,
         OAP.PERIOD_YEAR,
         START_DATE,
         END_DATE
    --,OOD.*
    --,OAP.*
    FROM APPS.ORG_ACCT_PERIODS_V OAP, APPS.ORG_ORGANIZATION_DEFINITIONS OOD
   WHERE     1 = 1
         AND OAP.ORGANIZATION_ID(+) = OOD.ORGANIZATION_ID
         AND     (:P_PERIOD_NAME IS NULL OR (PERIOD_NAME=:P_PERIOD_NAME))
         AND     (:P_LEDGER_NAME IS NULL OR (OOD.ORGANIZATION_CODE=:P_LEDGER_NAME))
         AND     (:P_MODULE_NAME IS NULL OR ('Inventory'=:P_MODULE_NAME))