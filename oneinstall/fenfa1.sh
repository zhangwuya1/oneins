#!/bin/sh
#author by hui
#date 20190905 
#description: finished the my system


Cur_Dir=$(pwd)
#==================================color=================================================#
Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}
Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}
#==================================color=================================================#
#root user load system

if [ `id -u`! = "0" ]
    then
      echo "the user is not root ,you must be root"
fi

Echo_Green "#############################################################"
Echo_Green "#..........................start............................#"
Echo_Green "#############################################################"
FenFa()
{
rm -f /root/.ssh/id_dsa*
ssh-keygen -t dsa -f /root/.ssh/id_dsa -P "" -q
#install sshpass
yum install sshpass -y &>/dev/null

#  fenfa key file
for ip in `cat $Cur_Dir/iplist.txt`
do
  echo "===== fenfa key to host $ip ====="
  sshpass -p111111  ssh-copy-id  -i  /root/.ssh/id_dsa.pub "-o StrictHostkeyChecking=no" root@$ip
  if [ $? -eq 0 ]
    then
      Echo_Green "##########################################################"
      Echo_Green "#...........$ip pub-key push end................#"
      Echo_Green "##########################################################"
  fi
done
}
FenFa
yum install -y pssh
pscp.pssh -h iplist.txt  -r ../oneinstall /root/
Echo_Blue "************************************************************ "
Echo_Blue "******************start pssh youhua ......****************** "
Echo_Blue "************************************************************ "
pssh -t 200 -v -h iplist.txt -i  "sh /root/oneinstall/youhua.sh"
Echo_Blue "************************************************************ "
Echo_Blue "******************start pssh install......****************** "
Echo_Blue "************************************************************ "
pssh -t 200 -v -h iplist.txt -i  "cd /root/oneinstall && ./install.sh"


