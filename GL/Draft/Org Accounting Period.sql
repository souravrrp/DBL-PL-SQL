SELECT
*
FROM
GL_PERIODS GP
,GL_PERIOD_SETS GPS
,GL_PERIOD_TYPES GPT
WHERE 1=1 
AND GP.PERIOD_SET_ID=GPS.PERIOD_SET_ID
--AND GP.PERIOD_SET_NAME=GPS.PERIOD_SET_NAME
AND GPT.PERIOD_TYPE=GP.PERIOD_TYPE
AND GP.PERIOD_SET_NAME='DBL BD Calendar'


---------------------------PERIOD STATUS------------------------------------------
SELECT
*
FROM
GL_PERIODS GP
WHERE 1=1
AND GP.PERIOD_SET_NAME='DBL BD Calendar'


---------------------------PERIOD SETS------------------------------------------
SELECT
*
FROM
GL_PERIOD_SETS  


---------------------------PERIOD TYPES-----------------------------------------
SELECT
*
FROM
GL_PERIOD_TYPES 