<?php
  $pass = "secret";
  $ipfdir = "../tmp/";

  header('Cache-Control: no-cache');
  header('Pragma: no-cache');

  // Input validation
  if (!isset($_GET['pass']) || $_GET['pass'] != $pass) {
    http_response_code(404);
    die(1);
  }
  if (!isset($_GET['name'])) {
    http_response_code(500);
    die("No name");
  }
  if (strlen($_GET['name']) > 32 || !preg_match('/^[a-zA-Z_\x7f-\xff][a-zA-Z0-9_.\x7f-\xff]*$/', $_GET['name'])) {
    http_response_code(500);
    die("Bad name");
  }

  $ipfn = $ipfdir.$_GET['name'].".txt";

  if (isset($_GET['newip'])) {

    // Set new IP for host
    if (filter_var($_GET['newip'], FILTER_VALIDATE_IP) == false) {
      http_response_code(500);
      die("Bad IP");
    }
    $ipfile = fopen($ipfn, "w");
    if ($ipfile == false) {
      http_response_code(500);
//    echo $ipfn, ": ";
      die("Unable to write file");
    }
    fwrite($ipfile, $_GET['newip']);
//  echo "Written ", $_GET['newip'], " to '", $ipfn, "'\n";

  } else {

    // Query IP of host
    $ipfile = fopen($ipfn, "r");
    if ($ipfile == false) {
      http_response_code(404);
//    echo $ipfn, ": ";
      die("Host not found");
    }
    echo fgets($ipfile);
  }
  fclose($ipfile);
?>
