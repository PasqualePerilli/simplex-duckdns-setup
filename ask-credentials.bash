#!/bin/bash

#We need to create a script that asks for your credentials and generates a credentials.env file
#SUBDOMAIN
#BASE_DOMAIN
#TZ
#DUCKDNS_TOKEN
#TURN_USER
#TURN_PASS
#XFTP_QUOTA
#ACME_EMAIL

_ask_user_question_with_confirmation(){
  local question="$1"
  local outputFilePath="$2"
  local isConfirmed="false"
  local answer=""
  local confirmation=""
  while [[ "$isConfirmed" == "false" ]]; do
    answer=""
    confirmation=""
    read -p "$question " answer < /dev/tty
    read -p "You answered: $answer. Is this correct? [y/N]: " confirmation < /dev/tty
    if [[ "$confirmation" == "y" ]] || [[ "$confirmation" == "yes" ]] || [[ "$confirmation" == "Y" ]] || [[ "$confirmation" == "YES" ]]; then
      echo "$answer" > "$outputFilePath" 
      isConfirmed="true"
    fi
  done

}

_generate_random_string(){
  local length="$1"
  local lowerCase="a-z"
  local upperCase="A-Z"
  local digits="0-9"
  local specialCharacters="_-"
  
  tr -dc "${lowerCase}${upperCase}${digits}${specialCharacters}" < /dev/urandom | head -c "$length"
  echo
}


echo "In order to set up SimpleX, this script needs you to provide a few credentials"
credentialsFolder="$HOME/.simplex-credentials"
mkdir -p "$credentialsFolder"
credentialsFile="$credentialsFolder/credentials.txt"
_ask_user_question_with_confirmation "Enter the DuckDNS subdomain:" "$credentialsFile"
subdomainName=$(cat "$credentialsFile")
#echo "Read subdomain name $subdomainName"
baseDomain="duckdns.org"
timeZone="America/Chicago"
_ask_user_question_with_confirmation "Enter the DuckDNS token:" "$credentialsFile"
duckToken=$(cat "$credentialsFile")
#echo "Read DuckDNS token $duckToken"
turnUser="simplex"
turnPassword=$(_generate_random_string 64)
simpleXFTPQuota="100gb"
_ask_user_question_with_confirmation "Enter the email to be notified about TLS certificates for the VoIP functionality:" "$credentialsFile"
acmeEmail=$(cat "$credentialsFile")
#echo "Read certificate notification email $acmeEmail"

rm -f "$credentialsFile" &> /dev/null
rm -rf "$credentialsFolder" &> /dev/null

mkdir -p "./env"

domain="${subdomainName}.${baseDomain}"
duckEnv="./env/duckdns.env"
simpleXChatEnv="./env/smp.env"
simpleXFTPEnv="./env/xftp.env"
coturnEnv="./env/coturn.env"
acmeEnv="./env/acme.env"

echo "SUBDOMAINS=${subdomainName}" > "$duckEnv"
echo "TOKEN=${duckToken}" >> "$duckEnv"

echo "ADDR=${domain}" > "$simpleXChatEnv"

echo "ADDR=${domain}" > "$simpleXFTPEnv"
echo "QUOTA=${simpleXFTPQuota}" >> "$simpleXFTPEnv"

echo "REALM=${domain}" > "$coturnEnv"
echo "USER=${turnUser}:${turnPassword}" >> "$coturnEnv"

echo "DOMAIN=${domain}" > "$acmeEnv"
echo "EMAIL=${acmeEmail}" >> "$acmeEnv"
echo "DUCKDNS_TOKEN=${duckToken}" >> "$acmeEnv"
