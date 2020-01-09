<?php
//ini_set('session.save_path','/tmp/sessions');
ini_set('session.use_only_cookies',1);
$visits_path = '/tmp/visits.db';
$users_path = '/tmp/users.db';
$comments_path = "/tmp/comments.db";
$id = dba_open($visits_path,"r","db4");
if(!$id){
    $id = dba_open($visits_path,"c","db4");
    dba_insert("visits","0",$id);
}
dba_close($id);
$id = dba_open($users_path,"c","db4");
dba_close($id);
$id = dba_open($comments_path,"c","db4");
dba_close($id);