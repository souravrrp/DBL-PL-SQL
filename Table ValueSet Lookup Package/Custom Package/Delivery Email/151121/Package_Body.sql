/* Formatted on 11/16/2021 10:35:15 AM (QP5 v5.365) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_email_delivery_pkg
IS
    -- CREATED BY : SOURAV PAUL
    -- CREATION DATE : 05-AUG-2020
    -- LAST UPDATE DATE :22-OCT-2020
    -- PURPOSE : EMAIL DATA UPLOAD INTO STAGING TABLE
    PROCEDURE iou_email_status_update (p_mail_status   VARCHAR2,
                                       p_iou_req_id    NUMBER)
    IS
    --PURPOSE : UPDATE IOU EMAIL STATUS UPDATE

    BEGIN
        UPDATE xxdbl.xxdbl_iou_req_dtl ird
           SET ird.mail_status = p_mail_status
         WHERE ird.iou_req_id = p_iou_req_id;

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                   'An error was encountered - '
                || SQLCODE
                || ' -ERROR- '
                || SQLERRM);
    END iou_email_status_update;

    PROCEDURE inv_track_sms_status_update (p_sms_status     VARCHAR2,
                                           p_inv_track_id   NUMBER)
    IS
    --PURPOSE : UPDATE INVOICE TRACKING SYSTEM SMS STATUS UPDATE

    BEGIN
        UPDATE xxdbl.xxdbl_invoice_tracking_system its
           SET its.sms_sent_status = p_sms_status
         WHERE its.invoice_tracking_system_id = p_inv_track_id;

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                   'An error was encountered - '
                || SQLCODE
                || ' -ERROR- '
                || SQLERRM);
    END inv_track_sms_status_update;
END xxdbl_email_delivery_pkg;
/