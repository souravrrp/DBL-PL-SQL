select regexp_substr(str, '[^,]+', 1, level) val
    from (select 'a,b,c,d' str from dual ) 
 connect by level <= length(str) - length(replace(str,','))+1
 
 
 
 TRANSACTION_TYPE_ID NOT IN (80, 98, 99, 120, 52, 26, 64)

SELECT
REGEXP_REPLACE((80, 98, 99, 120, 52, 26, 64), '(.)', '\1 ') "REGEXP_REPLACE"
FROM dual;

select regexp_substr(str, '[^,]+', 1, level) val
    from (select '80,98,99,120,52,26,64' str from dual ) 
 connect by level <= length(str) - length(replace(str,','))+1;
 
 select regexp_substr('80,98,99,120,52,26,64','[^,]+', 1, level) COLMN
  from dual
  connect BY regexp_substr('80,98,99,120,52,26,64', '[^,]+', 1, level)
  is not null
 
select * from emp where ename in (
  select regexp_substr('SMITH,ALLEN,WARD,JONES','[^,]+', 1, level) from dual
  connect by regexp_substr('SMITH,ALLEN,WARD,JONES', '[^,]+', 1, level) is not null );
  
  
 SELECT REGEXP_SUBSTR ('TechOnTheNet', 'a|e|i|o|u', 1, 3, 'i')
FROM dual;