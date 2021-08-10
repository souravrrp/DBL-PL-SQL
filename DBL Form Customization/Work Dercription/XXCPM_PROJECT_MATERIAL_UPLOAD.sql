XXCPM_PROJECT_MATERIAL_UPLOAD


CREATE OR REPLACE PROCEDURE XXDBL.XXCPM_PROJECT_MATERIAL_UPLOAD (
   P_PROJECT_ID             NUMBER,
   P_BUILDING_ID            NUMBER,
   P_REVISION_NUM           NUMBER,
   P_PROJECT_WORK_QTY_ID    NUMBER)
IS
   V_NUM   NUMBER;
BEGIN
   DELETE FROM PROJECT_WISE_MATERIAL_QNT
         WHERE     project_id = p_project_id
               AND building_id = NVL (p_building_id, building_id)
               AND REVISION_NUM = NVL (P_REVISION_NUM, REVISION_NUM)
               AND PROJECT_WORK_QTY_ID =
                     NVL (P_PROJECT_WORK_QTY_ID, PROJECT_WORK_QTY_ID);

   COMMIT;



   INSERT INTO PROJECT_WISE_MATERIAL_QNT (ORGANIZATION_ID,
                                          PROJECT_ID,
                                          BUILDING_ID,
                                          BUILDING_LEVEL_ID,
                                          APPARTMENT_ID,
                                          UNIT_LOCATION_ID,
                                          REVISION_NUM,
                                          NATURE_OF_JOB_ID,
                                          WORK_DESCRIPTION_ID,
                                          SUB_WORK_DESCRIPTION_ID,
                                          PROJECT_WORK_QTY_ID,
                                          INVENTORY_ITEM_ID,
                                          UNIT_OF_MEASURE,
                                          MTL_ORIGIN_LOOKUP_CODE,
                                          MTL_BRAND_LOOKUP_CODE,
                                          QUANTITY,
                                          UNIT_PRICE,
                                          CREATION_DATE,
                                          CREATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_LOGIN)
      SELECT 138,
             P.PROJECT_ID,
             BUILDING_ID,
             BUILDING_LEVEL_ID,
             APPARTMENT_ID,
             UNIT_LOCATION_ID,
             REVISION_NUM,
             PWQ.NATURE_OF_JOB_ID,
             PWQ.WORK_DESCRIPTION_ID,
             PWQ.SUB_WORK_DESCRIPTION_ID,
             PROJECT_WORK_QTY_ID,                              --SUB_WORK_QTY,
             -- M_SUB_WORK_DESCRIPTION ,
             WMR.INVENTORY_ITEM_ID,
             WMR.UNIT_OF_MEASURE MATERIAL_OUM,
             MTL_ORIGIN_LOOKUP_CODE,
             MTL_BRAND_LOOKUP_CODE,
             (REQUIRED_QUANTITY) * SUB_WORK_QTY REQ_QUNATITY,
             mp.UNIT_PRICE,
             SYSDATE,
             PWQ.CREATED_BY,
             SYSDATE,
             PWQ.LAST_UPDATED_BY,
             PWQ.LAST_UPDATE_LOGIN
        FROM PROJECT_WISE_WORK_QNT PWQ,
             (SELECT WR.NATURE_OF_JOB_ID,
                     WR.WORK_DESCRIPTION_ID,
                     WR.SUB_WORK_DESCRIPTION_ID,
                     WR.ORGANIZATION_ID,
                     WR.INVENTORY_ITEM_ID,
                     WR.MTL_SPECIFICATION,
                     WR.UNIT_OF_MEASURE,
                     WR.MTL_ORIGIN_LOOKUP_CODE,
                     WR.MTL_BRAND_LOOKUP_CODE,
                     (NVL (WR.REQUIRED_QUANTITY, 0) / NVL (EST_WORK_QTY, 1))
                        REQUIRED_QUANTITY,
                     MATERIAL_SEPCIFICATION_ID
                FROM WORK_MATERIAL_REQE wr, SUB_WORK_DESCRIPTION SW
               WHERE SW.SUB_WORK_DESCRIPTION_ID = WR.SUB_WORK_DESCRIPTION_ID)
             WMR,
             ALL_PROJECT_INFO_MASTER P,
             (  SELECT spec_id, MAX (unit_price) unit_price
                  FROM XX_MATERIAL_EST_PRICE
                 WHERE active_to IS NULL
              GROUP BY spec_id) MP
       WHERE     P.PROJECT_ID = PWQ.PROJECT_ID
             AND PWQ.NATURE_OF_JOB_ID = WMR.NATURE_OF_JOB_ID
             AND PWQ.WORK_DESCRIPTION_ID = WMR.WORK_DESCRIPTION_ID
             AND PWQ.SUB_WORK_DESCRIPTION_ID = WMR.SUB_WORK_DESCRIPTION_ID
             AND PWQ.PROJECT_WORK_QTY_ID =
                   NVL (P_PROJECT_WORK_QTY_ID, PWQ.PROJECT_WORK_QTY_ID)
             AND PWQ.PROJECT_ID = P_PROJECT_ID
             AND PWQ.BUILDING_ID = NVL (P_BUILDING_ID, PWQ.BUILDING_ID)
             AND PWQ.REVISION_NUM = NVL (p_revision_num, PWQ.REVISION_NUM)
             AND wmr.MATERIAL_SEPCIFICATION_ID = mp.SPEC_ID(+);

   COMMIT;
END;
/
