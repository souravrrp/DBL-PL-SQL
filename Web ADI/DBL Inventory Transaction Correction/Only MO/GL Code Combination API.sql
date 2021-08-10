/* Formatted on 10/18/2020 10:39:06 AM (QP5 v5.287) */
DECLARE
   p_corrected_gl_code   VARCHAR2 (233 BYTE)
                            := '105.102.401.10205.512144.106.999.101.999';
   l_segment1            GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
   l_segment2            GL_CODE_COMBINATIONS.SEGMENT2%TYPE;
   l_segment3            GL_CODE_COMBINATIONS.SEGMENT3%TYPE;
   l_segment4            GL_CODE_COMBINATIONS.SEGMENT4%TYPE;
   l_segment5            GL_CODE_COMBINATIONS.SEGMENT5%TYPE;
   l_segment6            GL_CODE_COMBINATIONS.SEGMENT6%TYPE;
   l_segment7            GL_CODE_COMBINATIONS.SEGMENT7%TYPE;
   l_segment8            GL_CODE_COMBINATIONS.SEGMENT8%TYPE;
   l_segment9            GL_CODE_COMBINATIONS.SEGMENT9%TYPE;
   l_valid_combination   BOOLEAN;
   l_cr_combination      BOOLEAN;
   l_ccid                GL_CODE_COMBINATIONS_KFV.code_combination_id%TYPE;
   l_structure_num       FND_ID_FLEX_STRUCTURES.ID_FLEX_NUM%TYPE;
   l_conc_segs           GL_CODE_COMBINATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
   p_error_msg1          VARCHAR2 (240);
   p_error_msg2          VARCHAR2 (240);
BEGIN
   SELECT RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*',
                                1,
                                1),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*',
                                1,
                                2),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*',
                                1,
                                3),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*',
                                1,
                                4),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*',
                                1,
                                1),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*',
                                1,
                                2),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*',
                                1,
                                3),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*',
                                1,
                                4),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*',
                                1,
                                4),
                 '.')
     INTO l_segment1,
          l_segment2,
          l_segment3,
          l_segment4,
          l_segment5,
          l_segment6,
          l_segment7,
          l_segment8,
          l_segment9
     FROM DUAL;

   /*
   l_segment1 := '201';
   l_segment2 := '101';
   l_segment3 := '151';
   l_segment4 := '18809';
   l_segment5 := '511104';
   l_segment6 := '998';
   l_segment7 := '999';
   l_segment8 := '101';
   l_segment9 := '999';
   */
   l_conc_segs :=
         l_segment1
      || '.'
      || l_segment2
      || '.'
      || l_segment3
      || '.'
      || l_segment4
      || '.'
      || l_segment5
      || '.'
      || l_segment6
      || '.'
      || l_segment7
      || '.'
      || l_segment8
      || '.'
      || l_segment9;

   BEGIN
      SELECT id_flex_num
        INTO l_structure_num
        FROM apps.fnd_id_flex_structures
       WHERE     id_flex_code = 'GL#'
             AND id_flex_structure_code = 'DBL_ACCOUNTING_FLEXFIELD';
   EXCEPTION
      WHEN OTHERS
      THEN
         l_structure_num := NULL;
   END;

   ---------------Check if CCID exits with the above Concatenated Segments---------------

   BEGIN
      SELECT code_combination_id
        INTO l_ccid
        FROM apps.gl_code_combinations_kfv
       WHERE concatenated_segments = l_conc_segs;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ccid := NULL;
   END;

   IF l_ccid IS NOT NULL
   THEN
      ------------------------The CCID is Available----------------------
      DBMS_OUTPUT.PUT_LINE ('COMBINATION_ID= ' || l_ccid);
   ELSE
      DBMS_OUTPUT.PUT_LINE (
         'This is a New Combination. Validation Starts….');
      ----------------------------------------------------------------
      ------------Validate the New Combination--------------------------
      ----------------------------------------------------------------
      l_valid_combination :=
         APPS.FND_FLEX_KEYVAL.VALIDATE_SEGS (
            operation          => 'CHECK_COMBINATION',
            appl_short_name    => 'SQLGL',
            key_flex_code      => 'GL#',
            structure_number   => L_STRUCTURE_NUM,
            concat_segments    => L_CONC_SEGS);
      p_error_msg1 := FND_FLEX_KEYVAL.ERROR_MESSAGE;

      IF l_valid_combination
      THEN
         DBMS_OUTPUT.PUT_LINE (
            'Validation Successful! Creating the Combination…');
         ----------------------------------------------------------------
         -------------------Create the New CCID--------------------------
         ----------------------------------------------------------------
         L_CR_COMBINATION :=
            APPS.FND_FLEX_KEYVAL.VALIDATE_SEGS (
               operation          => 'CREATE_COMBINATION',
               appl_short_name    => 'SQLGL',
               key_flex_code      => 'GL#',
               structure_number   => L_STRUCTURE_NUM,
               concat_segments    => L_CONC_SEGS);
         p_error_msg2 := FND_FLEX_KEYVAL.ERROR_MESSAGE;

         IF l_cr_combination
         THEN
            ----------------------------------------------------------------
            -------------------Fetch the New CCID--------------------------
            ----------------------------------------------------------------
            SELECT code_combination_id
              INTO l_ccid
              FROM apps.gl_code_combinations_kfv
             WHERE concatenated_segments = l_conc_segs;

            DBMS_OUTPUT.PUT_LINE ('NEW COMBINATION_ID = ' || l_ccid);
         ELSE
            -------------Error in creating a combination-----------------
            DBMS_OUTPUT.PUT_LINE (
               'Error in creating the combination: ' || p_error_msg2);
         END IF;
      ELSE
         --------The segments in the account string are not defined in gl value set----------
         DBMS_OUTPUT.PUT_LINE (
            'Error in validating the combination: ' || p_error_msg1);
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE (SQLCODE || ' ' || SQLERRM);
END;