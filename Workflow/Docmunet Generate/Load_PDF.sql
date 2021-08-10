/* Formatted on 10/7/2020 10:44:21 AM (QP5 v5.287) */
--Procedure to load a PDF as a BFILE:

CREATE OR REPLACE PROCEDURE load_lob
AS
   id          NUMBER;
   image1      BLOB;
   locator     BFILE;
   bfile_len   NUMBER;
   bf_desc     VARCHAR2 (30);
   bf_name     VARCHAR2 (30);
   bf_dir      VARCHAR2 (30);
   bf_typ      VARCHAR2 (4);
   ctr         INTEGER;

   CURSOR get_id
   IS
      SELECT bfile_id, bfile_desc, bfile_type FROM graphics_table;
BEGIN
   OPEN get_id;

   LOOP
      FETCH get_id INTO id, bf_desc, bf_typ;

      EXIT WHEN get_id%NOTFOUND;
      DBMS_OUTPUT.put_line ('ID: ' || TO_CHAR (id));

      SELECT bfile_loc
        INTO locator
        FROM graphics_table
       WHERE bfile_id = id;

      DBMS_LOB.filegetname (locator, bf_dir, bf_name);
      DBMS_OUTPUT.put_line ('Dir: ' || bf_dir);
      DBMS_LOB.fileopen (locator, DBMS_LOB.file_readonly);
      bfile_len := DBMS_LOB.getlength (locator);
      DBMS_OUTPUT.put_line (
         'ID: ' || TO_CHAR (id) || ' length: ' || TO_CHAR (bfile_len));

      SELECT temp_blob INTO image1 FROM temp_blob;

      bfile_len := DBMS_LOB.getlength (locator);
      DBMS_LOB.loadfromfile (image1,
                             locator,
                             bfile_len,
                             1,
                             1);

      INSERT INTO internal_graphics
           VALUES (id,
                   bf_desc,
                   image1,
                   bf_typ);

      DBMS_OUTPUT.put_line (
            bf_desc
         || ' Length: '
         || TO_CHAR (bfile_len)
         || ' Name: '
         || bf_name
         || ' Dir: '
         || bf_dir
         || ' '
         || bf_typ);
      DBMS_LOB.fileclose (locator);
   END LOOP;
END;
/

--Procedure to load a PDF into a BLOB column of a table: CODE

CREATE OR REPLACE PROCEDURE load_lob
AS
   id          NUMBER;
   image1      BLOB;
   locator     BFILE;
   bfile_len   NUMBER;
   bf_desc     VARCHAR2 (30);
   bf_name     VARCHAR2 (30);
   bf_dir      VARCHAR2 (30);
   bf_typ      VARCHAR2 (4);
   ctr         INTEGER;

   CURSOR get_id
   IS
      SELECT bfile_id, bfile_desc, bfile_type FROM graphics_table;
BEGIN
   OPEN get_id;

   LOOP
      FETCH get_id INTO id, bf_desc, bf_typ;

      EXIT WHEN get_id%NOTFOUND;
      DBMS_OUTPUT.put_line ('ID: ' || TO_CHAR (id));

      SELECT bfile_loc
        INTO locator
        FROM graphics_table
       WHERE bfile_id = id;

      DBMS_LOB.filegetname (locator, bf_dir, bf_name);
      DBMS_OUTPUT.put_line ('Dir: ' || bf_dir);
      DBMS_LOB.fileopen (locator, DBMS_LOB.file_readonly);
      bfile_len := DBMS_LOB.getlength (locator);
      DBMS_OUTPUT.put_line (
         'ID: ' || TO_CHAR (id) || ' length: ' || TO_CHAR (bfile_len));

      SELECT temp_blob INTO image1 FROM temp_blob;

      bfile_len := DBMS_LOB.getlength (locator);
      DBMS_LOB.loadfromfile (image1,
                             locator,
                             bfile_len,
                             1,
                             1);

      INSERT INTO internal_graphics
           VALUES (id,
                   bf_desc,
                   image1,
                   bf_typ);

      DBMS_OUTPUT.put_line (
            bf_desc
         || ' Length: '
         || TO_CHAR (bfile_len)
         || ' Name: '
         || bf_name
         || ' Dir: '
         || bf_dir
         || ' '
         || bf_typ);
      DBMS_LOB.fileclose (locator);
   END LOOP;
END;
/