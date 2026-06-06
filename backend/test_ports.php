<?php
echo "PHP socket test starting...\n";

$ports = [8000, 8001, 8002, 8080, 9000, 3000];
$hosts = ['127.0.0.1', '0.0.0.0', '192.168.1.4'];

foreach ($hosts as $host) {
    foreach ($ports as $port) {
        $s = @stream_socket_server("tcp://$host:$port", $errno, $errstr);
        if ($s) {
            echo "OK    - $host:$port\n";
            fclose($s);
        } else {
            echo "FAIL  - $host:$port => $errstr ($errno)\n";
        }
    }
}
echo "\nDone.\n";
