#!/bin/bash

CONNECT_INFO="./CONNECT_INFO"

function connect_info(){
    SrcHost=$(cat $CONNECT_INFO |grep -v ^#|grep -w info |grep SrcHost|awk '{print $3}')
    SrcPort=$(cat $CONNECT_INFO |grep -v ^#|grep -w info |grep SrcPort|awk '{print $3}')
    SrcUser=$(cat $CONNECT_INFO |grep -v ^#|grep -w info |grep SrcUser|awk '{print $3}')
    SrcPassword=$(cat $CONNECT_INFO |grep -v ^#|grep -w info |grep SrcPassword|awk '{print $3}')

    DstHost=$(cat $CONNECT_INFO |grep -v ^#|grep -w info |grep DstHost|awk '{print $3}')
    DstPort=$(cat $CONNECT_INFO |grep -v ^#|grep -w info |grep DstPort|awk '{print $3}')
    DstUser=$(cat $CONNECT_INFO |grep -v ^#|grep -w info |grep DstUser|awk '{print $3}')
    DstPassword=$(cat $CONNECT_INFO |grep -v ^#|grep -w info |grep DstPassword|awk '{print $3}')


    echo -e "填写的配置信息如下: \n[上游数据库]\n上游库host: $SrcHost \n上游库Port: $SrcPort \n上游库连接用户: $SrcUser \n上游库密码: $SrcPassword \n\n[下游库]\n下游库host: $DstHost \n下游库Port: $DstPort \n下游库User: $DstUser \n下游库密码: $DstPassword"
    src_conn="mysql -h$SrcHost -u$SrcUser -p$SrcPassword -P$SrcPort"
    dst_conn="mysql -h$DstHost -u$DstUser -p$DstPassword -P$DstPort"

}

function count(){
    for i in `cat ../srcdb_info/db_info |grep InnoDB|grep "[0-9]\."|awk '{print $1 "." $2}'|head -n 10 | tail -n +5`
    do
        echo $i
        a1=`$src_conn 2>/dev/null -e "select count(*) from $i"|grep -v count`
        a2=`$dst_conn 2>/dev/null -e "select count(*) from $i"|grep -v count`
        echo "src table rows count is: $a1" 
        echo "dst table rows count is: $a2"
        echo -e "\n\n"

        if [[ $a1 -ne $a2 ]]; then
            echo "数据不一致"
            exit 0
        fi
    done
}

connect_info
count