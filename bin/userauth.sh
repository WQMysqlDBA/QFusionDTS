#!/bin/bash

ARGS=`getopt -a -o  h:u:p:P:r:  --long  host:,user:,passwd:,port:,role:,help  -n $0 -- "$@"` 

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


mysql_conn="mysql -u$username -p$passwd -h$host -P$port"
$mysql_conn -e "select 1">/dev/null 2>&1
if [ $? -ne 0 ];then
    echo "[Error]: ......数据库链接失败"
    exit 0
else
    echo "[Info]: ......数据库连接成功"
fi

# cat ../srcdb_info/user_file|while read line
# do
#     #echo $line
#     #$mysql_conn -e  "$line"
#     #这里过滤掉qfusion的默认用户
#     # +------------------+-----------+
#     # | user             | host      |
#     # +------------------+-----------+
#     # | qfsys            | %         |
#     # | repl             | %         |
#     # | root             | %         |
#     # | heartbeat        | localhost |
#     # | mysql.infoschema | localhost |
#     # | mysql.session    | localhost |
#     # | mysql.sys        | localhost |
#     # | root             | localhost |
#     # +------------------+-----------+
#     #这里最好通过队列实现
#     for i in \'qfsys\'@\'%\' \'repl\'@\'%\' \'root\'@\'%\'   \'heartbeat\'@\'localhost\' \'mysql.infoschema\'@\'localhost\' \'mysql.session\'@\'localhost\' \'mysql.sys\'@\'localhost\' \'root\'@\'localhost\'
#     do
#         names=$line
#         if [[ "${names[@]}"  =~ "$i" ]]; then
#             echo "[Warning]: 用户 ${i} 已经在qfusion中存在，忽略复制此用户"
            
#         else
#             echo "[Info]:创建复制用户 ${i}"
#             echo "$mysql_conn -e "$line" "
            
#         fi
        
#     done

# done




# for i in \'qfsys\'@\'%\' \'repl\'@\'%\' \'root\'@\'%\'   \'heartbeat\'@\'localhost\' \'mysql.infoschema\'@\'localhost\' \'mysql.session\'@\'localhost\' \'mysql.sys\'@\'localhost\' \'root\'@\'localhost\'
# do
#     sed -i "/${i}/d"  ../srcdb_info/user_file
#     sed -i "/${i}/d"  ../srcdb_info/privilege_file
# done



$mysql_conn <../srcdb_info/user_file
if [  $? -eq 0 ];then
    echo "创建用户和授权成功，登陆目标库验证"
else
    echo "创建用户和授权失败或者部分失败，登陆目标库验证"
fi

# $mysql_conn <../srcdb_info/privilege_file
# if [  $? -eq 0 ];then
#     echo "创建用户和授权成功，登陆目标库验证"
# else
#     echo "创建用户和授权失败或者部分失败，登陆目标库验证"
# fi


cat ../srcdb_info/privilege_file |while read line
do
    $mysql_conn -e "$line"
    if [  $? -eq 0 ];then
        echo "执行$line授权成功，登陆目标库验证"
    else
        echo "执行$line授权失败，登陆目标库验证"
fi
done




