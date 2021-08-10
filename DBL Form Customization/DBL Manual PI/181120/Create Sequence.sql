/* Formatted on 11/19/2020 10:41:26 AM (QP5 v5.287) */
CREATE SEQUENCE XXDBL.XXDBL_MANUAL_PI_S START WITH 1000001
                                        MAXVALUE 9999999999999999999999999999
                                        MINVALUE 0
                                        NOCYCLE
                                        NOCACHE
                                        NOORDER
                                        NOKEEP
                                        GLOBAL;

  CREATE OR REPLACE SYNONYM APPS.XXDBL_MANUAL_PI_S FOR XXDBL.XXDBL_MANUAL_PI_S;
  
  --GRANT SELECT ON XXDBL.XXDBL_MANUAL_PI_S TO APPSRO;
  --GRANT ALTER, SELECT ON XXDBL.XXDBL_MANUAL_PI_S TO APPS WITH GRANT OPTION;
  --|| TRIM (LPAD (XXDBL_MANUAL_PI_S.NEXTVAL, 5, '0'));