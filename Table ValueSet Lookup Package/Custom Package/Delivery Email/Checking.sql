/* Formatted on 8/11/2021 2:27:31 PM (QP5 v5.287) */
  SELECT *
    FROM xxdbl.xxdbl_iou_req_dtl ird
   WHERE 1 = 1
--AND IOU_NUMBER='FFL-RMG/290721/1'
--AND TO_CHAR (iou_date, 'DD-MON-YYYY') = '01-AUG-2021'
--AND IOU_REQ_ID IS NULL
AND IOU_REQ_ID = 12427
ORDER BY iou_date, iou_req_id DESC;

EXECUTE APPS.xxdbl_email_delivery_pkg.iou_email_status_update('DBLCL','');
COMMIT;


UPDATE XXDBL.XXDBL_IOU_REQ_DTL
SET MAIL_STATUS = 'NA'
WHERE IOU_REQ_ID = 12427;

EXECUTE APPS.xxdbl_email_delivery_pkg.iou_email_status_update('NA',12427);   --CREATED-1ST
commit;