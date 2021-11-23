#!/bin/bash
# v2ray Ubuntu系统一键安装脚本
# Author: junjian
set +x
RED="\033[31m"      # Error message
GREEN="\033[32m"    # Success message
YELLOW="\033[33m"   # Warning message
BLUE="\033[36m"     # Info message
PLAIN='\033[0m'

OS=`hostnamectl | grep -i system | cut -d: -f2`
WORK_DIR=/
DOWNLOAD_LINK=''
ARM32=https://github.com/fatedier/frp/releases/download/v0.37.1/frp_0.37.1_linux_arm.tar.gz
X86=https://github.com/fatedier/frp/releases/download/v0.37.1/frp_0.37.1_linux_386.tar.gz
X86_64=https://github.com/fatedier/frp/releases/download/v0.37.1/frp_0.37.1_linux_amd64.tar.gz
colorEcho() {
    echo -e "${1}${@:2}${PLAIN}"
}

checkSystem() {
    result=$(id | awk '{print $1}')
    if [ $result != "uid=0(root)" ]; then
        colorEcho $RED " 请以root身份执行该脚本"
        exit 1
    fi

    res=`lsb_release -d | grep -i ubuntu`
    if [ "$?" != "0" ]; then
        res=`which apt`
        if [ "$?" != "0" ]; then
           colorEcho $RED " 系统不是Ubuntu"
            exit 1
        fi
        res=`which systemctl`
         if [ "$?" != "0" ]; then
            colorEcho $RED " 系统版本过低，请重装系统到高版本后再使用本脚本！"
            exit 1
         fi
    else
        result=`lsb_release -d | grep -oE "[0-9.]+"`
        main=${result%%.*}
        if [ $main -lt 16 ]; then
            colorEcho $RED " 不受支持的Ubuntu版本"
            exit 1
        fi
    fi
    set -x
    system_a=`uname -m`
    bits=`getconf LONG_BIT`
    result=$(echo $system_a|grep "arm")

    if [[ "$result" != ""  ]];then
        if [ $bits -eq 32 ];then
            DOWNLOAD_LINK=$ARM32
        fi
    fi

    result=$(echo $system_a|grep "x86")

    if [[ "$result" != ""  ]];then
        if [ $bits -eq 64 ];then
            DOWNLOAD_LINK=$X86_64
        elif [ $bits -eq 32];then
            DOWNLOAD_LINK=$X86
        fi
    fi

    if [ -z "$DOWNLOAD_LINK" ];then
        colorEcho $RED "Unsupport arch!"
        exit 2
    fi
    set +x

}


slogon() {
    clear
    echo "#############################################################"
    echo -e "#            ${RED}Ubuntu LTS v2ray一键安装脚本${PLAIN}                #"
    echo -e "# ${GREEN}作者${PLAIN}: 网络跳越(hijk)                                      #"
    echo -e "# ${GREEN}网址${PLAIN}: https://hijk.art                                    #"
    echo -e "# ${GREEN}论坛${PLAIN}: https://hijk.club                                   #"
    echo -e "# ${GREEN}TG群${PLAIN}: https://t.me/hijkclub                               #"
    echo -e "# ${GREEN}Youtube频道${PLAIN}: https://youtube.com/channel/UCYTB--VsObzepVJtc9yvUxQ #"
    echo "#############################################################"
    echo ""
}

download_src(){

    #        mkdir ~/frp
    cd ROOT_DIR
    cd frp &>/dev/null
    if [ $? -ne 0 ];then
       mkdir frp
#       cd frp
    fi

    if [ -f frpc.tar.gz ];then
        echo "文件已存在"
    else
        wget https://github.com/fatedier/frp/releases/download/v0.37.1/frp_0.37.1_linux_amd64.tar.gz -O ./frpc.tar.gz
    fi
#        git clone https://github.com/fatedier/frp.git ~/frp --depth 1

    tar -zxf frpc.tar.gz -C ./frp
    if [ $? -ne 0 ];then
           colorEcho $RED " 解压失败 $?"
    fi

    if [ $? -eq 0 ];then
        echo ""
        colorEcho $BLUE "Download source code finished."
        echo ""
    fi
}
download_gz(){
#    set -x
    rm -rf /tmp/frp
    mkdir -p /tmp/frp
    colorEcho $PLAIN "开始下载 ${DOWNLOAD_LINK}"
    echo ""
    wget $DOWNLOAD_LINK -O /tmp/frp/frpc.tar.gz
    tar zxf /tmp/frp/frpc.tar.gz -C /tmp/frp
    rm /tmp/frp/frpc.tar.gz
    cd /tmp/frp/*
#    echo "$PWD"
    WORK_DIR=$PWD
#    echo "$WORK_DIR"
#    set +x
}
check_port() {
        if [ "${PORT:0:1}" = "0" ]; then
            echo -e " ${RED}端口不能以0开头${PLAIN}"
            exit 1
        fi
        expr $1 + 0 &>/dev/null
        if [ $? -eq 0 ]; then
            if [ $1 -ge 1 ] && [ $1 -le 65535 ]; then
               echo ""
#              colorEcho $BLUE " 端口号： $1"
               echo ""
            else
                colorEcho $RED " 输入错误，端口号为1-65535的数字"
            fi
        else
            colorEcho $RED " 输入错误，端口号为1-65535的数字"
        fi

}
getData() {
    while true
    do
#        read -p " 请输入frps<==>frps通信端口[1-65535]:" PORT
        read -p $1 PORT
        [ -z "$PORT" ] && PORT="21568"
        if [ "${PORT:0:1}" = "0" ]; then
#            echo -e " ${RED}端口不能以0开头${PLAIN}"
            exit 1
        fi
        expr $PORT + 0 &>/dev/null
        if [ $? -eq 0 ]; then
            if [ $PORT -ge 1 ] && [ $PORT -le 65535 ]; then
#                echo ""
#                colorEcho $BLUE " 端口号： $PORT"
                #                echo ""
                echo $PORT
                break
            fi

#        else
#            colorEcho $RED " 输入错误，端口号为1-65535的数字"
        fi
    done
}
preinstall() {
    colorEcho $BLUE " 更新系统..."
    apt clean all
    apt update
    apt -y upgrade
    colorEcho $BLUE " 安装必要软件"
    apt install -y telnet wget vim net-tools ntpdate unzip
    res=`which wget`
    [ "$?" != "0" ] && apt install -y wget
    res=`which netstat`
    [ "$?" != "0" ] && apt install -y net-tools
    apt autoremove -y
}


installV2ray() {
    colorEcho $BLUE " 安装v2ray..."
    bash <(curl -sL ${V6_PROXY}https://raw.githubusercontent.com/hijkpw/scripts/master/goV2.sh)

    if [ ! -f $CONFIG_FILE ]; then
        colorEcho $RED " $OS 安装V2ray失败，请到 https://hijk.art 网站反馈"
        exit 1
    fi

    sed -i -e "s/port\":.*[0-9]*,/port\": ${PORT},/" $CONFIG_FILE
    alterid=`shuf -i50-80 -n1`
    sed -i -e "s/alterId\":.*[0-9]*/alterId\": ${alterid}/" $CONFIG_FILE
    uid=`grep id $CONFIG_FILE| cut -d: -f2 | tr -d \",' '`
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    ntpdate -u time.nist.gov

    systemctl enable v2ray
    systemctl restart v2ray
    sleep 3
    res=`netstat -ntlp| grep ${PORT} | grep v2ray`
    if [ "${res}" = "" ]; then
        colorEcho $red " $OS 端口号：${PORT}，v2启动失败，请检查端口是否被占用！"
        exit 1
    fi
    colorEcho $GREEN " v2ray安装成功！"
}

setFirewall() {
    res=`ufw status | grep -i inactive`
    if [ "$res" = "" ];then
        ufw allow ${PORT}/tcp
        ufw allow ${PORT}/udp
    fi
}
install_files(){
#    set -x
    echo $WORK_DIR
    cd $WORK_DIR
    rm -rf frps*
    cp frpc /usr/bin
    if [ $? -ne 0 ];then
        colorEcho $RED "COPY to /usr/bin failed!"
        exit 1
    fi

    if [ ! -d /etc/frp ];then
        mkdir -p /etc/frp
    fi
#    touch /etc/frp/frpc.ini
    cat<<EOF >/etc/frp/frpc.ini
    [common]
        server_addr = ${IP}
        server_port = ${port1}
        token = ${KEYCODE}
    [${APPNAME}]
        type = tcp
        local_ip = 127.0.0.1
        local_port = ${port3}
        remote_port = ${port2}
EOF
    sudo cp $WORK_DIR/systemd/frpc.service /etc/systemd/system/
    sudo systemctl enable /etc/systemd/system/frpc.service
    sudo systemctl daemon-reload
    sudo systemctl start /etc/systemd/system/frpc.service
    sleep 3
    sudo systemctl restart /etc/systemd/system/frpc.service

    colorEcho $GREEN " FINISHED!"
}
install() {
    echo -n " 系统版本:  "
    lsb_release -a

    checkSystem
    download_src
    getData
    prinstall
    installBBR
    installV2ray
    setFirewall

    info
    bbrReboot
}
    echo -n " 系统版本:  "
    lsb_release -a
    sudo systemctl stop frpc.service
    checkSystem
    #    download_src
    download_gz
    read -p "请输入服务器IP:" IP

    port1=`getData "请输入frps<==>frpc通信端口:" `
    # echo $port1
    check_port $port1

    port2=`getData "请输入client<==>frpc通信端口:" `
    # echo $port2
    check_port $port2

    port3=`getData "请输入本地端口:" `
    # echo $port2
    check_port $port3

    read -p "请输入token:" KEYCODE
    echo $KEYCODE

    read -p "请输入应用名称:" APPNAME
    echo $APPNAME

    colorEcho $BLUE " 服务器IP：${IP} "
    colorEcho $BLUE " 服务器PORT：${port1} "
    colorEcho $BLUE " 连接Token：${KEYCODE} "
    colorEcho $BLUE " 应用名称：${APPNAME} "
    colorEcho $BLUE " 应用端口：${port2} "
    colorEcho $BLUE " 本地端口: ${port3}"

    install_files



uninstall() {
    read -p " 确定卸载v2ray吗？(y/n)" answer
    [ -z ${answer} ] && answer="n"

    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        systemctl stop v2ray
        systemctl disable v2ray
        rm -rf /etc/v2ray/*
        rm -rf /usr/bin/v2ray/*
        rm -rf /var/log/v2ray/*
        rm -rf /etc/systemd/system/v2ray.service
        rm -rf /etc/systemd/system/multi-user.target.wants/v2ray.service

        echo -e " ${RED}卸载成功${PLAIN}"
    fi
}
