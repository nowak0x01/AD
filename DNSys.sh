#!/usr/bin/env bash

if [ $# -ne 2 ];then
    printf "\n$0 <domain> <dns server>\n\n"
    exit 1
fi

mkdir -p dnsys_tmp
printf "\n\e[1;37m[*]\e[1;31m Trying Zone-Transfer - domain: $1 \e[1;37m[*]\n\e[0m"
dig axfr $1 @$2 | grep -vE ';; |<<>>' | tee -a dnsys_tmp/1.axfr

if [ "$(echo $1 | tr '.' '\n' | wc -l)" -ge 3 ]; then
    regex='IN A'
else
    regex='IN    A'
fi

domains=$(cat dnsys_tmp/1.axfr | grep "$regex" | awk '{print $1}' | sed s/.$//g | sort -u)

for domain in $(echo $domains);do
    printf "\n\e[1;37m[*]\e[1;31m Trying Zone-Transfer (recursive) - domain: $domain \e[1;37m[*]\n\e[0m"
    dig axfr $domain @$2 | grep -vE ';; |<<>>' | tee -a dnsys_tmp/$domain.axfr
done

printf "\n\e[1;37m[#] \e[1;34mDomains you will need to bruteforce \e[1;37m[#]\e[0m\n\n"
grep 'Transfer failed' dnsys_tmp/* | cut -d'/' -f2 | cut -d':' -f1 | sed s/'.axfr'/''/g | sort -u
echo
