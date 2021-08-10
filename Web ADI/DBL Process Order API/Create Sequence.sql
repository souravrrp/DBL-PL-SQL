/* Formatted on 5/19/2021 4:21:40 PM (QP5 v5.287) */
CREATE SEQUENCE XXDBL.XXDBL_OM_ORDER_UPD_S START WITH 1000001
                                           MAXVALUE 9999999999999999999999999999
                                           MINVALUE 0
                                           NOCYCLE
                                           NOCACHE
                                           NOORDER
                                           NOKEEP
                                           GLOBAL;

  CREATE OR REPLACE SYNONYM APPS.XXDBL_OM_ORDER_UPD_S FOR XXDBL.XXDBL_OM_ORDER_UPD_S;

  --GRANT SELECT ON XXDBL.XXDBL_MANUAL_PI_S TO APPSRO;
  --GRANT ALTER, SELECT ON XXDBL.XXDBL_MANUAL_PI_S TO APPS WITH GRANT OPTION;
  --|| TRIM (LPAD (XXDBL_CUST_CREATION_S.NEXTVAL, 5, '0'));