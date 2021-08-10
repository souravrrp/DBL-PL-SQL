create or replace package XX_TEST_XML_GEN_PKG is

PROCEDURE P_RUN(p_errbuff            OUT VARCHAR2
               ,p_ret_code           OUT VARCHAR2
               ,p_person_id          IN  VARCHAR2
               ,p_effective_date     IN VARCHAR2
  );
end XX_TEST_XML_GEN_PKG;
/
CREATE OR REPLACE PACKAGE BODY XX_TEST_XML_GEN_PKG IS
--Global variable
g_procedure_name VARCHAR2(1000);
g_step_id        NUMBER;
g_request_id     NUMBER  := apps.fnd_global.conc_request_id;
PROCEDURE P_LOG (p_message IN VARCHAR2)IS
BEGIN
     --Setting the values of the global variables
   IF fnd_global.conc_request_id =-1 THEN
     dbms_output.put_line(p_message);
    ELSE
     --Writing in the Log file
     FND_FILE.PUT_LINE(FND_FILE.LOG, p_message);
    END IF;
EXCEPTION
     WHEN OTHERS THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
END P_LOG;
----=================================================================================================================
PROCEDURE P_OUTPUT (p_message IN VARCHAR2) IS
BEGIN
g_procedure_name:='P_OUTPUT';--This is for Debug log
g_step_id:=1;
   IF fnd_global.conc_request_id =-1 THEN
     dbms_output.put_line(p_message);
   ELSE
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_message);
   END IF;
     --Exception section
EXCEPTION
      WHEN OTHERS THEN
           P_LOG (g_procedure_name||'_'||g_step_id||': '||SQLERRM);
END P_OUTPUT;
----=================================================================================================================
PROCEDURE P_RUN(p_errbuff            OUT VARCHAR2
               ,p_ret_code           OUT VARCHAR2
               ,p_person_id          IN  VARCHAR2
               ,p_effective_date     IN VARCHAR2
  ) IS

CURSOR cur_mgr_dtls IS
SELECT papf.first_name,
       papf.last_name,
       papf.first_name||' '||papf.last_name full_name,
       papf.email_address,
       papf.employee_number
FROM per_all_people_f papf
WHERE papf.person_id=p_person_id
AND   trunc(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date;

CURSOR cur_emp_dtls(cv_effective_date DATE,cv_person_id NUMBER) IS
SELECT papf.first_name,
       papf.last_name,
       papf.first_name||' '||papf.last_name full_name,
       nvl((SELECT REPLACE(pg.NAME,'&','&#38;')
         FROM  per_grades pg
         WHERE pg.grade_id=paaf.grade_id
         )
        ,'')                                     grade,
       papf.employee_number,
       papf.email_address
FROM per_all_people_f      papf,
    per_all_assignments_f paaf
WHERE papf.person_id=paaf.person_id
AND   paaf.primary_flag='Y'
AND   paaf.assignment_status_type_id=1---for active assignment
AND   paaf.assignment_type='E'
AND   paaf.supervisor_id=cv_person_id
AND  trunc(cv_effective_date) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
AND  trunc(cv_effective_date) BETWEEN papf.effective_start_date AND papf.effective_end_date
AND  paaf.grade_id IS NOT NULL;
---local variable
l_effective_date        DATE;
l_xml_tag               VARCHAR2(1000);
l_server_id             VARCHAR2(1000);
l_smtp_port             VARCHAR2(1000);
l_reply_to_address      VARCHAR2(1000);
l_request_id            NUMBER;
BEGIN
l_effective_date:=TRUNC(FND_DATE.CANONICAL_TO_DATE(p_effective_date));
g_procedure_name:='P_RUN';--This is for Debug log
 g_step_id:=1;
 BEGIN
        SELECT NAME||'.@no-reply.com'
        INTO   l_reply_to_address
        FROM   v$database;
      EXCEPTION
      WHEN OTHERS THEN
       l_reply_to_address:='.@no-reply.com';
      END;
g_step_id:=2;
--XML tag creation
l_xml_tag :='<?xml version = "1.0" encoding = "UTF-8"?>';
P_OUTPUT (l_xml_tag);
l_xml_tag :='<ListOfEmpDtls>';
P_OUTPUT (l_xml_tag);
FOR cur_emp_dtls_rec IN cur_emp_dtls(l_effective_date,p_person_id) LOOP
     g_step_id:=3;
     l_xml_tag :='<EmpDtls>';
     P_OUTPUT (l_xml_tag);
     FOR cur_mgr_dtls_rec IN cur_mgr_dtls LOOP
         l_xml_tag :='<FromEmailAddress>'||cur_mgr_dtls_rec.email_address||'</FromEmailAddress>';
         P_OUTPUT (l_xml_tag);
     g_step_id:=8.1;
         l_xml_tag :='<ToEmailAddress>'||cur_emp_dtls_rec.email_address||'</ToEmailAddress>';
         P_OUTPUT (l_xml_tag);
     g_step_id:=8.2;
         l_xml_tag :='<CcEmailAddress>'||'hr@xyz.com'||'</CcEmailAddress>';
         P_OUTPUT (l_xml_tag);
     g_step_id:=9;
         l_xml_tag :='<ReplyToAddress>'||l_reply_to_address||'</ReplyToAddress>';
         P_OUTPUT (l_xml_tag);
     g_step_id:=10;
         /*Will be generate the name of the generated letter that will be sent to supervisor*/
         l_xml_tag :='<EmailSubject>'||'Grade Letter for '||cur_emp_dtls_rec.full_name||'(Employee number '||cur_emp_dtls_rec.employee_number||')'||'</EmailSubject>';
         P_OUTPUT (l_xml_tag);
     g_step_id:=11;
         l_xml_tag :='<AttchName>'||'Grade Letter_'||cur_emp_dtls_rec.employee_number||'</AttchName>';
         P_OUTPUT (l_xml_tag);        
       /* l_xml_tag :='</EmailDtls>';
        P_OUTPUT (l_xml_tag);        */
     END LOOP;
     --Employee Number
     g_step_id:=11.10;
     l_xml_tag :='<EmployeeNumber>'||cur_emp_dtls_rec.employee_number||'</EmployeeNumber>';
     P_OUTPUT (l_xml_tag);
     --Employee First Name
     g_step_id:=12;
     l_xml_tag :='<EmpFirstName>'||cur_emp_dtls_rec.first_name||'</EmpFirstName>';
     P_OUTPUT (l_xml_tag);
     --Employee Last Name
     g_step_id:=13;
     l_xml_tag :='<EmpLastName>'||cur_emp_dtls_rec.last_name||'</EmpLastName>';
     P_OUTPUT (l_xml_tag);
     --Employee Grade here value <Template Code>  is 'XX_TEST_XML_DT'
     g_step_id:=14;
     l_xml_tag :='<EmpGrade>'||cur_emp_dtls_rec.Grade||'</EmpGrade>' ;
     P_OUTPUT (l_xml_tag);
     g_step_id:=15;
     l_xml_tag :='</EmpDtls>';
     P_OUTPUT (l_xml_tag);
END LOOP;
l_xml_tag :='</ListOfEmpDtls>';
P_OUTPUT (l_xml_tag);

l_request_id :=
 fnd_request.submit_request(application => 'XDO',
                                           program     => 'XDOBURSTREP',
                                           description =>  NULL,
                                           start_time  =>  NULL,
                                           sub_request =>  FALSE,
                                           argument1   => NULL,
                                           argument2   =>  g_request_id,
                                           argument3   =>  'Y'
                                           );
EXCEPTION
WHEN OTHERS THEN
P_LOG (g_procedure_name||'_'||g_step_id||': '||SQLERRM);
END P_RUN;


end XX_TEST_XML_GEN_PKG;
/
