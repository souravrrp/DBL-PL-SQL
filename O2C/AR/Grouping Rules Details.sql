/* Formatted on 7/20/2020 4:14:15 PM (QP5 v5.287) */
SELECT UPPER (C.FROM_COLUMN_NAME), C.FROM_COLUMN_LENGTH
  FROM RA_GROUPING_TRX_TYPES T, RA_GROUP_BYS B, RA_GROUP_BY_COLUMNS C
 WHERE     T.GROUPING_RULE_ID = &group_rule_id
       AND T.CLASS =
              DECODE ('&trx_type',  'INV', 'I',  'CM', 'C',  'DM', 'D')
       AND T.GROUPING_TRX_TYPE_ID = B.GROUPING_TRX_TYPE_ID
       AND B.COLUMN_ID = C.COLUMN_ID;


---------------------------------------------------------------------------------
-- for MANDATORY

SELECT * FROM ra_grouping_trx_types;

SELECT * FROM ra_group_bys;

-- for OPTIONAL

SELECT column_type, from_column_name
  FROM ra_group_by_columns
 WHERE column_type <> 'M';

SELECT GROUPING_RULE_ID
  FROM RA_GROUPING_RULES
 WHERE NAME = '&Enter_Grouping_Rule_Name';


SELECT UPPER (C.FROM_COLUMN_NAME), C.FROM_COLUMN_LENGTH
  FROM RA_GROUPING_TRX_TYPES T, RA_GROUP_BYS B, RA_GROUP_BY_COLUMNS C
 WHERE     T.GROUPING_RULE_ID = &group_rule_id
       AND T.CLASS =
              DECODE ('&trx_type',  'INV', 'I',  'CM', 'C',  'DM', 'D')
       AND T.GROUPING_TRX_TYPE_ID = B.GROUPING_TRX_TYPE_ID
       AND B.COLUMN_ID = C.COLUMN_ID
UNION
SELECT UPPER (C.FROM_COLUMN_NAME), C.FROM_COLUMN_LENGTH
  FROM RA_GROUP_BY_COLUMNS C
 WHERE C.COLUMN_TYPE = 'M'
ORDER BY 1;