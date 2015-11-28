<?PHP
include "scripts/headers.php";
?>
<?PHP

// In the game, the user, if logged in, will have name and id inside $_SESSION
// however since this is a one page demo we did in the meeting, i just hard-coded
// $_SESSION name and ID. -- Normally, again, login would set session for us.
$conn = new Connection();

// Get each row we want to update (the user's owned rows)
$qarr = Array(':name'=>$_SESSION["name"]);
$qstr = "Select id, ownerusername AS name from gamerows where ownerusername = :name";
$results = $conn->Custom_Query($qstr, $qarr, TRUE);

// Call scan on each result row, to update those rows.
foreach ($results AS $value){
	$qarr = Array(':id'=>$value["id"]);
	$qstr = "CALL scan(:id, 0)";
	$conn->Custom_Query($qstr, $qarr, TRUE);
}

// Make a query that returns multiple rows; each row is stores as an array; result is a multi-d array
$qstr = "SELECT ID, ownerusername AS Owner, Attackers, Defenders, Money, Fuel, Hospital, MGS, FGS, hospital_level AS H_lvl, attack_level AS attack, defense_level AS defense
FROM gamerows
WHERE ownerusername = :name";
$qarr = Array(':name'=>$_SESSION["name"]);
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

<?PHP
	// THIS STRING CONTAINS THE INPUTS FOR INTERACTING WITH ROWS SUCH AS
	// BUYING ITEMS, AND ATTACKERS
	$formsString = '
	<tr>
	<td></td>
	<td class="add"></td>
	<td class="add"></td>
	<td class="add"></td>
	<td class="add"></td>
	<td class="add"></td>
	<td class="add"></td>
	<td class="add">
	<input>
	<button class="button tiny">Buy</button>
	</td>
	<td class="add">
	<input>
	<button class="button tiny">Buy</button>
	</td>
	<td class="add">
	<input>
	<button class="button tiny">Buy</button>
	</td>
	<td class="add">
	<input>
	<button class="button tiny">Buy</button>
	</td>
	<td class="add">
	<input>
	<button class="button tiny">Buy</button>
	</td>
	</tr>';
?>

<!-- THIS IS THE VIEW - IT IS WHAT THE USER SEES -->
<table id = "myrows">
<?PHP 
	echo $TableHeaders;
	foreach ($TableRows as $key) 
		echo $key . $formsString; 
?>




<!--</table>-->










