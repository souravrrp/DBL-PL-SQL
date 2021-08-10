/* Formatted on 4/28/2021 10:08:59 AM (QP5 v5.287) */
CREATE MATERIALIZED VIEW APPS.xxDDR_BS_EXCPTN_SKU_BU_WK_C_MV
(
   MFG_ORG_CD,
   RTL_ORG_CD,
   EXCPTN_TYP,
   ORG_BSNS_UNIT_ID,
   CHNL_TYP_CD,
   ORG_RGN_ID,
   MFG_SKU_ITEM_ID,
   MFG_ITEM_CLASS_ID,
   RTL_SKU_ITEM_ID,
   CLNDR_WK_ID,
   CNT_TOTAL,
   EXCPTN_CNT,
   EXCPTN_QTY,
   EXCPTN_AMT,
   CNT_EXCPTN_QTY,
   CNT_EXCPTN_AMT
)
   TABLESPACE APPS_TS_SUMMARY
   PCTUSED 0
   PCTFREE 10
   INITRANS 10
   MAXTRANS 255
   STORAGE (INITIAL 16 K
            NEXT 64 K
            MAXSIZE UNLIMITED
            MINEXTENTS 1
            MAXEXTENTS UNLIMITED
            PCTINCREASE 0
            BUFFER_POOL DEFAULT
            FLASH_CACHE DEFAULT
            CELL_FLASH_CACHE DEFAULT)
   NOCACHE
   LOGGING
   NOCOMPRESS
   NOPARALLEL
   BUILD DEFERRED
   USING INDEX
      TABLESPACE APPS_TS_SUMMARY
      PCTFREE 10
      INITRANS 11
      MAXTRANS 255
      STORAGE (INITIAL 16 K
               NEXT 64 K
               MINEXTENTS 1
               MAXEXTENTS UNLIMITED
               PCTINCREASE 0
               BUFFER_POOL DEFAULT
               FLASH_CACHE DEFAULT
               CELL_FLASH_CACHE DEFAULT)
   REFRESH
      FORCE
      ON DEMAND
      WITH PRIMARY KEY
AS
     /*Formatted on 17/Jan/21 9:17:11 AM (QP5 v5.256.13226.35538) */
     SELECT "A5"."MFG_ORG_CD" "MFG_ORG_CD",
            "A5"."RTL_ORG_CD" "RTL_ORG_CD",
            "A5"."EXCPTN_TYP" "EXCPTN_TYP",
            "A5"."ORG_BSNS_UNIT_ID" "ORG_BSNS_UNIT_ID",
            "A3"."CHNL_TYP_CD" "CHNL_TYP_CD",
            "A3"."ORG_RGN_ID" "ORG_RGN_ID",
            "A2"."MFG_SKU_ITEM_ID" "MFG_SKU_ITEM_ID",
            "A2"."MFG_ITEM_CLASS_ID" "MFG_ITEM_CLASS_ID",
            "A1"."RTL_SKU_ITEM_ID" "RTL_SKU_ITEM_ID",
            "A4"."CLNDR_WK_ID" "CLNDR_WK_ID",
            COUNT (*) "CNT_TOTAL",
            1 "EXCPTN_CNT",
            SUM (NVL ("A5"."EXCPTN_QTY", 0)) "EXCPTN_QTY",
            SUM (NVL ("A5"."EXCPTN_AMT", 0)) "EXCPTN_AMT",
            COUNT (NVL ("A5"."EXCPTN_QTY", 0)) "CNT_EXCPTN_QTY",
            COUNT (NVL ("A5"."EXCPTN_AMT", 0)) "CNT_EXCPTN_AMT"
       FROM "DDR"."DDR_B_EXCPTN_ITEM_DAY" "A5",
            "APPS"."DDR_R_CLNDR_DAY_DN_MV" "A4",
            "APPS"."DDR_R_ORG_BU_DN_MV" "A3",
            "APPS"."DDR_R_MFG_ITEM_SKU_DN_MV" "A2",
            "APPS"."DDR_R_RTL_ITEM_SKU_DN_MV" "A1"
      WHERE     "A4"."DAY_CD" = "A5"."DAY_CD"
            AND "A4"."CLNDR_DESC" = "A5"."MFG_ORG_CD" || '-CLNDR'
            AND "A2"."MFG_SKU_ITEM_ID" = "A5"."MFG_SKU_ITEM_ID"
            AND "A1"."RTL_SKU_ITEM_ID" = "A5"."RTL_SKU_ITEM_ID"
            AND "A3"."ORG_BSNS_UNIT_ID" = "A5"."ORG_BSNS_UNIT_ID"
   GROUP BY "A4"."CLNDR_WK_ID",
            "A5"."MFG_ORG_CD",
            "A5"."RTL_ORG_CD",
            "A5"."EXCPTN_TYP",
            "A5"."ORG_BSNS_UNIT_ID",
            "A3"."CHNL_TYP_CD",
            "A3"."ORG_RGN_ID",
            "A2"."MFG_SKU_ITEM_ID",
            "A2"."MFG_ITEM_CLASS_ID",
            "A1"."RTL_SKU_ITEM_ID";