/* Formatted on 10/17/2020 3:34:13 PM (QP5 v5.287) */
DECLARE
   --p_corrected_gl_code        VARCHAR2 (233 BYTE) := '155.102.335.13101.512118.102.999.101.999';
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
   segments (1) := '155';
   segments (2) := '102';
   segments (3) := '335';
   segments (4) := '13101';
   segments (5) := '512118';
   segments (6) := '102';
   segments (7) := '999';
   segments (8) := '101';
   segments (9) := '999';
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