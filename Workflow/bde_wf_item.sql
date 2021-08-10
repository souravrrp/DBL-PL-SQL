set term off;
/*$Header: bde_wf_item.sql 11.5.4                                           05/29/02*/

/*
 TITLE bde_wf_item.sql
  
DESCRIPTION

 This script is designed to be used to output Workflow related data for an single
 workflow item.  It outputs data which describes the pertinent transactional records
 for the item.  You will be prompted for the ITEM_TYPE and ITEM_KEY.  It will output
 data for:
    WF_ITEMS
    WF_ITEM_ATTRIBUTE_VALUES
    WF_ITEM_ACTIVITY_STATUSES
    WF_ITEM_ACTIVITY_STATUSES_H (Summary)
    WF_NOTIFICATIONS

 In addition it outputs error information and the status of the workflow error 
 process.

EXECUTION

 Run the script from a SQL*Plus session logged in as the APPS user.  The output 
 spools to a file called bde_wf_item.lst. 

 NOTES

 1. The output can be FTP'd to a PC and then loaded into wordpad.  
    Go to Page Setup and select Landscape as the Paper Size.
    Modify all 4 Margins to 0.5".
    Select all your document (Ctrl-A) and use Format Font to change the current
    font to Courier or New Courier 8.  
    With all your document selected (Ctrl-A) use Format Paragraph to set both
    Before and After Spacing to 0.  It comes with null causing a one line 
    spacing between lines.

 DISCLAIMER 
 
 This script is provided for educational purposes only.  It is not supported 
 by Oracle World Wide Technical Support.  The script has been tested and 
 appears to works as intended.  However, you should always test any script 
 before relying on it. 
 
 Proofread this script prior to running it!  Due to differences in the way text 
 editors, email packages and operating systems handle text formatting (spaces, 
 tabs and carriage returns), this script may not be in an executable state 
 when you first receive it.  Check over the script to ensure that errors of 
 this type are corrected. 

 This script can be given to customers.  Do not remove disclaimer paragraph.

 HISTORY 
 
 10-AUG-01 Created                                                   rnmercer 
 19-SEP-01 Added Child Processes                                     rnmercer
 17-APR-02 Find associated notifications by GROUP_ID                 rnmercer
 29-MAY-02 Modified to remove MAX(VERSION)                           rnmercer

*/
set echo off;
set verify off;
set linesize 156;
set pagesize 100;
set term on;

accept item_type_selected prompt 'Please enter ITEM_TYPE: '
accept item_key_selected prompt 'Please enter ITEM_KEY: '

spool bde_wf_item_&item_type_selected._&item_key_selected..lst

column ITEM_TYPE           format a09;
column ITEM_KEY            format a10;
column PRNT_TYPE           format a09;
column PRNT_KEY            format a10;
column PRNT_CNTXT          format a10;
column USER_KEY            format a20;
column ROOT_ACTIVITY       format a20;
column VERS                format 9999;
column OWNER_ROLE          format a10;
column BEGIN_DATE          format a18;
column END_DATE            format a18;

prompt Item 

select 
     ITM.ITEM_TYPE                      ITEM_TYPE
    ,ITM.ITEM_KEY                       ITEM_KEY
    ,ITM.USER_KEY                       USER_KEY
    ,ITM.ROOT_ACTIVITY                  ROOT_ACTIVITY
    ,ITM.ROOT_ACTIVITY_VERSION          VERS
    ,ITM.PARENT_ITEM_TYPE               PRNT_TYPE
    ,ITM.PARENT_ITEM_KEY                PRNT_KEY
    ,ITM.PARENT_CONTEXT                 PRNT_CNTXT
    ,to_char(ITM.BEGIN_DATE,'DD-MON-RR HH24:MI:SS')BEGIN_DATE
    ,to_char(ITM.END_DATE,'DD-MON-RR HH24:MI:SS')  END_DATE
    ,ITM.OWNER_ROLE                     OWNER_ROLE
from 
    WF_ITEMS               ITM
where
        ITM.ITEM_TYPE = '&item_type_selected'
    AND ITM.ITEM_KEY  = '&item_key_selected';

prompt Child Processes

select 
     ITM.ITEM_TYPE                      ITEM_TYPE
    ,ITM.ITEM_KEY                       ITEM_KEY
    ,ITM.USER_KEY                       USER_KEY
    ,ITM.ROOT_ACTIVITY                  ROOT_ACTIVITY
    ,ITM.ROOT_ACTIVITY_VERSION          VERS
    ,ITM.PARENT_ITEM_TYPE               PRNT_TYPE
    ,ITM.PARENT_ITEM_KEY                PRNT_KEY
    ,ITM.PARENT_CONTEXT                 PRNT_CNTXT
    ,to_char(ITM.BEGIN_DATE,'DD-MON-RR HH24:MI:SS')BEGIN_DATE
    ,to_char(ITM.END_DATE,'DD-MON-RR HH24:MI:SS')  END_DATE
    ,ITM.OWNER_ROLE                     OWNER_ROLE
from 
    WF_ITEMS               ITM
where
        ITM.PARENT_ITEM_TYPE = '&item_type_selected'
    AND ITM.PARENT_ITEM_KEY  = '&item_key_selected';


-- ITEM ATTRIBUTE VALUES
column VALUE                format A30;
column TYPE                 format a06;
column ATR_TYPE             format a09;
column DISPLAY_NAME         format a30;
column NAME                 format a20;

prompt Item Attribute Values

select 
     ATV.NAME                                 NAME         
    ,nvl(text_value, nvl(to_char(number_value),to_char(date_value,'DD-MON-YYYY hh24:mi:ss'))) value 
    ,decode(
       decode(nvl(text_value, 'T'),'T','T',NULL) || 
       decode(nvl(to_char(NUMBER_value), 'N'),'N','N',NULL) ||
       decode(nvl(to_char(DATE_value), 'D'),'D','D',NULL),
         'ND', 'TEXT',
         'TD', 'NUMBER',
         'TN', 'DATE',
         NULL)                                TYPE
    ,ATR.TYPE                                 ATR_TYPE
    ,ATR.DISPLAY_NAME                         DISPLAY_NAME
    --,ATV.TEXT_VALUE     
    --,ATV.NUMBER_VALUE   
    --,ATV.DATE_VALUE    
    --,ATV.EVENT_VALUE  
from 
    WF_ITEM_ATTRIBUTE_VALUES   ATV,
    WF_ITEM_ATTRIBUTES_VL      ATR
where
        ATV.ITEM_TYPE = ATR.ITEM_TYPE(+)
    AND ATV.NAME      = ATR.NAME(+)
    AND ATV.ITEM_TYPE = '&item_type_selected'
    AND ATV.ITEM_KEY  = '&item_key_selected'
    --AND ATR.TYPE <> 'EVENT'
order by 1;

prompt Item Attribute Event Values

select 
     ATV.NAME                                 NAME         
    ,ATR.TYPE                                 ATR_TYPE
    ,ATR.DISPLAY_NAME                         DISPLAY_NAME
    --,ATV.TEXT_VALUE     
    --,ATV.NUMBER_VALUE   
    --,ATV.DATE_VALUE    
    ,ATV.EVENT_VALUE  
from 
    WF_ITEM_ATTRIBUTE_VALUES   ATV,
    WF_ITEM_ATTRIBUTES_VL      ATR
where
        ATV.ITEM_TYPE = ATR.ITEM_TYPE(+)
    AND ATV.NAME      = ATR.NAME(+)
    AND ATV.ITEM_TYPE = '&item_type_selected'
    AND ATV.ITEM_KEY  = '&item_key_selected'
    AND ATR.TYPE = 'EVENT'
order by 1;



column NAME format a25;
column TYPE format a10;
column TEXT_VAL format a40;

break on activity_name skip 1;

prompt Activity Attribute Values

select 
       WFA1.DISPLAY_NAME    ACTIVITY_NAME,
       WAV.NAME             NAME,
       WAV.VALUE_TYPE       TYPE,
       WAV.TEXT_VALUE       TEXT_VAL,
       WAV.NUMBER_VALUE     NUMB_VAL,
       WAV.DATE_VALUE       DATE_VAL,
       WFP.INSTANCE_ID      INSTANCE_ID
from WF_ITEM_ACTIVITY_STATUSES WFS,
     WF_PROCESS_ACTIVITIES     WFP,
     WF_ITEMS                  WFI,
     WF_ACTIVITY_ATTR_VALUES   WAV,
     WF_ACTIVITIES_VL          WFA1
where 
       WFI.ITEM_TYPE           = '&item_type_selected'
  and  WFI.item_key            = '&item_key_selected'
  and  WFS.ITEM_TYPE           = WFI.ITEM_TYPE
  and  WFS.item_key            = WFI.item_key
  and  WFS.PROCESS_ACTIVITY    = WFP.INSTANCE_ID
  and  WAV.PROCESS_ACTIVITY_ID = WFP.INSTANCE_ID
  and  WFP.ACTIVITY_NAME       = WFA1.NAME
  and  WFP.ACTIVITY_ITEM_TYPE  = WFA1.ITEM_TYPE
  and  WFA1.BEGIN_DATE        <= WFI.BEGIN_DATE
  and  nvl(WFA1.END_DATE,SYSDATE) > WFI.BEGIN_DATE;

clear breaks;

-- WORKFLOW TABLES
column ITEM_KEY                format A08;
column FLOW_PROCESS            format A22;
column RESULT_CODE             format A15;
column RESULT                  format A15;
column ASGND_USER               format A10;
column ERROR_NAME              format A19;
column PROCESS_NAME            format A29;
column ACTIVITY_NAME           format A29;
column ERROR_ACTIVITY_NAME     format A31;
column ACT_STATUS              format A10;
column STATUS                  format A10;
column NOTIF_ID                format 99999999; 
column ERROR_NAME              format A14;
column ERR_RETRY_ROLE          format A14;
column ERR_RETRY_USER          format A14;
column BEGIN_DATE              format A15;
column END_DATE                format A15;
column ER                      format A02;
column OQ                      format A02;
column ACTIVITY                format a35;
column instance_id             format 999999999999;


prompt Item Activity Statuses - Internal Names

select  ap.name||'/'||pa.instance_label             Activity,
        ias.process_activity                         instance_id,
        ias.activity_status                         Status,
        ias.activity_result_code                    Result,
        ias.assigned_user                           ASGND_USER,
	  ias.notification_id                         NID,
	  ntf.status                                  "Status",
        to_char(ias.begin_date,'DD-MON HH24:MI:SS') begin_date,
        to_char(ias.end_date,'DD-MON HH24:MI:SS')   end_date
from    wf_item_activity_statuses ias,
        wf_process_activities pa,
        wf_activities ac,
        wf_activities ap,
        wf_items i,
	wf_notifications ntf
where   ias.item_type = '&item_type_selected'
and     ias.item_key  = '&item_key_selected'
and     ias.process_activity    = pa.instance_id
and     pa.activity_name        = ac.name
and     pa.activity_item_type   = ac.item_type
and     pa.process_name         = ap.name
and     pa.process_item_type    = ap.item_type
and     pa.process_version      = ap.version
and     i.item_type             = '&item_type_selected'
and     i.item_key              = ias.item_key
and     i.begin_date            >= ac.begin_date 
and     i.begin_date            < nvl(ac.end_date, i.begin_date+1)
and     ntf.notification_id(+)  = ias.notification_id
order by ias.begin_date, ias.execution_time;

prompt Item Activity Status - Display Names

select 
       --WFS.ITEM_KEY               ITEM_KEY, 
       WFA.DISPLAY_NAME           PROCESS_NAME,
       WFA1.DISPLAY_NAME          ACTIVITY_NAME,
       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT,
       LKP.MEANING                ACT_STATUS,
       WFS.NOTIFICATION_ID        NOTIF_ID,
       to_char(WFS.BEGIN_DATE,'DD-MON HH24:MI:SS') BEGIN_DATE,
       to_char(WFS.END_DATE,'DD-MON HH24:MI:SS') END_DATE,
       decode(nvl(rawtohex(WFS.OUTBOUND_QUEUE_ID),'@777')
              ,'@777','N'
              ,'Y')             OQ,
       decode(nvl(WFS.ERROR_NAME,'@777')
              ,'@777','N'
              ,'Y')             ER
from WF_ITEM_ACTIVITY_STATUSES WFS,
     WF_PROCESS_ACTIVITIES     WFP,
     WF_ACTIVITIES_VL          WFA,
     WF_ACTIVITIES_VL          WFA1,
     WF_ITEMS                  WFI,
     WF_LOOKUPS                LKP
where 
       WFI.ITEM_TYPE           = '&item_type_selected'
  and  WFI.item_key            = '&item_key_selected'
  and  WFS.ITEM_TYPE           = WFI.ITEM_TYPE
  and  WFS.item_key            = WFI.item_key
  and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID
  and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE
  and  WFP.PROCESS_NAME       = WFA.NAME
  and  WFP.PROCESS_VERSION    = WFA.VERSION
  and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE
  and  WFP.ACTIVITY_NAME      = WFA1.NAME
  and  WFA1.BEGIN_DATE        <= WFI.BEGIN_DATE
  and  nvl(WFA1.END_DATE,SYSDATE) > WFI.BEGIN_DATE
  and  LKP.LOOKUP_TYPE = 'WFENG_STATUS'
  and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS
  order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME;

prompt  Error Stack Information

select  ac.name Activity,
        ias.activity_result_code Result,
	ias.error_name ERROR_NAME, 
	ias.error_message ERROR_MESSAGE,
	ias.error_stack ERROR_STACK
from    wf_item_activity_statuses ias,
        wf_process_activities pa,
        wf_activities ac,
        wf_activities ap,
        wf_items i
where   ias.item_type = '&item_type_selected'
and     ias.item_key  = '&item_key_selected'
and     ias.activity_status     = 'ERROR'
and     ias.process_activity    = pa.instance_id
and     pa.activity_name        = ac.name
and     pa.activity_item_type   = ac.item_type
and     pa.process_name         = ap.name
and     pa.process_item_type    = ap.item_type
and     pa.process_version      = ap.version
and     i.item_type             = '&item_type_selected'
and     i.item_key              = ias.item_key
and     i.begin_date            >= ac.begin_date 
and     i.begin_date            < nvl(ac.end_date, i.begin_date+1)
order by ias.begin_date, ias.execution_time;



column   ERR_TYPE_KEY      format a14;
column   ASGND_USER        format a10;
column   ERR_PROCESS_NAME  format a18;
column   ERR_ACTIVITY_NAME format a22;

break on ERR_TYPE_KEY skip 2;

prompt Activity Statuses for Workflow Error Processes

select 
       WFS.ITEM_TYPE || '-' || WFS.ITEM_KEY               ERR_TYPE_KEY, 
       WFA.DISPLAY_NAME           ERR_PROCESS_NAME,
       WFA1.DISPLAY_NAME          ERR_ACTIVITY_NAME,
       WF_CORE.ACTIVITY_RESULT(WFA1.RESULT_TYPE,WFS.ACTIVITY_RESULT_CODE) RESULT,
       LKP.MEANING                ACT_STATUS,
       WFS.NOTIFICATION_ID        NOTIF_ID,
       WFS.ASSIGNED_USER          ASGND_USER,
       to_char(WFS.BEGIN_DATE,'DD-MON HH24:MI:SS') BEGIN_DATE,
       to_char(WFS.END_DATE,'DD-MON HH24:MI:SS') END_DATE
from WF_ITEM_ACTIVITY_STATUSES WFS,
     WF_PROCESS_ACTIVITIES     WFP,
     WF_ACTIVITIES_VL          WFA,
     WF_ACTIVITIES_VL          WFA1,
     WF_LOOKUPS                LKP,
     WF_ITEMS                  WFI
where 
       WFS.ITEM_TYPE          = WFI.ITEM_TYPE
  and  WFS.item_key           = WFI.ITEM_KEY
  and  WFS.PROCESS_ACTIVITY   = WFP.INSTANCE_ID
  and  WFP.PROCESS_ITEM_TYPE  = WFA.ITEM_TYPE
  and  WFP.PROCESS_NAME       = WFA.NAME
  and  WFP.PROCESS_VERSION    = WFA.VERSION
  and  WFP.ACTIVITY_ITEM_TYPE = WFA1.ITEM_TYPE
  and  WFP.ACTIVITY_NAME      = WFA1.NAME
  and  WFA1.BEGIN_DATE        <= WFI.BEGIN_DATE
  and  nvl(WFA1.END_DATE,SYSDATE) > WFI.BEGIN_DATE
  and  LKP.LOOKUP_TYPE = 'WFENG_STATUS'
  and  LKP.LOOKUP_CODE = WFS.ACTIVITY_STATUS
  and  WFI.PARENT_ITEM_TYPE = '&item_type_selected'
  and  WFI.PARENT_ITEM_KEY  = '&item_key_selected'
  and  WFI.ITEM_TYPE in (select WFAE.ERROR_ITEM_TYPE
                         from WF_ITEM_ACTIVITY_STATUSES WFSE,
                         WF_PROCESS_ACTIVITIES     WFPE,
                         WF_ACTIVITIES_VL          WFAE,
                         WF_ACTIVITIES_VL          WFA1E,
                         WF_ITEMS                  WFIE
                         where 
                                WFIE.ITEM_TYPE           = '&item_type_selected'
                           and  WFIE.item_key            = '&item_key_selected'
                           and  WFSE.ITEM_TYPE           = WFIE.ITEM_TYPE
                           and  WFSE.item_key            = WFIE.item_key
                           and  WFSE.PROCESS_ACTIVITY   = WFPE.INSTANCE_ID
                           and  WFPE.PROCESS_ITEM_TYPE  = WFAE.ITEM_TYPE
                           and  WFPE.PROCESS_NAME       = WFAE.NAME
                           and  WFPE.PROCESS_VERSION    = WFAE.VERSION
                           and  WFPE.ACTIVITY_ITEM_TYPE = WFA1E.ITEM_TYPE
                           and  WFPE.ACTIVITY_NAME      = WFA1E.NAME
                           and  WFA1E.BEGIN_DATE        <= WFIE.BEGIN_DATE
                           and  nvl(WFA1E.END_DATE,SYSDATE) > WFIE.BEGIN_DATE
                           and  WFSE.ACTIVITY_STATUS = 'ERROR')
  order by WFS.ITEM_KEY, WFS.BEGIN_DATE, EXECUTION_TIME;

prompt Item Activity Status History Summary

 select count(*)                 COUNT, 
        STH.PROCESS_ACTIVITY     PROCESS_ACTIVITY, 
        PRA.INSTANCE_LABEL       ACTIVITY_LABEL,
        STH.ACTIVITY_RESULT_CODE ACTIVITY_RESULT_CODE
 from wf_item_activity_statuses_h STH,
      wf_process_activities       PRA
 where STH.item_type      = '&item_type_selected'
  and  STH.item_key       = '&item_key_selected'
  and  PRA.instance_id(+) = STH.process_activity
 group by STH.process_activity,
          PRA.INSTANCE_LABEL,
          STH.ACTIVITY_RESULT_CODE;

column context           format A25;
column RESPONDER         format a18;
column RECIPIENT_ROLE    format a14;
column ACCESS_KEY        format a10;
column USER_COMMENT      format a20;
column CALLBACK          format a20;
column ORIGINAL_REC      format a20;
column FROM_USER         format a15;
column TO_USER           format a15;
column SUBJECT           format a120;
column MAIL_STAT         format a09;
column STATUS            format a09;
column BEGIN_DATE        format a10;
column END_DATE          format a10;
column PRI               format 999;

prompt Notifications

select
     NTF.NOTIFICATION_ID                NOTIF_ID
    ,NTF.CONTEXT                        CONTEXT
    ,NTF.GROUP_ID                       GROUP_ID
    ,NTF.STATUS                         STATUS
    ,NTF.MAIL_STATUS                    MAIL_STAT
    ,NTF.MESSAGE_TYPE                   MES_TYPE
    ,NTF.MESSAGE_NAME                   MESSAGE_NAME
    ,NTF.ACCESS_KEY                     ACCESS_KEY
    ,NTF.PRIORITY                       PRI
    ,NTF.BEGIN_DATE                     BEGIN_DATE
    ,NTF.END_DATE                       END_DATE
    ,NTF.DUE_DATE                       DUE_DATE
    --,NTF.USER_COMMENT                   USER_COMMENT
    ,NTF.CALLBACK                       CALLBACK
    ,NTF.RECIPIENT_ROLE                 RECIPIENT_ROLE
    ,NTF.RESPONDER                      RESPONDER
    ,NTF.ORIGINAL_RECIPIENT             ORIGINAL_REC
    ,NTF.FROM_USER                      FROM_USER
    ,NTF.TO_USER                        TO_USER
    --,NTF.LANGUAGE                       LANGUAGE
    --,NTF.MORE_INFO_ROLE                 MORE_INFO_ROLE
    ,NTF.SUBJECT                        SUBJECT
from WF_NOTIFICATIONS          NTF
where NTF.GROUP_ID in (select notification_id 
                               from wf_item_activity_statuses
                               where ITEM_TYPE = '&item_type_selected'
                                 AND ITEM_KEY  = '&item_key_selected');

spool off;