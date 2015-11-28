/*
Copyright 2015 Joseph Burger, Alexander McNulty and Nicholas Tarn, all rights reserved.
To use under MIT license, all copyrights must be perserved.
Contact me at 'candyapplecorn@gmail.com' if you would like to use this,
*/
/*
Copyright 2015 Joseph Burger, Alexander McNulty and Nicholas Tarn, all rights reserved.
To use under MIT license, all copyrights must be perserved.
Contact me at 'candyapplecorn@gmail.com' if you would like to use this,
*/
<?PHP include "scripts/headers.php"; ?>

<form action="" method="post">
row: <input type="text" name="row"> itemtype: <input type="text" name="item">
<input type="submit">
</form>

<?PHP
if(isset($_POST['row'])&&ctype_digit($_POST['row'])&&(isset($_POST['item']))&&ctype_digit($_POST['item'])){
	$row=$_POST['row'];
	$item=$_POST['item']; //item number is passed to purchase_item to buy one of a specific item.

	$conn = new Connection();

	$qarr = Array(':name'=>$_SESSION["name"], ':id'=>$row);
	$qstr = "Select id from gamerows where ownerusername = :name AND id = :id";
	$results = $conn->Custom_Query($qstr, $qarr, TRUE);

	$qarr = Array('row'=>$row,'item'=>$item);
	$qstr = "CALL purchase_item(:row, :item)";

	if(isset($results[0]["id"])){
		$conn->Custom_Query($qstr, $qarr, TRUE);
	}

    // If we don't unset item and row, then whenever the user refreshes the page,
    // the purchase item operation will be performed. 
    unset($_POST['item']);
    unset($_POST['row']);
}
include "map.php";
include "ownedrows.php";

?>
