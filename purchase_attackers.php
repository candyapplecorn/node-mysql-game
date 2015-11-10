<?PHP include "scripts/headers.php"; ?>

<form action="" method="post">
row: <input type="text" name="row"> amt: <input type="text" name="amt">
<input type="submit">
</form>

<?PHP
if(isset($_POST['row'])&&ctype_digit($_POST['row'])&&($_POST['amt'])&&ctype_digit($_POST['amt'])){
	$row=$_POST['row'];
	$amt=$_POST['amt'];

	$conn = new Connection();

	$qarr = Array(':name'=>$_SESSION["name"], ':id'=>$row);
	$qstr = "Select id from gamerows where ownerusername = :name AND id = :id";
	$results = $conn->Custom_Query($qstr, $qarr, TRUE);

	$qarr = Array('row'=>$row,'amt'=>$amt);
	$qstr = "CALL purchase_attackers(:row, :amt)";

	if(isset($results[0]["id"])){
		$conn->Custom_Query($qstr, $qarr, TRUE);
	}
}
include "map.php";
include "ownedrows.php";

?>
