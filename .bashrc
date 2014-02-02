# .bashrc
# Source global definitions
#
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions
#===============================================================================
# Shell Options 
#===============================================================================
shopt -s checkwinsize

#===============================================================================
# ALIAS
#===============================================================================
alias d='git diff --word-diff $@'
alias s='d;git status -sb'
alias b='git branch -avv'
alias a='git add $@'
alias c='git commit -v $@'
alias ac='git add .;c $@'
alias lg='git lg'
alias lynx='/Applications/Lynxlet.app/Contents/Resources/lynx/bin/lynx'
alias ports="echo 'User:      Command:   Port:'; echo '----------------------------' ; lsof -i 4 -P -n | grep -i 'listen' | awk '{print \$3, \$1, \$9}' | sed 's/ [a-z0-9\.\*]*:/ /' | sort -k 3 -n |xargs printf '%-10s %-10s %-10s\n' | uniq"
alias checkssl="echo | openssl s_client -connect www.google.com:443 2>/dev/null |openssl x509 -dates -noout"
alias vi='vim'

#===============================================================================
#vars
#===============================================================================
HISTCONTROL=ignoreboth
HISTIGNORE="&:bg:fg:ll:h:ii:show:source:ls:exit:vi *:"
HISTTIMEFORMAT='%F %T '
MYSQL_PS1="(\u@mysql)% "
PATH=$PATH:/usr/local/bin:~/.bin:~/Android/sdk/platform-tools:/opt/local/bin
TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
pblue='\e[0;32m'
PBLUE='\e[01;32m'
NC='\e[0m'
PATH=$PATH:~/bin
OS="$(uname -s)"
if [ ${OS} == 'Linux' ]; then
	if [ -f /etc/redhat-release ]; then
		grep -i fedora /etc/redhat-release 1>&2 > /dev/null
		if [ $? != 0 ]; then
			KERN_DIR=/usr/src/kernels/$(uname -r)
		else
			KERN_DIR=/usr/src/kernels/$(uname -r)-$(uname -m)
		fi
	fi
fi

parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1="${pblue}[\d]${NC}${green}[\u@\h]$NC${red}\$(parse_git_branch)${NC}${pblue}[\w]$NC\n%> "

#===============================================================================
#exports
#===============================================================================
export EDITOR=vim
export GIT_EDITOR='vim'
export PATH MYSQL_PS1 MYSQL_PS2 NMAPDIR TIMEFORMAT HISTINGNORE KERN_DIR

#===============================================================================
#functions
#===============================================================================
function xtitle () {
	case "$TERM" in
		*term | rxvt) printf "\033]0; $* \007" ;;
		*)  ;;
	esac
}
function m2u() { 
	cat $1 | tr "\015" "\012"; 
}
function search() { 
	find . -type f -name "$1" -print; 
}
function scan() { 
	sudo nmap2 -sV -sS -O ${1}; 
}
function my_ps() { 
	ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; 
}
function pp() { 
	my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; 
}
function tcpsniffer() {
	opts="-w /tmp/dump.pcap -s0 -nnnvvvX"
	if [ "${OS}" == "Linux" ]; then
		/usr/bin/sudo /usr/sbin/tcpdump -i eth0 ${opts} tcp port ${1} -w /tmp/dump.bin
	else
		/usr/bin/sudo /usr/sbin/tcpdump -i en0 ${opts} tcp port ${1}
	fi
}

function my_ip() {
	count=0
	if [ "${OS}" == "Linux" ]; then
		if [ "$(awk '/Fedora/ {print $1}' /etc/redhat-release)" == "Fedora" ]; then
			count=1
			NICS="$(ls -1d /sys/class/net/em* | awk -F\/ '{printf "%s ", $5}' | sed -e 's/ $//g')"
			for x in ${NICS}
			do
				eval "MY_IP${count}=$(/sbin/ip addr show dev em${count} | awk '/inet/ {printf $2}' | cut -d/ -f1) "
				count=$(( count + 1))
			done
		else
			NICS="$(ls -1d /sys/class/net/eth* | awk -F\/ '{printf "%s ", $5}' | sed -e 's/ $//g')"
			for x in ${NICS}
			do
				eval "MY_IP${count}=$(/sbin/ip addr show dev et${count} | awk '/inet/ {printf $2}' | cut -d/ -f1) "
				count=$(( count + 1))
			done
		fi
	else
		i=$(ifconfig | grep -v inet | awk '/en[0-9]/ {print $1}'| sed -e 's/*$//')
		for x in ${i}
		do
			eval "MY_IP${count}=$(/sbin/ifconfig en${count} | grep -v inet6 | awk '/inet/ { print $2 }')"
			count=$(( count + 1))
		done
	fi
}

my_ip 1 > /dev/null

function ii(){   # get current host related info
	printf "You are logged on ${RED}$HOST"
	printf "\nAdditionnal information:$NC " ; uname -a
	printf "\n${RED}Users logged on  :$NC " ; w -h
	printf "${RED}Current date     :$NC " ; date
	printf "${RED}Machine stats    :$NC " ; uptime
	printf "\n${RED}Local IP Address :$NC" ; printf "${MY_IP0:-"Not connected"}"
	printf "\n${RED}Wireless Address :$NC" ; printf "${MY_IP1:-"Not connected"}\n"
}

function show() {
	case ${1} in
		ip) 
		if [ "${OS}" == "Darwin" ]; then
			printf "LAN : ${MY_IP0:-"Not connectd"}\n"
			printf "WIFI: ${MY_IP1:-"Not connectd"}\n" 
		else
			printf "LAN: ${MY_IP0:-"Not connectd"}\n"
		fi
	;;
		ssh) netstat -ant | grep 22 | grep ESTABLISHED ;;
		who) who | awk '{print $1 " " $6}' ;;
		load) uptime ;;
		os) uname -r ;;
		*) printf "ip\nssh\nwho\n"
	esac
}

function git_here() {
	git init
	git config color.ui auto
	echo "log tmp db/*.sqlite3 nbproject/private bin .DS_Store" | tr " " "\n" > .gitignore
	git add .gitignore
	git commit -m "initial project setup"
}

function get_domain_controllers() {
	host -t srv _ldap._tcp.dc._msdcs.${1} | awk '{print $8}'
}

function track_name() {
	mpc current
}

function do_line() {
	printf -v line '%*s' "80"
	echo ${line// /=}
}

function get_certificate() {
	echo -n | openssl s_client -connect ${1}:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/${1}.cert
}

function get_certificate_bundle() {
	echo -n | openssl s_client -showcerts -connect ${1}:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/${1}.cert
}

function get_mirror() {
	if [ ${1} ]; then
		curl -s "http://mirrorlist.centos.org/?release=${1}&arch=x86_64&repo=os" | head -n 1
	else
		echo "Useage: get_mirror release-version '4|5|6'"
		echo "example: get_mirror 6"
	fi
}

complete -A hostname   telnet ftp ping disk ssh rwork
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail id finger
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown
complete -A directory  mkdir rmdir
complete -A directory   -o default cd

export PERL_LOCAL_LIB_ROOT="/Users/coolhurc/perl5:$PERL_LOCAL_LIB_ROOT";
export PERL_MB_OPT="--install_base "/Users/coolhurc/perl5"";
export PERL_MM_OPT="INSTALL_BASE=/Users/coolhurc/perl5";
export PERL5LIB="/Users/coolhurc/perl5/lib/perl5:$PERL5LIB";
export PATH="/Users/coolhurc/perl5/bin:$PATH";
