#!/bin/bash
#分批次导出数据库的建库建表语句，produce  event function trigger 用户 权限
##用户使用sql相关的参数 如sql_mode event_scheduler
##分析
  ###定向分析表的数据量
  ###定向分析系统配置生成mydumper的配置文件

##color

green="\033[32m"
yello="\033[33m"
bule="\033[34m"
default="\033[0m"

if [ ! -d "../srcdb_info" ]; then
  mkdir ../srcdb_info
fi
if [ ! -d "../dstdb_info" ]; then
  mkdir ../dstdb_info
fi


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
        -r|--role)
                role="$2"
                shift
                ;;
        --help)
                echo -e "bash $0 \n -h|--host [ip/hostname] \n -u|--user [username] \n -p|--passwd [password] \n -P|--port [PORT] \n -r|--role [src/dst]"
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

if [ "$role" == "src" ];then
    role_flag=srcdb_info
elif [ "$role" == "dst" ];then
    role_flag=dstdb_info
fi

db_info="../$role_flag/db_info"
view_info="../$role_flag/view_info"
proc_info="../$role_flag/proc_info"
func_info="../$role_flag/func_info"
event_info="../$role_flag/event_info"
trigger_info="../$role_flag/trigger_info"
user_file="../$role_flag/user_file"
privilege_file="../$role_flag/privilege_file"


echo -e "## 数据库连接信息: \n"
echo -e "username: $username \npassword: $passwd \nhost: $host \nport: $port"
##数据库链接
mysql_conn="mysql -u$username -p$passwd -h$host -P$port"
$mysql_conn -e "\s">/dev/null 2>&1
if [ $? -ne 0 ];then
    echo "[Error]: ......数据库链接失败"
    exit 0
fi



#db_info="./info/db_info"


echo >$db_info
db=$($mysql_conn -e "show databases;" |grep -Ev "Database|mysql|performance_schema|sys|information_schema"|xargs)
#db=$($mysql_conn -e "show databases;" |grep -Ev "Database|sys"|xargs)
echo -e "## 非系统库包括: $db\n"
sleep 1
if [ "$role" == "src" ];then
    echo $db >SrcdbName
fi




##数据流调研 && 表存储引擎调研
for i in $db
do
    QuerySql="SELECT \
      TABLE_SCHEMA,table_name,ROUND((DATA_LENGTH+INDEX_LENGTH)/1024/1024/1024,4) G,ENGINE \
    FROM \
      information_schema.tables \
    WHERE \
      table_schema= '${i}' ORDER BY g DESC;"
    #echo "### ${i}库中表统计信息" >>$db_info
    echo $QuerySql|$mysql_conn >>$db_info
    echo -e "\n">>$db_info
done
echo -e "\033[32m ###### 数据流调研 && 表存储引擎调研 ######\033[0m" 

cat $db_info|column -t

sleep 1


##view
#view_info="./info/view_info"
echo>$view_info
#echo "## view info" >$view_info
for i in $db
do
    #ViewSql="SELECT TABLE_NAME, CHECK_OPTION, IS_UPDATABLE, SECURITY_TYPE, DEFINER FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = '${i}' ORDER BY TABLE_NAME ASC"
    ViewSql="SELECT TABLE_SCHEMA, TABLE_NAME, DEFINER FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = '${i}' ORDER BY TABLE_NAME ASC"
    #echo "### ${i}库中VIEW情况" >>$view_info
    echo $ViewSql|$mysql_conn >>$view_info
    
done
echo -e "\033[32m ###### VIEW ######\033[0m" 
cat $view_info|column -t |grep -v TABLE_NAME

sleep 1


## proc && function
# proc_info="./info/proc_info"
# func_info="./info/func_info"
echo >$proc_info
echo >$func_info
for i in $db
do
    proc_sql="SHOW PROCEDURE STATUS WHERE Db = '${i}'"
    func_sql="SHOW FUNCTION STATUS WHERE Db = '${i}'"
    #echo "### ${i}库中存储过程情况">>$proc_info
    echo $proc_sql|$mysql_conn >>$proc_info
    #echo "### ${i}库中的函数情况">>$func_info
    echo $func_sql|$mysql_conn>>$func_info
done
echo -e "\033[32m ###### PROCEDURE ######\033[0m" 
cat $proc_info|grep -v "Db"|awk '{print $1 "    " $2 "    " $4}' |column -t
echo -e "\033[32m ###### FUNCTION ######\033[0m" 
cat $func_info|grep -v "Db"|awk '{print $1 "    " $2 "    " $4}' |column -t

sleep 1




##event
# event_info="./info/event_info"
echo >$event_info
for i in $db
do
    # event_sql="SELECT EVENT_CATALOG, EVENT_SCHEMA, EVENT_NAME, DEFINER, \
    # TIME_ZONE, EVENT_DEFINITION, EVENT_BODY, EVENT_TYPE, SQL_MODE, \
    # STATUS, EXECUTE_AT, INTERVAL_VALUE, INTERVAL_FIELD, STARTS, ENDS, ON_COMPLETION, \
    # CREATED, LAST_ALTERED, LAST_EXECUTED, ORIGINATOR, \
    # CHARACTER_SET_CLIENT, COLLATION_CONNECTION, DATABASE_COLLATION, EVENT_COMMENT \
    # FROM information_schema.EVENTS \
    # WHERE EVENT_SCHEMA = '${i}' \
    # ORDER BY EVENT_NAME ASC\G"
    event_sql="SELECT EVENT_SCHEMA, EVENT_NAME, DEFINER FROM information_schema.EVENTS WHERE EVENT_SCHEMA = '${i}' ORDER BY EVENT_NAME ASC"
    echo $event_sql|$mysql_conn>>$event_info
done

echo -e "\033[32m ###### EVENT ######\033[0m"
cat $event_info|column -t |grep -v EVENT_SCHEMA

sleep 1


##trigger
# trigger_info="./info/trigger_info"
echo >$trigger_info
for i in $db
do
    trigger_sql="select TRIGGER_SCHEMA, TRIGGER_NAME, DEFINER from information_schema.TRIGGERS where TRIGGER_SCHEMA='${i}' order by TRIGGER_SCHEMA ASC;"
    echo $trigger_sql|$mysql_conn>>$trigger_info
done
echo -e "\033[32m ###### TRIGGER ######\033[0m"
cat $trigger_info|column -t|grep -v TRIGGER_SCHEMA


sleep 1


##user
echo -e "$green ###### User ###### $default"
# user_sql="select concat('create user ',\"'\",user,\"'\",'@',\"'\",host,\"'\",' identified by password ',\"'\",authentication_string,\"';\") as CREATE_USER_SQL from mysql.user;"
# cat a |grep -E 'user.*host同时含有这俩字段的行
user_sql="select concat(\"'\",user,\"'\",'@',\"'\",host,\"'\") as MYSQL_USER_INFO from mysql.user;"
cat /dev/null >$user_file
cat /dev/null >$privilege_file
DB_user=$($mysql_conn -e "$user_sql" |grep -v MYSQL_USER_INFO|grep -Ev "qfsys|root|repl|heartbeat|mysql." )
for i in $DB_user
do
$mysql_conn -e "show create user $i"|grep -v "CREATE USER for">> $user_file
$mysql_conn -e "show grants for $i"|grep -v "Grants for">>$privilege_file
done
echo "flush privileges">> $user_file
sed -i "s/$/;/g" $user_file
echo -e "$yello[Info]: $default用户文件请查看文件 $user_file"

# ##privilege
# echo -e "$green ###### Privilege ###### $default"

# get_show_grant_sql="select concat(\"'\",user,\"'\",'@',\"'\",host,\"';\")  as GRANTSFORUSER from mysql.user;"
# show_grant_sql=$($mysql_conn -e"$get_show_grant_sql"|grep -v GRANTSFORUSER)>/dev/null


# echo >$privilege_file
# for i in $show_grant_sql
# do
# $mysql_conn -e "show grants for $i\G"|grep -v "Grants for">>$privilege_file
# done
echo "flush privileges">> $privilege_file
sed -i "s/$/;/g" $privilege_file
echo -e "$yello[Info]: $default 用户权限文件请查看文件 $privilege_file"

sleep 1
## 执行备份建议
cpu_num=$(cat /proc/cpuinfo |grep processor|wc -l)
let dump_thread=$cpu_num/2
echo -e "\n\n"
if [ "$role" == "src" ];then
    echo "[SUGGEESTION FOR BACKUP]"
    echo -e "$yello[Info]: $default 1、当前实例cpu个数为$cpu_num，执行 bash dump.sh -h \$host -u\$user -p\$password -t $dump_thread 进行备份"
    echo -e "$yello[Info]: $default 2、源库统计数据信息收集完成,稍后执行以下命令往目的库写入数据。\n " #bash mycheck.sh -h [*目标库ip(别搞错了)] -u -p -P"
    echo -e "$yello[Info]: $default 非系统库包括: $db,库名称存放在 SrcdbName 文件中。"
fi



