/* Formatted on 10/14/2020 2:52:44 PM (QP5 v5.287) */
DECLARE
   l_rowid                  ROWID;
   l_attached_document_id   NUMBER;
   l_document_id            NUMBER;
   l_media_id               NUMBER;
   l_category_id            NUMBER;
   l_pk1_value              fnd_attached_documents.pk1_value%TYPE := 12345678; --< Primary Key information that uniquely identifies the product (such as the product_ID)>;
   l_description            fnd_documents_tl.description%TYPE
                               := 'Test Attachment';
   l_filename               VARCHAR2 (240) := '<File Name>';
   l_seq_num                NUMBER;
   l_blob_data              BLOB;
   l_blob                   BLOB;
   l_bfile                  BFILE;
   l_byte                   NUMBER;
   l_fnd_user_id            NUMBER;
   l_short_datatype_id      NUMBER;
   x_blob                   BLOB;
   fils                     BFILE;
   blob_length              INTEGER;
   l_entity_name            VARCHAR2 (100) := 'entity';      --< entity_name>;
   l_category_name          VARCHAR2 (100) := 'category';  --< category_name>;
BEGIN
   fnd_global.apps_initialize (123, 456, 789); -- (< userid>, <applid>,<appluserid>);

   SELECT fnd_documents_s.NEXTVAL INTO l_document_id FROM DUAL;

   SELECT fnd_attached_documents_s.NEXTVAL
     INTO l_attached_document_id
     FROM DUAL;

   SELECT NVL (MAX (seq_num), 0) + 10
     INTO l_seq_num
     FROM fnd_attached_documents
    WHERE pk1_value = l_pk1_value AND entity_name = l_entity_name;

   -- Select User_id
   SELECT user_id
     INTO l_fnd_user_id
     FROM apps.fnd_user
    WHERE user_name = '103908';                                 --<user_name>;

   -- Get Data type id for Short Text types of attachments
   SELECT datatype_id
     INTO l_short_datatype_id
     FROM apps.fnd_document_datatypes
    WHERE NAME = 'FILE';

   -- Select Category id for Attachments

   SELECT category_id
     INTO l_category_id
     FROM apps.fnd_document_categories_vl
    WHERE USER_NAME = l_category_name;

   -- Select nexvalues of document id, attached document id and
   -- l_media_id
   SELECT apps.fnd_documents_s.NEXTVAL, apps.fnd_attached_documents_s.NEXTVAL
     --apps.fnd_documents_long_text_s.NEXTVAL
     INTO l_document_id, l_attached_document_id
     --l_media_id
     FROM DUAL;

   SELECT MAX (file_id) + 1
     INTO l_media_id
     FROM fnd_lobs;

   fils := BFILENAME (< FLIE PATH>, l_filename);
-- Obtain the size of the blob file
DBMS_LOB.fileopen (fils, DBMS_LOB.file_readonly);
blob_length := DBMS_LOB.getlength (fils);
DBMS_LOB.fileclose (fils);
-- Insert a new record into the table containing the
-- filename you have specified and a LOB LOCATOR.
-- Return the LOB LOCATOR and assign it to x_blob.
INSERT INTO fnd_lobs
(file_id, file_name, file_content_type, upload_date,
expiration_date, program_name, program_tag, file_data,
LANGUAGE, oracle_charset, file_format
)
VALUES (l_media_id, l_filename, 'application/pdf',--'text/plain',--application/pdf
SYSDATE,
NULL, 'FNDATTCH', NULL, EMPTY_BLOB (), --l_blob_data,
'US', 'UTF8', 'binary'
)
RETURNING file_data
INTO x_blob;
-- Load the file into the database as a BLOB
DBMS_LOB.OPEN (fils, DBMS_LOB.lob_readonly);
DBMS_LOB.OPEN (x_blob, DBMS_LOB.lob_readwrite);
DBMS_LOB.loadfromfile (x_blob, fils, blob_length);
-- Close handles to blob and file
DBMS_LOB.CLOSE (x_blob);
DBMS_LOB.CLOSE (fils);
DBMS_OUTPUT.put_line ('FND_LOBS File Id Created is ' || l_media_id);
COMMIT;
-- This package allows user to share file across multiple orgs or restrict to single org
fnd_documents_pkg.insert_row
(x_rowid => l_rowid,
x_document_id => l_document_id,
x_creation_date => SYSDATE,
x_created_by => l_fnd_user_id,-- fnd_profile.value('USER_ID')
x_last_update_date => SYSDATE,
x_last_updated_by => l_fnd_user_id,-- fnd_profile.value('USER_ID')
x_last_update_login => fnd_profile.VALUE('LOGIN_ID'),
x_datatype_id => l_short_datatype_id, -- FILE
X_security_id => <security ID defined in your Attchments, Usaully SOB ID/ORG_ID..>,
x_publish_flag => 'N', --This flag allow the file to share across multiple organization
x_category_id => l_category_id,
x_security_type => 1,
x_usage_type => 'S',
x_language => 'US',
x_description => l_filename,--l_description,
x_file_name => l_filename,
x_media_id => l_media_id
);
commit;

fnd_documents_pkg.insert_tl_row
(x_document_id => l_document_id,
x_creation_date => SYSDATE,
x_created_by => l_fnd_user_id,--fnd_profile.VALUE('USER_ID'),
x_last_update_date => SYSDATE,
x_last_updated_by => l_fnd_user_id,--fnd_profile.VALUE('USER_ID'),
x_last_update_login => fnd_profile.VALUE('LOGIN_ID'),
x_language => 'US',
x_description => l_filename--l_description
);
COMMIT;
fnd_attached_documents_pkg.insert_row
(x_rowid => l_rowid,
x_attached_document_id => l_attached_document_id,
x_document_id => l_document_id,
x_creation_date => SYSDATE,
x_created_by => l_fnd_user_id,--fnd_profile.VALUE('USER_ID'),
x_last_update_date => SYSDATE,
x_last_updated_by => l_fnd_user_id,--fnd_profile.VALUE('USER_ID'),
x_last_update_login => fnd_profile.VALUE('LOGIN_ID'),
x_seq_num => l_seq_num,
x_entity_name => l_entity_name,
x_column1 => NULL,
x_pk1_value => l_pk1_value,
x_pk2_value => NULL,
x_pk3_value => NULL,
x_pk4_value => NULL,
x_pk5_value => NULL,
x_automatically_added_flag => 'N',
x_datatype_id => 6,
x_category_id => l_category_id,
x_security_type => 1,
X_security_id => <security ID defined in your Attchments, Usaully SOB ID/ORG_ID..>,
x_publish_flag => 'Y',
x_language => 'US',
x_description => l_filename,--l_description,
x_file_name => l_filename,
x_media_id => l_media_id
);
COMMIT;
DBMS_OUTPUT.put_line ('MEDIA ID CREATED IS ' || l_media_id);
END;
/