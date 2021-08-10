SELECT
*
FROM
WF_ITEMS
WHERE 1=1
--ORDER BY CRE

SELECT
*
FROM
WF_ITEM_TYPES
WHERE 1=1
AND NAME LIKE '%BPM%'
OR NAME LIKE '%XXDBLREQ%'

---------------------------------------------------------------------------------------------------------------------------------------
--Steps to check who last updated a Workflow definition file (*.wft) and determine the timestamp of when it was last updated.

--Test the following steps in a development instance:

--1. First, find the definition file for the workflow item_type.

--How to Find workflow definition file (*.wft) using ITEM_TYPE (The example below uses Expenses APEXP):

--cd $APPL_TOP

--find . -type f -name "*.wft" -exec grep -l 'BEGIN ITEM_TYPE "APEXP"' {} \;

--./ap/12.0.0/patch/115/import/CS/apwxwkfl.wft

--./ap/12.0.0/patch/115/import/ZHT/apwxwkfl.wft

--./ap/12.0.0/patch/115/import/US/apwxwkfl.wft

--./ap/12.0.0/patch/115/import/ZHS/apwxwkfl.wft

--./ap/12.0.0/patch/115/import/S/apwxwkfl.wft

--./ap/12.0.0/patch/115/import/TR/apwxwkfl.wft

--./ap/12.0.0/patch/115/import/RU/apwxwkfl.wft

--All you need to know is the Item_Type: APEXP

--To use a workflow it has to exist in the workflow tables, so the workflow definition (*.wft) has to be loaded using WFLOAD command.

--Once a workflow is loaded into the database (WFLOAD) it is available to be instantiated (started), so it will be findable in ad_files and ad_file_versions.

--2. You can find the workflow definition files loaded into the DB by using the following sql:

--A. Show the current Workflow Definition file found in the Database

    select * from
    (select "Filename", "US Subdir", "US Version", "Created", "Last Update"
    from ( select af1.filename "Filename", af1.subdir "US Subdir", afv1.version "US Version", afv1.creation_date "Created", to_char(afv1.last_update_date,'DD-MON-YYYY') "Last Update",
    rank()over(partition by af1.filename
    order by afv1.version_segment1 desc,
    afv1.version_segment2 desc,afv1.version_segment3 desc,
    afv1.version_segment4 desc,afv1.version_segment5 desc,
    afv1.version_segment6 desc,afv1.version_segment7 desc,
    afv1.version_segment8 desc,afv1.version_segment9 desc,
    afv1.version_segment10 desc,
    afv1.translation_level desc) as rankUS
    from ad_files af1, ad_file_versions afv1
    where af1.file_id = afv1.file_id
    and af1.filename = 'apwxwkfl.wft'
    and af1.subdir = 'patch/115/import/US')
    where rankUS = 1);

--3. Show all the versions of a workflow definition file:

    select f.FILE_ID, f.APP_SHORT_NAME "TOP", f.SUBDIR, f.FILENAME,
    v.file_version_id, v.VERSION, v.creation_date, v.last_update_date,
    fu.USER_NAME "Updated By"
    from ad_files f, ad_file_versions v, fnd_user fu
    where f.FILE_ID=v.FILE_ID
    and f.FILENAME = 'apwxwkfl.wft'
    and f.subdir = 'patch/115/import/US'
    and fu.user_id = v.LAST_UPDATED_BY
    order by v.file_version_id desc;

--Note:

--WF_ITEM_TYPES table is the Master design-time table for all workflow definitions.

--WF_ITEMS table is the Master run-time table of all instantiated/started workflows.

--If a workflow has been started, a unique row (i.e. WF_ITEMS.item_key) will be found in the wf_items table until it has been completed and the runtime data is purged.

--Also a single workflow may spawn child workflows, which spawn grandchildren workflows etc...

--Order Management has a single Order Header (OEOH) which has many Order Lines (OEOL) which can also have other Lines or REQs, or POs or Errors, etc…

--To fully understand the scope of a Workflow Process, run the below scripts:

  --bde_wf_item.sql or bde_wf_process_tree.sql from Workflow Scripts (Doc ID 183643.1)

  --bde_wf_item.sql - Runtime Data of a Single Workflow Item (Doc ID 187071.1)

  --bde_wf_process_tree.sql - For analyzing the Root Parent, Children, Grandchildren Associations of a Single Workflow Process (Doc ID 1378954.1)
  
  
  
  
  
  --find . -type f -name "*.wft" -exec grep -l 'BEGIN ITEM_TYPE "DBLMOA"' {} \;

--/ap/12.0.0/patch/115/import/US/apwxwkfl.wft

--cd $APPL_TOP

--/u01/EBSCRP/fs1/EBSapps/appl/ap/12.0.0/patch/115/import/US/apwxwkfl.wft
  
  
  --------------------------------------------------------------------------------
  
  --FILE_ID   TOP  SUBDIR                     FILENAME           VERSION               LAST_UPDATE_DATE

--519754    PA    patch/115/import/US   PAPROJWF.wft   120.4.12020000.4  19-SEP-17

--519754    PA    patch/115/import/US   PAPROJWF.wft   120.4.12020000.3  11-AUG-16

--519754    PA    patch/115/import/US   PAPROJWF.wft   120.4                      27-NOV-12

--519754    PA    patch/115/import/US   PAPROJWF.wft   120.1.12010000.2  12-APR-09



--cd TO $PA_TOP/PATCH/115/IMPORT/US

--$ adident Header PAPROJWF.wft

--PAPROJWF.wft:

--$Header PAPROJWF.wft 120.4.12020000.4 2016/11/16 10:14:09 shghonge ship $

   --OR

--$ strings -a PAPROJWF.wft | grep Header

--# $Header: PAPROJWF.wft 120.4.12020000.4 2016/11/16 10:14:09 shghonge ship $

--IN the Workflow tables definitions are stored in wf_item_types table



