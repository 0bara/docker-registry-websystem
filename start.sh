#!/bin/sh
# created by t.obara(obara7802@gmail.com)
#

function check_key()
{
  pushd laravel
  len=`grep key app/config/app.php|wc -c`
  if [ $len -le 30 ]; then
    ## yet generate key.
    key=`php artisan key:generate | cut -b 18-49`
    sed -ir "s/'key' =>.*/'key' => '$key',/" app/config/app.php
  fi
  popd
}

function check_db()
{
  pushd laravel

  if [ ! -e app/database/production.sqlite ]; then
    ## yet migrate
    touch app/database/production.sqlite
    echo y | php artisan migrate
    chmod 666 app/database/production.sqlite
  fi

  popd
}

if [ -e "/usr/local/ssl" ]; then
  ## ssl用の証明書を/usr/local/sslから参照できるように-v でmountすること
  sed -ir 's#^SSLCertificateFile .*#SSLCertificateFile /usr/local/ssl/server.crt#' /etc/httpd/conf.d/ssl.conf
  sed -ir 's#^SSLCertificateKeyFile .*#SSLCertificateKeyFile /usr/local/ssl/server_nopass.key#' /etc/httpd/conf.d/ssl.conf
fi

check_key
check_db

/usr/bin/supervisord -n -c /etc/supervisord.conf
