<?PHP
echo "Dude!";
?>

<?PHP
$ini_array = parse_ini_file("sample.ini");
//print_r($ini_array);
echo $ini_array['username'];
//print_r($GLOBALS);
?>
