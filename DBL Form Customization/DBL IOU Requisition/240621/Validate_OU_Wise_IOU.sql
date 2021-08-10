/* Formatted on 6/24/2021 3:06:35 PM (QP5 v5.287) */
BEGIN
   IF     :XXDBL_IOU_REQ_DTL.OU_NAME = 'DBLCL'
      AND :XXDBL_IOU_REQ_DTL.LOCATION_NAME = 'Corporate Office'
   THEN
      :XXDBL_IOU_REQ_DTL.SND_APVR := '100372';
      :XXDBL_IOU_REQ_DTL.SND_APVR_NAME:='Mohammad Bayazed Bashar';
   END IF;
END;