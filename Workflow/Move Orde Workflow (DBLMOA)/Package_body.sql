/* Formatted on 8/23/2020 11:00:33 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY xxdbl_po_req_wf_pkg
AS
   PROCEDURE xxdbl_create_wf_doc (document_id     IN            VARCHAR2,
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
<th style="background-color:#CFE0F1;">Requisition Number</th>
</thead>
</tr>
<tbody>
'      ;

      FOR i
         IN (SELECT DISTINCT user_name, segment1
               FROM (SELECT prha.segment1,
                            prha.preparer_id,
                            prha.authorization_status,
                            FU.USER_NAME
                       FROM po_requisition_headers_all prha,
                            po_requisition_lines_all prla,
                            FND_USER FU
                      WHERE     prha.requisition_header_id =
                                   prla.requisition_header_id
                            AND prha.authorization_status = 'APPROVED'
                            AND FU.EMPLOYEE_ID = prla.suggested_buyer_id
                            --AND FU.USER_NAME = '103762'
                            --AND prha.segment1 = '25111002544'
                            AND FU.USER_NAME = '100151'
                            AND prha.segment1 = '15511000040' --AND prha.last_update_date >= SYSDATE - INTERVAL '10' MINUTE);
                                                             --AND prha.last_update_date >= SYSDATE
                    ))
      LOOP
         BEGIN
            l_body := l_body || '<tr>    
<td>'                   || i.user_name || '</td>     
<td>'                   || i.segment1 || '</td>     
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
   END xxdbl_create_wf_doc;
END xxdbl_po_req_wf_pkg;
/

SHOW ERRORS;
EXIT;