set linesize 152
set pagesize 132
col PROFILE_OPTION_NAME format A30 
col USER_PROFILE_OPTION_NAME format A38 word_wrap
col LEVEL_SET format a8 trunc
col PROFILE_OPTION_VALUE format A72 wrap

Prompt
Prompt * SMTP Host(Port) Profiles --> smtp Privilege ACE
Prompt *****************************************************************
break on PROFILE_OPTION_NAME on USER_PROFILE_OPTION_NAME
select distinct  p.profile_option_name PROFILE_OPTION_NAME,
n.user_profile_option_name USER_PROFILE_OPTION_NAME,
decode(v.level_id,
10001, 'Site',
10002, 'Appl',
10003, 'Resp',
10004, 'User',
10005, 'Server',
10006, 'Org',
10007, 'ServResp',
'UnDef') LEVEL_SET,
v.profile_option_value PROFILE_OPTION_VALUE
from fnd_profile_options p,
fnd_profile_option_values v,
fnd_profile_options_tl n,
fnd_user usr,
fnd_application app,
fnd_responsibility rsp,
fnd_nodes svr,
hr_operating_units org
where p.profile_option_id = v.profile_option_id (+)
and p.profile_option_name = n.profile_option_name
and 'US' = n.source_lang
and  p.profile_option_name in (
'OKS_SMTP_HOST',
'OKS_SMTP_PORT',
'PA_RP_SMTP_ADDRESS',
'MTH_MAIL_SERVER_NAME',
'MTH_MAIL_SERVER_PORT',
'WSH_DCP_EMAIL_SERVER' )
and    usr.user_id (+) = v.level_value
and    rsp.application_id (+) = v.level_value_application_id
and    rsp.responsibility_id (+) = v.level_value
and    app.application_id (+) = v.level_value
and    svr.node_id (+) = v.level_value
and    org.organization_id (+) = v.level_value
order by 1,3,4 ;

Prompt * Web Proxy Profiles  --> http_proxy Privilege ACE
Prompt *****************************************************************
break on PROFILE_OPTION_NAME on USER_PROFILE_OPTION_NAME
select distinct  p.profile_option_name PROFILE_OPTION_NAME,
n.user_profile_option_name USER_PROFILE_OPTION_NAME,
decode(v.level_id,
10001, 'Site',
10002, 'Appl',
10003, 'Resp',
10004, 'User',
10005, 'Server',
10006, 'Org',
10007, 'ServResp',
'UnDef') LEVEL_SET,
v.profile_option_value PROFILE_OPTION_VALUE
from fnd_profile_options p,
fnd_profile_option_values v,
fnd_profile_options_tl n,
fnd_user usr,
fnd_application app,
fnd_responsibility rsp,
fnd_nodes svr,
hr_operating_units org
where p.profile_option_id = v.profile_option_id (+)
and p.profile_option_name = n.profile_option_name
and 'US' = n.source_lang
and  p.profile_option_name in (
'IBY_HTTP_PROXY',
'QP_PROXY_SERVER',
'MTH_SOA_PROXY_SERVER',
'WSH_INTERNET_PROXY',
'WEB_PROXY_HOST',
'WEB_PROXY_PORT'                       )
and    usr.user_id (+) = v.level_value
and    rsp.application_id (+) = v.level_value_application_id
and    rsp.responsibility_id (+) = v.level_value
and    app.application_id (+) = v.level_value
and    svr.node_id (+) = v.level_value
and    org.organization_id (+) = v.level_value
order by 1,3,4 ;

Prompt 
Prompt * HTTP (URL) Profiles --> http Privilege ACE
Prompt *****************************************************************
break on PROFILE_OPTION_NAME on USER_PROFILE_OPTION_NAME
select distinct  p.profile_option_name PROFILE_OPTION_NAME,
n.user_profile_option_name USER_PROFILE_OPTION_NAME,
decode(v.level_id,
10001, 'Site',
10002, 'Appl',
10003, 'Resp',
10004, 'User',
10005, 'Server',
10006, 'Org',
10007, 'ServResp',
'UnDef') LEVEL_SET,
v.profile_option_value PROFILE_OPTION_VALUE
from fnd_profile_options p,
fnd_profile_option_values v,
fnd_profile_options_tl n,
fnd_user usr,
fnd_application app,
fnd_responsibility rsp,
fnd_nodes svr,
hr_operating_units org
where p.profile_option_id = v.profile_option_id (+)
and p.profile_option_name = n.profile_option_name
and 'US' = n.source_lang
and  p.profile_option_name in (
'ASO_CONFIGURATOR_URL',
'CZ_UIMGR_URL',
'APPS_JSP_AGENT',
'IBY_ECAPP_URL',
'OKS_ERN_URL',
'OKC_K_EXPERT_ENABLED',
'OKC_USE_CONTRACTS_RULES_ENGINE',
'APPS_FRAMEWORK_AGENT',
'QP_PRICING_ENGINE_URL',
'QP_INTERNAL_11510_J',
'QP_PRICING_ENGINE_TYPE',
'MSD_DEM_HOST_URL',
'WSH_ENABLE_DCP',
'WSH_OTM_SERVLET_URI',
'CSC_SCRIPTING_SID' ,
'IRC_GEOCODE_HOST'
)
and    usr.user_id (+) = v.level_value
and    rsp.application_id (+) = v.level_value_application_id
and    rsp.responsibility_id (+) = v.level_value
and    app.application_id (+) = v.level_value
and    svr.node_id (+) = v.level_value
and    org.organization_id (+) = v.level_value
order by 1,3,4 ;

Prompt * HTTP (URL) MTH_EVENT_ACTION_SETUP --> http Privilege ACE
Prompt *****************************************************************
select ACTION_TYPE_CODE, DOMAIN_NAME from MTH_EVENT_ACTION_SETUP ;


Prompt * cz_db_settings.VALUE for 'AltBatchValidateUrl' --> http Privilege ACE
Prompt *****************************************************************
select VALUE "cz_db_settings.VALUE" from CZ_DB_SETTINGS where SETTING_ID='AltBatchValidateUrl' ;

Prompt * ECX_TP_DETAILS_V.PROTOCOL_ADDRESS --> http Privilege ACE
Prompt *****************************************************************
select distinct PROTOCOL_ADDRESS from ECX_TP_DETAILS_V where TRANSACTION_TYPE = 'OKL_ST' ;

Prompt * MTM MTH_EVENT_ACTION_SETUP.ACTION_HANDLER_CODE URL -> http Privilege ACE
Prompt *****************************************************************
select SubStr(ACTION_HANDLER_CODE, InStr(ACTION_HANDLER_CODE,'URL=')+4,
InStr(ACTION_HANDLER_CODE,',')-(InStr(ACTION_HANDLER_CODE, 'URL=')+4))
from MTH_EVENT_ACTION_SETUP ;

Prompt * XDP - Customer Driven Setup --> http Privilege ACE
Prompt *****************************************************************
select
FEV.FE_ATTRIBUTE_VALUE "Attribute Value",
FEDV.DEFAULT_VALUE "Attribute Default Value",
FEDV.FE_ATTRIBUTE_NAME "Attribute Name",
FEV.DISPLAY_NAME "Attribute Description",
FET.FULFILLMENT_ELEMENT_TYPE "Element Type",
FET.DISPLAY_NAME "Element Type Description",
FE.FULFILLMENT_ELEMENT_NAME "Element Name",
FE.DISPLAY_NAME "Element Description",
FEGL.SW_GENERIC "Software Name",
FEGL.ADAPTER_TYPE "Adapter Type"
from  XDP_FES_VL FE,
XDP_FE_TYPES_VL FET,
XDP_FE_SW_GEN_LOOKUP FEGL,
XDP_FE_GENERIC_CONFIG FEG,
XDP_FE_ATTRIBUTE_DEF_VL FEDV,
XDP_FE_ATTRIBUTE_VAL_VL FEV
where FE.FETYPE_ID =FET.FETYPE_ID
and FET.FETYPE_ID=FEGL.FETYPE_ID
and FEGL.ADAPTER_TYPE ='HTTP'
and FE.FE_ID = FEG.FE_ID
and FEG.FE_SW_GEN_LOOKUP_ID   = FEGL.FE_SW_GEN_LOOKUP_ID
and FEGL.FE_SW_GEN_LOOKUP_ID  = FEDV.FE_SW_GEN_LOOKUP_ID
and FEDV.FE_ATTRIBUTE_ID      = FEV.FE_ATTRIBUTE_ID
order by 5,7 ;
