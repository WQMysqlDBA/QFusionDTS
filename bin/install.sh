#!/bin/bash


##color
green="\033[32m"
yello="\033[33m"
bule="\033[34m"
default="\033[0m"

function check_cmd(){
    cmd=$1
    which $cmd >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "[info] : no $cmd in system"
        cp ../package/$cmd /usr/bin
        chmod +x /usr/bin/$cmd
        which $cmd >/dev/null 2>&1 
        if [ $? -eq 0 ];then
            echo -e "$green[info] :$default init $cmd success ......"
        fi
    else
        $cmd -V >/dev/null 2>&1
        version=$($cmd -V|awk '{print $2}'|awk -F ',' '{print $1}')
        if [ $version != "0.10.1" ];then
            mv $cmd /usr/bin/cmd_bak
            cp ../package/$cmd /usr/bin
            chmod +x /usr/bin/$cmd
            echo -e "$green[info] :$default init $cmd success ......"
        else
            $cmd -V 
            echo "无需安装"
        fi
    fi
}


check_cmd mydumper

check_cmd myloader
