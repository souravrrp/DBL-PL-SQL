/* Formatted on 10/4/2021 3:10:26 PM (QP5 v5.365) */
CREATE SEQUENCE XX_APEX.XXAPEX_ORD_GRN_TRACK_S START WITH 1001
                                               MAXVALUE 9999999999999999999999999999
                                               MINVALUE 0
                                               NOCYCLE
                                               NOCACHE
                                               NOORDER
                                               NOKEEP
                                               GLOBAL;


CREATE OR REPLACE SYNONYM APPS.XXAPEX_ORD_GRN_TRCK_S FOR XX_APEX.XXAPEX_ORD_GRN_TRACK_S;

GRANT ALTER, SELECT
    ON XX_APEX.XXAPEX_ORD_GRN_TRACK_S
    TO APPS
    WITH GRANT OPTION;

GRANT SELECT ON XX_APEX.XXAPEX_ORD_GRN_TRACK_S TO APPSRO;


DROP SEQUENCE XX_APEX.XXAPEX_ORD_GRN_TRACK_S;

SELECT XX_APEX.XXAPEX_ORD_GRN_TRACK_S.NEXTVAL FROM DUAL;