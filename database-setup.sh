#!/bin/sh

## Consts
HOST='localhost'
DBNAME='koala'
USER='koala'
PASS=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 15`

## Start mysql
/usr/bin/mysqld_safe > /dev/null 2>&1 &

## Waiting started...
sleep 15

## Create DataBase and User and Privileges 
mysql -uroot -e "CREATE DATABASE $DBNAME;"
mysql -uroot -e "CREATE USER '$USER'@'$HOST' IDENTIFIED BY '$PASS';"
mysql -uroot -e "GRANT ALL PRIVILEGES ON $DBNAME . * TO '$USER'@'$HOST';"
mysql -uroot -e "FLUSH PRIVILEGES;"

## Overwriting default db configuration file
echo "<?php 
return [ 
'class' => 'yii\db\Connection', 
'dsn' => 'mysql:host=$HOST;dbname=$DBNAME',
'username' => '$USER', 
'password' => '$PASS', 
'charset' => 'utf8', 
];" > /var/www/koala/config/db.php

## Do migrations
/usr/bin/php /var/www/koala/yii migrate --interactive=0

## Stop daemon
mysqladmin -uroot shutdown
