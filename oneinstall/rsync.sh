#/bin/sh

Rsync_Server()
{
    if [ `rpm -qa rsync|wc -l` -eq 0 ]
        then
	    yum install -y rsync >/dev/null 2>&1
    fi

cat >/etc/rsyncd.conf<<EOF
	uid = rsync
	gid = rsync
	use chroot = no
	max connections = 2000
	timeout = 600
	pid file = /var/run/rsyncd.pid
	lock file = /var/run/rsync.lock
	log file = /var/log/rsyncd.log
	ignore errors
	read only = false
	list = false
	hosts allow = 192.168.58.0/24
	hosts deny = 0.0.0.0/32
	auth users =rsync_backup
	secrets file = /etc/rsync.password
	fake super = yes

	[backup]
	comment =backup server by super
	path = /backup
	
	[data]
	comment =data server by super
	path = /data
EOF

    useradd -s /sbin/nologin -M rsync
    mkdir /backup /data
    chown -R rsync.rsync /backup
    chown -R rsync.rsync /data

    echo "rsync_backup:111111">/etc/rsync.password
    echo "rsync_data:111111">>/etc/rsync.password
    chmod 600 /etc/rsync.password

    rsync --daemon
    echo "raync --daemon">>/etc/rc.local
}
Rsync_Pwd()
{
    echo "111111">/etc/rsync.password
    chmod 600 /etc/rsync.password
}

Rsync_Client()
{
     Rsync_Pwd
echo "#!/bin/sh">/scripts/beifen.sh
echo "rsync -avz $1 rsync_backup@172.16.1.190::backup/$1_\$(date +%F) --password-file=/etc/rsync.password" >>/scripts/beifen.sh
}

Crontab_Add()
{
  echo "00 00 * * * /bin/sh  /scripts/beifen.sh >/dev/null 2>&1">>/etc/crontab
}
