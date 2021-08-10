/* Formatted on 11/7/2020 3:00:21 PM (QP5 v5.354) */
SELECT * FROM apps.fnd_conc_req_summary_v;

SELECT *
  FROM apps.FND_USER
 WHERE 1 = 1                                            --and user_name='8824'
             AND user_id = '2916';

SELECT *
  FROM apps.akg_employee_details
 WHERE 1 = 1 AND employee_number = '32053';

SELECT d.user_name,
       b.program,
       b.process,
       b.sid,
       b.serial#
  FROM apps.fnd_logins  a,
       v$session        b,
       v$process        c,
       apps.fnd_user    d
 WHERE     b.paddr = c.addr
       AND a.pid = c.pid
       AND a.spid = b.process
       AND d.user_id = a.user_id
       AND (d.user_name = 'USER_NAME' OR 1 = 1)
       AND b.program LIKE '%JDBC%'
       AND b.process = '29925';

SELECT * FROM v$session;

SELECT * FROM v$process;

SELECT * FROM DBA_ROLE_PRIVS;

SELECT username
  FROM v$session
 WHERE     status = 'ACTIVE'
       AND RAWTOHEX (sql_address) <> '00'
       AND username IS NOT NULL;

SELECT fnd_global.user_id FROM DUAL;

SELECT fnd_global.user_name FROM duall;

SELECT *
  FROM all_source
 WHERE UPPER (TEXT) LIKE UPPER ('%procedure_name%') AND ROWNUM <= 10;

SELECT * FROM all_dependencies  --where referenced_name like '%PACKAGE_NAME%';
;
SELECT * FROM apps.FND_RESPONSIBILITY_TL;

SELECT * FROM apps.FND_RESPONSIBILITY;

SELECT * FROM apps.FND_APPLICATION;

SELECT 'Active', valid.*
  FROM apps.fnd_user valid
 WHERE valid.user_id IN (SELECT user_id
                           FROM apps.fnd_user
                          WHERE NVL (end_date, SYSDATE) >= SYSDATE)
UNION ALL
SELECT 'In Active', invalid.*
  FROM apps.fnd_user invalid
 WHERE invalid.user_id IN (SELECT user_id
                             FROM apps.fnd_user
                            WHERE NVL (end_date, SYSDATE) < SYSDATE)
ORDER BY 2;


SELECT *
  FROM (SELECT 'Active' "Status", valid.*
          FROM apps.fnd_user valid
         WHERE valid.user_id IN (SELECT user_id
                                   FROM apps.fnd_user
                                  WHERE NVL (end_date, SYSDATE) >= SYSDATE)
        UNION ALL
        SELECT 'In Active' "Status", invalid.*
          FROM apps.fnd_user invalid
         WHERE invalid.user_id IN (SELECT user_id
                                     FROM apps.fnd_user
                                    WHERE NVL (end_date, SYSDATE) < SYSDATE))
 WHERE user_id = :user_id OR user_name = :user_name;

SELECT user_name,
       employee_id,
       start_date,
       end_date,
       CASE
           WHEN end_date IS NULL OR end_date > SYSDATE THEN 'ACTIVE'
           ELSE 'INACTIVE'
       END    user_status
  FROM apps.fnd_user;

SELECT fat.application_name,
       fa.application_id,
       fpi.patch_level,
       DECODE (fpi.STATUS,
               'I', 'Licensed',
               'N', 'Not Licensed',
               'S', 'Shared',
               'Undetermined')    STATUS
  FROM apps.fnd_product_installations  fpi,
       apps.fnd_application            fa,
       apps.fnd_application_tl         fat
 WHERE     fpi.application_id = fa.application_id
       AND fat.application_id = fa.application_id
       AND fat.LANGUAGE = 'US';

SELECT *
  FROM apps.fnd_product_installations fpi
 WHERE 1 = 1 AND fpi.status = 'S'                             --'Undetermined'
;
SELECT * FROM apps.gl_bc_packets         --where po_header_id =<po_header_id>;
;
SELECT DISTINCT
       fcp.user_concurrent_program_name     "Concurrent Program Name",
       fcp.description                      "Concurrent Program Description",
       fef.executable_name                  "Executable Name",
       fef.description                      "Executable Description",
       fef.execution_file_name              "Procedure Name"
  FROM apps.fnd_executables_form_v fef, apps.fnd_concurrent_programs_vl fcp
 WHERE     fcp.APPLICATION_ID = fef.APPLICATION_ID
       AND fef.EXECUTABLE_ID = fcp.EXECUTABLE_ID
--   AND fef.executable_name='XX_EXECUTABLE'---Youer Executable Name
--  AND fcp.user_concurrent_program_name='Program Name'--Your Consurrent Program name
;
SELECT poh.segment1                            po_number,
       pol.line_num,
       pol.item_description,
       ploc.quantity,
       mtl.segment1 || ',' || mtl.segment2     po_item,
       prh.segment1                            req_num,
       fnd.user_name                           requestor,
       prl.need_by_date
  FROM apps.po_line_locations_all       ploc,
       apps.po_lines_all                pol,
       apps.po_headers_all              poh,
       apps.mtl_system_items_b          mtl,
       apps.po_requisition_lines_all    prl,
       apps.po_requisition_headers_all  prh,
       apps.fnd_user                    fnd
 WHERE     poh.po_header_id = pol.po_header_id(+)
       AND pol.po_line_id = ploc.po_line_id(+)
       AND pol.item_id = mtl.inventory_item_id(+)
       AND ploc.line_location_id = prl.line_location_id(+)
       AND prl.requisition_header_id = prh.requisition_header_id(+)
       AND prh.preparer_id = fnd.employee_id(+)
       AND mtl.organization_id(+) = :your_org;

  SELECT fu.user_name                  "User Name",
         frt.responsibility_name       "Responsibility Name",
         furg.start_date               "Start Date",
         furg.end_date                 "End Date",
         fr.responsibility_key         "Responsibility Key",
         fa.application_short_name     "Application Short Name"
    FROM apps.fnd_user_resp_groups_direct furg,
         applsys.fnd_user                fu,
         applsys.fnd_responsibility_tl   frt,
         applsys.fnd_responsibility      fr,
         applsys.fnd_application_tl      fat,
         applsys.fnd_application         fa
   WHERE     furg.user_id = fu.user_id
         AND furg.responsibility_id = frt.responsibility_id
         AND fr.responsibility_id = frt.responsibility_id
         AND fa.application_id = fat.application_id
         AND fr.application_id = fat.application_id
         AND frt.language = USERENV ('LANG')
         -- AND UPPER(fu.user_name) = UPPER('Jagadekar') -- <change it>
         AND (furg.end_date IS NULL OR furg.end_date >= TRUNC (SYSDATE))
         AND (fu.end_date IS NULL OR fu.end_date >= TRUNC (SYSDATE))
ORDER BY 1, 2;

SELECT fu.user_name,
       fr.responsibility_name,
       furg.START_DATE,
       furg.END_DATE
  FROM apps.fnd_user_resp_groups_direct  furg,
       apps.fnd_user                     fu,
       apps.fnd_responsibility_tl        fr
 WHERE     fu.user_name = UPPER ('&user_name')
       AND furg.user_id = fu.user_id
       AND furg.responsibility_id = fr.responsibility_id
       AND fr.language = USERENV ('LANG');

SELECT * FROM xxakg.dba_audit_trail;

  SELECT fnd.user_name,
         icx.responsibility_application_id,
         icx.responsibility_id,
         frt.responsibility_name,
         icx.session_id,
         icx.first_connect,
         icx.last_connect,
         DECODE ((icx.disabled_flag),  'N', 'ACTIVE',  'Y', 'INACTIVE')    status
    FROM apps.fnd_user             fnd,
         apps.icx_sessions         icx,
         apps.fnd_responsibility_tl frt
   WHERE     fnd.user_id = icx.user_id
         AND icx.responsibility_id = frt.responsibility_id
         AND icx.disabled_flag <> 'Y'
         AND fnd.user_name = '1613'
         AND TRUNC (icx.last_connect) = TRUNC (SYSDATE)
ORDER BY icx.last_connect;

  SELECT MAX (flr.start_time),
         flr.responsibility_id,
         fu.user_name,
         flt.responsibility_name
    FROM apps.fnd_logins                fl,
         apps.fnd_login_Responsibilities flr,
         apps.fnd_user                  fu,
         apps.fnd_responsibility_tl     flt
   WHERE     flr.login_id = fl.login_id
         AND flt.responsibility_id = flr.responsibility_id
         AND fu.user_id = fl.user_id
GROUP BY fl.user_id,
         flr.RESPONSIBILITY_ID,
         fu.user_name,
         flt.responsibility_name
ORDER BY fl.user_id;

SELECT DISTINCT e.application_name,
                a.responsibility_name                           --,a.LANGUAGE,
                                     --,b.responsibility_key
                                     ,
                c.user_menu_name,
                c.DESCRIPTION,
                fme.prompt,
                fme.description,
                fme.MENU_ID,
                frf.ACTION_ID
  FROM apps.fnd_responsibility_tl  a,
       apps.fnd_responsibility     b,
       apps.fnd_menus_tl           c,
       apps.fnd_menus              d,
       apps.fnd_application_tl     e,
       apps.fnd_application        f,
       apps.fnd_menus_tl           apm,
       apps.fnd_menu_entries_tl    fme,
       apps.FND_RESP_FUNCTIONS     frf
 WHERE     a.responsibility_id(+) = b.responsibility_id
       AND b.menu_id = c.menu_id
       AND b.menu_id = d.menu_id
       AND e.application_id = f.application_id
       AND f.application_id = b.application_id
       AND a.LANGUAGE = 'US'
       AND apm.menu_id = fme.menu_id
       AND fme.MENU_ID(+) = c.MENU_ID
       AND b.RESPONSIBILITY_ID = frf.RESPONSIBILITY_ID
--and c.CREATED_BY='8824'
;
SELECT * FROM apps.fnd_menu_entries_tl;

SELECT * FROM apps.per_all_people_f;

SELECT p.employee_number     "Employee Number",
       p.full_name           "Employee Name",
       p.attribute2          "Other Name",
       p.start_date          "Hire Date",
       p.email_address       "Email in HR Window",
       o.NAME                "Organization Name",
       u.user_name           "User Name",
       u.email_address       "Email in User Window"
  FROM apps.per_all_people_f         p,
       apps.fnd_user                 u,
       apps.per_all_assignments_f    a,
       apps.hr_organization_units_v  o
 WHERE     1 = 1
       AND p.employee_number IN ('8824')
       AND SYSDATE BETWEEN p.effective_start_date AND p.effective_end_date
       --AND p.business_group_id = 305
       AND o.organization_id = a.organization_id
       AND p.person_id = a.person_id
       AND SYSDATE BETWEEN a.effective_start_date AND a.effective_end_date
       AND u.employee_id(+) = p.person_id;

    SELECT *
      FROM (    SELECT menu_id,
                       sub_menu_id,
                       function_id,
                       LPAD (' ', (LEVEL - 1) * 2) || prompt     prompt,
                       entry_sequence
                  FROM apps.fnd_menu_entries_vl fme
                 WHERE prompt IS NOT NULL
            CONNECT BY PRIOR sub_menu_id = menu_id
            START WITH     menu_id = 67605
                       AND menu_id = 67605
                       AND prompt IS NOT NULL
                       AND grant_flag = 'Y'
              ORDER BY entry_sequence) a
CONNECT BY PRIOR sub_menu_id = menu_id
START WITH menu_id = 67605                               /*like INV_NAVIGATE*/
                           AND menu_id = 67605 AND prompt IS NOT NULL;


SELECT A.menu_id,
       B.sub_menu_id,
       C.prompt,
       B.function_id,
       D.user_function_name,
       B.entry_sequence
  FROM apps.Fnd_menus              A,
       apps.Fnd_menu_entries       B,
       apps.Fnd_menu_entries_tl    C,
       apps.FND_FORM_FUNCTIONS_TL  D
 WHERE     A.menu_id = B.menu_id
       AND B.menu_id = C.menu_id
       AND B.entry_sequence = C.entry_sequence
       AND B.function_id = D.function_id
       AND C.LANGUAGE = 'US'
       AND D.LANGUAGE = 'US'
       AND A.menu_id = 68077;