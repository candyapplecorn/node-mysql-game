<form action="" method="post">
row: <input type="text" name="row"> amt: <input type="text" name="amt">
<input type="submit">
</form>
<?PHP
include "scripts/headers.php";
	$row=0;
	$amt=0;
	if(isset($_POST['row'])&&ctype_digit($_POST['row'])&&($_POST['amt'])&&ctype_digit($_POST['amt'])){
		$row=$_POST['row'];
		$amt=$_POST['amt'];
	}
	
$conn = new Connection();

$qarr = Array(':name'=>$_SESSION["name"]);
$qstr = "Select id from gamerows where ownerusername = :name";
$results = $conn->Custom_Query($qstr, $qarr, TRUE);

$flag = FALSE;

foreach ($results AS $inner){
	foreach ($inner as $value){
		if($row==$value){
			$flag=TRUE;
		
		}
	}
}

$qarr = Array('row'=>$row,'amt'=>$amt);
$qstr = "CALL purchase_attackers(:row, :amt)";

if($flag){
	$conn->Custom_Query($qstr, $qarr, TRUE);
}
include "map.php";
include "ownedrows.php";
	
?>
