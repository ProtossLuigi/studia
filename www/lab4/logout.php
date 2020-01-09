<?php
session_start();
if (isset($_COOKIE["login"])){
    setcookie("login","",1);
}
$_SESSION = array();
session_destroy();
header('Location: index.php');
http_redirect();
exit;