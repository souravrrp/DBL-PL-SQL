/* Formatted on 9/19/2020 3:30:44 PM (QP5 v5.287) */
DECLARE
   v_do_seq        NUMBER;
   v_short_code    VARCHAR2 (100);
   v_bill_number   VARCHAR2 (100);
   v_org           NUMBER;
BEGIN
   fnd_standard.set_who;
   :XXDBL_IOU_REQ_DTL.IOU_REQ_ID :=
      XX_COM_PKG.GET_SEQUENCE_VALUE ('XXDBL_IOU_REQ_DTL', 'IOU_REQ_ID');

   SELECT   MAX (
               XX_COM_PKG.GET_SEQUENCE_VALUE ('XXDBL_IOU_REQ_DTL',
                                              'IOU_REQ_ID'))
          + 1
     INTO v_do_seq
     FROM DUAL;

   SELECT    :XXDBL_IOU_REQ_DTL.OU_NAME
          || '/'
          || v_short_code
          || 'BILL'
          || DECODE (v_short_code, NULL, NULL, '/')
          || v_do_seq
     INTO v_bill_number
     FROM DUAL;

   :XX_VMS_BILL_MST.BLL_NO := v_bill_number;

   :XX_VMS_BILL_MST.INVOICE_AMOUNT := :ITEM299;


   SELECT organization_id
     INTO v_org
     FROM hr_operating_units
    WHERE name = :xx_vms_bill_mst.purch_ou;

   :xx_vms_bill_mst.org_id := v_org;

   SET_ITEM_PROPERTY ('XX_VMS_BILL_MST.INVOICE', ENABLED, property_true);
END;

-----------------------------------

SELECT COUNT (IOU_REQ_ID) + 1 INTO v_unit_seq
    FROM XXDBL.XXDBL_IOU_REQ_DTL IRD
   WHERE 1 = 1 AND TRUNC (IOU_DATE) = TRUNC (SYSDATE)
   AND IRD.OU_NAME=:XXDBL_IOU_REQ_DTL.OU_NAME
	GROUP BY IRD.OU_NAME;

   

   SELECT   MAX (
               XX_COM_PKG.GET_SEQUENCE_VALUE ('XXDBL_IOU_REQ_DTL',
                                              'IOU_REQ_ID'))
          + 1
     INTO v_do_seq
     FROM DUAL;
     
     SELECT    :XXDBL_IOU_REQ_DTL.OU_NAME
          || '/'
          || vl_sysdate
          || v_unit_seq
     INTO v_iou_number
     FROM DUAL;
     
     :XXDBL_IOU_REQ_DTL.IOU_NUMBER:=v_iou_number;
     
     IF SQL%NOTFOUND
      THEN
         v_unit_seq := 1;
      ELSIF SQL%FOUND
      THEN
         v_unit_seq := v_unit_seq;
      END IF;