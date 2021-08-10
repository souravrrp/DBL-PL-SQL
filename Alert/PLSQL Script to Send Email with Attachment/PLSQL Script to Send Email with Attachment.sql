/* Formatted on 6/30/2020 11:03:41 AM (QP5 v5.287) */
DECLARE
   lv_mail_sts   VARCHAR2 (20);
   lv_err_msg    VARCHAR2 (2000);
   position_     NUMBER;

   PROCEDURE handle_recipients (
      pismtp_mail_conn   IN OUT UTL_SMTP.connection,
      piv_list           IN     VARCHAR2)
   AS
   BEGIN
      FOR rec IN (    SELECT TRIM (REGEXP_SUBSTR (piv_list,
                                                  '[^,]+',
                                                  1,
                                                  LEVEL))
                                email_id
                        FROM DUAL
                  CONNECT BY INSTR (piv_list,
                                    ',',
                                    1,
                                    LEVEL - 1) > 0)
      LOOP
         UTL_SMTP.rcpt (pismtp_mail_conn, TRIM (rec.email_id));
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Unhandled Exception. Error:' || SQLERRM);
         RAISE;
   END handle_recipients;

   PROCEDURE send_mail_with_attachments (
      piv_from          IN     VARCHAR2,
      piv_to            IN     VARCHAR2,
      piv_cc            IN     VARCHAR2 DEFAULT NULL,
      piv_bcc           IN     VARCHAR2,
      piv_subject       IN     VARCHAR2,
      pic_message       IN     CLOB,
      piv_mail_format   IN     VARCHAR2 DEFAULT 'TEXT',
      piv_file_dir0     IN     VARCHAR2,
      piv_filename0     IN     VARCHAR2,
      piv_file_mime0    IN     VARCHAR2,
      piv_filename1     IN     VARCHAR2 DEFAULT NULL,
      piv_file_dir1     IN     VARCHAR2 DEFAULT NULL,
      piv_file_mime1    IN     VARCHAR2 DEFAULT NULL,
      piv_filename2     IN     VARCHAR2 DEFAULT NULL,
      piv_file_dir2     IN     VARCHAR2 DEFAULT NULL,
      piv_file_mime2    IN     VARCHAR2 DEFAULT NULL,
      pov_mailed_sts       OUT VARCHAR2,
      pov_error_msg        OUT VARCHAR2)
   IS
      lsmtp_mail_conn              UTL_SMTP.connection;
      ln_step                      PLS_INTEGER := 12000;
      lv_mail_subject              VARCHAR2 (4000);

      lc_max_line_width   CONSTANT PLS_INTEGER DEFAULT 54;
      ln_amt                       BINARY_INTEGER := 672 * 3; /* ensures proper format; 2016 */
      lbf_bfile                    BFILE;
      ln_file_length               PLS_INTEGER;
      lrv_buf                      RAW (2100);
      ln_modulo                    PLS_INTEGER;
      ln_pieces                    PLS_INTEGER;
      ln_file_pos                  PLS_INTEGER := 1;
      lv_boundary                  VARCHAR2 (50) := '----=*#abc1234321cba#*=';

      gv_smtp_host                 VARCHAR2 (100) DEFAULT '10.12.12.129';
      gv_smtp_port                 VARCHAR2 (20) DEFAULT '25';
      routine_                     VARCHAR2 (100);

      PROCEDURE add_attachment (piv_file_dir    IN VARCHAR2,
                                piv_filename    IN VARCHAR2,
                                piv_file_mime   IN VARCHAR2)
      IS
      BEGIN
         position_ := 170;

         -- Start of attachment handling
         BEGIN
            UTL_SMTP.write_data (
               lsmtp_mail_conn,
                  'Content-Type: '
               || piv_file_mime
               || '; name="'
               || piv_filename
               || '"'
               || UTL_TCP.crlf);
            UTL_SMTP.write_data (
               lsmtp_mail_conn,
               'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
            UTL_SMTP.write_data (
               lsmtp_mail_conn,
                  'Content-Disposition: attachment; filename="'
               || piv_filename
               || '"'
               || UTL_TCP.crlf
               || UTL_TCP.crlf);

            position_ := 180;
            -- prepare file contents
            lbf_bfile := BFILENAME (piv_file_dir, piv_filename);
            -- Get the size of the file to be attached
            ln_file_length := DBMS_LOB.GETLENGTH (lbf_bfile);
            -- Calculate the number of pieces the file will be split up into
            ln_pieces := TRUNC (ln_file_length / ln_amt);
            -- Calculate the remainder after dividing the file into ln_amt chunks
            ln_modulo := MOD (ln_file_length, ln_amt);

            IF (ln_modulo <> 0)
            THEN
               -- Since the file does not devide equally
               -- we need to go round the loop an extra time to write the last
               -- few bytes - so add one to the loop counter.
               ln_pieces := ln_pieces + 1;
            END IF;

            DBMS_LOB.FILEOPEN (lbf_bfile, DBMS_LOB.FILE_READONLY);
            position_ := 190;

            FOR i IN 1 .. ln_pieces
            LOOP
               -- we can read at the beginning of the loop as we have already calculated
               -- how many iterations we will take and so do not need to check
               -- end of file inside the loop.
               lrv_buf := NULL;
               DBMS_LOB.READ (lbf_bfile,
                              ln_amt,
                              ln_file_pos,
                              lrv_buf);
               ln_file_pos := i * ln_amt + 1;
               UTL_SMTP.write_raw_data (lsmtp_mail_conn,
                                        UTL_ENCODE.BASE64_ENCODE (lrv_buf));
            END LOOP;

            DBMS_LOB.FILECLOSE (lbf_bfile);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line ('Error:' || SQLERRM);
               DBMS_LOB.FILECLOSE (lbf_bfile);
         END;

         -- End of attachment handling

         UTL_SMTP.write_data (lsmtp_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
         UTL_SMTP.write_data (lsmtp_mail_conn,
                              '--' || lv_boundary || '--' || UTL_TCP.crlf);
      END;
   BEGIN
      routine_ := 'TRIGGER_MAIL';

      position_ := 10;
      lsmtp_mail_conn := UTL_SMTP.open_connection (gv_smtp_host, gv_smtp_port);

      position_ := 20;
      UTL_SMTP.helo (lsmtp_mail_conn, gv_smtp_host);

      position_ := 30;
      UTL_SMTP.mail (lsmtp_mail_conn, piv_from);

      position_ := 40;
      handle_recipients (lsmtp_mail_conn, piv_to);

      position_ := 50;

      IF TRIM (piv_cc) IS NOT NULL
      THEN
         handle_recipients (lsmtp_mail_conn, piv_cc);
      END IF;

      position_ := 60;

      IF TRIM (piv_bcc) IS NOT NULL
      THEN
         handle_recipients (lsmtp_mail_conn, piv_bcc);
      END IF;

      position_ := 70;
      UTL_SMTP.open_data (lsmtp_mail_conn);

      position_ := 80;
      UTL_SMTP.write_data (
         lsmtp_mail_conn,
            'Date: '
         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
         || UTL_TCP.crlf);

      position_ := 90;
      UTL_SMTP.write_data (lsmtp_mail_conn, 'To: ' || piv_to || UTL_TCP.crlf);

      position_ := 100;

      IF TRIM (piv_cc) IS NOT NULL
      THEN
         UTL_SMTP.write_data (
            lsmtp_mail_conn,
            'CC: ' || REPLACE (piv_cc, ',', ';') || UTL_TCP.crlf);
      END IF;

      position_ := 110;

      IF TRIM (piv_bcc) IS NOT NULL
      THEN
         UTL_SMTP.write_data (
            lsmtp_mail_conn,
            'BCC: ' || REPLACE (piv_bcc, ',', ';') || UTL_TCP.crlf);
      END IF;

      position_ := 120;
      UTL_SMTP.write_data (lsmtp_mail_conn,
                           'From: ' || piv_from || UTL_TCP.crlf);

      position_ := 125;
      -- format the header for unicode subject
      lv_mail_subject :=
            '=?utf-8?B?'
         || UTL_RAW.CAST_TO_VARCHAR2 (
               UTL_ENCODE.BASE64_ENCODE (
                  UTL_RAW.CAST_TO_RAW (CONVERT (piv_subject, 'UTF8'))))
         || '?=';
      -- UTL_ENCODE inserts hex DA every 64 bytes, so we need to remove those
      -- or it will cause issues with longer email subjects
      lv_mail_subject := REPLACE (lv_mail_subject, CHR (13) || CHR (10), NULL);
      UTL_SMTP.write_data (lsmtp_mail_conn,
                           'Subject: ' || lv_mail_subject || UTL_TCP.CRLF);
      position_ := 130;
      UTL_SMTP.write_data (lsmtp_mail_conn,
                           'MIME-Version: 1.0' || UTL_TCP.crlf);
      UTL_SMTP.write_data (
         lsmtp_mail_conn,
            'Content-Type: multipart/mixed; boundary="'
         || lv_boundary
         || '"'
         || UTL_TCP.crlf
         || UTL_TCP.crlf);

      position_ := 140;

      IF piv_mail_format = 'TEXT'
      THEN
         UTL_SMTP.write_data (lsmtp_mail_conn,
                              '--' || lv_boundary || UTL_TCP.crlf);
         UTL_SMTP.write_data (
            lsmtp_mail_conn,
               'Content-Type: text/plain; charset="UTF-8"'
            || UTL_TCP.crlf
            || UTL_TCP.crlf);
         position_ := 150;

         FOR i IN 0 ..
                  TRUNC ( (DBMS_LOB.getlength (pic_message) - 1) / ln_step)
         LOOP
            UTL_SMTP.write_raw_data (
               lsmtp_mail_conn,
               UTL_RAW.cast_to_raw (
                     DBMS_LOB.SUBSTR (pic_message, ln_step, i * ln_step + 1)
                  || UTL_TCP.CRLF));
         END LOOP;

         position_ := 160;
         UTL_SMTP.write_data (lsmtp_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
         UTL_SMTP.write_data (lsmtp_mail_conn,
                              '--' || lv_boundary || UTL_TCP.crlf);
      ELSIF piv_mail_format = 'HTML'
      THEN
         UTL_SMTP.write_data (lsmtp_mail_conn,
                              '--' || lv_boundary || UTL_TCP.crlf);
         UTL_SMTP.write_data (lsmtp_mail_conn,
                              'MIME-Version: ' || '1.0' || UTL_TCP.crlf);
         UTL_SMTP.write_data (
            lsmtp_mail_conn,
            'Content-Type: ' || 'text/html; charset=UTF-8' || UTL_TCP.crlf);
         UTL_SMTP.write_data (
            lsmtp_mail_conn,
            'Content-Transfer-Encoding: ' || '8bit' || UTL_TCP.crlf);
         UTL_SMTP.write_data (lsmtp_mail_conn, UTL_TCP.crlf);
         position_ := 150;

         FOR i IN 0 ..
                  TRUNC ( (DBMS_LOB.getlength (pic_message) - 1) / ln_step)
         LOOP
            UTL_SMTP.write_raw_data (
               lsmtp_mail_conn,
               UTL_RAW.cast_to_raw (
                     DBMS_LOB.SUBSTR (pic_message, ln_step, i * ln_step + 1)
                  || UTL_TCP.CRLF));
         END LOOP;

         position_ := 160;
         UTL_SMTP.write_data (lsmtp_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
         UTL_SMTP.write_data (lsmtp_mail_conn,
                              '--' || lv_boundary || UTL_TCP.crlf);
      END IF;

      position_ := 170;

      -- Start of attachment handling
      IF     piv_file_dir0 IS NOT NULL
         AND piv_filename0 IS NOT NULL
         AND piv_file_mime0 IS NOT NULL
      THEN
         add_attachment (piv_file_dir0, piv_filename0, piv_file_mime0);
      END IF;

      IF     piv_file_dir1 IS NOT NULL
         AND piv_filename1 IS NOT NULL
         AND piv_file_mime1 IS NOT NULL
      THEN
         add_attachment (piv_file_dir1, piv_filename1, piv_file_mime1);
      END IF;

      IF     piv_file_dir2 IS NOT NULL
         AND piv_filename2 IS NOT NULL
         AND piv_file_mime2 IS NOT NULL
      THEN
         add_attachment (piv_file_dir2, piv_filename2, piv_file_mime2);
      END IF;

      position_ := 200;
      UTL_SMTP.close_data (lsmtp_mail_conn);

      position_ := 210;
      UTL_SMTP.quit (lsmtp_mail_conn);

      pov_error_msg := NULL;
      pov_mailed_sts := 'Y';
      DBMS_OUTPUT.put_line ('Email Sucessfully sent');
   EXCEPTION
      WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR
      THEN
         BEGIN
            DBMS_OUTPUT.put_line (
               'Exeption while sending the email message. Error:' || SQLERRM);
            UTL_SMTP.QUIT (lsmtp_mail_conn);
         EXCEPTION
            WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR
            THEN
               NULL; -- When the SMTP server is down or unavailable, we don't have
                    -- a connection to the server. The QUIT call will raise an
                                              -- exception that we can ignore.
         END;

         pov_error_msg :=
            'Failed to send mail due to the following error:' || SQLERRM;
         pov_mailed_sts := 'N';
         DBMS_OUTPUT.put_line (pov_error_msg);
   END send_mail_with_attachments;
BEGIN
   send_mail_with_attachments (
      piv_from          => 'smtpfrom@shareoracleapps.com',
      piv_to            => 'teamsearch@shareoracleapps.com',
      piv_cc            => NULL,
      piv_bcc           => NULL,
      piv_subject       => 'Test Email with Attachment',
      pic_message       => 'Hi This is a test message body',
      piv_mail_format   => 'TEXT',
      piv_file_dir0     => 'XXSH_EMAIL_FILES_TEMP_DB_DIR',
      piv_filename0     => 'test.csv',
      piv_file_mime0    => 'text/csv',
      piv_file_dir1     => NULL,
      piv_filename1     => NULL,
      piv_file_mime1    => NULL,
      piv_file_dir2     => NULL,
      piv_filename2     => NULL,
      piv_file_mime2    => NULL,
      pov_mailed_sts    => lv_mail_sts,
      pov_error_msg     => lv_err_msg);

   DBMS_OUTPUT.put_line (lv_err_msg);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (
         'Error: ' || SQLERRM || ' Position: ' || position_);
END;