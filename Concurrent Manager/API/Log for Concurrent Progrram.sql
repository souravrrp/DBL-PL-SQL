fnd_file.put_line(fnd_file.OUTPUT,'<html><body><table border="2">');

fnd_file.put_line(fnd_file.OUTPUT, '<tr>');

fnd_file.put_line(fnd_file.OUTPUT, '<td>"Employee No"</td> <td> "Employee Name" </td><td> "Current Salary"</td>');

fnd_file.put_line(fnd_file.OUTPUT,'</tr>');

fnd_file.put_line(fnd_file.OUTPUT,'</table></html></body>');

FND_FILE.put_line (
               FND_FILE.LOG,
                  '--------------Error while inserting records into stagein table !!!  --------------'||chr(10)|| SQLERRM);


Tried following also:

 

htp.print('<html>');

htp.print('<head>');

htp.print('<meta http-equiv="Content-Type" content="text/html">');

htp.print('<title>Title of the HTML File</title>');

htp.print('</head>');


htp.print('<body TEXT="#000000" BGCOLOR="#FFFFFF">');

htp.print('<h1>Heading in the HTML File</h1>');

htp.print('<p>Some text in the HTML file.');

htp.print('</body>');


htp.print('</html>');

 