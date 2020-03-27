#!/bin/bash
. nfs.sh
. rsync.sh
HostIp=`hostname -I`
if [ $HostIp = "172.16.1.190" ];then
    Rsync_Server
elif [ $HostIp = "172.16.1.188" ];then
    Nfs_Server
    sh inotifyins.sh
elif [ $HostIp = "172.16.1.189" ];then
    screen sh -x mysql.sh
    Rsync_Client /application/mysql
    Crontab_Add
elif [ $HostIp = "172.16.1.187" ];then
    Rsync_Client
    Crontab_Add
    Nfs_Client
    sh -x nginx.sh
    sh -x phpnosql.sh
elif [ $HostIp = "172.16.1.192" ];then
    sh -x apache.sh
    sh -x phpnosql.sh
    Nfs_Client
    Rsync_Client
    Crontab_Add
fi
