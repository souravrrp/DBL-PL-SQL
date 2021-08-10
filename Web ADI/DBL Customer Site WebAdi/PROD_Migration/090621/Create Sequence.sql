CREATE SEQUENCE XXDBL.XXDBL_CUST_SITE_S START WITH 1000001
                                            MAXVALUE 9999999999999999999999999999
                                            MINVALUE 0
                                            NOCYCLE
                                            NOCACHE
                                            NOORDER
                                            NOKEEP
                                            GLOBAL;

  CREATE OR REPLACE SYNONYM APPS.XXDBL_CUST_SITE_S FOR XXDBL.XXDBL_CUST_SITE_S;