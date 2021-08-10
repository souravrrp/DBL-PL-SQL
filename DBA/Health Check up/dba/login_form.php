<?php function login_form($init_usr) { 
global $DBA_HELPER; ?>
<p>
<center>
<h2>DBA Helper <?=$DBA_HELPER?></h2>
<h5>
You are running for the sheleter of DBA's little helper
<br>
It will help you on your way, get you through your busy day
</h5>
<hr>
<br>
</center>
</p>
<form action=<?php echo $_SERVER['PHP_SELF'] ?>  method="post" >
<table 
   cellpadding="0" 
   cellspacing="0" border="2" 
   align="center" 
   bgcolor="#10ADF4">
<th align="center">
<td colspan="2" align="center">Login:</td>
</th>
<tr>
<td>Username:</td>
 <td><input type="text" 
      name="user" 
      value= <?php
        if (!empty($_POST['user'])) echo $_POST['user'];
        else echo "$init_usr";
?>
      size="20" 
      maxlength="32">
 </td>
</tr>
<tr>
<td>Password:</td>
<td><input type="password" name="passwd" size="20"></td>
</tr>
<tr>
<td>Database:</td>
<td><input type="text" name="database"  size="20" maxsize=32></td>
</tr>
<tr>
<td><input type="submit" name="login" value="login"></td>
</tr>
</table>
</form>
<br>
<hr>
<?php
    } ?>
