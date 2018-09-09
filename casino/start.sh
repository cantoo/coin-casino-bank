/usr/local/openresty/bin/openresty -c conf/nginx.conf -p /data/app/coin-casino-bank/casino -s stop
sleep 1
/usr/local/openresty/bin/openresty -c conf/nginx.conf -p /data/app/coin-casino-bank/casino 
