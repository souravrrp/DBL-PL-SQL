/* Formatted on 9/12/2020 2:49:38 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY xxdbl_emp_wf_doc_pkg
AS
   PROCEDURE xx_create_wf_doc (document_id     IN            VARCHAR2,
                               display_type    IN            VARCHAR2,
                               document        IN OUT NOCOPY VARCHAR2,
                               document_type   IN OUT NOCOPY VARCHAR2)
   IS
      l_body   VARCHAR2 (32767);
   BEGIN
      --
      document_type := 'text/html';
      --
      l_body := ' 
<table>
<thead>
<tr>
<th style="background-color:#CFE0F1;">Employee Name</th>
<th style="background-color:#CFE0F1;">Employee Number</th>
</thead>
</tr>
<tbody>
'      ;

      FOR i IN (SELECT ename, empno
                  FROM emp)
      LOOP
         BEGIN
            l_body := l_body || '<tr>    
<td>'                   || i.ename || '</td>     
<td>'                   || i.empno || '</td>     
</tr>'       ;
         END;
      END LOOP;

      document := l_body;
      --
      --Setting document type which is nothing but MIME type
      --
      document_type := 'text/html';
   EXCEPTION
      WHEN OTHERS
      THEN
         document := '<H4>Error: ' || SQLERRM || '</H4>';
   END xx_create_wf_doc;
END xxdbl_emp_wf_doc_pkg;
/

SHOW ERRORS;
EXIT;