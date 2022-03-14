#!/bin/bash
proxy_source=(
    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt"
    "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/http.txt"
    "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/https.txt"
    "https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list.txt"
    "https://www.proxyscan.io/download?type=https"
    "https://www.proxyscan.io/download?type=http"
    "https://api.proxyscrape.com/v2/?request=getproxies&protocol=http&timeout=10000&country=all&ssl=all&anonymity=all"
)

for source in "${proxy_source[@]}"
do
    source_contents+=$(curl -s --noproxy "*" $source | shuf)
done

printf %s "$source_contents" |
while IFS= read -r line; do
     if [[ $line =~ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+).* ]]; then
         test_proxy="${BASH_REMATCH[1]}"
         echo "trying $test_proxy..."
         for i in {1..2}; do response=$(curl -s -m 9 -x "$test_proxy" "ifconfig.me"); if [ "$response" == "" ]; then break; fi; done
         if [ "$response" != "" ]; then
            echo "trying to get https://registry.terraform.io/.well-known/terraform.json..."
            check_https=$(curl -s -m 15 -x "$test_proxy" "https://registry.terraform.io/.well-known/terraform.json")
            if [ "$check_https" == "" ]; then
                echo "fail"
                continue;
            fi;
            echo "OK"
            if [[ $response =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
                check_ru=$(curl -s --noproxy "*" "http://ipinfo.io/${BASH_REMATCH[1]}/country")
                echo "country: $check_ru"
                if [ "$check_ru" != "RU" ]; then
                    echo "setting $test_proxy as prime proxy"
                    echo "export http_proxy=http://$test_proxy" > proxy.env
                    echo "export https_proxy=http://$test_proxy" >> proxy.env
                    exit 0
                fi
            fi
         fi
     fi
done
