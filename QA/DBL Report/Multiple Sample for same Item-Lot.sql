/* Formatted on 1/30/2022 4:48:10 PM (QP5 v5.374) */
  SELECT GMD.ORGANIZATION_ID    "ORG",
         ITM.SEGMENT1           "Item Code",
         GMD.SAMPLE_NO,
         GMD.SAMPLE_DESC,
         GMD.LOT_NUMBER,
         GMD.SAMPLE_QTY,
         CTG.SEGMENT2           "CTG",
         CTG.SEGMENT3,
         GMD.CREATION_DATE,
         (CASE
              WHEN GMD.SAMPLE_DISPOSITION IN ('1P', ' ') THEN 'Accept'
              ELSE 'Planned'
          END)                  "STATUS",
         GMD.RETAIN_AS,
         GMD.SAMPLE_DISPOSITION
    FROM APPS.GMD_SAMPLES           GMD,
         APPS.MTL_SYSTEM_ITEMS_B_KFV ITM,
         APPS.MTL_ITEM_CATEGORIES_V CTG
   WHERE     GMD.ORGANIZATION_ID = 158
         AND CTG.SEGMENT2 NOT IN 'NA'
         AND GMD.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
         AND GMD.ORGANIZATION_ID = ITM.ORGANIZATION_ID
         AND ITM.INVENTORY_ITEM_ID = CTG.INVENTORY_ITEM_ID
         AND ITM.ORGANIZATION_ID = CTG.ORGANIZATION_ID
         AND CTG.CATEGORY_SET_ID = 1
         --AND GMD.RETAIN_AS NOT IN 'Reserve'
         --AND CTG.SEGMENT3 IN 'SFG'
         --AND GMD.RETAIN_AS NOT IN ( 'R')
         --AND CTG.SEGMENT3 = 'API'
         --AND ITM.SEGMENT1 = '10100014'
         --AND GMD.SAMPLE_NO = '283'
         AND GMD.LOT_NUMBER = 'R000052'
         AND GMD.SAMPLE_DISPOSITION NOT IN '1P'
ORDER BY ITM.SEGMENT1, GMD.LOT_NUMBER,                        --GMD.RETAIN_AS,
                                       GMD.SAMPLE_NO;

--------------------------------------------------------------------------------

  SELECT GMD.ORGANIZATION_ID     "ORG",
         ITM.SEGMENT1            "Item Code",
         GMD.LOT_NUMBER,
         GMD.SAMPLE_NO,
         GMD.SAMPLE_DESC,
         GMD.RETAIN_AS,
         GMD.CREATION_DATE
    FROM APPS.GMD_SAMPLES           GMD,
         APPS.MTL_SYSTEM_ITEMS_B_KFV ITM,
         APPS.MTL_ITEM_CATEGORIES_V CTG
   WHERE     GMD.ORGANIZATION_ID = 158
         AND CTG.SEGMENT2 NOT IN 'NA'
         AND GMD.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
         AND GMD.ORGANIZATION_ID = ITM.ORGANIZATION_ID
         AND ITM.INVENTORY_ITEM_ID = CTG.INVENTORY_ITEM_ID
         AND ITM.ORGANIZATION_ID = CTG.ORGANIZATION_ID
         AND CTG.CATEGORY_SET_ID = 1
         --AND GMD.RETAIN_AS NOT IN 'Reserve'
         --AND CTG.SEGMENT3 IN 'SFG'
         --AND GMD.RETAIN_AS NOT IN ( 'R')
         --AND CTG.SEGMENT3 = 'API'
         --AND ITM.SEGMENT1 = '10100003'
         --AND GMD.SAMPLE_NO = '283'
         AND GMD.LOT_NUMBER = 'P000089'
         AND GMD.SAMPLE_DISPOSITION NOT IN '1P'
         AND NOT EXISTS
                 (SELECT 1
                    FROM APPS.GMD_SAMPLES GS
                   WHERE GS.RETAIN_AS = 'R' AND GMD.SAMPLE_NO = GS.SAMPLE_NO)
ORDER BY ITM.SEGMENT1, GMD.LOT_NUMBER, GMD.SAMPLE_NO          --,GMD.RETAIN_AS
;
--------------------------------------------------------------------------------


  SELECT GMD.ORGANIZATION_ID       "ORG",
         ITM.SEGMENT1              "Item Code",
         GMD.LOT_NUMBER,
         COUNT (GMD.SAMPLE_NO)     NO_OF_SAMPLE
    FROM APPS.GMD_SAMPLES           GMD,
         APPS.MTL_SYSTEM_ITEMS_B_KFV ITM,
         APPS.MTL_ITEM_CATEGORIES_V CTG
   WHERE     GMD.ORGANIZATION_ID = 158
         AND CTG.SEGMENT2 NOT IN 'NA'
         AND GMD.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
         AND GMD.ORGANIZATION_ID = ITM.ORGANIZATION_ID
         AND ITM.INVENTORY_ITEM_ID = CTG.INVENTORY_ITEM_ID
         AND ITM.ORGANIZATION_ID = CTG.ORGANIZATION_ID
         AND CTG.CATEGORY_SET_ID = 1
         --AND GMD.RETAIN_AS NOT IN 'Reserve'
         --AND CTG.SEGMENT3 IN 'SFG'
         --AND GMD.RETAIN_AS NOT IN ( 'R')
         --AND CTG.SEGMENT3 = 'API'
         --AND ITM.SEGMENT1 = '10100003'
         --AND GMD.SAMPLE_NO = '283'
         AND GMD.LOT_NUMBER = 'R000052'
         AND GMD.SAMPLE_DISPOSITION NOT IN '1P'
         AND NOT EXISTS
                 (SELECT 1
                    FROM APPS.GMD_SAMPLES GS
                   WHERE GS.RETAIN_AS = 'R' AND GMD.SAMPLE_NO = GS.SAMPLE_NO)
GROUP BY GMD.ORGANIZATION_ID, ITM.SEGMENT1, GMD.LOT_NUMBER
  HAVING COUNT (GMD.SAMPLE_NO) > 1
--ORDER BY ITM.SEGMENT1, GMD.LOT_NUMBER, GMD.SAMPLE_NO          --,GMD.RETAIN_AS
UNION ALL
  SELECT GMD.ORGANIZATION_ID       "ORG",
         ITM.SEGMENT1              "Item Code",
         GMD.LOT_NUMBER,
         COUNT (GMD.SAMPLE_NO)     NO_OF_SAMPLE
    FROM APPS.GMD_SAMPLES           GMD,
         APPS.MTL_SYSTEM_ITEMS_B_KFV ITM,
         APPS.MTL_ITEM_CATEGORIES_V CTG
   WHERE     GMD.ORGANIZATION_ID = 158
         AND CTG.SEGMENT2 NOT IN 'NA'
         AND GMD.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
         AND GMD.ORGANIZATION_ID = ITM.ORGANIZATION_ID
         AND ITM.INVENTORY_ITEM_ID = CTG.INVENTORY_ITEM_ID
         AND ITM.ORGANIZATION_ID = CTG.ORGANIZATION_ID
         AND CTG.CATEGORY_SET_ID = 1
         --AND GMD.RETAIN_AS NOT IN 'Reserve'
         --AND CTG.SEGMENT3 IN 'SFG'
         --AND GMD.RETAIN_AS NOT IN ( 'R')
         --AND CTG.SEGMENT3 = 'API'
         --AND ITM.SEGMENT1 = '10100003'
         --AND GMD.SAMPLE_NO = '283'
         AND GMD.LOT_NUMBER = 'R000052'
         AND GMD.SAMPLE_DISPOSITION NOT IN '1P'
         AND EXISTS
                 (SELECT 1
                    FROM APPS.GMD_SAMPLES GS
                   WHERE GS.RETAIN_AS = 'R' AND GMD.SAMPLE_NO = GS.SAMPLE_NO)
GROUP BY GMD.ORGANIZATION_ID, ITM.SEGMENT1, GMD.LOT_NUMBER
  HAVING COUNT (GMD.SAMPLE_NO) > 1
--ORDER BY ITM.SEGMENT1, GMD.LOT_NUMBER, GMD.SAMPLE_NO          --,GMD.RETAIN_AS
;
--------------------------------------------------------------------------------smallest

  SELECT GMD.ORGANIZATION_ID                 "ORG",
         ITM.SEGMENT1                        "Item Code",
         GMD.LOT_NUMBER,
         MIN (TO_NUMBER (GMD.SAMPLE_NO))     TOP_SAMPLE,
         MIN (GMD.CREATION_DATE)             TOP_LOT_DATE
    FROM APPS.GMD_SAMPLES           GMD,
         APPS.MTL_SYSTEM_ITEMS_B_KFV ITM,
         APPS.MTL_ITEM_CATEGORIES_V CTG
   WHERE     GMD.ORGANIZATION_ID = 158
         AND CTG.SEGMENT2 NOT IN 'NA'
         AND GMD.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
         AND GMD.ORGANIZATION_ID = ITM.ORGANIZATION_ID
         AND ITM.INVENTORY_ITEM_ID = CTG.INVENTORY_ITEM_ID
         AND ITM.ORGANIZATION_ID = CTG.ORGANIZATION_ID
         AND CTG.CATEGORY_SET_ID = 1
         --AND GMD.RETAIN_AS NOT IN 'Reserve'
         --AND CTG.SEGMENT3 IN 'SFG'
         --AND GMD.RETAIN_AS NOT IN ( 'R')
         --AND CTG.SEGMENT3 = 'API'
         --AND ITM.SEGMENT1 = '10100003'
         --AND GMD.SAMPLE_NO = '283'
         AND GMD.LOT_NUMBER = 'R000052'
         AND GMD.SAMPLE_DISPOSITION NOT IN '1P'
         AND NOT EXISTS
                 (SELECT 1
                    FROM APPS.GMD_SAMPLES GS
                   WHERE GS.RETAIN_AS = 'R' AND GMD.SAMPLE_NO = GS.SAMPLE_NO)
GROUP BY GMD.ORGANIZATION_ID, ITM.SEGMENT1, GMD.LOT_NUMBER
--HAVING COUNT (GMD.SAMPLE_NO) > 1
--ORDER BY ITM.SEGMENT1, GMD.LOT_NUMBER, GMD.SAMPLE_NO          --,GMD.RETAIN_AS
UNION ALL
  SELECT GMD.ORGANIZATION_ID                 "ORG",
         ITM.SEGMENT1                        "Item Code",
         GMD.LOT_NUMBER,
         MIN (TO_NUMBER (GMD.SAMPLE_NO))     TOP_SAMPLE,
         MIN (GMD.CREATION_DATE)             TOP_LOT_DATE
    FROM APPS.GMD_SAMPLES           GMD,
         APPS.MTL_SYSTEM_ITEMS_B_KFV ITM,
         APPS.MTL_ITEM_CATEGORIES_V CTG
   WHERE     GMD.ORGANIZATION_ID = 158
         AND CTG.SEGMENT2 NOT IN 'NA'
         AND GMD.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
         AND GMD.ORGANIZATION_ID = ITM.ORGANIZATION_ID
         AND ITM.INVENTORY_ITEM_ID = CTG.INVENTORY_ITEM_ID
         AND ITM.ORGANIZATION_ID = CTG.ORGANIZATION_ID
         AND CTG.CATEGORY_SET_ID = 1
         --AND GMD.RETAIN_AS NOT IN 'Reserve'
         --AND CTG.SEGMENT3 IN 'SFG'
         --AND GMD.RETAIN_AS NOT IN ( 'R')
         --AND CTG.SEGMENT3 = 'API'
         --AND ITM.SEGMENT1 = '10100003'
         --AND GMD.SAMPLE_NO = '283'
         AND GMD.LOT_NUMBER = 'R000052'
         AND GMD.SAMPLE_DISPOSITION NOT IN '1P'
         AND EXISTS
                 (SELECT 1
                    FROM APPS.GMD_SAMPLES GS
                   WHERE GS.RETAIN_AS = 'R' AND GMD.SAMPLE_NO = GS.SAMPLE_NO)
GROUP BY GMD.ORGANIZATION_ID, ITM.SEGMENT1, GMD.LOT_NUMBER
--HAVING COUNT (GMD.SAMPLE_NO) > 1
--ORDER BY ITM.SEGMENT1, GMD.LOT_NUMBER, GMD.SAMPLE_NO          --,GMD.RETAIN_AS
;
--------------------------------------------------------------------------------DETAILS

  /* Formatted on 1/31/2022 9:42:48 AM (QP5 v5.374) */
  SELECT GMD.ORGANIZATION_ID                               "ORG",
         (SELECT DISTINCT MEANING
            FROM FND_LOOKUP_VALUES_VL FLV
           WHERE     GMD.SOURCE = FLV.LOOKUP_CODE
                 AND FLV.LOOKUP_TYPE = 'GMD_QC_SOURCE')    SAMPLE_SOURCE,
         ITM.SEGMENT1                                      "Item Code",
         CTG.SEGMENT2                                      MAJOR_CAT,
         GMD.LOT_NUMBER,
         GMD.SAMPLE_NO,
         (CASE
              WHEN GMD.SAMPLE_DISPOSITION IN ('1P', ' ') THEN 'Accept'
              ELSE 'Planned'
          END)                                             "STATUS",
         GMD.SAMPLE_DESC,
         GMD.RETAIN_AS,
         GMD.CREATION_DATE
    FROM APPS.GMD_SAMPLES           GMD,
         APPS.MTL_SYSTEM_ITEMS_B_KFV ITM,
         APPS.MTL_ITEM_CATEGORIES_V CTG
   WHERE     GMD.ORGANIZATION_ID = 158
         AND CTG.SEGMENT2 NOT IN 'NA'
         AND GMD.INVENTORY_ITEM_ID = ITM.INVENTORY_ITEM_ID
         AND GMD.ORGANIZATION_ID = ITM.ORGANIZATION_ID
         AND ITM.INVENTORY_ITEM_ID = CTG.INVENTORY_ITEM_ID
         AND ITM.ORGANIZATION_ID = CTG.ORGANIZATION_ID
         AND CTG.CATEGORY_SET_ID = 1
         --AND GMD.RETAIN_AS NOT IN 'Reserve'
         --AND CTG.SEGMENT3 IN 'SFG'
         --AND GMD.RETAIN_AS NOT IN ( 'R')
         --AND CTG.SEGMENT3 = 'API'
         --AND ITM.SEGMENT1 = '10100003'
         --AND GMD.SAMPLE_NO = '283'
         AND EXISTS
                 (SELECT 1
                    FROM (  SELECT GMD.ORGANIZATION_ID       "ORG",
                                   ITM.SEGMENT1              "Item Code",
                                   GMD.LOT_NUMBER,
                                   COUNT (GMD.SAMPLE_NO)     NO_OF_SAMPLE
                              FROM APPS.GMD_SAMPLES         GMD,
                                   APPS.MTL_SYSTEM_ITEMS_B_KFV ITM,
                                   APPS.MTL_ITEM_CATEGORIES_V CTG
                             WHERE     GMD.ORGANIZATION_ID = 158
                                   AND CTG.SEGMENT2 NOT IN 'NA'
                                   AND GMD.INVENTORY_ITEM_ID =
                                       ITM.INVENTORY_ITEM_ID
                                   AND GMD.ORGANIZATION_ID = ITM.ORGANIZATION_ID
                                   AND ITM.INVENTORY_ITEM_ID =
                                       CTG.INVENTORY_ITEM_ID
                                   AND ITM.ORGANIZATION_ID = CTG.ORGANIZATION_ID
                                   AND CTG.CATEGORY_SET_ID = 1
                                   AND GMD.SAMPLE_DISPOSITION NOT IN '1P'
                                   AND NOT EXISTS
                                           (SELECT 1
                                              FROM APPS.GMD_SAMPLES GS
                                             WHERE     GS.RETAIN_AS = 'R'
                                                   AND GMD.SAMPLE_NO =
                                                       GS.SAMPLE_NO)
                          GROUP BY GMD.ORGANIZATION_ID,
                                   ITM.SEGMENT1,
                                   GMD.LOT_NUMBER
                            HAVING COUNT (GMD.SAMPLE_NO) > 1
                          UNION ALL
                            SELECT GMD.ORGANIZATION_ID       "ORG",
                                   ITM.SEGMENT1              "Item Code",
                                   GMD.LOT_NUMBER,
                                   COUNT (GMD.SAMPLE_NO)     NO_OF_SAMPLE
                              FROM APPS.GMD_SAMPLES         GMD,
                                   APPS.MTL_SYSTEM_ITEMS_B_KFV ITM,
                                   APPS.MTL_ITEM_CATEGORIES_V CTG
                             WHERE     GMD.ORGANIZATION_ID = 158
                                   AND CTG.SEGMENT2 NOT IN 'NA'
                                   AND GMD.INVENTORY_ITEM_ID =
                                       ITM.INVENTORY_ITEM_ID
                                   AND GMD.ORGANIZATION_ID = ITM.ORGANIZATION_ID
                                   AND ITM.INVENTORY_ITEM_ID =
                                       CTG.INVENTORY_ITEM_ID
                                   AND ITM.ORGANIZATION_ID = CTG.ORGANIZATION_ID
                                   AND CTG.CATEGORY_SET_ID = 1
                                   AND GMD.SAMPLE_DISPOSITION NOT IN '1P'
                                   AND EXISTS
                                           (SELECT 1
                                              FROM APPS.GMD_SAMPLES GS
                                             WHERE     GS.RETAIN_AS = 'R'
                                                   AND GMD.SAMPLE_NO =
                                                       GS.SAMPLE_NO)
                          GROUP BY GMD.ORGANIZATION_ID,
                                   ITM.SEGMENT1,
                                   GMD.LOT_NUMBER
                            HAVING COUNT (GMD.SAMPLE_NO) > 1)
                   WHERE LOT_NUMBER = GMD.LOT_NUMBER)
         AND GMD.SAMPLE_DISPOSITION NOT IN '1P'
ORDER BY ITM.SEGMENT1,
         GMD.LOT_NUMBER,
         GMD.SAMPLE_NO,
         GMD.RETAIN_AS;