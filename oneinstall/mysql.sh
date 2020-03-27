#!/bin/sh
#author by hui
#date:20190816-16:26
Cur_Dir=$(pwd)
dfile=/application/mysql-5.7.9/data
#1.install lib-soft base-soft
yum -y install make gcc-c++ cmake bison-devel  ncurses-devel perl vim wget >/dev/null 2>&1

#2.create user
useradd  mysql -s  /sbin/nologin -M

#3.copy boost
cd /tools
mkdir -p /usr/local/boost
cp $Cur_Dir/packages/boost_1_59_0.tar.gz /usr/local/boost

if [ -s "$Cur_Dir/packages/mysql-5.7.9.tar.gz" ];then
    cp $Cur_Dir/packages/mysql-5.7.9.tar.gz /tools
else
    wget  -c https://downloads.mysql.com/archives/get/file/mysql-5.7.9.tar.gz
fi

tar -xf mysql-5.7.9.tar.gz

#4.start install
cd mysql-5.7.9

cmake -DCMAKE_INSTALL_PREFIX=/application/mysql-5.7.9 -DMYSQL_DATADIR=/application/mysql-5.7.9/data -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_BOOST=/usr/local/boost

make && make install

chown -R mysql:mysql /application/mysql-5.7.9

#5.initialization

cp support-files/my-default.cnf  /etc/my.cnf

cat>/etc/my.cnf<<EOF
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html
# *** DO NOT EDIT THIS FILE. It's a template which will be copied to the
# *** default location during install, and will be replaced if you
# *** upgrade to a newer version of MySQL.

[mysqld]

# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M

# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin

# These are commonly set, remove the # and set as required.
# basedir = .....
# datadir = .....
# port = .....
# server_id = .....
# socket = .....

basedir = /application/mysql-5.7.9
datadir = /application/mysql-5.7.9/data
port = 3306
server_id = 1
socket = /tmp/mysql.sock

# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M 

EOF

cd /application/mysql-5.7.9

if [  -s $dfile ]
    then
	rm -fr $dfile
fi

bin/mysqld --initialize --user=mysql --datadir=$dfile
#start mysql
if [ "/application/mysql-5.7.9" = "$Cur_Dir" ]
    then
      `cd /application/mysql-5.7.9`
fi
support-files/mysql.server start

#添加启动项
\cp support-files/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql

#xiugaimima 
#>alter user user() identified by '123456';

#shezhiqidongxiang 创建systemd启动项
#mkdir /etc/systemd/system/mysqld.service.d


#peizhihuanjingbianliang 
#cat>>/etc/profile<<EOF

echo '#mysql'>>/etc/profile
echo 'PATH=${PATH}:/application/mysql/bin'>>/etc/profile

source /etc/profile


