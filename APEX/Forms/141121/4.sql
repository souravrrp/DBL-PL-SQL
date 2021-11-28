CREATE TABLE XX_APEX.XX_APEX_MENU_LIST
(
  MENU_LIST_ID         NUMBER GENERATED ALWAYS AS IDENTITY ( START WITH 41 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP) NOT NULL,
  APPLICATION_NAME     VARCHAR2(100 BYTE),
  MENU_MODULE_ID       NUMBER,
  MENU_NAME            VARCHAR2(200 BYTE),
  PAGE_NO              NUMBER,
  PAGE_ICON            VARCHAR2(200 BYTE),
  PARENT_MENU_LIST_ID  VARCHAR2(200 BYTE),
  PARENT_MENU_NAME     VARCHAR2(200 BYTE),
  MENU_STATUS          NUMBER,
  REMARKS              VARCHAR2(500 BYTE),
  CREATED_BY           VARCHAR2(100 BYTE),
  CREATION_DATE        DATE,
  LAST_UPDATED_BY      VARCHAR2(100 BYTE),
  LAST_UPDATE_DATE     DATE
);


CREATE UNIQUE INDEX XX_APEX.XX_APEX_MENU_LIST_PK ON XX_APEX.XX_APEX_MENU_LIST
(MENU_LIST_ID);

ALTER TABLE XX_APEX.XX_APEX_MENU_LIST ADD (
  CONSTRAINT XX_APEX_MENU_LIST_PK
  PRIMARY KEY
  (MENU_LIST_ID)
  USING INDEX XX_APEX.XX_APEX_MENU_LIST_PK
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM XX_APEX_MENU_LIST FOR XX_APEX.XX_APEX_MENU_LIST;