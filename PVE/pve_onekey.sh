#!/bin/bash
export LC_ALL=en_US.UTF-8
# 字体颜色设置
TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
# PVE语言包设置
pvelocale(){
	sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && TIME g "PVE语言包设置完成!"
}
# apt国内源
aptsources() {
  cp -rf /etc/apt/sources.list /etc/apt/backup/sources.list.bak
  echo " 请选择您需要的apt国内源"
  echo " 1. 清华大学镜像站"
  echo " 2. 中科大镜像站"
  echo " 3. 上海交大镜像站"
  echo " 4. 阿里云镜像站"
  echo " 5. 腾讯云镜像站"
  echo " 6. 网易镜像站"
  echo " 7. 华为镜像站"
  input="请输入选择"
  while :; do
  read -p " ${input}： " aptsource
  case $aptsource in
  1)
    cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free
		deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free
		deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free
		deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free
		deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free
		deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free
		deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free
		deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free
	EOF
  break
  ;;
  2)
    cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free
		deb-src https://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free
		deb https://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free
		deb-src https://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free
		deb https://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free
		deb-src https://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free
		deb https://mirrors.ustc.edu.cn/debian-security/ bullseye-security main contrib non-free
		deb-src https://mirrors.ustc.edu.cn/debian-security/ bullseye-security main contrib non-free
	EOF
  break
  ;;  
  3)
    cat > /etc/apt/sources.list <<-EOF
		deb https://mirror.sjtu.edu.cn/debian/ bullseye main non-free contrib
		deb-src https://mirror.sjtu.edu.cn/debian/ bullseye main non-free contrib
		deb https://mirror.sjtu.edu.cn/debian/ bullseye-security main
		deb-src https://mirror.sjtu.edu.cn/debian/ bullseye-security main
		deb https://mirror.sjtu.edu.cn/debian/ bullseye-updates main non-free contrib
		deb-src https://mirror.sjtu.edu.cn/debian/ bullseye-updates main non-free contrib
		deb https://mirror.sjtu.edu.cn/debian/ bullseye-backports main non-free contrib
		deb-src https://mirror.sjtu.edu.cn/debian/ bullseye-backports main non-free contrib
	EOF
  break
  ;;
  4)
    cat > /etc/apt/sources.list <<-EOF
		deb http://mirrors.aliyun.com/debian/ bullseye main non-free contrib
		deb-src http://mirrors.aliyun.com/debian/ bullseye main non-free contrib
		deb http://mirrors.aliyun.com/debian-security/ bullseye-security main
		deb-src http://mirrors.aliyun.com/debian-security/ bullseye-security main
		deb http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
		deb-src http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
		deb http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
		deb-src http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
	EOF
  break
  ;;
  5)
    cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.tencent.com/debian/ bullseye main non-free contrib
		deb-src https://mirrors.tencent.com/debian/ bullseye main non-free contrib
		deb https://mirrors.tencent.com/debian-security/ bullseye-security main
		deb-src https://mirrors.tencent.com/debian-security/ bullseye-security main
		deb https://mirrors.tencent.com/debian/ bullseye-updates main non-free contrib
		deb-src https://mirrors.tencent.com/debian/ bullseye-updates main non-free contrib
		deb https://mirrors.tencent.com/debian/ bullseye-backports main non-free contrib
		deb-src https://mirrors.tencent.com/debian/ bullseye-backports main non-free contrib
	EOF
  break
  ;;
  6)
    cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.163.com/debian/ bullseye main non-free contrib
		deb-src https://mirrors.163.com/debian/ bullseye main non-free contrib
		deb https://mirrors.163.com/debian-security/ bullseye-security main
		deb-src https://mirrors.163.com/debian-security/ bullseye-security main
		deb https://mirrors.163.com/debian/ bullseye-updates main non-free contrib
		deb-src https://mirrors.163.com/debian/ bullseye-updates main non-free contrib
		deb https://mirrors.163.com/debian/ bullseye-backports main non-free contrib
		deb-src https://mirrors.163.com/debian/ bullseye-backports main non-free contrib
	EOF
  break
  ;;
  7)
    cat > /etc/apt/sources.list <<-EOF
		deb https://mirrors.huaweicloud.com/debian/ bullseye main non-free contrib
		deb-src https://mirrors.huaweicloud.com/debian/ bullseye main non-free contrib
		deb https://mirrors.huaweicloud.com/debian-security/ bullseye-security main
		deb-src https://mirrors.huaweicloud.com/debian-security/ bullseye-security main
		deb https://mirrors.huaweicloud.com/debian/ bullseye-updates main non-free contrib
		deb-src https://mirrors.huaweicloud.com/debian/ bullseye-updates main non-free contrib
		deb https://mirrors.huaweicloud.com/debian/ bullseye-backports main non-free contrib
		deb-src https://mirrors.huaweicloud.com/debian/ bullseye-backports main non-free contrib
	EOF
  break
  ;;
  *)
    input="请输入正确的编码！"
  ;;
  esac
  done
  TIME g "apt源，更换完成!"
}
# CT模板国内源
ctsources() {
  cp -rf /usr/share/perl5/PVE/APLInfo.pm /usr/share/perl5/PVE/APLInfo.pm.bak
  echo " 请选择您需要的CT模板国内源"
  echo " 1. 清华大学镜像站"
  echo " 2. 中科大镜像站"
  input="请输入选择"
  while :; do
  read -p " ${input}： " aptsource
  case $aptsource in
  1)
    sed -i 's|http://download.proxmox.com|https://mirrors.tuna.tsinghua.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
  break
  ;;
  2)
    sed -i 's|http://download.proxmox.com|http://mirrors.ustc.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
  break
  ;;
  *)
    input="请输入正确的编码"
  ;;
  esac
  done
  TIME g "CT模板源，更换完成!"
}
# 更换使用帮助源
pvehelp(){
  cp -rf /etc/apt/sources.list.d/pve-no-subscription.list /etc/apt/backup/pve-no-subscription.list.bak
  cat > /etc/apt/sources.list.d/pve-no-subscription.list <<-EOF
deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian bullseye pve-no-subscription
EOF
  TIME g "使用帮助源，更换完成!"
}
# 关闭企业源
pveenterprise(){
	if [[ -e /etc/apt/sources.list.d/pve-enterprise.list ]];then
		cp -rf /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/backup/pve-enterprise.list.bak
		rm -rf /etc/apt/sources.list.d/pve-enterprise.list
		TIME g "CT模板源，更换完成!"
	else
		TIME g "pve-enterprise.list不存在，忽略!"
	fi
}
# 移除无效订阅
novalidsub(){
	# 移除 Proxmox VE 无有效订阅提示 (6.4-5、6、8、9 、13；7.0-9、10、11已测试通过)
	cp -rf /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak
	sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
	# sed -i 's#if (res === null || res === undefined || !res || res#if (false) {#g' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
	# sed -i '/data.status.toLowerCase/d' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
	TIME g "已移除订阅提示!"
}
pvegpg(){
	cp -rf /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg /etc/apt/backup/proxmox-release-bullseye.gpg.bak
	rm -rf /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
	wget -q --timeout=5 --tries=1 --show-progres http://mirrors.ustc.edu.cn/proxmox/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
	if [[ $? -ne 0 ]];then
		TIME r "尝试重新下载..."
		wget -q --timeout=5 --tries=1 --show-progres http://mirrors.ustc.edu.cn/proxmox/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
			if [[ $? -ne 0 ]];then
				TIME r "下载秘钥失败，请检查网络再尝试!"
				sleep 2
				exit 1
		else
			TIME g "密匙下载完成!"
			fi
	else
		TIME g "密匙下载完成!"	
	fi
}
#####  开始 #####
clear
TIME y "提示：PVE原配置文件放入/etc/apt/backup文件夹"
[[ ! -d /etc/apt/backup ]] && mkdir -p /etc/apt/backup
echo
TIME y "※※※※※PVE语言包设置...!※※※※※"
pvelocale
echo
TIME y "※※※※※更换apt源...!※※※※※"
aptsources
echo
TIME y "※※※※※更换CT模板源...!※※※※※"
ctsources
echo
TIME y "※※※※※更换使用帮助源...!※※※※※"
pvehelp
echo
TIME y "※※※※※关闭企业源...!※※※※※"
pveenterprise
echo
TIME y "※※※※※移除 Proxmox VE 无有效订阅提示...!※※※※※"
novalidsub
echo
TIME y "※※※※※下载PVE7.0源的密匙!※※※※※"
pvegpg
echo
TIME y "※※※※※重新加载服务配置文件、重启web控制台※※※※※"
systemctl daemon-reload && systemctl restart pveproxy.service && TIME g "服务重启完成!"
sleep 3
echo
TIME y "※※※※※更新源、安装常用软件和升级※※※※※"
apt-get update && apt-get install -y net-tools curl git
# apt-get dist-upgrade -y
TIME y "如需对PVE进行升级，请使用apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y"
sleep 3
echo
TIME y "修改完毕！"
echo
