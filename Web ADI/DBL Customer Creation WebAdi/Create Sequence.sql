/* Formatted on 3/14/2021 10:37:04 AM (QP5 v5.287) */
CREATE SEQUENCE XXDBL.XXDBL_CUSTOMER_CREATION_S START WITH 1000001
                                            MAXVALUE 9999999999999999999999999999
                                            MINVALUE 0
                                            NOCYCLE
                                            NOCACHE
                                            NOORDER
                                            NOKEEP
                                            GLOBAL;

  CREATE OR REPLACE SYNONYM APPS.XXDBL_CUSTOMER_CREATION_S FOR XXDBL.XXDBL_CUSTOMER_CREATION_S;

  --GRANT SELECT ON XXDBL.XXDBL_MANUAL_PI_S TO APPSRO;
  --GRANT ALTER, SELECT ON XXDBL.XXDBL_MANUAL_PI_S TO APPS WITH GRANT OPTION;
  --|| TRIM (LPAD (XXDBL_CUST_CREATION_S.NEXTVAL, 5, '0'));