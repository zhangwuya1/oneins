#!/bin/sh
#author by supu
#date 20190823-21.25
#version：0.1
#description:这是一个初始化的优化脚本包括：
#1.yum源替换aliyun
#2.时间同步
#3.关闭selinux
#4.关闭防火墙
#5.创建常用目录
#6.修改主机名

#=================================color======================================#
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

#============================repo source===================================#
Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
    else
        Is_64bit='n'
    fi
}
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux" /etc/issue || grep -Eq "Red Hat Enterprise Linux" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eq "Amazon Linux" /etc/*-release; then
        DISTRO='Amazon'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release; then
        DISTRO='Mint'
        PM='apt'
    elif grep -Eqi "Kali" /etc/issue || grep -Eq "Kali" /etc/*-release; then
        DISTRO='Kali'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_RHEL_Version()
{
    Get_Dist_Name
    if [ "${DISTRO}" = "CentOS" ]; then
        if grep -Eqi "release 5." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 5"
            RHEL_Ver='5'
        elif grep -Eqi "release 6." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 6"
            RHEL_Ver='6'
        elif grep -Eqi "release 7." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 7"
            RHEL_Ver='7'
        elif grep -Eqi "release 8." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 8"
            RHEL_Ver='8'
        fi
    fi
}
RHEL_Modify_Source()
{
    Get_RHEL_Version
    if [ "${RHELRepo}" = "local" ]; then
        echo "DO NOT change RHEL repository, use the repository you set."
    else
        echo "RHEL will use ali centos repository..."
#        \cp ${cur_dir}/conf/CentOS-Base-163.repo /etc/yum.repos.d/CentOS-Base-163.repo
#        sed -i "s/\$releasever/${RHEL_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
#        sed -i "s/RPM-GPG-KEY-CentOS-6/RPM-GPG-KEY-CentOS-${RHEL_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
	echo ${RHEL_Ver}
	wget -O /etc/yum.repos.d/CentOS-base.repo http://mirrors.aliyun.com/repo/Centos-${RHEL_Ver}.repo
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-${RHEL_Ver}.repo
        yum clean all
        yum makecache
    fi
}
#=============================================end repo==========================================================#
#=============================================time ntp==========================================================#

Set_Timezone()
{
    Echo_Blue "Setting timezone..."
    rm -rf /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

CentOS_InstallNTP()
{
    Echo_Blue "[+] Installing ntp..."
    yum install -y ntpdate
    ntpdate cn.pool.ntp.org
}

#============================================disable selinux====================================================#
Disable_Selinux()
{
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}

#==================================================end===========================================================#

StopFirewall()
{
    systemctl stop firewalld
    systemctl disable firewalld

}

Create_Directory()
{
mkdir /tools /application /scripts
} 

Set_HostName()
{
    HostIp=`ip add|grep 'eno'|grep 'inet'|awk '{print $2}'|sed 's#\/24##g'`
    HostName=`cat /root/oneinstall/hostnamelist.txt|grep $HostIp |awk '{print $2}'`
    hostnamectl --static set-hostname $HostName
}
#==================================================end===========================================================#
#1.soft yum install
Echo_Blue "#======================================================1.安装工具软件、调整yum源===============================================================#"
yum install -y vim wget ntpdate lrzsz net-tools lsof screen >/dev/null 2>&1
RHEL_Modify_Source

#2.time ntp
Echo_Blue "#==================================================2.ntp 时间同步 ===========================================================#"
#Set_Timezone
CentOS_InstallNTP

#3.disable selinux
Echo_Blue "#===============================================3.disable selinux =======================================================#"
Disable_Selinux

#4.stop firewall
Echo_Blue "#================================================4.stop firewall ======================================================#"
StopFirewall

#5.create a standard directory
Echo_Blue "#=============================================5.create directory ====================================================#"
Create_Directory

#6.rename hostname
Echo_Blue "#==============================================6.修改主机名 =======================================================#"
Set_HostName
sleep 1
Echo_Blue "###################################################################################################################"
Echo_Blue "#...........................................youhua finished.......................................................#"
Echo_Blue "###################################################################################################################"

