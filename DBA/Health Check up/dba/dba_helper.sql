SET define OFF
CREATE OR REPLACE
PACKAGE dba_helper
AS
FUNCTION change_param(
    par IN VARCHAR2,
    chg IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION kill_session(
    usr     IN VARCHAR2,
    sid     IN NUMBER,
    serial  IN NUMBER,
    inst_id IN NUMBER := NULL)
  RETURN VARCHAR2 deterministic;
FUNCTION drop_user(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION cr_user(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION session_info(
    sid     IN NUMBER,
    serial  IN NUMBER,
    inst_id IN NUMBER)
  RETURN VARCHAR2 deterministic;
FUNCTION session_info(
    sid    IN NUMBER,
    serial IN NUMBER)
  RETURN VARCHAR2 deterministic;
FUNCTION sql_info(
    addr IN raw,
    hsh  IN NUMBER,
    id   IN VARCHAR2 := '')
  RETURN VARCHAR2 deterministic;
FUNCTION user_info(
    u IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION filter_schema(
    a IN VARCHAR2,
    b IN VARCHAR2)
  RETURN NUMBER deterministic;
FUNCTION get_obj(
    id1 IN NUMBER,
    id2 IN NUMBER)
  RETURN VARCHAR2 deterministic;
FUNCTION rsize(
    typ IN VARCHAR2,
    fno IN NUMBER)
  RETURN VARCHAR2 deterministic;
FUNCTION extnd(
    typ IN VARCHAR2,
    fno IN NUMBER)
  RETURN VARCHAR2 deterministic;
FUNCTION role_member(
    role IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION grnt_role(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION grnt_priv(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION chg_passw(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION ts_info(
    ts IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION seg_info(
    seg IN VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION obj_list(
    own VARCHAR2,
    typ VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION tab_list(
    own VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION obj_info(
    own VARCHAR2,
    typ VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION obj_desc(
    own VARCHAR2,
    typ VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION compile(
    own VARCHAR2,
    typ VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION errors(
    own VARCHAR2,
    typ VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION tab_info(
    own VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION move_obj(
    own VARCHAR2,
    nm  VARCHAR2,
  type  VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION const_info(
    own VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION const_list(
    own VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION job_output(
    rec   VARCHAR2,
    stamp VARCHAR2 )
  RETURN VARCHAR2 deterministic;
FUNCTION er_diag(
    own VARCHAR2 )
  RETURN VARCHAR2 deterministic;
FUNCTION get_lob(
    own VARCHAR2,
    seg VARCHAR2,
  type  VARCHAR2,
  pname VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION enable_job(
    own VARCHAR2,
    job VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION ctl_pump(
    own VARCHAR2,
    job VARCHAR2)
  RETURN VARCHAR2 deterministic;
FUNCTION get_trace_file(
    p_sid    NUMBER,
    p_serial NUMBER)
  RETURN VARCHAR2 deterministic;
END;
/
CREATE OR REPLACE
PACKAGE BODY dba_helper
AS
  inst  NUMBER;
  iname VARCHAR2(16);
  vers  VARCHAR2(20);
  comp  VARCHAR2(20);
FUNCTION change_param(
    par IN VARCHAR2,
    chg IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="alter_parameter.php?parameter=';
BEGIN
  IF(chg  = 'IMMEDIATE') THEN
    anch := anch || par || '">' || par || '</A>';
  ELSE
    anch := par;
  END IF;
  RETURN(anch);
END;
FUNCTION kill_session(
    usr     IN VARCHAR2,
    sid     IN NUMBER,
    serial  IN NUMBER,
    inst_id IN NUMBER := NULL)
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="kill_session.php?sid=';
BEGIN
  IF (inst_id                   != inst AND inst_id IS NOT NULL) THEN
    IF (vers LIKE '11%' AND usr IS NOT NULL) THEN
      anch                      := anch||sid ||'&serial='||serial||'&inst='||inst_id;
      anch                      := anch||'">Kill</A>';
      RETURN(anch);
    ELSE
      RETURN('GLOBAL');
    END IF;
  END IF;
  IF(usr IS NOT NULL) THEN
    anch := anch || sid || '&serial=' || serial || '">Kill</A>';
    RETURN(anch);
  ELSE
    RETURN('   ');
  END IF;
END;
FUNCTION drop_user(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="drop_user.php?usr=';
BEGIN
  IF(usr IS NOT NULL) THEN
    anch := anch || usr || '">Drop User</A>';
    RETURN(anch);
  ELSE
    RETURN('   ');
  END IF;
END;
FUNCTION cr_user(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="recreate_user.php?usr=';
BEGIN
  IF(usr IS NOT NULL) THEN
    anch := anch || usr || '" target="_blank">Recreate</A>';
    RETURN(anch);
  ELSE
    RETURN('   ');
  END IF;
END;
FUNCTION sql_info(
    addr IN raw,
    hsh  IN NUMBER,
    id   IN VARCHAR2 := '')
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="sql_info.php?addr=';
BEGIN
  anch := anch || addr || '&hash=' || hsh || '&id=' || id || ' " target="_blank">SQL</A>';
  RETURN(anch);
END;
FUNCTION session_info(
    sid     IN NUMBER,
    serial  IN NUMBER,
    inst_id IN NUMBER)
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="session_info.php?sid=';
BEGIN
  IF(inst_id != inst) THEN
    RETURN('GLOBAL');
  END IF;
  anch := anch || sid || '&serial=' || serial || '" target="_blank">Info</A>';
  RETURN(anch);
END;
FUNCTION session_info(
    sid    IN NUMBER,
    serial IN NUMBER)
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="session_info.php?sid=';
BEGIN
  anch := anch || sid || '&serial=' || serial || '" target="_blank">Info</A>';
  RETURN(anch);
END;
FUNCTION user_info(
    u IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="user_info.php?user=';
BEGIN
  anch := anch || u || '" target="_blank">' || u || '</A>';
  RETURN(anch);
END;
FUNCTION filter_schema(
    a IN VARCHAR2,
    b IN VARCHAR2)
  RETURN NUMBER deterministic
IS
BEGIN
  IF((b = 'ALL') OR(b IS NULL)) THEN
    RETURN(1);
  ELSIF(a = b) THEN
    RETURN(1);
  ELSE
    RETURN(0);
  END IF;
END;
FUNCTION get_obj(
    id1 IN NUMBER,
    id2 IN NUMBER)
  RETURN VARCHAR2 deterministic
IS
  obj VARCHAR2(256);
BEGIN
  IF (id2 = 0) THEN
    SELECT owner
      || '.'
      || object_name
    INTO obj
    FROM dba_objects
    WHERE object_id = id1;
    RETURN(obj);
  ELSE
    RETURN('None');
  END IF;
EXCEPTION
WHEN no_data_found THEN
  RETURN('None');
END;
FUNCTION rsize(
    typ IN VARCHAR2,
    fno IN NUMBER)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(128) := '<A href="resize_file.php?type=';
  anch2 VARCHAR2(80)  := '">Resize</A>';
BEGIN
  anch := anch || LOWER(typ) || '&file=' || fno || anch2;
  RETURN(anch);
END;
FUNCTION extnd(
    typ IN VARCHAR2,
    fno IN NUMBER)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(128) := '<A href="autoextend_file.php?type=';
  anch2 VARCHAR2(80)  := '">Autoextend</A>';
BEGIN
  anch := anch || LOWER(typ) || '&file=' || fno || anch2;
  RETURN(anch);
END;
FUNCTION role_member(
    role IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(128) := '<A href="role_members.php?role=';
  anch2 VARCHAR2(80)  := '" target="_blank">Role Members</A>';
BEGIN
  anch := anch || UPPER(role) || anch2;
  RETURN(anch);
END;
FUNCTION grnt_role(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(128) := '<A href="grant_role.php?usr=';
  anch2 VARCHAR2(80)  := '" target="_blank">'||usr||'</A>';
BEGIN
  anch := anch || UPPER(usr) || anch2;
  RETURN(anch);
END;
FUNCTION grnt_priv(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(128) := '<A href="grant_priv.php?usr=';
  anch2 VARCHAR2(80)  := '" target="output">Handle Privs</A>';
BEGIN
  anch := anch || UPPER(usr) || anch2;
  RETURN(anch);
END;
FUNCTION chg_passw(
    usr IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(128) := '<A href="chg_passw.php?usr=';
  anch2 VARCHAR2(80)  := '" target="output">Change Password</A>';
BEGIN
  anch := anch || UPPER(usr) || anch2;
  RETURN(anch);
END;
FUNCTION ts_info(
    ts IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="ts_info.php?tblspc=';
  anch2 VARCHAR2(256) := '" target="_blank">' || ts || '</A>';
BEGIN
  anch := anch || ts || anch2;
  RETURN(anch);
END;
FUNCTION seg_info(
    seg IN VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="seg_info.php?tblspc=';
  anch2 VARCHAR2(256) := '" target="_blank">Segments</A>';
BEGIN
  anch := anch || seg || anch2;
  RETURN(anch);
END;
FUNCTION obj_list(
    own VARCHAR2,
    typ VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="object_list.php?own=';
  anch2 VARCHAR2(256) := '" target="_blank">';
BEGIN
  anch := anch || own || '&type=' || typ || anch2 || own || '</A>';
  RETURN(anch);
END;
FUNCTION tab_list(
    own VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="table_list.php?own=';
  anch2 VARCHAR2(256) := '" target="_blank">';
BEGIN
  anch := anch || own || anch2 || own || '</A>';
  RETURN(anch);
END;
FUNCTION obj_info(
    own VARCHAR2,
    typ VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="object_info.php?own=';
  anch2 VARCHAR2(256) := '" target="_blank">';
BEGIN
  anch := anch || own || '&type=' || typ || '&name=' || nm || anch2 || nm || '</A>';
  RETURN(anch);
END;
FUNCTION obj_desc(
    own VARCHAR2,
    typ VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="desc_obj.php?own=';
  anch2 VARCHAR2(256) := '" target="_blank">';
BEGIN
  anch := anch || own || '&type=' || typ || '&name=' || nm || anch2 || nm || '</A>';
  RETURN(anch);
END;
FUNCTION compile(
    own VARCHAR2,
    typ VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="compile.php?own=';
  anch2 VARCHAR2(256) := '">compile</A>';
  tp    VARCHAR2(32)  := UPPER(typ);
BEGIN
  IF(tp = 'PACKAGE BODY') THEN
    tp := 'BODY';
  END IF;
  anch := anch || own || '&type=' || tp || '&obj=' || nm || anch2;
  RETURN(anch);
END;
FUNCTION errors(
    own VARCHAR2,
    typ VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="errors.php?own=';
  anch2 VARCHAR2(256) := '" target="_blank">Show Errors</A>';
  tp    VARCHAR2(32)  := UPPER(typ);
BEGIN
  IF(tp = 'PACKAGE BODY') THEN
    tp := 'BODY';
  END IF;
  anch := anch || own || '&type=' || tp || '&obj=' || nm || anch2;
  RETURN(anch);
END;
FUNCTION tab_info(
    own VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="tab_info.php?own=';
  anch2 VARCHAR2(256) := '">';
BEGIN
  anch := anch || own || '&name=' || nm || anch2 || nm || '</A>';
  RETURN(anch);
END;
FUNCTION move_obj(
    own VARCHAR2,
    nm  VARCHAR2,
  type  VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="move_obj.php?own=';
  anch2 VARCHAR2(256) := '">Relocate</A>';
BEGIN
  anch := anch || own || '&name=' || nm || '&type=' || type || anch2;
RETURN(anch);
END;
FUNCTION const_list(
    own VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="const_list.php?own=';
  anch2 VARCHAR2(256) := '" target="_blank">';
BEGIN
  anch := anch || own || anch2 || own || '</A>';
  RETURN(anch);
END;
FUNCTION const_info(
    own VARCHAR2,
    nm  VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="object_info.php?own=';
  anch2 VARCHAR2(256) := '">';
BEGIN
  anch := anch || own || '&type=REF_CONSTRAINT&name=' || nm || anch2 || nm || '</A>';
  RETURN(anch);
END;
FUNCTION job_output(
    rec   VARCHAR2,
    stamp VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="rman_output.php?recid=';
  anch2 VARCHAR2(256) := '" target="_blank">';
BEGIN
  anch := anch||rec||'&stamp=' || stamp || anch2 || 'RMAN Job Output' || '</A>';
  RETURN(anch);
END;
FUNCTION er_diag(
    own VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch  VARCHAR2(512) := '<A href="er_diagram.php?own=';
  anch2 VARCHAR2(256) := '" target="_blank">';
BEGIN
  anch := anch || own || anch2 || 'ER Diagram</A>';
  RETURN(anch);
END;
FUNCTION get_lob(
    own VARCHAR2,
    seg VARCHAR2,
  type  VARCHAR2,
  pname VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  tbl VARCHAR2(128) := NULL;
BEGIN
  IF ( type='LOBSEGMENT') THEN
    SELECT table_name INTO tbl FROM dba_lobs WHERE owner=own AND segment_name=seg;
  ELSIF (type='LOB PARTITION') THEN
    SELECT table_name
      ||'.'
      ||partition_name
    INTO tbl
    FROM dba_lob_partitions
    WHERE table_owner     =own
    AND lob_name          =seg
    AND lob_partition_name=pname;
  END IF;
  RETURN(tbl);
END;
FUNCTION enable_job(
    own VARCHAR2,
    job VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="enable_sched_job.php?own=';
BEGIN
  anch := anch|| own ||'&job=' || job || '">' || 'Job Ctl.' || '</A>';
  RETURN(anch);
END;
FUNCTION ctl_pump(
    own VARCHAR2,
    job VARCHAR2)
  RETURN VARCHAR2 deterministic
IS
  anch VARCHAR2(512) := '<A href="ctl_dpump.php?own=';
BEGIN
  anch := anch|| own ||'&job=' || job || '">' || 'Job Ctl.' || '</A>';
  RETURN(anch);
END;
FUNCTION get_trace_file(
    p_sid    NUMBER,
    p_serial NUMBER)
  RETURN VARCHAR2 deterministic
IS
  filler VARCHAR2(20):='_ora_';
  v_spid NUMBER      :=0;
BEGIN
  SELECT p.spid
  INTO v_spid
  FROM v$process p
  JOIN v$session s
  ON (p.addr   =s.paddr)
  WHERE s.sid  =p_sid
  AND s.serial#=p_serial;
  RETURN(iname||filler||v_spid||'.trc');
END;
BEGIN
  SELECT instance_number, instance_name INTO inst, iname FROM v$instance;
  dbms_utility.db_version(vers,comp);
END;
/
EXIT;
