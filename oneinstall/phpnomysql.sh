#!/bin/sh
Make_Install()
{
    make -j `grep 'processor' /proc/cpuinfo | wc -l`
    if [ $? -ne 0 ]; then
        make
    fi
    make install
}
Ln_PHP_Bin()
{
    ln -sf /application/php/bin/php /usr/bin/php
    ln -sf /application/php/bin/phpize /usr/bin/phpize
    ln -sf /application/php/bin/pear /usr/bin/pear
    ln -sf /application/php/bin/pecl /usr/bin/pecl
    ln -sf /application/php/sbin/php-fpm /usr/bin/php-fpm
    rm -f /application/php/conf.d/*
}
    yum install  freetype-devel libjpeg-turbo-devel libpng-devel gd-devel libcurl-devel libxslt-devel libmcrypt libmcrypt-devel mhash mhash-devel mcrypt -y
    wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz -P /tools
    cd /tools && tar xf libiconv-1.14.tar.gz && cd libiconv-1.14
    ./configure --prefix=/usr/local/libiconv

    wget -c https://www.php.net/distributions/php-5.6.31.tar.gz -P /tools
    cd /tools && tar xf php-5.6.31.tar.gz && cd php-5.6.31
    ln -s /application/mysql/lib/libmysqlclient.so.20 /usr/lib64/
    touch ext/phar/phar.phar
    ./configure --prefix=/application/php-5.6.31 \
#			 --with-mysql=/application/mysql \
			 --with-mysql=mysqlnd
			 --with-iconv-dir=/usr/local/libiconv/ \
			 --with-freetype-dir \
			 --with-jpeg-dir \
			 --with-png-dir \
			 --with-zlib \
			 --with-libxml-dir=/usr/ \
			 --enable-xml \
			 --disable-rpath \
			 --enable-safe-mode \
			 --enable-bcmath \
			 --enable-shmop \
			 --enable-sysvsem \
			 --enable-inline-optimization \
			 --with-curl \
			 --with-curlwrappers \
			 --enable-mbregex \
			 --enable-fpm \
			 --enable-mbstring \
			 --with-mcrypt \
			 --with-gd \
			 --enable-gd-native-ttf \
			 --with-openssl \
			 --with-mhash \
			 --enable-pcntl \
			 --enable-sockets \
			 --with-xmlrpc \
			 --enable-zip \
			 --enable-soap \
			 --enable-short-tags \
			 --enable-zend-multibyte \
			 --enable-static \
			 --with-xsl \
			 --with-fpm-user=nginx \
			 --with-fpm-group=nginx \
			 --enable-ftp 
    Make_Install
    Ln_PHP_Bin

    ln -s /application/php-5.6.31 /application/php
    cp php.ini-production /application/php/lib/php.ini
    touch  /application/php/etc/php-fpm.conf
    cat >/application/php/etc/php-fpm.conf<<EOF
[global]
pid = /application/php/var/run/php-fpm.pid
error_log = /application/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = nginx
listen.group = nginx
listen.mode = 0666
user = nginx
group = nginx
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
pm.max_requests = 1024
pm.process_idle_timeout = 10s
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

cp /tools/php-5.6.31/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

