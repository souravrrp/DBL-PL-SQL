--
-- Begin default relation declare section
--
DECLARE
  recstat     VARCHAR2(20) := :System.record_status;   
  startitm    VARCHAR2(61) := :System.cursor_item;   
  rel_id      Relation;
--
-- End default relation declare section
--
--
-- Begin default relation program section
--
BEGIN
  IF ( recstat = 'NEW' or recstat = 'INSERT' ) THEN   
    RETURN;
  END IF;
  --
  -- Begin XXVEH_ACTIVITIES detail program section
  --
  IF ( (:XX_VMS.VMST_ID is not null) ) THEN   
    rel_id := Find_Relation('XX_VMS.XX_VMS_XXVEH_ACTIVITIES');   
    Query_Master_Details(rel_id, 'XXVEH_ACTIVITIES');   
  END IF;
  --
  -- End XXVEH_ACTIVITIES detail program section
  --

  IF ( :System.cursor_item <> startitm ) THEN     
     Go_Item(startitm);     
     Check_Package_Failure;     
  END IF;
END;
--
-- End default relation program section
--
