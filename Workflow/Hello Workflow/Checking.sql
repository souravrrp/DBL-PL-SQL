SELECT file_id,stored_file
--        INTO bdoc
        FROM BLOB_TABLE
       WHERE file_name = l_file_name;
       
       SELECT file_id,file_name, file_content_type, file_data
     --INTO filename, content_type, bdoc
     FROM fnd_lobs
    WHERE 1=1
    AND UPPER(file_content_type) LIKE UPPER('Excel%')
    --AND file_name LIKE '%PR%'
    --AND file_id = lob_id;
    
    select *
--into l_result_out
from oe_hold_sources HS,
oe_hold_definitions h
where 1=1
--AND HS.hold_entity_code = p_hold_entity_code
--and HS.hold_entity_id = p_hold_entity_id
and HS.hold_id = 1
and HS.released_flag = 'N'
AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >= ROUND( SYSDATE )
AND hs.hold_id = h.hold_id
AND SYSDATE BETWEEN NVL( H.START_DATE_ACTIVE, SYSDATE )
AND NVL( H.END_DATE_ACTIVE, SYSDATE );


SELECT Count(1) --INTO x_attachments_cnt 
FROM FND_ATTACHED_DOCUMENTS
  WHERE ENTITY_NAME LIKE 'PON_DISCUSSIONS'
  --AND PK1_VALUE = x_discussion_id
  --AND PK2_VALUE = x_entry_id
  ;
  
  
  ALTER PACKAGE APPS.XXDBL_CUSTOM_WORKFLOW 
   COMPILE BODY; 
   
   
   ALTER PACKAGE APPS.XXDBL_CUSTOM_WORKFLOW 
   COMPILE PACKAGE; 
   
   --SQL> 
   select text from dba_source where name = 'XXDBL_CUSTOM_WORKFLOW' and line =2;

--SQL> 
select object_name,object_type,owner,status from dba_objects where object_name = 'XXDBL_CUSTOM_WORKFLOW';