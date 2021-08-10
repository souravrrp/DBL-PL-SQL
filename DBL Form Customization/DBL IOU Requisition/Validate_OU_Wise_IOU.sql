/* Formatted on 6/7/2021 3:06:19 PM (QP5 v5.287) */
PROCEDURE VALIDATE_OU_WISE_REQ
IS
   v_iou_req   NUMBER;
BEGIN
   IF     :XXDBL_IOU_REQ_DTL.OU_NAME = 'DBLPHARMA'
      AND :XXDBL_IOU_REQ_DTL.LOCATION_NAME = 'Pharma'
      AND (   :XXDBL_IOU_REQ_DTL.SND_APVR IS NULL
           OR :XXDBL_IOU_REQ_DTL.SND_APVR <> '103645')
      AND :XXDBL_IOU_REQ_DTL.FST_APVR <> '103645'
      AND :XXDBL_IOU_REQ_DTL.ADVANCE_AMOUNT >= 10000
   THEN
      SET_ALERT_PROPERTY (
         'alt_iou_req',
         alert_message_text,
         'Please assign Site Head as Second Approver of this IOU Requisition.');
      v_iou_req := SHOW_ALERT ('alt_iou_req');
      RAISE form_trigger_failure;
   END IF;
END;