#!/bin/bash
Cur_Dir=`pwd`
#安装inotify
cd /tools
if [ -s "$Cur_Dir/packages/inotify-tools-3.13.tar.gz" ];then
    cp $Cur_Dir/packages/inotify-tools-3.13.tar.gz /tools
else
    wget -c https://jaist.dl.sourceforge.net/project/inotify-tools/inotify-tools/3.13/inotify-tools-3.13.tar.gz >/dev/null 2>&1
fi
tar xf inotify-tools-3.13.tar.gz && cd inotify-tools-3.13
./configure --prefix=/usr/local/inotify-tool/
make && make install

cd $Cur_Dir
#实时同步脚本
cat >/scripts/inotify.sh<<EOF
#!/bin/bash
inotify=/usr/local/inotify-tools/bin/inotifywait

 "\$inotify" -mrq --format '%w%f' -e create,close_write,delete /data |while read file
do
  cd /data &&  rsync -az ./ --delete rsync_backup@172.16.1.190::data \
--password-file=/etc/rsync.password
done
EOF

#rsync 客户端密码
echo "111111"> /etc/rsync.password
chmod 600 /etc/rsync.password 

#后台运行实时同步脚本
sh -x /scripts/inotify.sh &

#加入开机启动项
cat >>/etc/rc.local<<EOF
/bin/sh /scripts/inotify.sh &
EOF
