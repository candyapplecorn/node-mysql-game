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

if ($_SERVER["REQUEST_METHOD"] == "POST") { 
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

<nav class="top-bar secondary login" data-topbar role="navigation">
  <div class="row full">
    <h2 class="header-pop-up">Login</h2>
      <form name="login" action="<?PHP echo $_SERVER['PHP_SELF']; ?>" method="post">
        <ul class="">
          <li class="small-6 medium-6 columns">
            <label>Username</label>
            <input name="Username" value="<?PHP echo $_SESSION["Username"]; ?>">
            <?PHP echo $loginerrors[0]; ?>
          </li>
          <li class="small-6 medium-6 columns">
            <label>Password</label>
            <input name="Password" type="password" value="<?PHP echo $_SESSION['Password']; ?>">
            <?PHP echo $loginerrors[1]; ?>
          </li>
            <!-- Tell the server we want to log in -->
            <input type="HIDDEN" name="TYPE" value="LOGIN">
        </ul>
        <button class="button right">Submit</button>
      </form>
  </section>
</nav>

<nav class="top-bar secondary sign-up" data-topbar role="navigation">
  <div class="row full">
  <h2 class="header-pop-up">Sign Up</h2>
    <form name="register" action="<?PHP echo $_SERVER['PHP_SELF']; ?>" method="post">
      <ul class="">
        <li class="small-6 medium-3 columns">
          <label>Email</label><input name="registerEmail" value="<?PHP echo $_SESSION['registerEmail'] ?>">
          <?PHP echo $registererrors[2]; ?>
        </li>
        <li class="small-6 medium-3 columns">
          <label>Username</label><input name="registerUsername" value="<?PHP echo $_SESSION['registerUsername']; ?>">
          <?PHP echo $registererrors[0]; ?>
        </li>
        <li class="small-6 medium-3 columns">  
          <label>Password</label><input name="registerPassword" type="password" value="<?PHP echo $_SESSION['registerPassword']; ?>">
          <?PHP echo $registererrors[1]; ?>
        </li>
        <li class="small-6 medium-3 columns">
          <label>Confirm Password</label><input name="registerPasswordConfirm" type="password" >
          <?PHP echo $registererrors[3]; ?>
        </li>
        <!-- Tell the server we want to register -->
        <input type="HIDDEN" name="TYPE" value="REGISTER">
      </ul>
      <button class="button right">Submit</button>
    </form>
  </section>
</nav>
