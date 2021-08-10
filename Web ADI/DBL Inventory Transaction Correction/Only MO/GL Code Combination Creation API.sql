/* Formatted on 10/17/2020 4:20:50 PM (QP5 v5.287) */
DECLARE
   p_corrected_gl_code        VARCHAR2 (233 BYTE)
                                 := '155.102.335.17116.512114.999.999.301.999';
   l_segment1                 GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
   l_segment2                 GL_CODE_COMBINATIONS.SEGMENT2%TYPE;
   l_segment3                 GL_CODE_COMBINATIONS.SEGMENT3%TYPE;
   l_segment4                 GL_CODE_COMBINATIONS.SEGMENT4%TYPE;
   l_segment5                 GL_CODE_COMBINATIONS.SEGMENT5%TYPE;
   l_segment6                 GL_CODE_COMBINATIONS.SEGMENT6%TYPE;
   l_segment7                 GL_CODE_COMBINATIONS.SEGMENT7%TYPE;
   l_segment8                 GL_CODE_COMBINATIONS.SEGMENT8%TYPE;
   l_segment9                 GL_CODE_COMBINATIONS.SEGMENT9%TYPE;
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
   SELECT RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*.',
                                1,
                                1),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*.',
                                1,
                                2),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*.',
                                1,
                                3),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*.',
                                1,
                                4),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*.',
                                1,
                                1),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*.',
                                1,
                                2),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*.',
                                1,
                                3),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*.',
                                1,
                                4),
                 '.'),
          RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                '[^.]*.',
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

   l_application_short_name := 'SQLGL';
   l_key_flex_code := 'GL#';

   SELECT id_flex_num
     INTO l_structure_num
     FROM apps.fnd_id_flex_structures
    WHERE     ID_FLEX_CODE = 'GL#'
          AND ID_FLEX_STRUCTURE_CODE = 'DBL_ACCOUNTING_FLEXFIELD';

   l_validation_date := SYSDATE;
   DBMS_OUTPUT.PUT_LINE (
                  'Please Create New Code Combination for : '
               || l_segment1);
   n_segments := 9;
   segments (1) := l_segment1;
   segments (2) := l_segment2;
   segments (3) := l_segment3;
   segments (4) := l_segment4;
   segments (5) := l_segment5;
   segments (6) := l_segment6;
   segments (7) := l_segment7;
   segments (8) := l_segment8;
   segments (9) := l_segment9;
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