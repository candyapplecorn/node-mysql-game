<?PHP
// Start the session - The very first thing that runs on any page.
session_start();

$GLOBALS['Path'] = $_SERVER["DOCUMENT_ROOT"] . '/'; //Site Path

require_once("classes/connection.php");
require_once("classes/authentication.php");
require_once("classes/alerts.php");
