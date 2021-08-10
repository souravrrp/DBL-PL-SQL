SELECT
BD.*
--BM.*
FROM
XX_VMS_BILL_MST BM
,XX_VMS_BILL_DTL BD
WHERE 1=1
AND BM.VMS_BILL_ID=BD.VMS_BILL_ID
AND BM.BLL_NO='BILL71729'
;

--------------------------------------------------------------------------------
SELECT
*
FROM
XX_VMS_BILL_MST
where 1=1
and VMS_BILL_ID=10149
;

SELECT
*
FROM
XX_VMS_BILL_DTL;

--------------------------------------------------------------------------------
