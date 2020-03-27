#!/bin/sh
#author by hui
#date 20190827 17:41
#description:

Nfs_Server()
{
#1. nfs-utils rpcbind install
if [  `rpm -qa rpcbind nfs-utils|wc -l` -eq 0 ]
    then
	yum install -y rpcbind nfs-utils >/dev/null 2>&1
    else 
	echo "=======The rpcbind nfs-utils already installed========"
fi

#2.nfs、rpcbind start
systemctl start rpcbind nfs
systemctl enable rpcbind nfs

#3.mount
mkdir /data
cat >>/etc/exports<<EOF
/data 172.16.1.*(rw,sync)
EOF
systemctl reload nfs
exportfs -rv
}

Nfs_Client()
{
#1. nfs-utils rpcbind install
if [  `rpm -qa rpcbind nfs-utils|wc -l` -eq 0 ]
    then
	yum install -y rpcbind nfs-utils >/dev/null 2>&1
    else 
	echo "=======The rpcbind nfs-utils already installed========"
fi

#2.nfs、rpcbind start
systemctl start rpcbind nfs
systemctl enable rpcbind nfs
showmount -e 127.0.0.1


read -p "please input you directory:" NfsDir
mount -t nfs 172.16.1.188:/data $NfsDir

}
