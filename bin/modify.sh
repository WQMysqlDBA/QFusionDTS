#!/bin/bash

backupdatadir="../backup"

ARGS=`getopt -a -o  h:u:p:P:  --long  host:,user:,passwd:,port:,help  -n $0 -- "$@"` 

eval set -- "${ARGS}" 


while true  
do  
        case "$1" in 
        -h|--host)
                host="$2"
                shift
                ;;
        -u|--user)  
                username="$2" 
                shift  
                ;;
        -p|--passwd)  
                passwd="$2" 
                shift
                ;;
        -P|--port)
                port="$2"
                shift
                ;;
        --help)
                echo -e "bash $0 \n -h|--host [ip/hostname] \n -u|--user [username] \n -p|--passwd [password] \n -P|--port [PORT]"
                shift
                ;;
        --)  
                shift
                break 
                ;;
        *)
                #echo "Internal error!"
                #echo "bash $0 --help"
                exit 1
                ;;
        esac  
shift
done 
# if not exist user passwd port
if [ -z $host ];then
    host="localhost"
fi
if [ -z $passwd ];then
    username=""
fi
if [ -z $passwd ];then
    passwd=""
fi
if [ -z $port ];then
    port="3306"
fi
#echo -e "## 数据库连接信息: \n"
#echo -e "username: $username \npassword: $passwd \nhost: $host \nport: $port"
##数据库链接
mysql_conn="mysql  -u$username -p$passwd -h$host -P$port  "
$mysql_conn -e "\s">/dev/null 2>&1
if [ $? -ne 0 ];then
    echo "[Error]: ......数据库链接失败"
    exit 0
fi




#db=$($mysql_conn -e "show databases;" |grep -Ev "Database|mysql|performance_schema|sys|information_schema"|xargs)
db=$(cat SrcdbName)
foreign_key_checks=$(${mysql_conn} 2>/dev/null  -e "show variables like 'foreign_key_checks'"|grep -v Variable_name |awk '{print $2}')
echo "foreign_key_checks: $foreign_key_checks"
for i in $db
do
    echo "# 数据库${i}文件"
    echo "## 创建数据库语句"
    ls ${backupdatadir} | grep "${i}-schema-create.sql" >>/dev/null


    for j1 in $(ls ${backupdatadir} | grep "${i}-schema-create.sql")
    do    
        ${mysql_conn} 2>/dev/null <${backupdatadir}/${j1}
        if [ $? -eq 0 ];then
            echo -e "\033[33m测试创建库${i}\033[0m成功">>/dev/null
        else
            echo -e "\033[33m测试创建库${i}\033[0m失败"
        fi
    done

    echo "## 表结构文件"
    ls ${backupdatadir} | grep "${i}\."|grep "schema.sql" >>/dev/null
    for j in $(ls ${backupdatadir} | grep "${i}\."|grep "schema.sql")
    #echo -e "\033[33m导入测试创建表\033[0m" 
    do
        #change table structure to InnoDB
        sed -i -e "s/MyISAM/InnoDB/g" -e "s/MEMORY/InnoDB/g"  -e "s/ROW_FORMAT=FIXED//g" ${backupdatadir}/$j #&& echo "修改${i}.${j}"元数据信息成功 
        ## 检查外键是否过滤
        ${mysql_conn} 2>/dev/null -e "set global foreign_key_checks=0"
        ${mysql_conn} 2>/dev/null -D ${i} <${backupdatadir}/${j}
        if [ $? -eq 0 ];then
            echo -e "\033[33m表文件${j}写入成功\033[0m" >>/dev/null
        else
            echo -e "\033[33m表文件${j}写入失败\033[0m,创建表不通过，请验证！！！"
            ${mysql_conn} 2&>1 /dev/null -e"set global foreign_key_checks=$foreign_key_checks"
            exit 0
        fi
    done
    echo -e "\n\n"
    sleep 1
done

${mysql_conn} 2>/dev/null -e"set global foreign_key_checks=$foreign_key_checks"
