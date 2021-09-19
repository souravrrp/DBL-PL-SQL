/* Formatted on 8/9/2021 3:55:28 PM (QP5 v5.287) */
SELECT apps.xx_com_pkg.get_dept_from_user_name_id ('103662', NULL) dept_name,
       NVL (
          REGEXP_SUBSTR (
             apps.xx_com_pkg.get_dept_from_user_name_id ('103662', NULL),
             '[^-]+',
             3,
             3),
          REGEXP_SUBSTR (
             apps.xx_com_pkg.get_dept_from_user_name_id ('103662', NULL),
             '[^-]+',
             2,
             2))
          short_dept_name
  FROM DUAL;


SELECT apps.xx_com_pkg.designation_from_user_name_id ('103908', NULL)
          designation,
       REGEXP_SUBSTR (
          apps.xx_com_pkg.designation_from_user_name_id ('103908', NULL),
          '[^.]+',
          1,
          2)
          short_designation
  FROM DUAL;