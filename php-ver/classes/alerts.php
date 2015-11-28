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
<?PHP
class Alerts {

    public static function addNewAlert($Message, $Type)
    {
        // Here we check to make sure these variables have been setup before trying to push to them.
         $AllAlertTypes = array("warning", "error", "notice", "success");
        foreach ($AllAlertTypes as $AlertType){
            if (!isset($_SESSION[$AlertType])){ $_SESSION[$AlertType] = array();}
        }

        // Loop through the type of Alert to display and add it to the array.
        switch ($Type) {
            case 'warning':
                array_push($_SESSION['warning'], $Message);
                break;

            case 'error':
                array_push($_SESSION['error'], $Message);
                break;

            case 'success':
                array_push($_SESSION['success'], $Message);
                break;

            case 'notice':
                array_push($_SESSION['notice'], $Message);
                break;
        }
    }

    public static function clearAllAlerts()
    {
        $_SESSION['warning'] = array();
        $_SESSION['error'] = array();
        $_SESSION['success'] = array();
        $_SESSION['notice'] = array();
    }
    
    public static function saveAlerts(){
        $save = [ $_SESSION['warning'], $_SESSION['error'], $_SESSION['success'], $_SESSION['notice'] ];
        return $save;
    }
    public static function loadAlerts($loadme){
        foreach ($AllAlertTypes as $AlertType){
            $_SESSION[$AlertType] = $loadme[$AlertType];
        }
    }

    //Strips strings.
    public static function displayAllAlerts()
    {
        // Here we loop through
        $AllAlertTypes = array("warning", "error", "notice", "success");
        foreach ($AllAlertTypes as $AlertType){
            if(isset($_SESSION[$AlertType])){
                foreach ($_SESSION[$AlertType] as $Alert){
                    Alerts::displayAlert($Alert,$AlertType);
                }

                unset($_SESSION[$AlertType]);
            }
        }
    }

    public static function displayAlert($Message,$Type="notice")
    {
        echo '<script type="text/javascript">';
        switch ($Type) {
            case 'error':
                echo '$.growl.error({ message: "' . $Message . '" });';
                break;
            case 'notice':
                echo '$.growl.notice({ message: "' . $Message . '" });';
                break;
            case 'success':
                echo '$.growl.success({ message: "' . $Message . '" });';
                break;
            case 'warning':
                echo '$.growl.warning({ message: "' . $Message . '" });';
                break;
            default:
                 echo '$.growl.notice({ message: "' . $Message . '" });';
                break;
        }
        echo '</script>';
    }



} // End Class
