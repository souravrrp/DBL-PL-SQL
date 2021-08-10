<?php session_start();
ob_start(); ?>
<html>
<head>
<title>ER Diagram</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>ER Diagram for <?=$_GET['own']?></h2>
<hr>
<?php
require_once ('config.php');
$own=$_REQUEST['own'];
$pattern=trim(@$_POST['pattern']);
if (empty($pattern)) $pattern='%';

$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addHidden('own',$own);
$form->addText("pattern", 'Table Pattern:', $pattern);
$form->addSubmit("submit", "Display");
$form->display();
if (isset($_POST['submit'])) {
   header("location: er_draw.php?own=$own&patt=$pattern");
}
?>
</center>
</body>
</html>
