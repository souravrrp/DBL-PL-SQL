/* Formatted on 4/4/2021 11:30:38 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY apex_global
AS
   /****************************************************************
   *
   * PROGRAM NAME
   *    APEX_GLOBAL.pkb
   *
   * DESCRIPTION
   *    Routines for collaboration of APEX with EBS
   *
   * CHANGE HISTORY
   * Who          When         What
   * ---------------------------------------------------------------
   * M. Weeren    18-06-2014   Initial Version
   *****************************************************************/

   FUNCTION check_ebs_credentials
      RETURN BOOLEAN
   IS
      c_ebs            VARCHAR2 (240) := 'E-Business Suite';

      l_authorized     BOOLEAN;
      l_user_id        NUMBER;
      l_resp_id        NUMBER;
      l_resp_appl_id   NUMBER;
      l_sec_group_id   NUMBER;
      l_org_id         NUMBER;
      l_time_out       NUMBER;
      l_ebs_url        VARCHAR2 (100);
      l_appl_name      VARCHAR2 (240);

      CURSOR get_apps_credentials
      IS
         SELECT iss.user_id,
                iss.responsibility_id,
                iss.responsibility_application_id,
                iss.security_group_id,
                iss.org_id,
                iss.time_out,
                isa.VALUE
           FROM apps.icx_sessions iss, apps.icx_session_attributes isa
          WHERE     iss.session_id = apps.icx_sec.getsessioncookie
                AND isa.session_id = iss.session_id
                AND isa.name = '_USERORSSWAPORTALURL';

      CURSOR get_appl_name (b_appl_id NUMBER)
      IS
         SELECT application_name
           FROM apps.fnd_application_tl
          WHERE application_id = b_appl_id AND language = USERENV ('LANG');
   BEGIN
      OPEN get_apps_credentials;

      FETCH get_apps_credentials
         INTO l_user_id,
              l_resp_id,
              l_resp_appl_id,
              l_sec_group_id,
              l_org_id,
              l_time_out,
              l_ebs_url;

      IF get_apps_credentials%NOTFOUND
      THEN
         l_authorized := FALSE;
      ELSE
         l_authorized := TRUE;

         OPEN get_appl_name (l_resp_appl_id);

         FETCH get_appl_name INTO l_appl_name;

         IF get_appl_name%NOTFOUND
         THEN
            l_appl_name := c_ebs;
         END IF;

         CLOSE get_appl_name;

         APEX_UTIL.set_session_state ('EBS_USER_ID', TO_CHAR (l_user_id));
         APEX_UTIL.set_session_state ('EBS_RESP_ID', TO_CHAR (l_resp_id));
         APEX_UTIL.set_session_state ('EBS_RESP_APPL_ID',
                                      TO_CHAR (l_resp_appl_id));
         APEX_UTIL.set_session_state ('EBS_SEC_GROUP_ID',
                                      TO_CHAR (l_sec_group_id));
         APEX_UTIL.set_session_state ('EBS_ORG_ID', TO_CHAR (l_org_id));
         --       apex_util.set_session_state('EBS_TIME_OUT',TO_CHAR(l_time_out));
         APEX_UTIL.set_session_state ('EBS_URL', l_ebs_url);
         APEX_UTIL.set_session_state ('EBS_APPLICATION_NAME', l_appl_name);

         APEX_UTIL.set_session_max_idle_seconds (l_time_out * 60,
                                                 'APPLICATION');
      END IF;

      CLOSE get_apps_credentials;

      RETURN l_authorized;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF get_apps_credentials%ISOPEN
         THEN
            CLOSE get_apps_credentials;
         END IF;

         RETURN FALSE;
   END;

   PROCEDURE apps_initialize (user_id             IN NUMBER,
                              resp_id             IN NUMBER,
                              resp_appl_id        IN NUMBER,
                              security_group_id   IN NUMBER DEFAULT 0,
                              server_id           IN NUMBER DEFAULT -1)
   IS
   BEGIN
      fnd_global.apps_initialize (user_id,
                                  resp_id,
                                  resp_appl_id,
                                  security_group_id,
                                  server_id);
   END;

   FUNCTION get_profile_value (name IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN fnd_profile.VALUE (name);
   END;

   FUNCTION submit_request (application   IN VARCHAR2 DEFAULT NULL,
                            program       IN VARCHAR2 DEFAULT NULL,
                            description   IN VARCHAR2 DEFAULT NULL,
                            start_time    IN VARCHAR2 DEFAULT NULL,
                            sub_request   IN BOOLEAN DEFAULT FALSE,
                            argument1     IN VARCHAR2 DEFAULT CHR (0),
                            argument2     IN VARCHAR2 DEFAULT CHR (0),
                            argument3     IN VARCHAR2 DEFAULT CHR (0),
                            argument4     IN VARCHAR2 DEFAULT CHR (0),
                            argument5     IN VARCHAR2 DEFAULT CHR (0),
                            argument6     IN VARCHAR2 DEFAULT CHR (0),
                            argument7     IN VARCHAR2 DEFAULT CHR (0),
                            argument8     IN VARCHAR2 DEFAULT CHR (0),
                            argument9     IN VARCHAR2 DEFAULT CHR (0),
                            argument10    IN VARCHAR2 DEFAULT CHR (0),
                            argument11    IN VARCHAR2 DEFAULT CHR (0),
                            argument12    IN VARCHAR2 DEFAULT CHR (0),
                            argument13    IN VARCHAR2 DEFAULT CHR (0),
                            argument14    IN VARCHAR2 DEFAULT CHR (0),
                            argument15    IN VARCHAR2 DEFAULT CHR (0),
                            argument16    IN VARCHAR2 DEFAULT CHR (0),
                            argument17    IN VARCHAR2 DEFAULT CHR (0),
                            argument18    IN VARCHAR2 DEFAULT CHR (0),
                            argument19    IN VARCHAR2 DEFAULT CHR (0),
                            argument20    IN VARCHAR2 DEFAULT CHR (0),
                            argument21    IN VARCHAR2 DEFAULT CHR (0),
                            argument22    IN VARCHAR2 DEFAULT CHR (0),
                            argument23    IN VARCHAR2 DEFAULT CHR (0),
                            argument24    IN VARCHAR2 DEFAULT CHR (0),
                            argument25    IN VARCHAR2 DEFAULT CHR (0),
                            argument26    IN VARCHAR2 DEFAULT CHR (0),
                            argument27    IN VARCHAR2 DEFAULT CHR (0),
                            argument28    IN VARCHAR2 DEFAULT CHR (0),
                            argument29    IN VARCHAR2 DEFAULT CHR (0),
                            argument30    IN VARCHAR2 DEFAULT CHR (0),
                            argument31    IN VARCHAR2 DEFAULT CHR (0),
                            argument32    IN VARCHAR2 DEFAULT CHR (0),
                            argument33    IN VARCHAR2 DEFAULT CHR (0),
                            argument34    IN VARCHAR2 DEFAULT CHR (0),
                            argument35    IN VARCHAR2 DEFAULT CHR (0),
                            argument36    IN VARCHAR2 DEFAULT CHR (0),
                            argument37    IN VARCHAR2 DEFAULT CHR (0),
                            argument38    IN VARCHAR2 DEFAULT CHR (0),
                            argument39    IN VARCHAR2 DEFAULT CHR (0),
                            argument40    IN VARCHAR2 DEFAULT CHR (0),
                            argument41    IN VARCHAR2 DEFAULT CHR (0),
                            argument42    IN VARCHAR2 DEFAULT CHR (0),
                            argument43    IN VARCHAR2 DEFAULT CHR (0),
                            argument44    IN VARCHAR2 DEFAULT CHR (0),
                            argument45    IN VARCHAR2 DEFAULT CHR (0),
                            argument46    IN VARCHAR2 DEFAULT CHR (0),
                            argument47    IN VARCHAR2 DEFAULT CHR (0),
                            argument48    IN VARCHAR2 DEFAULT CHR (0),
                            argument49    IN VARCHAR2 DEFAULT CHR (0),
                            argument50    IN VARCHAR2 DEFAULT CHR (0),
                            argument51    IN VARCHAR2 DEFAULT CHR (0),
                            argument52    IN VARCHAR2 DEFAULT CHR (0),
                            argument53    IN VARCHAR2 DEFAULT CHR (0),
                            argument54    IN VARCHAR2 DEFAULT CHR (0),
                            argument55    IN VARCHAR2 DEFAULT CHR (0),
                            argument56    IN VARCHAR2 DEFAULT CHR (0),
                            argument57    IN VARCHAR2 DEFAULT CHR (0),
                            argument58    IN VARCHAR2 DEFAULT CHR (0),
                            argument59    IN VARCHAR2 DEFAULT CHR (0),
                            argument60    IN VARCHAR2 DEFAULT CHR (0),
                            argument61    IN VARCHAR2 DEFAULT CHR (0),
                            argument62    IN VARCHAR2 DEFAULT CHR (0),
                            argument63    IN VARCHAR2 DEFAULT CHR (0),
                            argument64    IN VARCHAR2 DEFAULT CHR (0),
                            argument65    IN VARCHAR2 DEFAULT CHR (0),
                            argument66    IN VARCHAR2 DEFAULT CHR (0),
                            argument67    IN VARCHAR2 DEFAULT CHR (0),
                            argument68    IN VARCHAR2 DEFAULT CHR (0),
                            argument69    IN VARCHAR2 DEFAULT CHR (0),
                            argument70    IN VARCHAR2 DEFAULT CHR (0),
                            argument71    IN VARCHAR2 DEFAULT CHR (0),
                            argument72    IN VARCHAR2 DEFAULT CHR (0),
                            argument73    IN VARCHAR2 DEFAULT CHR (0),
                            argument74    IN VARCHAR2 DEFAULT CHR (0),
                            argument75    IN VARCHAR2 DEFAULT CHR (0),
                            argument76    IN VARCHAR2 DEFAULT CHR (0),
                            argument77    IN VARCHAR2 DEFAULT CHR (0),
                            argument78    IN VARCHAR2 DEFAULT CHR (0),
                            argument79    IN VARCHAR2 DEFAULT CHR (0),
                            argument80    IN VARCHAR2 DEFAULT CHR (0),
                            argument81    IN VARCHAR2 DEFAULT CHR (0),
                            argument82    IN VARCHAR2 DEFAULT CHR (0),
                            argument83    IN VARCHAR2 DEFAULT CHR (0),
                            argument84    IN VARCHAR2 DEFAULT CHR (0),
                            argument85    IN VARCHAR2 DEFAULT CHR (0),
                            argument86    IN VARCHAR2 DEFAULT CHR (0),
                            argument87    IN VARCHAR2 DEFAULT CHR (0),
                            argument88    IN VARCHAR2 DEFAULT CHR (0),
                            argument89    IN VARCHAR2 DEFAULT CHR (0),
                            argument90    IN VARCHAR2 DEFAULT CHR (0),
                            argument91    IN VARCHAR2 DEFAULT CHR (0),
                            argument92    IN VARCHAR2 DEFAULT CHR (0),
                            argument93    IN VARCHAR2 DEFAULT CHR (0),
                            argument94    IN VARCHAR2 DEFAULT CHR (0),
                            argument95    IN VARCHAR2 DEFAULT CHR (0),
                            argument96    IN VARCHAR2 DEFAULT CHR (0),
                            argument97    IN VARCHAR2 DEFAULT CHR (0),
                            argument98    IN VARCHAR2 DEFAULT CHR (0),
                            argument99    IN VARCHAR2 DEFAULT CHR (0),
                            argument100   IN VARCHAR2 DEFAULT CHR (0))
      RETURN NUMBER
   IS
   BEGIN
      RETURN fnd_request.submit_request (application,
                                         program,
                                         description,
                                         start_time,
                                         sub_request,
                                         argument1,
                                         argument2,
                                         argument3,
                                         argument4,
                                         argument5,
                                         argument6,
                                         argument7,
                                         argument8,
                                         argument9,
                                         argument10,
                                         argument11,
                                         argument12,
                                         argument13,
                                         argument14,
                                         argument15,
                                         argument16,
                                         argument17,
                                         argument18,
                                         argument19,
                                         argument20,
                                         argument21,
                                         argument22,
                                         argument23,
                                         argument24,
                                         argument25,
                                         argument26,
                                         argument27,
                                         argument28,
                                         argument29,
                                         argument30,
                                         argument31,
                                         argument32,
                                         argument33,
                                         argument34,
                                         argument35,
                                         argument36,
                                         argument37,
                                         argument38,
                                         argument39,
                                         argument40,
                                         argument41,
                                         argument42,
                                         argument43,
                                         argument44,
                                         argument45,
                                         argument46,
                                         argument47,
                                         argument48,
                                         argument49,
                                         argument50,
                                         argument51,
                                         argument52,
                                         argument53,
                                         argument54,
                                         argument55,
                                         argument56,
                                         argument57,
                                         argument58,
                                         argument59,
                                         argument60,
                                         argument61,
                                         argument62,
                                         argument63,
                                         argument64,
                                         argument65,
                                         argument66,
                                         argument67,
                                         argument68,
                                         argument69,
                                         argument70,
                                         argument71,
                                         argument72,
                                         argument73,
                                         argument74,
                                         argument75,
                                         argument76,
                                         argument77,
                                         argument78,
                                         argument79,
                                         argument80,
                                         argument81,
                                         argument82,
                                         argument83,
                                         argument84,
                                         argument85,
                                         argument86,
                                         argument87,
                                         argument88,
                                         argument89,
                                         argument90,
                                         argument91,
                                         argument92,
                                         argument93,
                                         argument94,
                                         argument95,
                                         argument96,
                                         argument97,
                                         argument98,
                                         argument99,
                                         argument100);
   END;

   PROCEDURE write_dos_blob_to_unix_file (p_location   IN VARCHAR2,
                                          p_file_id    IN NUMBER)
   IS
      c_chunck_size   CONSTANT NUMBER := 32760;

      l_file_id                NUMBER;
      l_filename               VARCHAR2 (100);

      l_blob                   BLOB;
      l_blob_length            NUMBER;
      l_bytes_written          NUMBER := 0;
      l_chunck                 RAW (32760);
      l_chunck_size            NUMBER;

      l_output                 UTL_FILE.file_type;
   BEGIN
      -- select filename, blob incl length into variables
      SELECT file_name, DBMS_LOB.getlength (file_data), file_data
        INTO l_filename, l_blob_length, l_blob
        FROM fnd_lobs                                       --xxoic_files_pons
       WHERE file_id = p_file_id;

      -- define output directory
      l_output :=
         UTL_FILE.fopen (p_location,
                         l_filename,
                         'W',
                         c_chunck_size);

      -- if small enough for a single write
      IF l_blob_length <= c_chunck_size
      THEN
         UTL_FILE.put (l_output,
                       REPLACE (UTL_RAW.cast_to_varchar2 (l_blob), CHR (13)));
         UTL_FILE.fflush (l_output);
      ELSE                                                  -- write in pieces
         l_chunck_size := c_chunck_size;

         WHILE l_bytes_written < l_blob_length
         LOOP
            l_chunck_size :=
               LEAST (c_chunck_size, l_blob_length - l_bytes_written);
            DBMS_LOB.read (l_blob,
                           l_chunck_size,
                           l_bytes_written + 1,
                           l_chunck);

            UTL_FILE.put (
               l_output,
               REPLACE (UTL_RAW.cast_to_varchar2 (l_chunck), CHR (13)));
            UTL_FILE.fflush (l_output);

            l_bytes_written := l_bytes_written + l_chunck_size;
         END LOOP;
      END IF;

      UTL_FILE.fclose (l_output);
   END;
END;
/

SHOW ERROR;
EXIT;