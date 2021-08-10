/* Formatted on 7/15/2020 11:58:24 AM (QP5 v5.287) */
DECLARE
   UID    NUMBER;
   rid    NUMBER;
   rad    NUMBER;
   sgid   NUMBER;
BEGIN
   SELECT USER_ID,
          RESPONSIBILITY_ID,
          RESPONSIBILITY_APPLICATION_ID,
          SECURITY_GROUP_ID
     INTO UID,
          rid,
          rad,
          sgid
     FROM FND_USER_RESP_GROUPS
    WHERE     USER_ID = (SELECT USER_ID
                           FROM FND_USER
                          WHERE USER_NAME = 'SYSADMIN')
          AND RESPONSIBILITY_ID =
                 (SELECT RESPONSIBILITY_ID
                    FROM FND_RESPONSIBILITY_VL
                   WHERE RESPONSIBILITY_KEY = 'SYSTEM_ADMINISTRATOR');

   FND_GLOBAL.apps_initialize (UID,
                               rid,
                               rad,
                               sgid);
   ego_p4t_upgrade_pvt.upgrade_to_pim4telco (NULL);
END;