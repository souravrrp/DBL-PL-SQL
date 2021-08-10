

SELECT

VM.*
FROM
XX_VECHICLE_MST VM
,XX_VECHICLE_ORG VO
,XX_VECHICLE_USER VU
,XX_VECHICLE_DRIVER VD
WHERE 1=1
AND VM.VMST_ID=VO.VMST_ID(+)
AND VM.VMST_ID=VU.VMST_ID(+)
AND VM.VMST_ID=VD.VMST_ID(+)
AND VM.V_REG_NO='DM-GA-27-2118'
AND VM.VMST_ID='10078'


SELECT
*
FROM
XX_VECHICLE_USER VU
WHERE 1=1
AND VU.VMST_ID='10078'

SELECT
*
FROM
XX_VECHICLE_DRIVER VD
WHERE 1=1
AND VD.VMST_ID='10078' 

SELECT
*
FROM
XX_VECHICLE_ORG VO
WHERE 1=1
AND VO.VMST_ID='10078'

SELECT
*
FROM
XX_VECHICLE_OPERATING

--------------------------------------------------------------------------------

/* Formatted on 12/18/2019 5:19:48 PM (QP5 v5.287) */
SELECT 
    VBM.V_REG_NO VEHICLE_NO
    ,VBM.PURCH_OU
    ,VBM.BLL_NO
    ,VBM.*
  FROM XX_VMS_BILL_MST VBM
  , XX_VMS_BILL_DTL VBD
 WHERE 1=1
 AND VBM.VMS_BILL_ID = VBD.VMS_BILL_ID
 AND VBM.V_REG_NO='DM-GA-31-1782';



SELECT
*
FROM
XX_VECHICLE_MST

SELECT
*
FROM
XX_VECHICLE_USER

SELECT
*
FROM
XX_VECHICLE_DRIVER

SELECT
*
FROM
XX_VECHICLE_ORG

SELECT
*
FROM
XX_VECHICLE_OPERATING

--------------------------------------------------------------------------------

SELECT DISTINCT vbm.v_reg_no, vbm.purch_ou, vbm.bll_no
  FROM xx_vms_bill_mst vbm, xx_vms_bill_dtl vbd
 WHERE vbm.vms_bill_id = vbd.vms_bill_id
UNION ALL
SELECT DISTINCT v_reg_no, op_unit, bll_no
  FROM xxveh_activities a, xx_vechicle_mst b
 WHERE a.vmst_id = b.vmst_id AND status = 'BRTA';

--------------------------------------------------------------------------------

SELECT * FROM XXDBL_VECHICLE;