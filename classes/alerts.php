<?php
class Alerts {

    public static function Show($Message, $Title="", $Type="")
    {
        echo '<script type="text/javascript">';
        switch ($Type) {
            case 'error':
                if ($Title=="")
                    echo '$.growl.error({ message: "' . $Message . '" });';
                else
                    echo '$.growl.error({ title: "'.$Title.'", message: "' . $Message . '" });';
                break;
            case 'notice':
                if ($Title=="")
                    echo '$.growl.notice({ message: "' . $Message . '" });';
                else
                    echo '$.growl.notice({ title: "'.$Title.'", message: "' . $Message . '" });';
                break;
            case 'warning':
                if ($Title=="")
                    echo '$.growl.warning({ message: "' . $Message . '" });';
                else
                    echo '$.growl.warning({ title: "'.$Title.'", message: "' . $Message . '" });';
                break;
            default:
                if ($Title=="")
                    echo '$.growl({ message: "' . $Message . '" });';
                else
                    echo '$.growl({ title: "'.$Title.'", message: "' . $Message . '" });';
                break;
        }
        echo '</script>';
    }

} 
