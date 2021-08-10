SELECT apps.ap_amount_utilities_pkg.ap_convert_number(12345) AS amt_in_words    FROM dual;

Select XXDBL_NUMBER_CONVERSION(-3786.9899876) from dual;
Select XXDBL_NUMBER_CONVERSION(7685.78788) from dual;
Select XXDBL_NUMBER_CONVERSION(7678) from dual;

select to_char(to_date(:p_number,'j'),'jsp') from dual;


SELECT TO_CHAR (TO_DATE (234, 'j'), 'jsp') FROM DUAL;
--//Output: two hundred thirty-four

SELECT TO_CHAR (TO_DATE (24834, 'j'), 'jsp') FROM DUAL;
--//Output: twenty-four thousand eight hundred thirty-four

SELECT TO_CHAR (TO_DATE (2447834, 'j'), 'jsp') FROM DUAL;
--//Output: two million four hundred forty-seven thousand eight hundred thirty-four


SELECT xxdbl_spell_number (5585) FROM DUAL;