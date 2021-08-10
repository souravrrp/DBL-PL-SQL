select
*
from
CM_CMPT_MTL



select
*
from
gl_aloc_bas

select
*
from
fm_form_mst_b

select
*
from
fm_form_eff

CM_CMPT_MTL

select
*
from
cm_cmpt_dtl

select
*
from
cm_rlup_ctl

select
*
from
cm_acst_led

select
*
from
CM_CMPT_DTL_VW

select
*
from
CM_CUPD_CTL 
WHERE 1=1
AND DELETE_MARK!=0

--------------------------COST_ANALYSIS-----------------------------------------

select
*
from
cm_alys_mst


-------------------------------COST_COMPONENTS----------------------------------

SELECT
COST_CMPNTCLS_DESC COST_CMPNTCLS_DESCRIPTION
,CCM.*
FROM
APPS.CM_CMPT_MST_VL  CCM
WHERE 1=1
--AND COST_CMPNTCLS_ID=48

SELECT
COST_CMPNTCLS_DESC COST_CMPNTCLS_DESCRIPTION
,CCM.*
FROM
apps.cm_cmpt_mst  CCM
WHERE 1=1
--AND COST_CMPNTCLS_ID=48
order by COST_CMPNTCLS_ID

------------------------------------COST_COMPONENT_GROUP------------------------

SELECT
*
FROM
CM_CMPT_GRP


------------------------------------COST_TYPE-----------------------------------
SELECT
*
FROM
CM_MTHD_MST 

-------------------------------COST_CALENDERS-----------------------------------
SELECT
*
FROM
CM_CLDR_HDR_VL


----------------------COST_ADJUSTMENT_REASON------------------------------------

SELECT
*
FROM
CM_REAS_CDS 