/* Formatted on 10/18/2020 1:09:01 PM (QP5 v5.287) */
DECLARE
   p_corrected_gl_code        VARCHAR2 (233)
                                 := '155.102.335.13101.512118.102.999.101.999';
   l_application_short_name   VARCHAR2 (240);
   l_key_flex_code            VARCHAR2 (240);
   l_structure_num            NUMBER;
   l_validation_date          DATE;
   n_segments                 NUMBER;
   SEGMENTS                   APPS.FND_FLEX_EXT.SEGMENTARRAY;
   l_combination_id           NUMBER;
   l_data_set                 NUMBER;
   l_return                   BOOLEAN;
   l_message                  VARCHAR2 (240);
BEGIN
   l_application_short_name := 'SQLGL';
   l_key_flex_code := 'GL#';

   SELECT id_flex_num
     INTO l_structure_num
     FROM apps.fnd_id_flex_structures
    WHERE     ID_FLEX_CODE = 'GL#'
          AND ID_FLEX_STRUCTURE_CODE = 'DBL_ACCOUNTING_FLEXFIELD';


   l_validation_date := SYSDATE;
   n_segments := 9;
   DBMS_OUTPUT.PUT_LINE (   'Company ID = '
                         || RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                                  '[^.]*.',
                                                  1,
                                                  1),
                                   '.'));
   DBMS_OUTPUT.PUT_LINE (   'Location ID = '
                         || REGEXP_SUBSTR (p_corrected_gl_code,
                                                  '[^.]*.',
                                                  1,
                                                  2));
   segments (1) :=
      REGEXP_SUBSTR (p_corrected_gl_code,
                     '[^.]*',
                     1,
                     1);
   segments (2) :=
      REGEXP_SUBSTR (p_corrected_gl_code,
                     '[^.]*',
                     1,
                     2);
   segments (3) :=
      REGEXP_SUBSTR (p_corrected_gl_code,
                     '[^.]*',
                     1,
                     3);
   segments (4) :=
      REGEXP_SUBSTR (p_corrected_gl_code,
                     '[^.]*',
                     1,
                     4);
   segments (5) :=
      REGEXP_SUBSTR (p_corrected_gl_code,
                     '[^.]*',
                     1,
                     5);
   segments (6) :=
      REGEXP_SUBSTR (p_corrected_gl_code,
                     '[^.]*',
                     1,
                     6);
   segments (7) :=
      REGEXP_SUBSTR (p_corrected_gl_code,
                     '[^.]*',
                     1,
                     7);
   segments (8) :=
      REGEXP_SUBSTR (p_corrected_gl_code,
                     '[^.]*',
                     1,
                     8);
   segments (9) :=
      REGEXP_SUBSTR (p_corrected_gl_code,
                     '[^.]*',
                     1,
                     9);
   /*
   segments (1) := l_segment1;
   segments (2) := l_segment2;
   segments (3) := l_segment3;
   segments (4) := l_segment4;
   segments (5) := l_segment5;
   segments (6) := l_segment6;
   segments (7) := l_segment7;
   segments (8) := l_segment8;
   segments (9) := l_segment9;
   */
   l_data_set := NULL;

   l_return :=
      FND_FLEX_EXT.GET_COMBINATION_ID (
         application_short_name   => l_application_short_name,
         key_flex_code            => l_key_flex_code,
         structure_number         => l_structure_num,
         validation_date          => l_validation_date,
         n_segments               => n_segments,
         segments                 => segments,
         combination_id           => l_combination_id,
         data_set                 => l_data_set);
   l_message := FND_FLEX_EXT.GET_MESSAGE;

   IF l_return
   THEN
      DBMS_OUTPUT.PUT_LINE ('l_Return = TRUE');
      DBMS_OUTPUT.PUT_LINE ('COMBINATION_ID = ' || l_combination_id);
   ELSE
      DBMS_OUTPUT.PUT_LINE ('Error: ' || l_message);
   END IF;
END;