/* Formatted on 5/18/2021 9:47:29 AM (QP5 v5.287) */
CREATE TABLE USER_INFORMATION
(
   USER_ID                    NUMBER,
   UNIQUE_ID                  NUMBER,
   EMAIL                      VARCHAR2 (50 BYTE),
   CONTACT_NO                 VARCHAR2 (50 BYTE),
   LOGIN_NAME                 VARCHAR2 (50 BYTE),
   PWD                        VARCHAR2 (100 BYTE),
   USER_LEVEL                 NUMBER,
   NEED_FIRST_LOGIN_PWD_CNG   VARCHAR2 (50 BYTE),
   STATUS                     VARCHAR2 (50 BYTE),
   CREATED_BY                 VARCHAR2 (50 BYTE),
   CREATED_ON                 VARCHAR2 (50 BYTE),
   MODIFIED_BY                VARCHAR2 (50 BYTE),
   MODIFIED_ON                VARCHAR2 (50 BYTE)
)