#!/bin/bash

if [ $# -ne 1 ]; then
    printf "\n$0 <rpcclient syntax>\n
    \texample: $0 \"rpcclient -U 'jeff' <host>\"\n
    "
    exit 1
fi

mkdir -p rpc-enum/tmp

commands=(
    'getdompwinfo:Domain Password Policy:domain_passpol.out'
    'enumdomains:Enum Domains:enum_domains.out'
    'querydominfo:Current Domain querydominfo:current_domain_querydominfo.out'
    'dsenumdomtrusts:Enumerate all trusted domains in an AD forest:AllDomainsTrusts.out'
    'enumdomusers:All Users:all_users.out'
    'querydispinfo:All Users (Description) [1] - querydispinfo:all_users_with_description1.out'
    'querydispinfo2:All Users (Description) [2] - querydispinfo:all_users_with_description2.out'
    'querydispinfo3:All Users (Description) [3] - querydispinfo:all_users_with_description3.out'
    'enumdomgroups:All Groups:all_groups.out'
    'enumtrust:Domain Trusts:DomainsTrusts.out'
    'lsaquerysecobj:Query LSA Object:queryLSA.out'
    'enumprocs:enumprocs - Enum System Process:_enumprocs.out'
    'enumpermachineconnections:Enumerate Per Machine Connections:_enumpermachineconnections.out'
    'enummonitors:Enumerate Print Monitors:_enummonitors.out'
)

for cmd in "${commands[@]}"; do
    IFS=':' read -r command description output_file <<< "$cmd"
    printf "\n\e[1;37m[+] \e[1;34m%s \e[1;37m[+]\e[0m\n\n" "$description"
    eval "$1 -c '$command' | tee -a rpc-enum/$output_file"
done

printf "\n\e[1;37m######## Enumerating Users Details ########\e[0m\n\n"
cut -d'[' -f2 rpc-enum/all_users.out | cut -d']' -f1 | grep -vE 'HealthMailbox|SM_' | sort -u > rpc-enum/tmp/users_unique.out
awk -F'Account: ' '{print $2}' rpc-enum/all_users_with_description* | awk '{print $1}' | grep -vE 'HealthMailbox|SM_' | sort -u >> rpc-enum/tmp/users_unique.out
sort -u rpc-enum/tmp/users_unique.out > rpc-enum/tmp/users.out
while IFS= read -r _user; do
    printf "\n\e[1;37m[+] \e[1;34mUser: \e[1;31m$_user \e[1;37m[+]\e[0m\n\n" | tee -a rpc-enum/USERS_DETAILS.out
    RID=$(grep "$_user" rpc-enum/all_users.out | sort -u | awk -F'rid:\[' '{print $2}' | cut -d']' -f1 | sort -u)
    if [ -z "$RID" ]; then
        RID=$(grep "$_user" rpc-enum/all_users_with_description* | awk -F'RID: ' '{print $2}' | awk '{print $1}' | sort -u)
    fi
    eval "$1 -c 'queryuser $RID' | tee -a rpc-enum/USERS_DETAILS.out"
done < rpc-enum/tmp/users.out

i=1
printf "\n\e[1;37m######## Enumerating Users of all Groups ########\e[0m\n\n"
cut -d'[' -f2 < rpc-enum/all_groups.out | cut -d']' -f1 | sort -u > rpc-enum/tmp/groups.out
while IFS= read -r _group; do
    printf "\n\e[1;37m[+] \e[1;34mGroup: \e[1;31m$_group \e[1;37m[+]\e[0m\n\n"
    printf "\n\e[1;37m[+] \e[1;34mGroup: \e[1;31m$_group \e[1;37m[+]\e[0m\n\n" >> rpc-enum/GROUPS_DETAILS.out
    RID=$(grep "$_group" rpc-enum/all_groups.out | awk -F'rid:\[' '{print $2}' | cut -d']' -f1 | sort -u)
    ID=$(eval "$1 -c 'querygroupmem $RID' | cut -d'[' -f2 | cut -d']' -f1")
    echo "$ID" > rpc-enum/tmp/$i.tmp
    while IFS= read -r _x; do
        eval "$1 -c 'queryuser $_x' | grep 'User Name'"
    done < rpc-enum/tmp/$i.tmp
    ((i+=1))
done < rpc-enum/tmp/groups.out
