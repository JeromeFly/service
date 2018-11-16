#!/bin/bash

#deploy DNS with shell script.
function SERVICE_STATUS
{
	if [ $? -ne 0 ]; then
		echo -e "SERVICE START ERROE!\n"
		exit
	fi
}
echo -e "Begin installed DNS...\n"
setenforce 0 &> /dev/null
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
echo -e "SElinux is disabled.\n"
systemctl stop firewalld &> /dev/null
systemctl disable firewalld &> /dev/null
echo -e "firealld is disabled.\n"
yum install bind bind-utils bind-libs -y &> /dev/null
if [ $? -ne 0 ]; then
	echo -e "installed ERROE!\n"
	exit
fi
echo -e "DNS software with installed.\n"
read -p "Please enter a Host name[example: ___.baidu.com]:" Host
echo ""
read -p "Please enter a domain name[example: www.___.com)]:" Name
echo ""
read -p "Please enter a domain name[example: www.baidu.___)]:" Name_3
echo ""
read -p "Please enter IP[example: 192.168.122.31]:" IP
echo ""
sed -i 's/127.0.0.1/0.0.0.0\/0/' /etc/named.conf
sed -i 's/{ localhost; };/{ any; };/' /etc/named.conf
ls /var/named/named.${Name}.${Name_3} &> /dev/null	#目录可以进行封装
if [ $? -ne 0 ]; then
	cat >> /etc/named.conf << EOF
include "/etc/named.${Name}.${Name_3}.zones";
EOF
	/bin/cp -af /etc/named.rfc1912.zones /etc/named.${Name}.${Name_3}.zones
	cat > /etc/named.${Name}.${Name_3}.zones << EOF
zone "${Name}.${Name_3}" IN {
	type master;
	file "named.${Name}.${Name_3}";
	allow-update { none; };
};
EOF
	/bin/cp -af /var/named/named.localhost /var/named/named.${Name}.${Name_3}
	cat >> /var/named/named.${Name}.${Name_3} << EOF
${Host}	A	${IP}
EOF
	systemctl restart named &> /dev/null
	SERVICE_STATUS
else
	cat >> /var/named/named.${Name}.${Name_3} << EOF
${Host}	A	${IP}
EOF
	systemctl restart named &> /dev/null
	SERVICE_STATUS
fi
echo "Complete!"
