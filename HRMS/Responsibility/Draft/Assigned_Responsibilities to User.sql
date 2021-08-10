/* Formatted on 9/16/2020 11:49:46 AM (QP5 v5.354) */
SELECT b.user_name,
       d.full_name,
       c.responsibility_name,
       a.START_DATE,
       a.END_DATE
  FROM apps.fnd_user_resp_groups_direct  a,
       apps.fnd_user                     b,
       apps.fnd_responsibility_tl        c,
       apps.per_all_people_f             d
 WHERE     a.user_id = b.user_id
       AND a.responsibility_id = c.responsibility_id
       AND b.user_name = NVL (d.employee_number, d.NPW_NUMBER)
       AND SYSDATE BETWEEN effective_start_date AND effective_end_date
       AND (   :P_RESPONSIBILITY_NAME IS NULL
            OR (UPPER (c.responsibility_name) LIKE
                    UPPER ('%' || :P_RESPONSIBILITY_NAME || '%')))
       AND (   :P_USER_NAME IS NULL
            OR (UPPER (b.user_name) = UPPER ( :P_USER_NAME)))
       --and c.responsibility_name in ('AKG Employee Self Service')
       AND c.ZD_EDITION_NAME = 'SET2'
       --AND a.END_DATE IS NULL
       --AND (UPPER (c.responsibility_name) LIKE '%PO%' OR UPPER (c.responsibility_name) LIKE '%PR%' OR UPPER (c.responsibility_name) LIKE '%INV%')
       --AND b.user_name IN ('102246', '103822', '100386', '100397')
       ;

-------------------------------APPLICATION WISE RESPONSIBILITY------------------

SELECT FU.USER_ID,
       FU.USER_NAME,
       PPF.FIRST_NAME || ' ' || PPF.MIDDLE_NAMES || ' ' || PPF.LAST_NAME
           EMPLOYEE_NAME,
       --PPF.FULL_NAME,
       RV.RESPONSIBILITY_NAME,
       FA.APPLICATION_NAME,
       URGD.START_DATE,
       URGD.END_DATE
  FROM APPS.FND_USER_RESP_GROUPS_DIRECT  URGD,
       APPS.FND_USER                     FU,
       APPS.FND_RESPONSIBILITY_VL        RV,
       APPS.PER_ALL_PEOPLE_F             PPF,
       APPS.FND_APPLICATION_VL           FA
 WHERE     URGD.USER_ID = FU.USER_ID(+)
       AND URGD.RESPONSIBILITY_ID = RV.RESPONSIBILITY_ID(+)
       --AND FU.USER_NAME = PPF.EMPLOYEE_NUMBER(+)
       AND FU.USER_NAME = NVL (PPF.EMPLOYEE_NUMBER, PPF.NPW_NUMBER)
       AND RV.APPLICATION_ID = FA.APPLICATION_ID(+)
       AND (   :P_RESPONSIBILITY_NAME IS NULL
            OR (UPPER (RV.RESPONSIBILITY_NAME) LIKE
                    UPPER ('%' || :P_RESPONSIBILITY_NAME || '%')))
       AND (   :P_USER_NAME IS NULL
            OR (UPPER (FU.USER_NAME) = UPPER ( :P_USER_NAME)))
       AND (   :P_APPLICATION_NAME IS NULL
            OR (UPPER (FA.APPLICATION_NAME) LIKE
                    UPPER ('%' || :P_APPLICATION_NAME || '%')))
--AND URGD.END_DATE IS NULL
--AND (UPPER (c.responsibility_name) LIKE '%PO%' OR UPPER (c.responsibility_name) LIKE '%PR%' OR UPPER (c.responsibility_name) LIKE '%INV%')
--AND SYSDATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
--and c.responsibility_name in ('AKG Employee Self Service')
--AND FU.USER_NAME IN ('103908')
;
-----------------------------------DEPARTMENT WISE RESPONSIBILITY---------------


  SELECT b.user_name,
         d.full_name,
         HAOU.NAME     DEPARTMENT,
         c.responsibility_name,
         a.START_DATE,
         a.END_DATE
    FROM apps.fnd_user_resp_groups_direct a,
         apps.fnd_user                   b,
         apps.fnd_responsibility_tl      c,
         apps.per_all_people_f           d,
         APPS.PER_ALL_ASSIGNMENTS_F      PAAF,
         APPS.HR_ALL_ORGANIZATION_UNITS  HAOU
   WHERE     a.user_id = b.user_id
         AND a.responsibility_id = c.responsibility_id
         AND b.user_name = d.employee_number
         AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
         AND d.PERSON_ID = PAAF.PERSON_ID
         AND PAAF.BUSINESS_GROUP_ID = 81
         AND D.CURRENT_EMP_OR_APL_FLAG = 'Y'
         AND TRUNC (SYSDATE) BETWEEN TRUNC (PAAF.EFFECTIVE_START_DATE)
                                 AND TRUNC (PAAF.EFFECTIVE_END_DATE)
         --AND SYSDATE BETWEEN effective_start_date AND effective_end_date
         AND (   :P_RESPONSIBILITY_NAME IS NULL
              OR (UPPER (c.responsibility_name) LIKE
                      UPPER ('%' || :P_RESPONSIBILITY_NAME || '%')))
         AND (   :P_USER_NAME IS NULL
              OR (UPPER (b.user_name) = UPPER ( :P_USER_NAME)))
         AND (   ( :P_DEPARTMENT IS NULL)
              OR (UPPER (HAOU.NAME) LIKE UPPER ('%' || :P_DEPARTMENT || '%')))
--and c.responsibility_name in ('AKG Employee Self Service')
--AND b.user_name in ('103908')
ORDER BY b.user_name;

--------------------------------------------------------------------------------

/* Formatted on 10/8/2020 12:55:45 PM (QP5 v5.354) */
SELECT b.user_name,
       d.full_name,
       c.responsibility_name,
       a.START_DATE,
       a.END_DATE
  FROM apps.fnd_user_resp_groups_direct  a,
       apps.fnd_user                     b,
       apps.fnd_responsibility_tl        c,
       apps.per_all_people_f             d
 WHERE     a.user_id = b.user_id
       AND a.responsibility_id = c.responsibility_id
       AND b.user_name = d.employee_number
       AND SYSDATE BETWEEN effective_start_date AND effective_end_date
       AND c.ZD_EDITION_NAME = 'SET2'
       AND a.END_DATE IS NULL
       AND b.END_DATE IS NULL
       AND c.APPLICATION_ID IN (401,201)
       AND NVL(d.CURRENT_EMP_OR_APL_FLAG,'Y') = 'Y'
       AND (   UPPER (c.responsibility_name) LIKE '%PO%'
            OR UPPER (c.responsibility_name) LIKE '%PR%'
            OR UPPER (c.responsibility_name) LIKE '%INV%');



-----------------------------------DBL Responsibility---------------------------

  SELECT fuser.user_id,
         fuser.user_name             "User Name",
         furgd.responsibility_id,
         employee_id,
         frt.responsibility_name     "Responsibility Name"
    --,frt.*
    FROM fnd_user_resp_groups_direct furgd,
         fnd_user                   fuser,
         --  fnd_responsibility fresp,
         --  fnd_application_tl fat,
         fnd_responsibility_tl      frt,
         fnd_application            fapp
   WHERE     1 = 1
         AND furgd.user_id = fuser.user_id
         AND furgd.responsibility_id = frt.responsibility_id
         AND furgd.RESPONSIBILITY_APPLICATION_ID = fapp.APPLICATION_ID
         AND frt.APPLICATION_ID = fapp.APPLICATION_ID
         AND frt.language = USERENV ('LANG')
         AND frt.ZD_EDITION_NAME = 'SET1'
         --AND APPLICATION_SHORT_NAME = 'PO'
         --AND  frt.responsibility_name='ASL : PO - Manager'
         ---AND fuser.user_name IN ('102246', '103822', '100386', '100397')
         AND (furgd.end_date IS NULL OR furgd.end_date >= TRUNC (SYSDATE))
         AND (fuser.end_date IS NULL OR fuser.end_date >= TRUNC (SYSDATE))
ORDER BY frt.responsibility_name;

--------------------------------------------------------------------------------
/* Formatted on 7/16/2019 4:32:36 PM (QP5 v5.287) */
SELECT 
       FAT.APPLICATION_NAME,
       --AED.DEPARTMENT,
       B.USER_NAME,
       --AED.FULL_NAME EMPLOYEE_NAME,
       C.RESPONSIBILITY_NAME,
       A.START_DATE,
       A.END_DATE
       --,d.*
       --,b.*
       --,c.*
       --,a.*
  FROM APPS.FND_USER_RESP_GROUPS_DIRECT A,
       APPS.FND_USER B,
       APPS.FND_RESPONSIBILITY_TL C,
       --APPS.PER_ALL_PEOPLE_F D,
       APPS.FND_APPLICATION_TL FAT
       --,APPS.AKG_EMPLOYEE_DETAILS AED
 WHERE     A.USER_ID = B.USER_ID
       AND A.RESPONSIBILITY_ID = C.RESPONSIBILITY_ID
       AND B.END_DATE IS NULL
       AND A.END_DATE IS NULL
       --AND B.USER_NAME = D.EMPLOYEE_NUMBER
       --AND SYSDATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
       AND A.RESPONSIBILITY_APPLICATION_ID=FAT.APPLICATION_ID
       --AND AED.PERSON_ID=B.EMPLOYEE_ID
       --AND FAT.APPLICATION_NAME IN ('Receivables','Advanced Pricing','Order Management')
       --and c.responsibility_name='AKG Employee Self Service'
       --AND B.USER_NAME='32053'-- IN ('32053','1772','1882','3892','4202','1836')
       --AND LOCATION_NAME IN ('Gulshan Office, Dhaka','Shah Cement Factory, Munshigonj')
