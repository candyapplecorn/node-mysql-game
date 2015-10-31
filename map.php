<form action="" method="post">
Top row to scan: <input type="text" name="f_id"><br>
<input type="submit">
</form>
<?PHP

include "scripts/headers.php";

//first row to be scanned is hard coded here.
$f_id=1;
if(isset($_POST['f_id'])&&ctype_digit($_POST['f_id'])){
	$f_id=$_POST['f_id'];
}
$l_id=$f_id+9;
$conn = new Connection();

// Make a query that returns multiple rows; each row is stores as an array; result is a multi-d array
$qstr = "SELECT gamerows.ID, gamerows.ownerusername AS Owner, gamerows.defenders + gamerows.attackers AS Forces, gamerows.Money, gamerows.Fuel, ROUND(gamerows.morale) AS Morale
FROM gamerows
LEFT JOIN players
ON players.id = gamerows.owner
WHERE gamerows.ID >= :f_id
AND gamerows.id <= :l_id";
$qarr = Array('f_id'=>$f_id , 'l_id'=>$l_id);
$results = $conn->Custom_Query($qstr, $qarr, TRUE);

// First, insert a TH's into the table for each key
$TableHeaders = "<TR>";
$TableRows = Array();
foreach($results as $key=>$value) {
	$TableRows[$key] = "<TR>";
	foreach($value as $xkey=>$x){
		if ($key == 0){
			$TableHeaders .= '<TH>' . $xkey . '</TH>';	
		}

		$TableRows[$key] .= '<TD>' . $x . '</TD>';
	}
	$TableRows[$key] .= "</TR>";
}
$TableHeaders .= "</TR>";
?>

<!-- THIS IS THE VIEW - IT IS WHAT THE USER SEES -->
<table id = "myrows">
<?PHP 
	echo $TableHeaders;
	foreach ($TableRows as $key) 
		echo $key; 
?>
</table>