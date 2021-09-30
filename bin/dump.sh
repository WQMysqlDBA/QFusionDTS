ARGS=`getopt -a -o  h:u:p:P:t:  --long  host:,user:,passwd:,port:,,thread:,help  -n $0 -- "$@"` 

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
        -t|--thread)
                thread="$2"
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



##数据库链接
mysql_conn="mysql -u$username -p$passwd -h$host -P$port"
$mysql_conn -e "\s">/dev/null 2>&1
if [ $? -ne 0 ];then
    echo -e "## 数据库连接信息:"
    echo -e "username: $username \npassword: $passwd \nhost: $host \nport: $port\n"
    echo "[Error]: ......数据库连接失败,请检查"
    exit 0
else
    echo "[Info]: ......数据库连接成功"
    sleep 1
fi

echo "[Info]: ......开始使用mydumper备份"
echo -e "username:   $username \npassword:   $passwd \nhost:       $host \nport:       $port\nthread:     $thread "
sleep 1

mydumper --user $username --password $passwd -h $host -P $port  --triggers --events --routines --threads $thread  --less-locking --regex '^(?!(mysql\.|information_schema\.|performance_schema\.|sys\.))'  --build-empty-files  --verbose 2 --outputdir ../backup/
#--logfile mydump_log  


