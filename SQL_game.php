<?PHP include "scripts/headers.php"; ?>
<!DOCTYPE html>
<html lang="en" prefix="og: http://ogp.me/ns#" itemscope itemtype="http://schema.org/Article">
<head>
  <meta charset="utf-8">
  <title>SQL Chief</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Are you tired of browser-based games that are thinly veiled interfaces for databases? Finally, there's a game that just is a database! THRILL as you insert your very own row in the 'rows' table! With careful selection of SQL queries, you will soon have three or even four-digit numbers in some of the fields in your row! Other queries may allow you to use those numbers to subtract from rows entered by other players -- all while pushing the numbers in your own row even higher! As you master the game, you may find that you have inserted not just one row into the game, but several! Log in on the right to get started."/>
  <link rel="stylesheet" type="text/css" href="pub/css/foundation.min.css">
  <link rel="stylesheet" type="text/css" href="pub/css/normalize.css">
  <link rel="stylesheet" type="text/css" href="pub/css/style.css">
  <link rel="icon" href="pub/img/favicon.ico" type="image/x-icon">
  <link rel="shortcut icon" href="/img/favicon.ico" type="image/x-icon">
</head>

<body>
<!-- Header -->
  <nav class="top-bar" data-topbar role="navigation">
    <ul class="title-area">
      <li class="name">
        <h1><a href="#"><img src="pub/img/MultiDoge.png">&nbsp;SQL Chief</a></h1>
      </li>
      <li class="toggle-topbar menu-icon"><a href="#"><span>Menu</span></a></li>
    </ul>
    <section class="top-bar-section">
      <ul class="right">
        <li class=""><a href="#">Login</a></li>
        <li class=""><a href="#">Sign Up</a></li>
      </ul>
      <ul class="left">
        <li><a href="#" class="donate">Donate!</a></li>
      </ul>
    </section>
  </nav>
  <?PHP include "scripts/user_auth.php"; ?>
  <!--
  <nav class="top-bar secondary login" data-topbar role="navigation">
    <div class="row full">
      <h2 class="header-pop-up">Login</h2>
      <form>
        <ul class="">
          <li class="small-6 medium-6 columns">
            <label>Username</label><input>
          </li>
          <li class="small-6 medium-6 columns">
            <label>Password</label><input>
          </li>
        </ul>
        <button class="button right">Submit</button>
      </form>
    </section>
  </nav>
  <nav class="top-bar secondary sign-up" data-topbar role="navigation">
    <div class="row full">
    <h2 class="header-pop-up">Sign Up</h2>
      <form>
        <ul class="">
          <li class="small-6 medium-3 columns">
            <label>Email</label><input>
          </li>
          <li class="small-6 medium-3 columns">
            <label>Username</label><input>
          </li>
          <li class="small-6 medium-3 columns">  
            <label>Password</label><input>
          </li>
          <li class="small-6 medium-3 columns">
            <label>Confirm Password</label><input>
          </li>
        </ul>
        <button class="button right">Submit</button>
      </form>
    </section>
  </nav>
  -->
<!-- End Header -->
<!-- Main -->
  <div class="main">
    <div class="row full outward">
      <div class="content right small-12 medium-9 columns">
        <table>
          <thead>
            <tr>
              <th width="10%">Row</th>
              <th class="numbers" width="30%">Money</th>
              <th class="numbers" width="30%">Fuel</th>
              <th class="numbers" width="30%">Attackers</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>501</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XXX</td>
            </tr>
            <tr>
              <td>502</td>
              <td class="numbers">X,XXX</td>
              <td class="numbers">X,XXX</td>
              <td class="numbers">X,XXX</td>
            </tr>
            <tr>
              <td>503</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XX,XXX</td>
            </tr>
            <tr>
              <td>503</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XX,XXX</td>
            </tr>
            <tr>
              <td>503</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XX,XXX</td>
            </tr>
            <tr>
              <td>503</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XX,XXX</td>
            </tr>
            <tr>
              <td>503</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XX,XXX</td>
            </tr>
            <tr>
              <td>503</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XX,XXX</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="sidebar small-12 medium-3 columns">
        <div class="row full">
          <a href="#" class="small-4 medium-12 columns button small">Scan</a>
          <a href="#" class="small-4 medium-12 columns button small">Transport</a>
          <a href="#" class="small-4 medium-12 columns button small">Attack</a>
        </div>
      </div>
    </div>
    <div class="row full">
    <div class="sidebar  right small-12 medium-3 columns">
        <div class="row full">
          <a href="#" class="small-4 medium-12 columns button small">Scan</a>
          <a href="#" class="small-4 medium-12 columns button small">Transport</a>
          <a href="#" class="small-4 medium-12 columns button small">Attack</a>
        </div>
      </div>
      <div class="content left small-12 medium-9 columns">
        <table>
          <thead>
            <tr>
              <th width="10%">Row</th>
              <th class="numbers" width="30%">Money</th>
              <th class="numbers" width="30%">Fuel</th>
              <th class="numbers" width="30%">Attackers</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>501</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XXX</td>
            </tr>
            <tr>
              <td>502</td>
              <td class="numbers">X,XXX</td>
              <td class="numbers">X,XXX</td>
              <td class="numbers">X,XXX</td>
            </tr>
            <tr>
              <td>503</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XX,XXX</td>
            </tr>
            <tr>
              <td>503</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XX,XXX</td>
            </tr>
            <tr>
              <td>503</td>
              <td class="numbers">XX,XXX</td>
              <td class="numbers">XXX</td>
              <td class="numbers">XX,XXX</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
<!-- Script Tags -->
  <script src="pub/js/foundation.min.js"></script>
  <script src="pub/js/script.js"></script>
</body>
</html>
