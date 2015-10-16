<?php
class Authentication
{
public $Connection;
const DATE_FORMAT = 'Y-m-d H:i:s';
function __construct()
{
    $this->Connection = new Connection();
}
function Login($Username,$Password)
{
    // Check if parameters are blank
    if($Username=='' || $Password=='') {
        Alerts::addNewAlert("Please fill out all required fields.", "error");
        return;
    }

    // Check and see if there were any matches in the result.
    $pw = $this->Connection->Custom_Query("SELECT md5(:Password) AS pw", array(':Password'=>$Password));

    // Query to get the credentials of the user logging in.
    $Login_Array = array(':Username'=>$Username);
    $Login_Result = $this->Connection->Custom_Query("SELECT * FROM players WHERE Username=:Username", $Login_Array);

    if (empty($Login_Result) || $pw["pw"] != $Login_Result['password']) {
        Alerts::addNewAlert("Username and Password combination is incorrect.", "error");
        return;
    }
    
    //Login is successful
    //Update the DB for the date of the login.
    $Last_Login_Array = array(':Account_Last_Login'=>date(self::DATE_FORMAT),':ID'=>$_SESSION['ID']);
    $this->Connection->Custom_Execute("UPDATE players SET lastlogin =:Account_Last_Login WHERE ID=:ID",$Last_Login_Array);
    $_SESSION["name"] = $Login_Result["username"];
    $_SESSION["id"] = $Login_Result["id"];
    // Display success toast.
    //if (!isset($_SESSION["id"])){
        Alerts::addNewAlert("You have logged in as " . $_SESSION['name'], "notice");
    //}
    // Redirect user to homepage.
    header( 'Location: /php-mysql-game/SQL_game.php');
}

function Register($User,$Pass,$Mail,$Permissions='4')
{
    $Username = Functions::Make_Safe($User);
    $Password = Functions::Make_Safe($Pass);
    $EMail = Functions::Make_Safe($Mail);
    $MD5Password = password_hash($Password, PASSWORD_DEFAULT);
    // Check if parameters are blank
    if(isset($Username) && isset($Password) && isset($EMail)) {
         if (!preg_match('/[^a-z_\-0-9]/i', $Username)) {
            if (filter_var($EMail, FILTER_VALIDATE_EMAIL)) {
                //Populate result sets to check if there is already players with these credentials in the db.
                $Register_Username_Array = array(':Username'=>$Username);
                $Register_Username_Result = $this->Connection->Custom_Query("SELECT * FROM players WHERE Username=:Username LIMIT 1", $Register_Username_Array);
                $Register_EMail_Array = array(':EMail'=>$EMail);
                $Register_EMail_Result = $this->Connection->Custom_Query("SELECT * FROM players WHERE EMail=:EMail LIMIT 1", $Register_EMail_Array);
                // Check if the username is already registered.
                if(empty($Register_Username_Result)) {
                    // Check is the email is already registerd.
                    if(empty($Register_EMail_Result)) {
                        $Now = date(self::DATE_FORMAT);
                        // Write query to insert registration data into db.
                        $Registration_Insert_Array = array(':Username'=>$Username,':Password'=>$MD5Password, ':EMail'=>$EMail,':Permissions'=>$Permissions,':Account_Created'=>$Now,':Account_Locked'=>0);
                        $this->Connection->Custom_Execute("INSERT INTO players (Username,Password,EMail,Permissions,Account_Created,Account_Locked) VALUES (:Username, :Password, :EMail, :Permissions, :Account_Created, :Account_Locked)",$Registration_Insert_Array);
                        // Create a new user class and check the ID to make sure the user was added.
                        $User = new User($this->Connection->PDO_Connection->lastInsertId());
                        if (isset($User->ID)) {
                            //Insert new default data into the players_settings table for the userid;
                            $Registration_Insert_playersettings_Array = array(':UserID'=>$User->ID);
                            $this->Connection->Custom_Execute("INSERT INTO players_settings (UserID) VALUES (:UserID)",$Registration_Insert_playersettings_Array);
                        }
                        // Check to see if insert worked.
                        if($this->Connection->PDO_Connection->lastInsertId()!='') {
                            // Success
                            Write_Log("players", "ACCOUNT: Successfull register attempt for account [$Username] and email [$EMail]");
                            // Login the user sending the unencrypted password since login re-encrypts it.
                            self::Login($Username,$Password);
                        } else {
                            Alerts::show("There was a problem creating this account. Please try again.", "error");
                            Write_Log("players", "ACCOUNT: Unknown error, couldn't register user to database.");
                        }
                     } else {
                        Alerts::show("That email has been taken. Please select a new one.", "error");
                        Write_Log("players", "ACCOUNT: Failed register attempt for account [$Username], email [$EMail] already exists.");
                    }
                } else {
                    Alerts::show("That username has been taken. Please select a new one.", "error");
                    Write_Log("players", "ACCOUNT: Failed register attempt for account [$Username] username already exists.");
                }
            } else {
                Alerts::show("Please select a valid email.", "error");
                Write_Log("players", "ACCOUNT: Non valid email given.");
            }
        } else {
            Alerts::show("Please select a valid alphanumeric username.", "error");
            Write_Log("players", "ACCOUNT: Non alphanumeric username given.");
        }
    } else {
        Alerts::show("Please fill out all required fields.", "error");
        Write_Log("players", "ACCOUNT: Not all register fields given.");
    }
}
function Logout()
{
    $_SESSION = array();
    session_destroy();
    header( 'Location: /') ;
}
} // END CLASS
