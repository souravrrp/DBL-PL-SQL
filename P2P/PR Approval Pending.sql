Select   Q.org,Q.Requestor_Name, Q.Status, Count (*) No_Of_Lines
    From (Select Prla.Destination_Organization_Id,
 (SELECT ORGANIZATION_CODE FROM apps.org_organization_definitions
                           where ORGANIZATION_ID=Prla.Destination_Organization_Id)Org,
              (Select (papf.FIRST_NAME || ' ' || papf.MIDDLE_NAMES || ' ' || papf.LAST_NAME)
                    From Apps.Per_All_People_F Papf
                   Where Papf.Person_Id = Prla.To_Person_Id
                     And Sysdate Between Effective_Start_Date
                                     And Effective_End_Date) Requestor_Name,
                 Prha.Authorization_Status Status
            From Apps.Po_Requisition_Headers_All Prha,
                 Apps.Po_Requisition_Lines_All Prla
           Where Prha.Requisition_Header_Id = Prla.Requisition_Header_Id
             And Prha.Creation_Date < Sysdate - 30
             And Prha.Authorization_Status Not In ('APPROVED', 'CANCELLED')
             And Nvl (Prla.Closed_Code, 'OPEN') <> 'FINALLY CLOSED'
             --And Prla.Destination_Organization_Id = :P_Organization_Id
             And Prha.Org_Id = 131) Q
Group By Q.org,Q.Requestor_Name, Q.Status
Order By Q.org,Q.Requestor_Name, Q.Status;


--------------------------------------------------------------------------------

SELECT   pah.action_code
       , pah.object_id
       , pah.action_date
       , pah.sequence_num step
       , pah.creation_date
       , prha.segment1 req_num
       , prha.wf_item_key
       , prha.authorization_status
       , fu.description
       , papf.full_name hr_full_name
       , papf.employee_number emp_no
       , pj.NAME job
    FROM po.po_action_history pah
       , po.po_requisition_headers_all prha
       , applsys.fnd_user fu
       , hr.per_all_people_f papf
       , hr.per_all_assignments_f paaf
       , hr.per_jobs pj
   WHERE object_id = prha.requisition_header_id
     AND pah.employee_id = fu.employee_id
     AND fu.employee_id = papf.person_id
     AND papf.person_id = paaf.person_id
     AND paaf.job_id = pj.job_id
     AND paaf.primary_flag = 'Y'
     AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
     AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
     AND pah.object_type_code = 'REQUISITION'
     AND pah.action_code = 'APPROVE'
     AND prha.authorization_status = 'IN PROCESS'
     and ((:p_emp_id is null) or (nvl(papf.employee_number,papf.npw_number) = :p_emp_id))
ORDER BY pah.creation_date desc;