/* Formatted on 9/20/2020 4:56:44 PM (QP5 v5.287) */
DECLARE
   l_iou_req              NUMBER;
   l_status   VARCHAR2 (100);
BEGIN
   IF :XXDBL_IOU_REQ_DTL.STATUS = 'NEW'
   THEN
      pr_message ('Do you want to create IOU Requisition ' || '?', 'Q');
      pr_message ('Confirm ' || '?', 'Q');

      IF :SYSTEM.form_status != 'QUERY'
      THEN
         :SYSTEM.message_level := 25;
         POST;
         :SYSTEM.message_level := 0;
      END IF;

      SET_ITEM_PROPERTY ('XXDBL_IOU_REQ_DTL.OU_NAME', ENABLED, property_false);
      SET_ITEM_PROPERTY ('XXDBL_IOU_REQ_DTL.RETURN_DAYS', ENABLED, property_false);
      SET_ITEM_PROPERTY ('XXDBL_IOU_REQ_DTL.REASON_FOR_ADVANCE', ENABLED, property_false);
      SET_ITEM_PROPERTY ('XXDBL_IOU_REQ_DTL.ADVANCE_AMOUNT', ENABLED, property_false);

      EXECUTE_QUERY;
      go_block('GATE_PASS_MASTER') ;
        GO_ITEM('GATE_PASS_MASTER.TO_HEAD');  
     
        :GATE_PASS_MASTER.CREATED_BY:= fnd_global.user_id;
        :GATE_PASS_MASTER.CREATION_DATE := SYSDATE;
        :GATE_PASS_MASTER.ORGANIZATION_ID:= :parameter.inv_organization_id;
        :SYSTEM.MESSAGE_LEVEL := 25;
                
        commit_form; 
        exit_form(no_validate);
        Clear_Form(No_Validate);
   END IF;
END;
------------------------------------------

/* Formatted on 9/20/2020 4:56:44 PM (QP5 v5.287) */
DECLARE
   l_iou_req              NUMBER;
   l_status   VARCHAR2 (100);
BEGIN
   IF :XXDBL_IOU_REQ_DTL.STATUS = 'NEW'
   THEN
      --pr_message ('Do you want to create IOU Requisition ' || '?', 'Q');
      --pr_message ('Confirm ' || '?', 'Q');

      --IF :SYSTEM.form_status != 'QUERY'
      --THEN
         --:SYSTEM.message_level := 25;
         --POST;
         --:SYSTEM.message_level := 0;
      --END IF;
      :XXDBL_IOU_REQ_DTL.STATUS := 'CREATED';
      commit;
      IF :XXDBL_IOU_REQ_DTL.STATUS = 'CREATED'
        THEN

          SET_ITEM_PROPERTY ('XXDBL_IOU_REQ_DTL.OU_NAME', ENABLED, property_false);
          SET_ITEM_PROPERTY ('XXDBL_IOU_REQ_DTL.RETURN_DAYS', ENABLED, property_false);
          SET_ITEM_PROPERTY ('XXDBL_IOU_REQ_DTL.REASON_FOR_ADVANCE', ENABLED, property_false);
          SET_ITEM_PROPERTY ('XXDBL_IOU_REQ_DTL.ADVANCE_AMOUNT', ENABLED, property_false);
      END IF;
      --commit_form;
      --exit_form(no_validate);
      clear_form(no_validate);
      go_block ('XXDBL_IOU_REQ_DTL');
      GO_ITEM('XXDBL_IOU_REQ_DTL.OU_NAME');  
      
    	--execute_query;
   END IF;
END;