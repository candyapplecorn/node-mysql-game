<?PHP
if ($_GET["argument"]=='logOut'){
    if(session_id() == '') {
        session_start();
    }
    //include "../classes/alerts.php";
    session_unset();
    session_destroy();
    UNSET($_SESSION["id"]);
    $link = "/php-mysql-game/SQL_game.php";
    echo $link; 
}
else{
    echo '<li class=""><a id="logout_btn" >Logout</a></li>';
    echo '<script>
        $("#logout_btn").click(function() {
            $.ajax({
                url: "scripts/logout.php?argument=logOut",
                    success: function(data){
                        window.location.href = data;
                    }
                });
            });
        </script>';
}
?>


