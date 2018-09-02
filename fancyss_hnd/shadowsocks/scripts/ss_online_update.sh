#!/bin/sh

# shadowsocks script for HND router with kernel 4.1.27 merlin firmware
# by sadog (sadoneli@gmail.com) from koolshare.cn

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
eval `dbus export ss`
LOCK_FILE=/tmp/online_update.lock
DEL_SUBSCRIBE=0

# ==============================
# ssconf_basic_ping_
# ssconf_basic_webtest_
# ssconf_basic_node_
# ssconf_basic_koolgame_udp_
# ssconf_basic_method_
# ssconf_basic_mode_
# ssconf_basic_name_
# ssconf_basic_password_
# ssconf_basic_port_
# ssconf_basic_rss_obfs_
# ssconf_basic_rss_obfs_param_
# ssconf_basic_rss_protocol_
# ssconf_basic_rss_protocol_param_
# ssconf_basic_server_
# ssconf_basic_ss_obfs_
# ssconf_basic_ss_obfs_host_
# ssconf_basic_use_kcp_
# ssconf_basic_use_lb_
# ssconf_basic_lbmode_
# ssconf_basic_weight_
# ssconf_basic_v2ray_use_json_
# ssconf_basic_v2ray_uuid_
# ssconf_basic_v2ray_alterid_
# ssconf_basic_v2ray_security_
# ssconf_basic_v2ray_network_
# ssconf_basic_v2ray_headtype_tcp_
# ssconf_basic_v2ray_headtype_kcp_
# ssconf_basic_v2ray_network_path_
# ssconf_basic_v2ray_network_host_
# ssconf_basic_v2ray_network_security_
# ssconf_basic_v2ray_mux_enable_
# ssconf_basic_v2ray_mux_concurrency_
# ssconf_basic_v2ray_json_
# ssconf_basic_type_
# ==============================

set_lock(){
	exec 233>"$LOCK_FILE"
	flock -n 233 || {
		echo_date "订阅脚本已经在运行，请稍候再试！"
		exit 1
	}
}

unset_lock(){
	flock -u 233
	rm -rf "$LOCK_FILE"
}

prepare(){
	# 0 检测排序
	seq_nu=`dbus list ssconf_basic_|grep _name_ | cut -d "=" -f1|cut -d "_" -f4|sort -n|wc -l`
	seq_max_nu=`dbus list ssconf_basic_|grep _name_ | cut -d "=" -f1|cut -d "_" -f4|sort -rn|head -n1`
	if [ "$seq_nu" == "$seq_max_nu" ];then
		echo_date "节点顺序正确，无需调整!"
		return 0
	fi 
	# 1 提取干净的节点配置，并重新排序
	echo_date 备份shadowsocks节点信息...
	echo_date 如果节点数量过多，此处可能需要等待较长时间，请耐心等待...
	rm -rf /tmp/ss_conf.sh
	touch /tmp/ss_conf.sh
	chmod +x /tmp/ss_conf.sh
	echo "#!/bin/sh" >> /tmp/ss_conf.sh
	valid_nus=`dbus list ssconf_basic_|grep _name_ | cut -d "=" -f1|cut -d "_" -f4|sort -n`
	q=1
	for nu in $valid_nus
	do
		[ -n "$(dbus get ssconf_basic_koolgame_udp_$nu)" ] && echo dbus set ssconf_basic_koolgame_udp_$q=$(dbus get ssconf_basic_koolgame_udp_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_method_$nu)" ] && echo dbus set ssconf_basic_method_$q=$(dbus get ssconf_basic_method_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_mode_$nu)" ] && echo dbus set ssconf_basic_mode_$q=$(dbus get ssconf_basic_mode_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_name_$nu)" ] && echo dbus set ssconf_basic_name_$q=$(dbus get ssconf_basic_name_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_password_$nu)" ] && echo dbus set ssconf_basic_password_$q=$(dbus get ssconf_basic_password_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_port_$nu)" ] && echo dbus set ssconf_basic_port_$q=$(dbus get ssconf_basic_port_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_rss_obfs_$nu)" ] && echo dbus set ssconf_basic_rss_obfs_$q=$(dbus get ssconf_basic_rss_obfs_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_rss_obfs_param_$nu)" ] && echo dbus set ssconf_basic_rss_obfs_param_$q=$(dbus get ssconf_basic_rss_obfs_param_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_rss_protocol_$nu)" ] && echo dbus set ssconf_basic_rss_protocol_$q=$(dbus get ssconf_basic_rss_protocol_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_rss_protocol_param_$nu)" ] && echo dbus set ssconf_basic_rss_protocol_param_$q=$(dbus get ssconf_basic_rss_protocol_param_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_server_$nu)" ] && echo dbus set ssconf_basic_server_$q=$(dbus get ssconf_basic_server_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_ss_obfs_$nu)" ] && echo dbus set ssconf_basic_ss_obfs_$q=$(dbus get ssconf_basic_ss_obfs_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_ss_obfs_host_$nu)" ] && echo dbus set ssconf_basic_ss_obfs_host_$q=$(dbus get ssconf_basic_ss_obfs_host_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_use_kcp_$nu)" ] && echo dbus set ssconf_basic_use_kcp_$q=$(dbus get ssconf_basic_use_kcp_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_use_lb_$nu)" ] && echo dbus set ssconf_basic_use_lb_$q=$(dbus get ssconf_basic_use_lb_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_lbmode_$nu)" ] && echo dbus set ssconf_basic_lbmode_$q=$(dbus get ssconf_basic_lbmode_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_weight_$nu)" ] && echo dbus set ssconf_basic_weight_$q=$(dbus get ssconf_basic_weight_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_group_$nu)" ] && echo dbus set ssconf_basic_group_$q=$(dbus get ssconf_basic_group_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_use_json_$nu)" ] && echo dbus set ssconf_basic_v2ray_use_json_$q=$(dbus get ssconf_basic_v2ray_use_json_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_uuid_$nu)" ] && echo dbus set ssconf_basic_v2ray_uuid_$q=$(dbus get ssconf_basic_v2ray_uuid_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_alterid_$nu)" ] && echo dbus set ssconf_basic_v2ray_alterid_$q=$(dbus get ssconf_basic_v2ray_alterid_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_security_$nu)" ] && echo dbus set ssconf_basic_v2ray_security_$q=$(dbus get ssconf_basic_v2ray_security_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_network_$nu)" ] && echo dbus set ssconf_basic_v2ray_network_$q=$(dbus get ssconf_basic_v2ray_network_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_headtype_tcp_$nu)" ] && echo dbus set ssconf_basic_v2ray_headtype_tcp_$q=$(dbus get ssconf_basic_v2ray_headtype_tcp_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_headtype_kcp_$nu)" ] && echo dbus set ssconf_basic_v2ray_headtype_kcp_$q=$(dbus get ssconf_basic_v2ray_headtype_kcp_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_network_path_$nu)" ] && echo dbus set ssconf_basic_v2ray_network_path_$q=$(dbus get ssconf_basic_v2ray_network_path_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_network_host_$nu)" ] && echo dbus set ssconf_basic_v2ray_network_host_$q=$(dbus get ssconf_basic_v2ray_network_host_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_network_security_$nu)" ] && echo dbus set ssconf_basic_v2ray_network_security_$q=$(dbus get ssconf_basic_v2ray_network_security_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_mux_enable_$nu)" ] && echo dbus set ssconf_basic_v2ray_mux_enable_$q=$(dbus get ssconf_basic_v2ray_mux_enable_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_mux_concurrency_$nu)" ] && echo dbus set ssconf_basic_v2ray_mux_concurrency_$q=$(dbus get ssconf_basic_v2ray_mux_concurrency_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_v2ray_json_$nu)" ] && echo dbus set ssconf_basic_v2ray_json_$q=$(dbus get ssconf_basic_v2ray_json_$nu) >> /tmp/ss_conf.sh
		[ -n "$(dbus get ssconf_basic_type_$nu)" ] && echo dbus set ssconf_basic_type_$q=$(dbus get ssconf_basic_type_$nu) >> /tmp/ss_conf.sh
		
		echo "#------------------------" >> /tmp/ss_conf.sh
		if [ "$nu" == "$ssconf_basic_node" ];then
			echo dbus set ssconf_basic_node=$q >> /tmp/ss_conf.sh
		fi
		let q+=1
	done
	#echo $q
	# -----------------
	# 2 清除已有的ss节点配置
	echo_date 一些必要的检查工作...
	confs=`dbus list ssconf_basic_ | cut -d "=" -f 1`
	for conf in $confs
	do
		#echo_date 移除$conf
		dbus remove $conf
	done
	# -----------------
	# 3 应用之前提取的干净的ss配置
	echo_date 检查完毕！节点信息备份在/koolshare/configs/ss_conf.sh
	cat /tmp/ss_conf.sh | sed 's/=/=\"/' | sed 's/$/\"/g' > /koolshare/configs/ss_conf.sh
	sh /koolshare/configs/ss_conf.sh
	# ==============================
}


decode_url_link(){
	local link=$1
	local len=`echo $link| wc -L`
	local mod4=$(($len%4))
	if [ "$mod4" -gt "0" ]; then
		local var="===="
		local newlink=${link}${var:$mod4}
		echo -n "$newlink" | sed 's/-/+/g; s/_/\//g' | base64 -d 2>/dev/null
	else
		echo -n "$link" | sed 's/-/+/g; s/_/\//g' | base64 -d 2>/dev/null
	fi
}

add_ssr_servers(){
	sleep 1
	ssrindex=$(($(dbus list ssconf_basic_|grep _name_ | cut -d "=" -f1|cut -d "_" -f4|sort -rn|head -n1)+1))
	dbus set ssconf_basic_name_$ssrindex=$remarks
	[ -z "$1" ] && dbus set ssconf_basic_group_$ssrindex=$group
	dbus set ssconf_basic_mode_$ssrindex=$ssr_subscribe_mode
	dbus set ssconf_basic_server_$ssrindex=$server
	dbus set ssconf_basic_port_$ssrindex=$server_port
	dbus set ssconf_basic_rss_protocol_$ssrindex=$protocol
	dbus set ssconf_basic_rss_protocol_param_$ssrindex=$protoparam
	dbus set ssconf_basic_method_$ssrindex=$encrypt_method
	dbus set ssconf_basic_rss_obfs_$ssrindex=$obfs
	dbus set ssconf_basic_type_$ssrindex="1"
	[ -n "$1" ] && dbus set ssconf_basic_rss_obfs_param_$ssrindex=$obfsparam
	dbus set ssconf_basic_password_$ssrindex=$password
	echo_date SSR节点：新增加 【$remarks】 到节点列表第 $ssrindex 位。
}

add_ss_servers(){
	ssindex=$(($(dbus list ssconf_basic_|grep _name_ | cut -d "=" -f1|cut -d "_" -f4|sort -rn|head -n1)+1))
	echo_date 添加SS节点：$remarks
	dbus set ssconf_basic_name_$ssindex=$remarks
	dbus set ssconf_basic_mode_$ssindex="2"
	dbus set ssconf_basic_server_$ssindex=$server
	dbus set ssconf_basic_port_$ssindex=$server_port
	dbus set ssconf_basic_method_$ssindex=$encrypt_method
	dbus set ssconf_basic_password_$ssindex=$password
	dbus set ssconf_basic_type_$ssindex="0"
	echo_date SS节点：新增加 【$remarks】 到节点列表第 $ssrindex 位。
}

get_remote_config(){
	decode_link="$1"
	action="$2"
	server=$(echo "$decode_link" |awk -F':' '{print $1}')
	server_port=$(echo "$decode_link" |awk -F':' '{print $2}')
	protocol=$(echo "$decode_link" |awk -F':' '{print $3}')
	encrypt_method=$(echo "$decode_link" |awk -F':' '{print $4}')
	obfs=$(echo "$decode_link" |awk -F':' '{print $5}'|sed 's/_compatible//g')
	
	password=$(decode_url_link $(echo "$decode_link" |awk -F':' '{print $6}'|awk -F'/' '{print $1}'))
	password=`echo $password|base64_encode`
	
	obfsparam_temp=$(echo "$decode_link" |awk -F':' '{print $6}'|grep -Eo "obfsparam.+"|sed 's/obfsparam=//g'|awk -F'&' '{print $1}')
	[ -n "$obfsparam_temp" ] && obfsparam=$(decode_url_link $obfsparam_temp) || obfsparam=''
	
	protoparam_temp=$(echo "$decode_link" |awk -F':' '{print $6}'|grep -Eo "protoparam.+"|sed 's/protoparam=//g'|awk -F'&' '{print $1}')
	[ -n "$protoparam_temp" ] && protoparam=$(decode_url_link $protoparam_temp|sed 's/_compatible//g') || protoparam=''
	
	remarks_temp=$(echo "$decode_link" |awk -F':' '{print $6}'|grep -Eo "remarks.+"|sed 's/remarks=//g'|awk -F'&' '{print $1}')
	if [ "$action" == "1" ];then
		#订阅
		[ -n "$remarks_temp" ] && remarks=$(decode_url_link $remarks_temp) || remarks=""
	elif [ "$action" == "2" ];then
		# ssr://添加
		[ -n "$remarks_temp" ] && remarks=$(decode_url_link $remarks_temp) || remarks='AutoSuB'
	fi
	
	group_temp=$(echo "$decode_link" |awk -F':' '{print $6}'|grep -Eo "group.+"|sed 's/group=//g'|awk -F'&' '{print $1}')
	if [ "$action" == "1" ];then
		#订阅
		[ -n "$group_temp" ] && group=$(decode_url_link $group_temp) || group=""
	elif [ "$action" == "2" ];then
		# ssr://添加
		[ -n "$group_temp" ] && group=$(decode_url_link $group_temp) || group='AutoSuBGroup'
	fi

	[ -n "$group" ] && group_base64=`echo $group | base64_encode | sed 's/ -//g'`
	[ -n "$server" ] && server_base64=`echo $server | base64_encode | sed 's/ -//g'`	
	#把全部服务器节点写入文件 /usr/share/shadowsocks/serverconfig/all_onlineservers
	[ -n "$group" ] && [ -n "$server" ] && echo $server_base64 $group_base64 >> /tmp/all_onlineservers
	#echo ------
	#echo group: $group
	#echo remarks: $remarks
	#echo server: $server
	#echo server_port: $server_port
	#echo password: $password
	#echo encrypt_method: $encrypt_method
	#echo protocol: $protocol
	#echo protoparam: $protoparam
	#echo obfs: $obfs
	#echo obfsparam: $obfsparam
	#echo ------
	echo "$group" >> /tmp/all_group_info.txt
	[ -n "$group" ] && return 0 || return 1
}

update_config(){
	#isadded_server=$(uci show shadowsocks | grep -c "server=\'$server\'")
	isadded_server=$(cat /tmp/all_localservers | grep $group_base64 | awk '{print $1}' | grep -c $server_base64|head -n1)
	if [ "$isadded_server" == "0" ]; then
		add_ssr_servers
		[ "$ssr_subscribe_obfspara" == "0" ] && dbus set ssconf_basic_rss_obfs_param_$ssrindex=""
		[ "$ssr_subscribe_obfspara" == "1" ] && dbus set ssconf_basic_rss_obfs_param_$ssrindex="$obfsparam"
		[ "$ssr_subscribe_obfspara" == "2" ] && dbus set ssconf_basic_rss_obfs_param_$ssrindex="$ssr_subscribe_obfspara_val"
		let addnum+=1
	else
		# 如果在本地的订阅节点中没找到该节点，检测下配置是否更改，如果更改，则更新配置
		index=$(cat /tmp/all_localservers| grep $group_base64 | grep $server_base64 |awk '{print $3}'|head -n1)
		local_server_port=$(dbus get ssconf_basic_port_$index)
		local_protocol=$(dbus get ssconf_basic_rss_protocol_$index)
		local_encrypt_method=$(dbus get ssconf_basic_method_$index)
		local_obfs=$(dbus get ssconf_basic_rss_obfs_$index)
		local_password=$(dbus get ssconf_basic_password_$index)
		local_remarks=$(dbus get ssconf_basic_name_$index)
		local_group=$(dbus get ssconf_basic_group_$index)
		#echo update $index
		local i=0
		[ "$ssr_subscribe_obfspara" == "0" ] && dbus remove ssconf_basic_rss_obfs_param_$index
		[ "$ssr_subscribe_obfspara" == "1" ] && dbus set ssconf_basic_rss_obfs_param_$index="$obfsparam"
		[ "$ssr_subscribe_obfspara" == "2" ] && dbus set ssconf_basic_rss_obfs_param_$index="$ssr_subscribe_obfspara_val"
		dbus set ssconf_basic_mode_$index="$ssr_subscribe_mode"
		[ "$local_remarks" != "$remarks" ] && dbus set ssconf_basic_name_$index=$remarks
		[ "$local_server_port" != "$server_port" ] && dbus set ssconf_basic_port_$index=$server_port && let i+=1
		[ "$local_protocol" != "$protocol" ] && dbus set ssconf_basic_rss_protocol_$index=$protocol && let i+=1
		[ "$local_encrypt_method" != "$encrypt_method" ] && dbus set ssconf_basic_method_$index=$encrypt_method && let i+=1
		[ "$local_obfs" != "$obfs" ] && dbus set ssconf_basic_rss_obfs_$index=$obfs && let i+=1
		[ "$local_password" != "$password" ] && dbus set ssconf_basic_password_$index=$password && let i+=1
		if [ "$i" -gt "0" ];then
			echo_date 修改SSR节点：【$remarks】 && 
			let updatenum+=1
		else
			echo_date SSR节点：【$remarks】 参数未发生变化，跳过！
		fi
	fi
}

del_none_exist(){
	#删除订阅服务器已经不存在的节点
	for localserver in $(cat /tmp/all_localservers| grep $group_base64|awk '{print $1}')
	do
		if [ "`cat /tmp/all_onlineservers | grep -c $localserver`" -eq "0" ];then
			del_index=`cat /tmp/all_localservers | grep $localserver | awk '{print $3}'`
			#for localindex in $(dbus list ssconf_basic_server|grep -v ssconf_basic_server_ip_|grep -w $localserver|cut -d "_" -f 4 |cut -d "=" -f1)
			for localindex in $del_index
			do
				echo_date 删除节点：`dbus get ssconf_basic_name_$localindex` ，因为该节点在订阅服务器上已经不存在...
				dbus remove ssconf_basic_group_$localindex
				dbus remove ssconf_basic_method_$localindex
				dbus remove ssconf_basic_mode_$localindex
				dbus remove ssconf_basic_name_$localindex
				dbus remove ssconf_basic_password_$localindex
				dbus remove ssconf_basic_port_$localindex
				dbus remove ssconf_basic_rss_obfs_$localindex
				dbus remove ssconf_basic_rss_obfs_param_$localindex
				dbus remove ssconf_basic_rss_protocol_$localindex
				dbus remove ssconf_basic_rss_protocol_param_$localindex
				dbus remove ssconf_basic_server_$localindex
				dbus remove ssconf_basic_server_ip_$localindex
				dbus remove ssconf_basic_ss_obfs_$localindex
				dbus remove ssconf_basic_ss_obfs_host_$localindex
				dbus remove ssconf_basic_use_kcp_$localindex
				dbus remove ssconf_basic_use_lb_$localindex
				dbus remove ssconf_basic_lbmode_$localindex
				dbus remove ssconf_basic_weight_$localindex
				dbus remove ssconf_basic_koolgame_udp_$localindex
				dbus remove ssconf_basic_v2ray_use_json_$localindex
				dbus remove ssconf_basic_v2ray_uuid_$localindex
				dbus remove ssconf_basic_v2ray_alterid_$localindex
				dbus remove ssconf_basic_v2ray_security_$localindex
				dbus remove ssconf_basic_v2ray_network_$localindex
				dbus remove ssconf_basic_v2ray_headtype_tcp_$localindex
				dbus remove ssconf_basic_v2ray_headtype_kcp_$localindex
				dbus remove ssconf_basic_v2ray_network_path_$localindex
				dbus remove ssconf_basic_v2ray_network_host_$localindex
				dbus remove ssconf_basic_v2ray_network_security_$localindex
				dbus remove ssconf_basic_v2ray_mux_enable_$localindex
				dbus remove ssconf_basic_v2ray_mux_concurrency_$localindex
				dbus remove ssconf_basic_v2ray_json_$localindex
				let delnum+=1
			done
		fi
	done
}

remove_node_gap(){
	SEQ=$(dbus list ssconf_basic_|grep _name_|cut -d "_" -f 4|cut -d "=" -f 1|sort -n)
	MAX=$(dbus list ssconf_basic_|grep _name_|cut -d "_" -f 4|cut -d "=" -f 1|sort -rn|head -n1)
	NODE_NU=$(dbus list ssconf_basic_|grep _name_|wc -l)
	KCP_NODE=`dbus get ss_kcp_node`
	
	#echo_date 现有节点顺序：$SEQ
	echo_date 最大SSR节点序号：$MAX
	echo_date SSR节点数量：$NODE_NU
	
	if [ "$MAX" != "$NODE_NU" ];then
		echo_date 节点排序需要调整!
		y=1
		for nu in $SEQ
		do
			if [ "$y" == "$nu" ];then
				echo_date 节点 $y 不需要调整 !
			else
				echo_date 调整节点 $nu 到 节点$y !
				[ -n "$(dbus get ssconf_basic_group_$nu)" ] && dbus set ssconf_basic_group_"$y"="$(dbus get ssconf_basic_group_$nu)" && dbus remove ssconf_basic_group_$nu
				[ -n "$(dbus get ssconf_basic_method_$nu)" ] && dbus set ssconf_basic_method_"$y"="$(dbus get ssconf_basic_method_$nu)" && dbus remove ssconf_basic_method_$nu
				[ -n "$(dbus get ssconf_basic_mode_$nu)" ] && dbus set ssconf_basic_mode_"$y"="$(dbus get ssconf_basic_mode_$nu)" && dbus remove ssconf_basic_mode_$nu
				[ -n "$(dbus get ssconf_basic_name_$nu)" ] && dbus set ssconf_basic_name_"$y"="$(dbus get ssconf_basic_name_$nu)" && dbus remove ssconf_basic_name_$nu
				[ -n "$(dbus get ssconf_basic_password_$nu)" ] && dbus set ssconf_basic_password_"$y"="$(dbus get ssconf_basic_password_$nu)" && dbus remove ssconf_basic_password_$nu
				[ -n "$(dbus get ssconf_basic_port_$nu)" ] && dbus set ssconf_basic_port_"$y"="$(dbus get ssconf_basic_port_$nu)" && dbus remove ssconf_basic_port_$nu
				[ -n "$(dbus get ssconf_basic_rss_obfs_$nu)" ] && dbus set ssconf_basic_rss_obfs_"$y"="$(dbus get ssconf_basic_rss_obfs_$nu)" && dbus remove ssconf_basic_rss_obfs_$nu
				[ -n "$(dbus get ssconf_basic_rss_obfs_param_$nu)" ] && dbus set ssconf_basic_rss_obfs_param_"$y"="$(dbus get ssconf_basic_rss_obfs_param_$nu)" && dbus remove ssconf_basic_rss_obfs_param_$nu
				[ -n "$(dbus get ssconf_basic_rss_protocol_$nu)" ] && dbus set ssconf_basic_rss_protocol_"$y"="$(dbus get ssconf_basic_rss_protocol_$nu)" && dbus remove ssconf_basic_rss_protocol_$nu
				[ -n "$(dbus get ssconf_basic_rss_protocol_param_$nu)" ] && dbus set ssconf_basic_rss_protocol_param_"$y"="$(dbus get ssconf_basic_rss_protocol_param_$nu)" && dbus remove ssconf_basic_rss_protocol_param_$nu
				[ -n "$(dbus get ssconf_basic_server_$nu)" ] && dbus set ssconf_basic_server_"$y"="$(dbus get ssconf_basic_server_$nu)" && dbus remove ssconf_basic_server_$nu
				[ -n "$(dbus get ssconf_basic_server_ip_$nu)" ] && dbus set ssconf_basic_server_ip_"$y"="$(dbus get ssconf_basic_server_ip_$nu)" && dbus remove ssconf_basic_server_ip_$nu
				[ -n "$(dbus get ssconf_basic_ss_obfs_host_$nu)" ] && dbus set ssconf_basic_ss_obfs_host_"$y"="$(dbus get ssconf_basic_ss_obfs_host_$nu)" && dbus remove ssconf_basic_ss_obfs_host_$nu
				[ -n "$(dbus get ssconf_basic_use_kcp_$nu)" ] && dbus set ssconf_basic_use_kcp_"$y"="$(dbus get ssconf_basic_use_kcp_$nu)" && dbus remove ssconf_basic_use_kcp_$nu
				[ -n "$(dbus get ssconf_basic_use_lb_$nu)" ] && dbus set ssconf_basic_use_lb_"$y"="$(dbus get ssconf_basic_use_lb_$nu)" && dbus remove ssconf_basic_use_lb_$nu
				[ -n "$(dbus get ssconf_basic_lbmode_$nu)" ] && dbus set ssconf_basic_lbmode_"$y"="$(dbus get ssconf_basic_lbmode_$nu)" && dbus remove ssconf_basic_lbmode_$nu
				[ -n "$(dbus get ssconf_basic_weight_$nu)" ] && dbus set ssconf_basic_weight_"$y"="$(dbus get ssconf_basic_weight_$nu)" && dbus remove ssconf_basic_weight_$nu
				[ -n "$(dbus get ssconf_basic_koolgame_udp_$nu)" ] && dbus set ssconf_basic_koolgame_udp_"$y"="$(dbus get ssconf_basic_koolgame_udp_$nu)" && dbus remove ssconf_basic_koolgame_udp_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_use_json_$nu)" ] && dbus set ssconf_basic_v2ray_use_json_"$y"="$(dbus get ssconf_basic_v2ray_use_json_$nu)" && dbus remove ssconf_basic_v2ray_use_json_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_uuid_$nu)" ] && dbus set ssconf_basic_v2ray_uuid_"$y"="$(dbus get ssconf_basic_v2ray_uuid_$nu)" && dbus remove ssconf_basic_v2ray_uuid_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_alterid_$nu)" ] && dbus set ssconf_basic_v2ray_alterid_"$y"="$(dbus get ssconf_basic_v2ray_alterid_$nu)" && dbus remove ssconf_basic_v2ray_alterid_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_security_$nu)" ] && dbus set ssconf_basic_v2ray_security_"$y"="$(dbus get ssconf_basic_v2ray_security_$nu)" && dbus remove ssconf_basic_v2ray_security_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_network_$nu)" ] && dbus set ssconf_basic_v2ray_network_"$y"="$(dbus get ssconf_basic_v2ray_network_$nu)" && dbus remove ssconf_basic_v2ray_network_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_headtype_tcp_$nu)" ] && dbus set ssconf_basic_v2ray_headtype_tcp_"$y"="$(dbus get ssconf_basic_v2ray_headtype_tcp_$nu)" && dbus remove ssconf_basic_v2ray_headtype_tcp_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_headtype_kcp_$nu)" ] && dbus set ssconf_basic_v2ray_headtype_kcp_"$y"="$(dbus get ssconf_basic_v2ray_headtype_kcp_$nu)" && dbus remove ssconf_basic_v2ray_headtype_kcp_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_network_path_$nu)" ] && dbus set ssconf_basic_v2ray_network_path_"$y"="$(dbus get ssconf_basic_v2ray_network_path_$nu)" && dbus remove ssconf_basic_v2ray_network_path_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_network_host_$nu)" ] && dbus set ssconf_basic_v2ray_network_host_"$y"="$(dbus get ssconf_basic_v2ray_network_host_$nu)" && dbus remove ssconf_basic_v2ray_network_host_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_network_security_$nu)" ] && dbus set ssconf_basic_v2ray_network_security_"$y"="$(dbus get ssconf_basic_v2ray_network_security_$nu)" && dbus remove ssconf_basic_v2ray_network_security_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_mux_enable_$nu)" ] && dbus set ssconf_basic_v2ray_mux_enable_"$y"="$(dbus get ssconf_basic_v2ray_mux_enable_$nu)" && dbus remove ssconf_basic_v2ray_mux_enable_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_mux_concurrency_$nu)" ] && dbus set ssconf_basic_v2ray_mux_concurrency_"$y"="$(dbus get ssconf_basic_v2ray_mux_concurrency_$nu)" && dbus remove ssconf_basic_v2ray_mux_concurrency_$nu
				[ -n "$(dbus get ssconf_basic_v2ray_json_$nu)" ] && dbus set ssconf_basic_v2ray_json_"$y"="$(dbus get ssconf_basic_v2ray_json_$nu)" && dbus remove ssconf_basic_v2ray_json_$nu
				[ -n "$(dbus get ssconf_basic_type_$nu)" ] && dbus set ssconf_basic_type_"$y"="$(dbus get ssconf_basic_type_$nu)" && dbus remove ssconf_basic_type_$nu
				sleep 1
				# change node nu
				if [ "$nu" == "$ssconf_basic_node" ];then
					dbus set ssconf_basic_node="$y"
				fi
			fi
			let y+=1
		done
	else
		echo_date 节点排序正确!
	fi
}

get_oneline_rule_now(){
	# ss订阅
	ssr_subscribe_link="$1"
	echo_date "开始更新在线订阅列表..." 
	echo_date "开始下载订阅链接到本地临时文件，请稍等..."
	rm -rf /tmp/ssr_subscribe_file* >/dev/null 2>&1
	socksopen=`netstat -nlp|grep -w 23456|grep -E "local|v2ray"`
	
	if [ "$ss_basic_online_links_goss" == "1" ];then
		if [ -n "$socksopen" ];then
			echo_date "使用SS网络下载..."
			curl --connect-timeout 8 -s -L --socks5-hostname 127.0.0.1:23456 $ssr_subscribe_link > /tmp/ssr_subscribe_file.txt
		else
			echo_date "没有可用的socks5代理端口，改用常规网络下载..."
			curl --connect-timeout 8 -s -L $ssr_subscribe_link > /tmp/ssr_subscribe_file.txt
		fi
	else
		echo_date "使用常规网络下载..."
		curl --connect-timeout 8 -s -L $ssr_subscribe_link > /tmp/ssr_subscribe_file.txt
	fi

	#虽然为0但是还是要检测下是否下载到正确的内容
	if [ "$?" == "0" ];then
		#订阅地址有跳转
		blank=`cat /tmp/ssr_subscribe_file.txt|grep -E " |Redirecting|301"`
		if [ -n "$blank" ];then
			echo_date 订阅链接可能有跳转，尝试更换wget进行下载...
			rm /tmp/ssr_subscribe_file.txt
			if [ "`echo $ssr_subscribe_link|grep ^https`" ];then
				wget --no-check-certificate -qO /tmp/ssr_subscribe_file.txt $ssr_subscribe_link
			else
				wget -qO /tmp/ssr_subscribe_file.txt $ssr_subscribe_link
			fi
		fi
		#下载为空...
		if [ -z "`cat /tmp/ssr_subscribe_file.txt`" ];then
			echo_date 下载为空...
			return 3
		fi
		#产品信息错误
		wrong1=`cat /tmp/ssr_subscribe_file.txt|grep "{"`
		wrong2=`cat /tmp/ssr_subscribe_file.txt|grep "<"`
		if [ -n "$wrong1" -o -n "$wrong2" ];then
			return 2
		fi
	else
		return 1
	fi

	if [ "$?" == "0" ];then
		echo_date 下载订阅成功...
		echo_date 开始解析节点信息...
		#cat /tmp/ssr_subscribe_file.txt | base64 -d > /tmp/ssr_subscribe_file_temp1.txt
		decode_url_link `cat /tmp/ssr_subscribe_file.txt` > /tmp/ssr_subscribe_file_temp1.txt
		# 检测ss ssr
		NODE_FORMAT1=`cat /tmp/ssr_subscribe_file_temp1.txt | grep -E "^ss://"`
		NODE_FORMAT2=`cat /tmp/ssr_subscribe_file_temp1.txt | grep -E "^ssr://"`
		if [ -n "$NODE_FORMAT1" ];then
			echo_date 暂时不支持ss节点订阅...
			echo_date 退出订阅程序...
		elif [ -n "$NODE_FORMAT2" ];then
			NODE_NU=`cat /tmp/ssr_subscribe_file_temp1.txt | grep -c "ssr://"`
			echo_date 检测到ssr节点格式，共计$NODE_NU个节点...
			#判断格式
			maxnum=$(decode_url_link `cat /tmp/ssr_subscribe_file.txt` | grep "MAX=" | awk -F"=" '{print $2}' | grep -Eo "[0-9]+")
			if [ -n "$maxnum" ]; then
				urllinks=$(decode_url_link `cat /tmp/ssr_subscribe_file.txt` | sed '/MAX=/d' | shuf -n $maxnum | sed 's/ssr:\/\///g')
			else
				urllinks=$(decode_url_link `cat /tmp/ssr_subscribe_file.txt` | sed 's/ssr:\/\///g')
			fi
			[ -z "$urllinks" ] && continue
			for link in $urllinks
			do
				decode_link=$(decode_url_link $link)
				get_remote_config $decode_link 1
				[ "$?" == "0" ] && update_config || echo_date "检测到一个错误节点，已经跳过！"
			done
			# 储存对应订阅链接的group信息
			if [ -n "$group" ];then
				dbus set ss_online_group_$z=$group
				echo $group >> /tmp/group_info.txt
			else
				# 如果最后一个节点是空的，那么使用这种方式去获取group名字
				group=`cat /tmp/all_group_info.txt | sort -u | tail -n1`
				[ -n "$group" ] && dbus set ss_online_group_$z=$group
				[ -n "$group" ] && echo $group >> /tmp/group_info.txt
			fi
			# 去除订阅服务器上已经删除的节点
			del_none_exist
			# 节点重新排序
			remove_node_gap
			USER_ADD=$(($(dbus list ssconf_basic_|grep _name_|wc -l) - $(dbus list ssconf_basic_|grep _group_|wc -l))) || 0
			ONLINE_GET=$(dbus list ssconf_basic_|grep _group_|wc -l) || 0
			echo_date "本次更新订阅来源 【$group】， 新增节点 $addnum 个，修改 $updatenum 个，删除 $delnum 个；"
			echo_date "现共有自添加SSR节点：$USER_ADD 个。"
			echo_date "现共有订阅SSR节点：$ONLINE_GET 个。"
			echo_date "在线订阅列表更新完成!"
		else
			return 3
		fi
	else
		return 1
	fi
}

start_update(){
	prepare
	rm -rf /tmp/ssr_subscribe_file.txt >/dev/null 2>&1
	rm -rf /tmp/ssr_subscribe_file_temp1.txt >/dev/null 2>&1
	rm -rf /tmp/all_localservers >/dev/null 2>&1
	rm -rf /tmp/all_onlineservers >/dev/null 2>&1
	rm -rf /tmp/all_group_info.txt >/dev/null 2>&1
	rm -rf /tmp/group_info.txt >/dev/null 2>&1
	sleep 1
	echo_date 收集本地节点名到文件
	LOCAL_NODES=`dbus list ssconf_basic_|grep _group_|cut -d "_" -f 4|cut -d "=" -f 1|sort -n`
	if [ -n "$LOCAL_NODES" ];then
		for LOCAL_NODE in $LOCAL_NODES
		do
			echo `dbus get ssconf_basic_server_$LOCAL_NODE|base64_encode` `dbus get ssconf_basic_group_$LOCAL_NODE|base64_encode`| eval echo `sed 's/$/ $LOCAL_NODE/g'` >> /tmp/all_localservers
		done
	else
		touch /tmp/all_localservers
	fi
	
	z=0
	online_url_nu=`dbus get ss_online_links|base64_decode|sed 's/$/\n/'|sed '/^$/d'|wc -l`
	#echo_date online_url_nu $online_url_nu
	until [ "$z" == "$online_url_nu" ]
	do
		z=$(($z+1))
		#url=`dbus get ss_online_link_$z`
		url=`dbus get ss_online_links|base64_decode|awk '{print $1}'|sed -n "$z p"|sed '/^#/d'`
		[ -z "$url" ] && continue
		echo_date "==================================================================="
    	echo_date "                服务器订阅程序(Shell by stones & sadog)"
    	echo_date "==================================================================="
		echo_date "从 $url 获取订阅..."
		addnum=0
		updatenum=0
		delnum=0
		get_oneline_rule_now "$url"

		case $? in
		0)
			continue
			;;
		2)
			echo_date "无法获取产品信息！请检查你的服务商是否更换了订阅链接！"
			rm -rf /tmp/ssr_subscribe_file.txt >/dev/null 2>&1 &
			let DEL_SUBSCRIBE+=1
			sleep 2
			echo_date 退出订阅程序...
			;;
		3)
			echo_date "该订阅链接不包含任何节点信息！请检查你的服务商是否更换了订阅链接！"
			rm -rf /tmp/ssr_subscribe_file.txt >/dev/null 2>&1 &
			let DEL_SUBSCRIBE+=1
			sleep 2
			echo_date 退出订阅程序...
			;;
		1|*)
			echo_date "下载订阅失败...请检查你的网络..."
			rm -rf /tmp/ssr_subscribe_file.txt >/dev/null 2>&1 &
			let DEL_SUBSCRIBE+=1
			sleep 2
			echo_date 退出订阅程序...
			;;
		esac
	done

	if [ "$DEL_SUBSCRIBE" == "0" ];then
		# 尝试删除去掉订阅链接对应的节点
		local_groups=`dbus list ssconf_basic_group_|cut -d "=" -f2|sort -u`
		if [ -f "/tmp/group_info.txt" ];then
			for local_group in $local_groups
			do
				MATCH=`cat /tmp/group_info.txt | grep $local_group`
				if [ -z "$MATCH" ];then
					echo_date "==================================================================="
					echo_date 【$local_group】 节点已经不再订阅，将进行删除... 
					confs_nu=`dbus list ssconf |grep "$local_group"| cut -d "=" -f 1|cut -d "_" -f 4`
					for conf_nu in $confs_nu
					do
						dbus remove ssconf_basic_group_$conf_nu
						dbus remove ssconf_basic_method_$conf_nu
						dbus remove ssconf_basic_mode_$conf_nu
						dbus remove ssconf_basic_name_$conf_nu
						dbus remove ssconf_basic_password_$conf_nu
						dbus remove ssconf_basic_port_$conf_nu
						dbus remove ssconf_basic_rss_obfs_$conf_nu
						dbus remove ssconf_basic_rss_obfs_param_$conf_nu
						dbus remove ssconf_basic_rss_protocol_$conf_nu
						dbus remove ssconf_basic_rss_protocol_param_$conf_nu
						dbus remove ssconf_basic_server_$conf_nu
						dbus remove ssconf_basic_server_ip_$conf_nu
						dbus remove ssconf_basic_ss_obfs_$conf_nu
						dbus remove ssconf_basic_ss_obfs_host_$conf_nu
						dbus remove ssconf_basic_use_kcp_$conf_nu
						dbus remove ssconf_basic_use_lb_$conf_nu
						dbus remove ssconf_basic_lbmode_$conf_nu
						dbus remove ssconf_basic_weight_$conf_nu
						dbus remove ssconf_basic_koolgame_udp_$conf_nu
						dbus remove ssconf_basic_v2ray_use_json_$conf_nu
						dbus remove ssconf_basic_v2ray_uuid_$conf_nu
						dbus remove ssconf_basic_v2ray_alterid_$conf_nu
						dbus remove ssconf_basic_v2ray_security_$conf_nu
						dbus remove ssconf_basic_v2ray_network_$conf_nu
						dbus remove ssconf_basic_v2ray_headtype_tcp_$conf_nu
						dbus remove ssconf_basic_v2ray_headtype_kcp_$conf_nu
						dbus remove ssconf_basic_v2ray_network_path_$conf_nu
						dbus remove ssconf_basic_v2ray_network_host_$conf_nu
						dbus remove ssconf_basic_v2ray_network_security_$conf_nu
						dbus remove ssconf_basic_v2ray_mux_enable_$conf_nu
						dbus remove ssconf_basic_v2ray_mux_concurrency_$conf_nu
						dbus remove ssconf_basic_v2ray_json_$conf_nu
						dbus remove ssconf_basic_type_$conf_nu
					done
					# 删除不再订阅节点的group信息
					confs_nu_2=`dbus list ss_online_group_|grep "$local_group"| cut -d "=" -f 1|cut -d "_" -f 4`
					if [ -n "$confs_nu_2" ];then
						for conf_nu_2 in $confs_nu_2
						do
							dbus remove ss_online_group_$conf_nu_2
						done
					fi
					
					echo_date 删除完成完成！
					need_adjust=1
				fi
			done
			sleep 1
			# 再次排序
			if [ "$need_adjust" == "1" ];then
				echo_date 因为进行了删除订阅节点操作，需要对节点顺序进行检查！
				remove_node_gap
			fi
		fi
	else
		echo_date "由于订阅过程有失败，本次不检测需要删除的订阅，以免误伤；下次成功订阅后再进行检测。"
	fi
	# 结束
	echo_date "==================================================================="
	echo_date "所有订阅任务完成，请等待6秒，或者手动关闭本窗口！"
	echo_date "==================================================================="
	sleep 1
	rm -rf /tmp/ssr_subscribe_file.txt >/dev/null 2>&1
	rm -rf /tmp/ssr_subscribe_file_temp1.txt >/dev/null 2>&1
	rm -rf /tmp/all_localservers >/dev/null 2>&1
	rm -rf /tmp/all_onlineservers >/dev/null 2>&1
	rm -rf /tmp/all_group_info.txt >/dev/null 2>&1
	rm -rf /tmp/group_info.txt >/dev/null 2>&1
}

get_ss_config(){
	decode_link=$1
	server=$(echo "$decode_link" |awk -F':' '{print $2}'|awk -F'@' '{print $2}')
	server_port=$(echo "$decode_link" |awk -F':' '{print $3}')
	encrypt_method=$(echo "$decode_link" |awk -F':' '{print $1}')
	password=$(echo "$decode_link" |awk -F':' '{print $2}'|awk -F'@' '{print $1}')
	password=`echo $password|base64_encode`
}

add() {
	echo_date "==================================================================="
	sleep 1
	echo_date 通过SS/SSR链接添加节点...
	rm -rf /tmp/ssr_subscribe_file.txt >/dev/null 2>&1
	rm -rf /tmp/ssr_subscribe_file_temp1.txt >/dev/null 2>&1
	rm -rf /tmp/all_localservers >/dev/null 2>&1
	rm -rf /tmp/all_onlineservers >/dev/null 2>&1
	rm -rf /tmp/all_group_info.txt >/dev/null 2>&1
	rm -rf /tmp/group_info.txt >/dev/null 2>&1
	echo_date 添加链接为：`dbus get ss_base64_links`
	ssrlinks=`dbus get ss_base64_links|sed 's/$/\n/'|sed '/^$/d'`
	for ssrlink in $ssrlinks
	do
		if [ -n "$ssrlink" ];then
			if [ -n "`echo -n "$ssrlink" | grep "ssr://"`" ]; then
				echo_date 检测到SSR链接...开始尝试解析...
				new_ssrlink=`echo -n "$ssrlink" | sed 's/ssr:\/\///g'`
				decode_ssrlink=$(decode_url_link $new_ssrlink)
				get_remote_config $decode_ssrlink 2
				add_ssr_servers 1
			else
				echo_date 检测到SS链接...开始尝试解析...
				if [ -n "`echo -n "$ssrlink" | grep "#"`" ];then
					new_sslink=`echo -n "$ssrlink" | awk -F'#' '{print $1}' | sed 's/ss:\/\///g'`
					remarks=`echo -n "$ssrlink" | awk -F'#' '{print $2}'`
				else
					new_sslink=`echo -n "$ssrlink" | sed 's/ss:\/\///g'`
					remarks='AddByLink'
				fi
				decode_sslink=$(decode_url_link $new_sslink)
				get_ss_config $decode_sslink
				add_ss_servers
			fi
		fi
		dbus remove ss_base64_links
	done
	echo_date "==================================================================="
}

remove_all(){
	# 2 清除已有的ss节点配置
	echo_date 删除所有节点信息！
	confs=`dbus list ssconf_basic_ | cut -d "=" -f 1`
	for conf in $confs
	do
		echo_date 移除$conf
		dbus remove $conf
	done
}

remove_online(){
	# 2 清除已有的ss节点配置
	echo_date 删除所有订阅节点信息...自添加的节点不受影响！
	remove_nus=`dbus list ssconf_basic_|grep _group_ | cut -d "=" -f 1 | cut -d "_" -f4 | sort -n`
	for remove_nu in $remove_nus
	do
		echo_date 移除第 $remove_nu 节点...
		dbus remove ssconf_basic_group_$remove_nu
		dbus remove ssconf_basic_method_$remove_nu
		dbus remove ssconf_basic_mode_$remove_nu
		dbus remove ssconf_basic_name_$remove_nu
		dbus remove ssconf_basic_password_$remove_nu
		dbus remove ssconf_basic_port_$remove_nu
		dbus remove ssconf_basic_rss_obfs_$remove_nu
		dbus remove ssconf_basic_rss_obfs_param_$remove_nu
		dbus remove ssconf_basic_rss_protocol_$remove_nu
		dbus remove ssconf_basic_rss_protocol_param_$remove_nu
		dbus remove ssconf_basic_server_$remove_nu
		dbus remove ssconf_basic_server_ip_$remove_nu
		dbus remove ssconf_basic_ss_obfs_$remove_nu
		dbus remove ssconf_basic_ss_obfs_host_$remove_nu
		dbus remove ssconf_basic_use_kcp_$remove_nu
		dbus remove ssconf_basic_use_lb_$remove_nu
		dbus remove ssconf_basic_lbmode_$remove_nu
		dbus remove ssconf_basic_weight_$remove_nu
		dbus remove ssconf_basic_koolgame_udp_$remove_nu
		dbus remove ssconf_basic_v2ray_use_json_$remove_nu
		dbus remove ssconf_basic_v2ray_uuid_$remove_nu
		dbus remove ssconf_basic_v2ray_alterid_$remove_nu
		dbus remove ssconf_basic_v2ray_security_$remove_nu
		dbus remove ssconf_basic_v2ray_network_$remove_nu
		dbus remove ssconf_basic_v2ray_headtype_tcp_$remove_nu
		dbus remove ssconf_basic_v2ray_headtype_kcp_$remove_nu
		dbus remove ssconf_basic_v2ray_network_path_$remove_nu
		dbus remove ssconf_basic_v2ray_network_host_$remove_nu
		dbus remove ssconf_basic_v2ray_network_security_$remove_nu
		dbus remove ssconf_basic_v2ray_mux_enable_$remove_nu
		dbus remove ssconf_basic_v2ray_mux_concurrency_$remove_nu
		dbus remove ssconf_basic_v2ray_json_$remove_nu
		dbus remove ssconf_basic_type_$remove_nu
	done
}

case $2 in
0)
	# 删除所有节点
	set_lock
	echo " " > /tmp/upload/ss_log.txt
	http_response "$1"
	remove_all >> /tmp/upload/ss_log.txt
	echo XU6J03M6 >> /tmp/upload/ss_log.txt
	unset_lock
	;;
1)
	# 删除所有订阅节点
	set_lock
	echo " " > /tmp/upload/ss_log.txt
	http_response "$1"
	remove_online >> /tmp/upload/ss_log.txt
	echo XU6J03M6 >> /tmp/upload/ss_log.txt
	unset_lock
	;;
2)
	# 保存订阅设置但是不订阅
	set_lock
	echo " " > /tmp/upload/ss_log.txt
	http_response "$1"
	local_groups=`dbus list ssconf_basic_|grep group|cut -d "=" -f2|sort -u|wc -l`
	online_group=`dbus get ss_online_links|base64_decode|sed 's/$/\n/'|sed '/^$/d'|wc -l`
	echo_date "保存订阅节点成功，现共有 $online_group 组订阅来源，当前节点列表内已经订阅了 $local_groups 组..." >> /tmp/upload/ss_log.txt
	sed -i '/ssnodeupdate/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	if [ "$ss_basic_node_update" = "1" ];then
		if [ "$ss_basic_node_update_day" = "7" ];then
			cru a ssnodeupdate "0 $ss_basic_node_update_hr * * * /koolshare/scripts/ss_online_update.sh 3"
			echo_date "设置自动更新订阅服务在每天 $ss_basic_node_update_hr 点。" >> /tmp/upload/ss_log.txt
		else
			cru a ssnodeupdate "0 $ss_basic_node_update_hr * * ss_basic_node_update_day /koolshare/scripts/ss_online_update.sh 3"
			echo_date "设置自动更新订阅服务在星期 $ss_basic_node_update_day 的 $ss_basic_node_update_hr 点。" >> /tmp/upload/ss_log.txt
		fi
	else
		echo_date "关闭自动更新订阅服务！" >> /tmp/upload/ss_log.txt
		sed -i '/ssnodeupdate/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	fi
	echo XU6J03M6 >> /tmp/upload/ss_log.txt
	unset_lock
	;;
3)
	# 订阅节点
	set_lock
	echo " " > /tmp/upload/ss_log.txt
	http_response "$1"
	echo_date "开始订阅" >> /tmp/upload/ss_log.txt
	start_update >> /tmp/upload/ss_log.txt
	echo XU6J03M6 >> /tmp/upload/ss_log.txt
	unset_lock
	;;
4)
	# 订阅ssr://
	set_lock
	echo " " > /tmp/upload/ss_log.txt
	http_response "$1"
	add >> /tmp/upload/ss_log.txt
	echo XU6J03M6 >> /tmp/upload/ss_log.txt
	unset_lock
	;;
esac