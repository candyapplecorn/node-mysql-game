<?PHP
/*
test_input taken from w3schools:
http://www.w3schools.com/php/php_form_validation.asp
*/
function test_input($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && !isset($_SESSION["id"])) { 
    /* The user just hit the Submit button for login */
    if ($_POST['TYPE'] == "LOGIN"){
        if ( !($_POST['Username'])) {
            $loginerrors[0]='<small class="error">Please supply a username.</small>';
        } else { 
            $_SESSION['Username'] = test_input($_POST["Username"]); 
        }
        if ( !($_POST['Password'])) {
            $loginerrors[1]='<small class="error">Please supply a password.</small>';
        } else {
            $_SESSION['Password'] = test_input( $_POST["Password"]);
        }
        /* begin actual database login stuff */
        if ( ($_POST['Password']) && ($_POST['Username'])) {
            $auth = new Authentication();
            $auth->Login(test_input($_POST['Username']), test_input($_POST['Password']));
            unset ($_POST['Password']);
            unset ($_POST['Username']);
            unset ($_SESSION['Username']);
            unset ($_SESSION['Password']);
        }
    }
    
    /* The user just hit the Submit button for register */

    if ($_POST['TYPE'] == "REGISTER"){
        if ( !($_POST['registerEmail']) ){
            $registererrors[2]='<small class="error">Please supply an email.</small>';
        } else if ( !filter_var($_POST['registerEmail'], FILTER_VALIDATE_EMAIL) ) {
            $registererrors[2]='<small class="error">Provided email is invalid.</small>';
        } else { 
            $_SESSION['registerEmail'] = test_input($_POST["registerEmail"]); 
        }
        if ( !($_POST['registerUsername']) ){
            $registererrors[0]='<small class="error">Please supply a username.</small>';
        } else { 
            $_SESSION['registerUsername'] = test_input($_POST["registerUsername"]); 
        }
        if ( !($_POST['registerPassword']) ){
            $registererrors[1]='<small class="error">Please supply a password.</small>';
        } else { 
            $_SESSION['registerPassword'] = test_input($_POST["registerPassword"]); 
        }
        if ( !($_POST['registerPasswordConfirm']) ){
            $registererrors[3]='<small class="error">Please supply a password.</small>';
        } else if ($_POST['registerPasswordConfirm'] != $_POST["registerPassword"]){ 
            $registererrors[1] = $registererrors[3] = 
                '<small class="error">Password and confirmation password do not match.</small>';

        }

        /* Time for user registration! */
        if ($_SESSION['registerPassword'] && $_SESSION['registerUsername'] && $_SESSION['registerEmail'] ){
        }
    }
}

?>

<nav id="loginform" class="top-bar secondary login" data-topbar role="navigation" >
  <div class="row full">
    <h2 class="header-pop-up">Login</h2>
      <form name="login" action="<?PHP echo $_SERVER['PHP_SELF']; ?>" method="post">
        <ul class="">
          <li class="small-6 medium-6 columns">
            <label>Username</label>
            <input name="Username" value="<?PHP echo isset($_SESSION["Username"]) ? $_SESSION["Username"] : ""; ?>">
            <?PHP echo isset($loginerrors[0]) ? $loginerrors[0] : ""; ?>
          </li>
          <li class="small-6 medium-6 columns">
            <label>Password</label>
            <input name="Password" type="password" value="<?PHP echo isset($_SESSION['Password']) ? $_SESSION['Password'] : ""; ?>">
            <?PHP echo isset($loginerrors[1]) ? $loginerrors[1] : ""; ?>
          </li>
            <!-- Tell the server we want to log in -->
            <input type="HIDDEN" name="TYPE" value="LOGIN">
        </ul>
        <button class="button right">Submit</button>
      </form>
  </section>
</nav>

<nav id="signupform" class="top-bar secondary sign-up" data-topbar role="navigation">
  <div class="row full">
  <h2 class="header-pop-up">Sign Up</h2>
    <form name="register" action="<?PHP echo $_SERVER['PHP_SELF']; ?>" method="post">
      <ul class="">
        <li class="small-6 medium-3 columns">
          <label>Email</label><input name="registerEmail" value="<?PHP echo isset($_SESSION['registerEmail']) ? $_SESSION['registerEmail'] : ""; ?>">
          <?PHP echo isset($registererrors[2]) ? $registererrors[2] : "" ; ?>
        </li>
        <li class="small-6 medium-3 columns">
          <label>Username</label><input name="registerUsername" value="<?PHP echo isset($_SESSION['registerUsername']) ? $_SESSION['registerUsername'] : ""; ?>">
          <?PHP echo isset($registererrors[0]) ? $registererrors[0] : ""; ?>
        </li>
        <li class="small-6 medium-3 columns">  
          <label>Password</label><input name="registerPassword" type="password" value="<?PHP echo isset($_SESSION['registerPassword']) ? $_SESSION['registerPassword'] : ""; ?>">
          <?PHP echo isset($registererrors[1]) ? $registererrors[1] : ""; ?>
        </li>
        <li class="small-6 medium-3 columns">
          <label>Confirm Password</label><input name="registerPasswordConfirm" type="password" >
          <?PHP echo isset($registererrors[3]) ? $registererrors[3] : ""; ?>
        </li>
        <!-- Tell the server we want to register -->
        <input type="HIDDEN" name="TYPE" value="REGISTER">
      </ul>
      <button class="button right">Submit</button>
    </form>
  </section>
</nav>

<script>
    document.getElementById("signup").addEventListener('click', function(){
        var self =  document.getElementById("signupform");
        self.style.visibility = self.style.visibility == "hidden" ? "visible" : "hidden";
        /*$(document).foundation();
        $(document).foundation('reflow');*/
    });
    document.getElementById("login").addEventListener('click', function(){
        var self =  document.getElementById("loginform");
        self.style.visibility = self.style.visibility == "hidden" ? "visible" : "hidden";
        /*$(document).foundation();
        $(document).foundation('reflow');*/
    });
</script>
