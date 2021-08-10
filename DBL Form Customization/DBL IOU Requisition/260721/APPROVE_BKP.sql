DECLARE
   v_approve             NUMBER;
   l_iou_req_id          NUMBER;
   l_subwork_id          NUMBER;

   v_emp_no              VARCHAR2 (100);
   l_second_approver     VARCHAR2 (100);
   l_first_approver      VARCHAR2 (100);
   v_emp_name            VARCHAR2 (500);
   --l_item_name    VARCHAR2(200);
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
BEGIN
   GO_BLOCK ('XXDBL_IOU_REQ_DTL');
   l_iou_req_id := :XXDBL_IOU_REQ_DTL.IOU_REQ_ID;

   SELECT fu.user_name
     INTO v_emp_no
     FROM fnd_user fu
    WHERE fu.user_id = p_user_id;

   SELECT first_approver
     INTO l_first_approver
     FROM xxdbl.xxdbl_iou_req_dtl
    WHERE iou_req_id = l_iou_req_id;
   
   SELECT second_approver
     INTO l_second_approver
     FROM xxdbl.xxdbl_iou_req_dtl
    WHERE iou_req_id = l_iou_req_id;

   --SELECT DISTINCT MSI.DESCRIPTION||'('||MSI.SEGMENT1||')' INTO l_item_name FROM APPS.MTL_SYSTEM_ITEMS_B MSI WHERE MSI.INVENTORY_ITEM_ID=l_item_id;



   IF     :XXDBL_IOU_REQ_DTL.IOU_REQ_ID IS NOT NULL
      AND :XXDBL_IOU_REQ_DTL.PRESENT_STATUS = 'CREATED'
      AND l_second_approver IS NOT NULL
      AND l_first_approver=v_emp_no
   THEN
      
      SET_ALERT_PROPERTY ('alt_approve',
                          alert_message_text,
                          'Do You Want to Approve IOU Requisition ?'); --||l_item_name||

      v_approve := SHOW_ALERT ('alt_approve');

      IF v_approve = alert_button1
      THEN
         :XXDBL_IOU_REQ_DTL.APPROVED_BY := v_emp_no;
         :XXDBL_IOU_REQ_DTL.PRESENT_STATUS := 'APPROVED';

         UPDATE xxdbl.xxdbl_iou_req_dtl ird
            SET approved_date = SYSDATE
          WHERE iou_req_id = l_iou_req_id;

         COMMIT;
         EXECUTE_QUERY;
         --DELETE_RECORD;
         --COMMIT;
         CLEAR_BLOCK (no_validate);
         GO_BLOCK ('XXDBL_IOU_REQ_DTL');
      END IF;
   ELSIF     :XXDBL_IOU_REQ_DTL.IOU_REQ_ID IS NOT NULL
         AND :XXDBL_IOU_REQ_DTL.PRESENT_STATUS = 'CREATED'
         AND L_SECOND_APPROVER IS NULL
         AND l_first_approver=v_emp_no
   THEN
      :XXDBL_IOU_REQ_DTL.FINAL_APPROVER := v_emp_no;
      SET_ALERT_PROPERTY ('alt_approve',
                          alert_message_text,
                          'Do You Want to Final Approve IOU Requisition ?'); --||l_item_name||

      v_approve := SHOW_ALERT ('alt_approve');


      IF v_approve = alert_button1
      THEN
         :XXDBL_IOU_REQ_DTL.PRESENT_STATUS := 'FINAL APPROVE';

         UPDATE xxdbl.xxdbl_iou_req_dtl ird
            SET FINAL_APPROVED_DATE = SYSDATE
          WHERE iou_req_id = l_iou_req_id;

         COMMIT;
         EXECUTE_QUERY;
         --DELETE_RECORD;
         --COMMIT;
         CLEAR_BLOCK (no_validate);
         GO_BLOCK ('XXDBL_IOU_REQ_DTL');
      END IF;
   ELSIF     :XXDBL_IOU_REQ_DTL.IOU_REQ_ID IS NOT NULL
         AND :XXDBL_IOU_REQ_DTL.PRESENT_STATUS='APPROVED'
         AND l_second_approver=v_emp_no
   THEN
      :XXDBL_IOU_REQ_DTL.FINAL_APPROVER := v_emp_no;
      SET_ALERT_PROPERTY ('alt_approve',
                          alert_message_text,
                          'Do You Want to Final Approve IOU Requisition ?'); --||l_item_name||

      v_approve := SHOW_ALERT ('alt_approve');


      IF v_approve = alert_button1
      THEN
         :XXDBL_IOU_REQ_DTL.PRESENT_STATUS := 'FINAL APPROVE';

         UPDATE xxdbl.xxdbl_iou_req_dtl ird
            SET FINAL_APPROVED_DATE = SYSDATE
          WHERE iou_req_id = l_iou_req_id;

         COMMIT;
         EXECUTE_QUERY;
         --DELETE_RECORD;
         --COMMIT;
         CLEAR_BLOCK (no_validate);
         GO_BLOCK ('XXDBL_IOU_REQ_DTL');
      END IF;
   END IF;
--EXECUTE_QUERY;
END;