<?php
session_start();
error_reporting(E_ALL & ~E_STRICT & ~E_DEPRECATED);
require_once ('config.php');
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
require_once 'Image/GraphViz.php';

$DSN = $_SESSION['DSN'];
$db = NewADOConnection("oci8");
$own = @$_GET['own'];
$pattern=@$_GET['patt'];

// php_beautifier->setBeautify(false);
	$EDGE = "SELECT c1.table_name as child,
                        c2.table_name as parent,
                        c1.constraint_name 
			 FROM dba_constraints c1, dba_constraints c2
			 WHERE c1.owner=:OWN and
                                   (c1.table_name like upper(:PATTERN) or
                                    c2.table_name like upper(:PATTERN)) and
				   c2.owner=:OWN and
				   c1.r_owner=:OWN and
				   c1.constraint_type='R' and
				   c2.constraint_name=c1.r_constraint_name and
				   c2.constraint_type in ('P','U')";
// php_beautifier->setBeautify(true);
$graph = new Image_GraphViz();
$graph->addAttributes(array('label'=> "*** ER diagram for $own",
			    'labelloc'=>'t',
			    'fontname'=>'Helvetica',
			    'fontsize'=>10,
			    'labelfontname'=>'Helvetica',
			    'labelfontsize'=>10,
			    'orientation' => 'portrait',
			    'labeljust'=>'l',
			    'labeldistance'=>'5.0',
			    'rankdir' => 'LR',
			));

try {
	$db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
	$rs = $db->Execute($EDGE, array('OWN'=>$own,'PATTERN'=>$pattern));
	while ($row = $rs->FetchRow()) {
		$graph->addNode(
			$row[0],
			array(
		        'height'=>'0.2',
		        'width'=>'2.1',
		        'label'=>$row[0],
                        'fixedsize' => false,
		        'fontsize' => '5',
                        'fontname' => 'Verdana',
		        'shape' => 'record',
		        'style' => 'filled',
		        'filcolor' => 'magenta',
			)
		);
		$graph->addNode(
			$row[1],
			array(
		        'height'=>'0.2',
		        'width'=>'2.1',
		        'label'=>$row[1],
                        'fixedsize' => false,
		        'fontsize' => '5',
                        'fontname' => 'Verdana',
		        'shape' => 'record',
		        'style' => 'filled',
		        'filcolor' => 'magenta',
			)
		);
		$graph->addEdge(
			array($row[0] => $row[1]),
			array( 
                                'label' => $row[2],
				'color' => 'grey',
                                'fontsize' => 6,
				'arrowhead' => 'oarrow',
				'arrowtail' => 'crow',
				'style' => 'dashed',
			)
		);
	}
	$graph->image('png');

}
catch(Exception $e) {
	die($e->getMessage());
}
?>
