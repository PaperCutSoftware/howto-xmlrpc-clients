#!/usr/bin/env php
<?php

function do_call($request) {
  
    $url = "http://localhost:8080/users";
    $header[] = "Content-type: text/xml";
    $header[] = "Content-length: ".strlen($request);
    
    $ch = curl_init();   
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_TIMEOUT, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $request);
    
    $data = curl_exec($ch);       
    if (curl_errno($ch)) {
        print curl_error($ch);
    } else {
        curl_close($ch);
        return $data;
    }
}

$request = xmlrpc_encode_request("userExists", "alec");
$response = do_call($request);
$answer = xmlrpc_decode($response);
echo($answer);
?>

