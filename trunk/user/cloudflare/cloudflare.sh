#!/bin/bash
#copyright by hiboy
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
scriptfilepath=$(cd "$(dirname "$0")"; pwd)/$(basename $0)
cloudflare_enable=`nvram get cloudflare_enable`
[ -z $cloudflare_enable ] && cloudflare_enable=0 && nvram set cloudflare_enable=0
if [ "$cloudflare_enable" != "0" ] ; then

cloudflare_token=`nvram get cloudflare_token`
cloudflare_Email=`nvram get cloudflare_Email`
cloudflare_Key=`nvram get cloudflare_Key`
cloudflare_domian=`nvram get cloudflare_domian`
cloudflare_host=`nvram get cloudflare_host`
cloudflare_domian2=`nvram get cloudflare_domian2`
cloudflare_host2=`nvram get cloudflare_host2`
cloudflare_domian6=`nvram get cloudflare_domian6`
cloudflare_host6=`nvram get cloudflare_host6`
cloudflare_interval=`nvram get cloudflare_interval`

if [ ! -z "$cloudflare_token" ] ; then
account_key_1="Authorization: Bearer $cloudflare_token"
account_key_2="-s" # 预留位置，传入可用参数
account_key_a1=" -H "
account_key_a2="-s"
fi
if [ -z "$cloudflare_token" ] && [ ! -z "$cloudflare_Email" ] && [ ! -z "$cloudflare_Key" ] ; then
account_key_1="X-Auth-Email: $cloudflare_Email"
account_key_2="X-Auth-Key: $cloudflare_Key"
account_key_a1=" -H "
account_key_a2=" -H "
fi


if [ "$cloudflare_domian"x != "x" ] && [ "$cloudflare_host"x = "x" ] ; then
	cloudflare_host="www"
	nvram set cloudflare_host="www"
fi
if [ "$cloudflare_domian2"x != "x" ] && [ "$cloudflare_host2"x = "x" ] ; then
	cloudflare_host2="www"
	nvram set cloudflare_host2="www"
fi
if [ "$cloudflare_domian6"x != "x" ] && [ "$cloudflare_host6"x = "x" ] ; then
	cloudflare_host6="www"
	nvram set cloudflare_host6="www"
fi

IPv6=0
domain_type=""
hostIP=""
Zone_ID=""
DOMAIN=""
HOST=""
[ -z $cloudflare_interval ] && cloudflare_interval=600 && nvram set cloudflare_interval=$cloudflare_interval
cloudflare_renum=`nvram get cloudflare_renum`

fi



cloudflare_restart () {

relock="/var/lock/cloudflare_restart.lock"
if [ "$1" = "o" ] ; then
	nvram set cloudflare_renum="0"
	[ -f $relock ] && rm -f $relock
	return 0
fi
if [ "$1" = "x" ] ; then
	if [ -f $relock ] ; then
		logger -t "【cloudflare】" "多次尝试启动失败，等待【"`cat $relock`"分钟】后自动尝试重新启动"
		exit 0
	fi
	cloudflare_renum=${cloudflare_renum:-"0"}
	cloudflare_renum=`expr $cloudflare_renum + 1`
	nvram set cloudflare_renum="$cloudflare_renum"
	if [ "$cloudflare_renum" -gt "3" ] ; then
		I=19
		echo $I > $relock
		logger -t "【cloudflare】" "多次尝试启动失败，等待【"`cat $relock`"分钟】后自动尝试重新启动"
		while [ $I -gt 0 ]; do
			I=$(($I - 1))
			echo $I > $relock
			sleep 60
			[ "$(nvram get cloudflare_renum)" = "0" ] && exit 0
			[ $I -lt 0 ] && break
		done
		nvram set cloudflare_renum="1"
	fi
	[ -f $relock ] && rm -f $relock
fi
nvram set cloudflare_status=0
eval "$scriptfilepath &"
exit 0
}

cloudflare_get_status () {

A_restart=`nvram get cloudflare_status`
B_restart="$cloudflare_enable$cloudflare_token$cloudflare_Email$cloudflare_Key$cloudflare_domian$cloudflare_host$cloudflare_domian2$cloudflare_host2$cloudflare_domian6$cloudflare_host6$cloudflare_interval$(cat /etc/storage/ddns_script.sh | grep -v '^#' | grep -v '^$')"
B_restart=`echo -n "$B_restart" | md5sum | sed s/[[:space:]]//g | sed s/-//g`
if [ "$A_restart" != "$B_restart" ] ; then
	nvram set cloudflare_status=$B_restart
	needed_restart=1
else
	needed_restart=0
fi
}

cloudflare_check () {

cloudflare_get_status
if [ "$cloudflare_enable" != "1" ] && [ "$needed_restart" = "1" ] ; then
	[ ! -z "$(ps -w | grep "$scriptname keep" | grep -v grep )" ] && logger -t "【cloudflare动态域名】" "停止 cloudflare" && cloudflare_close
	{ kill_ps "$scriptname" exit0; exit 0; }
fi
if [ "$cloudflare_enable" = "1" ] ; then
	if [ "$needed_restart" = "1" ] ; then
		cloudflare_close
		sleep 1
		eval "$scriptfilepath keep &"
		exit 0
	else
		[ -z "$(ps -w | grep "$scriptname keep" | grep -v grep )" ] || [ ! -s "`which curl`" ] && cloudflare_restart
	fi
fi
}

cloudflare_keep () {
cloudflare_start
logger -t "【cloudflare动态域名】" "守护进程启动"
cat >> "/tmp/script/_opt_script_check" <<-OSC
[ -z "\`pidof cloudflare.sh\`" ] && logger -t "【cloudflare】" "重新启动" && eval "$scriptfilepath &" && sed -Ei '/【cloudflare】|^$/d' /tmp/script/_opt_script_check # 【cloudflare】
OSC
while true; do
sleep 43
sleep $cloudflare_interval
[ ! -s "`which curl`" ] && cloudflare_restart
cloudflare_enable=`nvram get cloudflare_enable`
[ "$cloudflare_enable" = "0" ] && cloudflare_close && exit 0;
if [ "$cloudflare_enable" = "1" ] ; then
	cloudflare_start
fi
done
}

kill_ps () {

COMMAND="$1"
if [ ! -z "$COMMAND" ] ; then
	eval $(ps -w | grep "$COMMAND" | grep -v $$ | grep -v grep | awk '{print "kill "$1";";}')
	eval $(ps -w | grep "$COMMAND" | grep -v $$ | grep -v grep | awk '{print "kill -9 "$1";";}')
fi
if [ "$2" == "exit0" ] ; then
	exit 0
fi
}

cloudflare_close () {
sed -Ei '/【cloudflare】|^$/d' /tmp/script/_opt_script_check
kill_ps "$scriptname keep"
kill_ps "/tmp/script/_cloudflare"
kill_ps "_cloudflare.sh"
kill_ps "$scriptname"
logger -t "【cloudflare动态域名】" "已停止运行"
}

cloudflare_start () {
IPv6=0
if [ "$cloudflare_domian"x != "x" ] && [ "$cloudflare_host"x != "x" ] ; then
	DOMAIN="$cloudflare_domian"
	HOST="$cloudflare_host"
	RECORD_ID=""
	arDdnsCheck
fi
if [ "$cloudflare_domian2"x != "x" ] && [ "$cloudflare_host2"x != "x" ] ; then
	sleep 1
	DOMAIN="$cloudflare_domian2"
	HOST="$cloudflare_host2"
	RECORD_ID=""
	arDdnsCheck
fi
if [ "$cloudflare_domian6"x != "x" ] && [ "$cloudflare_host6"x != "x" ] ; then
	sleep 1
	IPv6=1
	DOMAIN="$cloudflare_domian6"
	HOST="$cloudflare_host6"
	RECORD_ID=""
	arDdnsCheck
fi

}

Zone_ID=""
get_Zone_ID() {
# 获得Zone_ID
Zone_ID=$(curl -Lk -s -X GET "https://api.cloudflare.com/client/v4/zones" \
     -H "Content-Type: application/json" \
     $account_key_a1 "$account_key_1" \
     $account_key_a2 "$account_key_2")
Zone_ID=$(echo $Zone_ID| sed -e "s/ //g" |grep -o "id\":\"[0-9a-z]*\",\"name\":\"$DOMAIN\",\"status\""|grep -o "id\":\"[0-9a-z]*\""| awk -F : '{print $2}'|grep -o "[a-z0-9]*")
sleep 1

}

arDdnsInfo() {
if [ "$IPv6" = "1" ]; then
	domain_type="AAAA"
else
	domain_type="A"
fi

case  $HOST  in
	  \*)
		host_domian="\\$HOST.$DOMAIN"
		;;
	  \@)
		host_domian="$DOMAIN"
		;;
	  *)
		host_domian="$HOST.$DOMAIN"
		;;
esac

# 获得Zone_ID
get_Zone_ID
# 获得最后更新IP
recordIP=$(curl -Lk -s -X GET "https://api.cloudflare.com/client/v4/zones/$Zone_ID/dns_records?type=$domain_type&match=all" \
     -H "Content-Type: application/json" \
     $account_key_a1 "$account_key_1" \
     $account_key_a2 "$account_key_2")
sleep 1
RECORD_ID=$(echo $recordIP | sed -e "s/ //g" | sed -e "s/"'"ttl":'"/"' \n '"/g" | grep "type\":\"$domain_type\"" | grep ",\"name\":\"$host_domian\"" | grep -o "\"id\":\"[0-9a-z]\{32,\}\",\"" | awk -F : '{print $2}'|grep -o "[a-z0-9]*")
recordIP=$(echo $recordIP | sed -e "s/ //g" | sed -e "s/"'"ttl":'"/"' \n '"/g" | grep "type\":\"$domain_type\"" | grep ",\"name\":\"$host_domian\"" | grep -o ",\"content\":\"[^\"]*\"" | awk -F 'content":"' '{print $2}' | tr -d '"' |head -n1)
# 检查是否有名称重复的子域名
if [ "$(echo "$RECORD_ID" | grep -o "[0-9a-z]\{32,\}"| wc -l)" -gt "1" ] ; then
	logger -t "【cloudflare动态域名】" "$HOST.$DOMAIN 获得最后更新IP时发现重复的子域名！"
	for Delete_RECORD_ID in $RECORD_ID
	do
	logger -t "【cloudflare动态域名】" "$HOST.$DOMAIN 删除名称重复的子域名！ID: $Delete_RECORD_ID"
	RESULT=$(curl -Lk -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$Zone_ID/dns_records/$Delete_RECORD_ID" \
     -H "Content-Type: application/json"\
     $account_key_a1 "$account_key_1" \
     $account_key_a2 "$account_key_2" )
	sleep 1
	done
	recordIP="0"
	echo $recordIP
	return 0
fi
	if [ "$IPv6" = "1" ]; then
	echo $recordIP
	return 0
	else
	case "$recordIP" in 
	[1-9]*)
		echo $recordIP
		return 0
		;;
	*)
		echo "Get Record Info Failed!"
		#logger -t "【cloudflare动态域名】" "获取记录信息失败！"
		return 1
		;;
	esac
	fi

}

# 更新记录信息
# 参数: 主域名 子域名
arDdnsUpdate() {
I=3
RECORD_ID=""
if [ "$IPv6" = "1" ]; then
	domain_type="AAAA"
else
	domain_type="A"
fi

case  $HOST  in
	  \*)
		host_domian="\\$HOST.$DOMAIN"
		;;
	  \@)
		host_domian="$DOMAIN"
		;;
	  *)
		host_domian="$HOST.$DOMAIN"
		;;
esac

while [ -z "$RECORD_ID" ] ; do
	I=$(($I - 1))
	[ $I -lt 0 ] && break
# 获得Zone_ID
get_Zone_ID
# 获得记录ID
RECORD_ID=$(curl -Lk -s -X GET "https://api.cloudflare.com/client/v4/zones/$Zone_ID/dns_records?type=$domain_type&match=all" \
     -H "Content-Type: application/json" \
     $account_key_a1 "$account_key_1" \
     $account_key_a2 "$account_key_2")
sleep 1
RECORD_ID=$(echo $RECORD_ID | sed -e "s/ //g" | sed -e "s/"'"ttl":'"/"' \n '"/g" | grep "type\":\"$domain_type\"" | grep ",\"name\":\"$host_domian\"" | grep -o "\"id\":\"[0-9a-z]\{32,\}\",\"" | awk -F : '{print $2}'|grep -o "[a-z0-9]*")
# 检查是否有名称重复的子域名
if [ "$(echo "$RECORD_ID" | grep -o "[0-9a-z]\{32,\}"| wc -l)" -gt "1" ] ; then
	logger -t "【cloudflare动态域名】" "$HOST.$DOMAIN 更新记录信息时发现重复的子域名！"
	for Delete_RECORD_ID in $RECORD_ID
	do
	logger -t "【cloudflare动态域名】" "$HOST.$DOMAIN 删除名称重复的子域名！ID: $Delete_RECORD_ID"
	RESULT=$(curl -Lk -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$Zone_ID/dns_records/$Delete_RECORD_ID" \
     -H "Content-Type: application/json" \
     $account_key_a1 "$account_key_1" \
     $account_key_a2 "$account_key_2")
	sleep 1
	done
	RECORD_ID=""
fi
#echo "RECORD ID: $RECORD_ID"
sleep 1
done
if [ -z "$RECORD_ID" ] ; then
	# 添加子域名记录IP
	RESULT=$(curl -Lk -s -X POST "https://api.cloudflare.com/client/v4/zones/$Zone_ID/dns_records" \
     -H "Content-Type: application/json" \
     $account_key_a1 "$account_key_1" \
     $account_key_a2 "$account_key_2" \
     --data '{"type":"'$domain_type'","name":"'$HOST'","content":"'$hostIP'","ttl":120,"proxied":false}')
	sleep 1
	RESULT=$(echo $RESULT | sed -e "s/ //g" | grep -o "success\":[a-z]*,"|awk -F : '{print $2}'|grep -o "[a-z]*")
	echo "创建dns_records: $RESULT"
else
	# 更新记录IP
	RESULT=$(curl -Lk -s -X PUT "https://api.cloudflare.com/client/v4/zones/$Zone_ID/dns_records/$RECORD_ID" \
     -H "Content-Type: application/json" \
     $account_key_a1 "$account_key_1" \
     $account_key_a2 "$account_key_2" \
     --data '{"type":"'$domain_type'","name":"'$HOST'","content":"'$hostIP'","ttl":120,"proxied":false}')
	sleep 1
	RESULT=$(echo $RESULT | sed -e "s/ //g" | grep -o "success\":[a-z]*,"|awk -F : '{print $2}'|grep -o "[a-z]*")
	echo "更新dns_records: $RESULT"
fi
if [ "$(printf "%s" "$RESULT"|grep -c -o "true")" = 1 ];then
	echo "$(date) -- Update success"
	return 0
else
	echo "$(date) -- Update failed"
	return 1
fi

}

# 动态检查更新
# 参数: 主域名 子域名
arDdnsCheck() {
	#local postRS
	#local lastIP
	source /etc/storage/ddns_script.sh
	hostIP=$arIpAddress
	hostIP=`echo $hostIP | head -n1 | cut -d' ' -f1`
	if [ -z $(echo "$hostIP" | grep : | grep -v "\.") ] && [ "$IPv6" = "1" ] ; then 
		IPv6=0
		logger -t "【cloudflare动态域名】" "错误！$hostIP 获取目前 IPv6 失败，请在脚本更换其他获取地址，保证取得IPv6地址(例如:ff03:0:0:0:0:0:0:c1)"
		return 1
	fi
	if [ "$hostIP"x = "x"  ] ; then
		curltest=`which curl`
		if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
			[ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
			[ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "ip.3322.net" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
			[ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "http://myip.ipip.net" | grep "当前 IP" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
			[ "$hostIP"x = "x"  ] && hostIP=`wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "http://ddns.oray.com/checkip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
		else
			[ "$hostIP"x = "x"  ] && hostIP=`curl -Lk --user-agent "$user_agent" -s "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
			[ "$hostIP"x = "x"  ] && hostIP=`curl -L --user-agent "$user_agent" -s ip.3322.net | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
			[ "$hostIP"x = "x"  ] && hostIP=`curl -Lk --user-agent "$user_agent" -s "http://myip.ipip.net" | grep "当前 IP" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
			[ "$hostIP"x = "x"  ] && hostIP=`curl -L --user-agent "$user_agent" -s http://ddns.oray.com/checkip | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
		fi
		if [ "$hostIP"x = "x"  ] ; then
			logger -t "【cloudflare动态域名】" "错误！获取目前 IP 失败，请在脚本更换其他获取地址"
			return 1
		fi
	fi
	echo "Updating Domain: $HOST.$DOMAIN"
	echo "hostIP: $hostIP"
	lastIP=$(arDdnsInfo)
	if [ $? -eq 1 ]; then
		[ "$IPv6" != "1" ] && lastIP=$(arNslookup "$HOST.$DOMAIN")
		[ "$IPv6" = "1" ] && lastIP=$(arNslookup6 "$HOST.$DOMAIN")
	fi
	echo "lastIP: $lastIP"
	if [ "$lastIP" != "$hostIP" ] ; then
		logger -t "【cloudflare动态域名】" "开始更新 "$HOST.$DOMAIN" 域名 IP 指向"
		logger -t "【cloudflare动态域名】" "目前 IP: $hostIP"
		logger -t "【cloudflare动态域名】" "上次 IP: $lastIP"
		sleep 1
		postRS=$(arDdnsUpdate)
		if [ $? -eq 0 ]; then
			echo "postRS: $postRS"
			logger -t "【cloudflare动态域名】" "更新动态DNS记录成功！"
			return 0
		else
			echo $postRS
			logger -t "【cloudflare动态域名】" "更新动态DNS记录失败！请检查您的网络。"
			if [ "$IPv6" = "1" ] ; then 
				IPv6=0
				logger -t "【cloudflare动态域名】" "错误！$hostIP 获取目前 IPv6 失败，请在脚本更换其他获取地址，保证取得IPv6地址(例如:ff03:0:0:0:0:0:0:c1)"
				return 1
			fi
			return 1
		fi
	fi
	echo $lastIP
	echo "Last IP is the same as current IP!"
	return 1
}

initconfig () {

if [ ! -s "/etc/storage/ddns_script.sh" ] ; then
cat > "/etc/storage/ddns_script.sh" <<-\EEE
# 自行测试哪个代码能获取正确的IP，删除前面的#可生效
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
arIpAddress () {
# IPv4地址获取
# 获得外网地址
curltest=`which curl`
if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
    #wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "https://1.0.0.2/cdn-cgi/trace" | awk -F= '/ip/{print $2}'
    #wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "http://myip.ipip.net" | grep "当前 IP" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
    wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
    #wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "ip.3322.net" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
    #wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "http://ddns.oray.com/checkip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
else
    #curl -L --user-agent "$user_agent" -s "https://1.0.0.2/cdn-cgi/trace" | awk -F= '/ip/{print $2}'
    #curl -L --user-agent "$user_agent" -s "http://myip.ipip.net" | grep "当前 IP" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
    curl -L --user-agent "$user_agent" -s "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
    #curl -L --user-agent "$user_agent" -s ip.3322.net | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
    #curl -L --user-agent "$user_agent" -s http://ddns.oray.com/checkip | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
fi
}
arIpAddress6 () {
# IPv6地址获取
# 因为一般ipv6没有nat ipv6的获得可以本机获得
ifconfig $(nvram get wan0_ifname_t) | awk '/Global/{print $3}' | awk -F/ '{print $1}'
#curl -6 -L --user-agent "$user_agent" -s "https://[2606:4700:4700::1002]/cdn-cgi/trace" | awk -F= '/ip/{print $2}'
}

if [ "$IPv6" = "1" ] ; then
arIpAddress=$(arIpAddress6)
else
arIpAddress=$(arIpAddress)
fi


EEE
	chmod 755 "$ddns_script"
fi

}

initconfig

case $1 in
start)
	cloudflare_close
	cloudflare_check
	;;
check)
	cloudflare_check
	;;
stop)
	cloudflare_close
	;;
keep)
	cloudflare_keep
	;;
*)
	cloudflare_check
	;;
esac

