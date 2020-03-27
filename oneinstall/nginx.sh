#!/bin/sh
    useradd -s /sbin/nologin -M nginx
    yum install pcre pcre-devel openssl openssl-devel -y >/dev/null 2>&1
    wget -q http://nginx.org/download/nginx-1.12.1.tar.gz -P /tools 
    cd /tools/
    tar xf nginx-1.12.1.tar.gz
    cd nginx-1.12.1
    ./configure --prefix=/application/nginx-1.12.1 --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module
    make && make install
cd /application
ln -s nginx-1.12.1/ nginx
cd nginx
./sbin/nginx 
