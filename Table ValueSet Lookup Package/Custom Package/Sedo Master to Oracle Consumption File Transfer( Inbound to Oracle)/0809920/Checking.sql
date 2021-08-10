--Sedo Master to Oracle Consumption File Transfer( Inbound to Oracle)
--XXDBL_OPM_BATCH_INBOUND
--apps.XXDBL_SEDOMAST_INBOUND_PKG.MAIN_PRC


select
*
from
xxdbl.xxdbl_opm_conv_stg;

select
*
from
dba_directories
where 1=1
and directory_name='SEDO_INPUT';