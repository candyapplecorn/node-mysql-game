<?PHP
// Start the session - The very first thing that runs on any page.
session_start();

$GLOBALS['Path'] = $_SERVER["DOCUMENT_ROOT"] . '/'; //Site Path

//display_errors(false);
//log_errors(false);
//error_reporting(0);
//@ini_set('display_errors', 0);

require_once("classes/connection.php");
require_once("classes/authentication.php");
require_once("classes/alerts.php");
