/* Formatted on 12/6/2020 3:47:37 PM (QP5 v5.287) */
DECLARE
   v_reject              NUMBER;
   l_iou_req_id          NUMBER;

   v_emp_no              VARCHAR2 (100);
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

   --SELECT DISTINCT MSI.DESCRIPTION||'('||MSI.SEGMENT1||')' INTO l_item_name FROM APPS.MTL_SYSTEM_ITEMS_B MSI WHERE MSI.INVENTORY_ITEM_ID=l_item_id;



   IF :XXDBL_IOU_REQ_DTL.IOU_REQ_ID IS NOT NULL
   THEN
      :XXDBL_IOU_REQ_DTL.REJECTED_BY := v_emp_no;
      SET_ALERT_PROPERTY ('alt_reject',
                          alert_message_text,
                          'Do You Want to Reject IOU Requisition ?'); --||l_item_name||

      v_reject := SHOW_ALERT ('alt_reject');

      IF v_reject = alert_button1
      THEN
         :XXDBL_IOU_REQ_DTL.PRESENT_STATUS := 'APRV_REJECTED';

         UPDATE xxdbl.xxdbl_iou_req_dtl ird
            SET rejected_date = SYSDATE
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