/* Formatted on 9/23/2021 11:26:28 AM (QP5 v5.354) */
DECLARE
    ACL_PATH   VARCHAR2 (4000);
BEGIN
    --Look for the ACL currently assigned to '*' and give APEX_050000
    -- the "connect" privilege if APEX_050000 does not have the privilege yet.

    SELECT ACL
      INTO ACL_PATH
      FROM DBA_NETWORK_ACLS
     WHERE HOST = '*' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL;

    IF DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE (ACL_PATH,
                                               'APEX_200100',
                                               'connect')
           IS NULL
    THEN
        DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (ACL_PATH,
                                              'APEX_200100',
                                              TRUE,
                                              'connect');
    END IF;
EXCEPTION
    -- When no ACL has been assigned to '*'.
    WHEN NO_DATA_FOUND
    THEN
        DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
            'power_users.xml',
            'ACL that lets power users to connect to everywhere',
            'APEX_200100',
            TRUE,
            'connect');
        DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL ('power_users.xml', '*');
END;
/

COMMIT;

DECLARE
    ACL_PATH   VARCHAR2 (4000);
BEGIN
    -- Look for the ACL currently assigned to 'localhost' and give APEX_050000
    -- the "connect" privilege if APEX_040200 does not have the privilege yet.
    SELECT ACL
      INTO ACL_PATH
      FROM DBA_NETWORK_ACLS
     WHERE HOST = 'localhost' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL;

    IF DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE (ACL_PATH,
                                               'APEX_200100',
                                               'connect')
           IS NULL
    THEN
        DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (ACL_PATH,
                                              'APEX_200100',
                                              TRUE,
                                              'connect');
    END IF;
EXCEPTION
    -- When no ACL has been assigned to 'localhost'.
    WHEN NO_DATA_FOUND
    THEN
        DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
            'local-access-users.xml',
            'ACL that lets users to connect to localhost',
            'APEX_200100',
            TRUE,
            'connect');
        DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL ('local-access-users.xml',
                                           'localhost');
END;
/

COMMIT;