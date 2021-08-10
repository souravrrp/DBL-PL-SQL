   select 
   pah.object_id,
   nvl(ppf.first_name||' '||ppf.middle_names||' '||ppf.last_name ,'NA') Final_Approver
   from 
   po_action_history pah,
   per_people_f ppf
   where object_type_code='REQUISITION'
   and pah.employee_id=ppf.person_id
   and pah.sequence_num=(select max(sequence_num) from po_action_history a where  action_code='APPROVE' and object_type_code='REQUISITION' and a.object_id=pah.object_id )
   and action_code='APPROVE'
--   and object_id=:p_po_number 