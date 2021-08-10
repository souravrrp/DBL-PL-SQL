SELECT prha.segment1,
                        prha.preparer_id,
                        prha.authorization_status,
                        FU.USER_NAME
                   FROM po_requisition_headers_all prha,
                        po_requisition_lines_all prla,
                        FND_USER FU
                  WHERE     prha.requisition_header_id =
                               prla.requisition_header_id
                        AND prha.authorization_status = 'APPROVED'
                        AND FU.EMPLOYEE_ID = prla.suggested_buyer_id
                        AND FU.USER_NAME='103762'
                        AND prha.segment1='25111002544'
                        --AND prha.last_update_date >= SYSDATE);



--2- Create a procedure
 create or replace procedure XXREQNOTIFTOBUYER (errbuf OUT varchar2, retcode OUT varchar2)
 as
   cursor c1 is
 select distinct user_name, segment1 from (
 select prha.segment1, prha.preparer_id, prha.authorization_status  ,FU.USER_NAME
 from po_requisition_headers_all prha,po_requisition_lines_all prla, FND_USER FU
 where    
 prha.requisition_header_id = prla.requisition_header_id
 and prha.authorization_status='APPROVED'
 AND FU.EMPLOYEE_ID = prla.suggested_buyer_id
 and prha.last_update_date>= sysdate -interval '10' minute);

  v_seq_no number(10);
   begin

  for i in c1 loop
         select XXREQAPPSEQ.nextval into v_seq_no from dual;
     wf_engine.createprocess(itemtype => 'XXREQAPP',
                                        itemkey  =>v_seq_no, process  => 'XXREQAPPPROC');

     wf_engine.setitemattrtext(itemtype => 'XXREQAPP',
                                        itemkey  => v_seq_no, aname    => 'XXBUYER',
                          avalue   =>i.user_name);

     wf_engine.setitemattrtext(itemtype => 'XXREQAPP',
                                        itemkey  =>v_seq_no, aname    => 'XXREQNO',
            avalue   => i.segment1);

     wf_engine.startprocess(itemtype  => 'XXREQAPP',
                   itemkey   => v_seq_no);

  v_seq_no :=0;
  end loop;

    -- Return 0 for successful completion.
     errbuf := '';
    retcode := '0';
  commit;

  exception
      when others then   errbuf := 'Error';
           retcode := '2';
 end;

   --3- Register an Executable:

   BEGIN
        FND_PROGRAM.executable ('XXREQNOTIFTOBUYER' -- executable name
       , 'Payables' -- application
       , 'XX_REQNOTBUY_API' -- short_name
       , 'Executable for Approved requisition notif to Buyer' -- description
       , 'PL/SQL Stored Procedure' -- execution_method
       , 'XXREQNOTIFTOBUYER' -- execution_file_name
       , ''-- subroutine_name
       , '' -- Execution File Path
       , 'US' -- language_code
       ,'');
       COMMIT;
   END;
 

 -- 4- Register a concurrent Program:

 BEGIN
 FND_PROGRAM.register('XXREQNOTIFTOBUYER' -- program
, 'Payables' -- application
, 'Y' -- enabled
, 'XX_REQNOTBUY_API' -- short_name
, 'Approved requisition notif to Buyer' -- description
, 'XX_REQNOTBUY_API' -- executable_short_name
, 'Payables' -- executable_application
, ''  -- execution_options
, ''  -- priority
, 'Y' -- save_output
, 'Y' -- print
,  '' -- cols
, ''  -- rows
, ''  -- style
, 'N' -- style_required
, ''  -- printer
, ''  -- request_type
, ''  -- request_type_application
, 'Y' -- use_in_srs
, 'N' -- allow_disabled_values
, 'N' -- run_alone
, 'TEXT' -- output_type
, 'N' -- enable_trace
, 'Y' -- restart
, 'Y' -- nls_compliant
, '' -- icon_name
, 'US'); -- language_code
 COMMIT;
            END;
--5- Attaching the Concurrent Program with Reguest Group

BEGIN
        FND_PROGRAM.add_to_group('XX_REQNOTBUY_API' -- program_short_name
                , 'Payables' -- application
        , 'All Reports' -- Report Group Name
        , 'SQLAP'); -- Report Group Application
        COMMIT;
 END;

--6- Scheduling the Concurrent program