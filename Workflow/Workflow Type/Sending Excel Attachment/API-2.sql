/* Formatted on 7/18/2020 10:36:22 AM (QP5 v5.287) */
PROCEDURE xx_notif_attach_procedure (document_id     IN     VARCHAR2,
                                     display_type    IN     VARCHAR2,
                                     document        IN OUT BLOB,
                                     document_type   IN OUT VARCHAR2)
IS
   lob_id         NUMBER;
   bdoc           BLOB;
   content_type   VARCHAR2 (100);
   filename       VARCHAR2 (300);
BEGIN
   set_debug_context ('xx_notif_attach_procedure');
   lob_id := TO_NUMBER (document_id);

   -- Obtain the BLOB version of the document
   SELECT file_name, file_content_type, file_data
     INTO filename, content_type, bdoc
     FROM fnd_lobs
    WHERE file_id = lob_id;

   document_type := content_type || ';name=' || filename;
   DBMS_LOB.COPY (document, bdoc, DBMS_LOB.getlength (bdoc));
EXCEPTION
   WHEN OTHERS
   THEN
      debug ('ERROR ^^^^0018 ' || SQLERRM);
      wf_core.CONTEXT ('xx_g4g_package',
                       'xx_notif_attach_procedure',
                       document_id,
                       display_type);
      RAISE;
END xx_notif_attach_procedure;