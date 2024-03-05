#!/bin/bash

if [ $# -ne 3 ];then
    printf "\n$0 <host> <users> <passwords>\n\n"
    exit 1
fi

mkdir nkexec

printf "\n\e[1;37m[#] \e[1;31mProtocol: SMB \e[0m| \e[1;31mMode: Domain User \e[1;37m[#]\e[0m\n\n"
nxc smb $1 -u $2 -p $3 --continue-on-success --shares | tee -a nkexec/smb-domain.out

printf "\n\e[1;37m[#] \e[1;31mProtocol: SMB \e[0m| \e[1;31mMode: Local User \e[1;37m[#]\e[0m\n\n"
nxc smb $1 -u $2 -p $3 --continue-on-success --local-auth --shares | tee -a nkexec/smb-local.out

printf "\n\e[1;37m[#] \e[1;31mProtocol: WinRM \e[0m| \e[1;31mMode: Domain User \e[1;37m[#]\e[0m\n\n"
nxc winrm $1 -u $2 -p $3 --continue-on-success | tee -a nkexec/winrm-domain.out

printf "\n\e[1;37m[#] \e[1;31mProtocol: WinRM \e[0m| \e[1;31mMode: Local User \e[1;37m[#]\e[0m\n\n"
nxc winrm $1 -u $2 -p $3 --continue-on-success --local-auth | tee -a nkexec/winrm-local.out

printf "\n\e[1;37m[#] \e[1;31mProtocol: RDP \e[0m| \e[1;31mMode: Domain User \e[1;37m[#]\e[0m\n\n"
nxc rdp $1 -u $2 -p $3 --continue-on-success | tee -a nkexec/rdp-domain.out

printf "\n\e[1;37m[#] \e[1;31mProtocol: RDP \e[0m| \e[1;31mMode: Local User \e[1;37m[#]\e[0m\n\n"
nxc rdp $1 -u $2 -p $3 --continue-on-success --local-auth | tee -a nkexec/rdp-local.out

printf "\n\e[1;37m[#] \e[1;31mProtocol: ssh \e[1;37m[#]\e[0m\n\n"
nxc ssh $1 -u $2 -p $3 --continue-on-success | tee -a nkexec/ssh.out

printf "\n\e[1;37m[#] \e[1;31mProtocol: ftp \e[1;37m[#]\e[0m\n\n"
nxc ftp $1 -u $2 -p $3 --continue-on-success | tee -a nkexec/ftp.out

printf "\n\e[1;37m[#] \e[1;31mProtocol: MSSQL \e[0m| \e[1;31mMode: Domain User \e[1;37m[#]\e[0m\n\n"
nxc mssql $1 -u $2 -p $3 --continue-on-success | tee -a nkexec/mssql-domain.out

printf "\n\e[1;37m[#] \e[1;31mProtocol: MSSQL \e[0m| \e[1;31mMode: Local User \e[1;37m[#]\e[0m\n\n"
nxc mssql $1 -u $2 -p $3 --continue-on-success --local-auth | tee -a nkexec/mssql-local.out
