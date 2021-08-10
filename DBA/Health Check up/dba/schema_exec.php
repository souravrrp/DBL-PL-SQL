<?php ob_start(); session_start();?>
<html>
<head>
<title>Set Schema Filter</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Set Schema For SQL Worksheet</h2>
<h4>All SQL in SQL Worksheet will be executed in this schema</h4>
<hr>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    if (!empty($_SESSION["exec"])) {
        unset($_SESSION["exec"]);
    }
    if (isset($_POST['pattern']))
        $patt=strtoupper($_POST['pattern']);
    else $patt='%';
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText("pattern", 'Pattern:', $patt);
    $form->addSubmit("submit", "Pattern");
    $form->display();
    $SCHM = @$_POST["schema"];
    if (!empty($SCHM)) {
        $_SESSION["exec"] = $SCHM;
        header('Location: connect.html');
        exit;
    } else {
        $usr = array($DSN['username']=>$DSN['username']);
        try {
            $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
            $SQL = "select username from dba_users
                    where username not like '%SYS%' and
                          username != :USR and
                          username like :PATT
                    order by 1";
            $rs = $db->Execute($SQL,array("USR"  => $DSN['username'],
                                          "PATT" => $patt));
            while ($row = $rs->FetchRow()) {
                $usr[$row[0]] = $row[0];
            }
            $db->close();
            $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
            $form->addSelect("schema", 'Schema:', $usr);
            $form->addSubmit("submit", "Filter");
            $form->addBlank(2);
            $form->display();
        }
        catch(Exception $e) {
            die($e->getTraceAsString());
        }
    }
?>
</center>
</body>
</html>
