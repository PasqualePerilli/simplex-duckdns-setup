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

_generate_coturn_config_file(){
  local subdomainName="$1"
  local baseDomain="$2"
  local turnUser="$3"
  local turnPassword="$4"
  local configFile="./coturn/turnserver.conf"
  local publicIPv4=$(curl -s ifconfig.me)
  local internalIPv4=$(hostname -I | tr ' ' '\n' | head -n 1)

  echo "Deleting existing coturn configuration file $configFile from disk"
  sudo rm -f "$configFile" &> /dev/null
  sudo rm -rf "$configFile" &> /dev/null
  echo "# --- Basic server ---" > "$configFile"
  echo "listening-port=3478" >> "$configFile"
  echo "fingerprint" >> "$configFile"
  echo "lt-cred-mech" >> "$configFile"
  echo "" >> "$configFile"
  echo "# --- Domain / identity ---" >> "$configFile"
  echo "realm=${subdomainName}.${baseDomain}" >> "$configFile"
  echo "" >> "$configFile"
  echo "# --- Authentication (simple static user for testing) ---" >> "$configFile"
  echo "user=${turnUser}:${turnPassword}" >> "$configFile"
  echo "" >> "$configFile"
  echo "# --- Networking (IMPORTANT for your setup) ---" >> "$configFile"
  echo "listening-ip=${internalIPv4}" >> "$configFile"
  echo "external-ip=${publicIPv4}/${internalIPv4}" >> "$configFile"
  echo "" >> "$configFile"
  echo "# --- Logging (so you actually see activity) ---" >> "$configFile"
  echo "verbose" >> "$configFile"
  echo "log-file=stdout" >> "$configFile"
  echo "" >> "$configFile"
  echo "# --- TURN support (explicitly ensure relay is enabled) ---" >> "$configFile"
  echo "stun-only=no" >> "$configFile"
  echo "" >> "$configFile"
  echo "# --- Security baseline (optional but recommended) ---" >> "$configFile"
  echo "no-multicast-peers" >> "$configFile"
  echo "no-cli" >> "$configFile"
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
echo "XFTP_URL=https://${domain}:8443" >> "$simpleXChatEnv"

echo "ADDR=${domain}" > "$simpleXFTPEnv"
echo "QUOTA=${simpleXFTPQuota}" >> "$simpleXFTPEnv"

echo "REALM=${domain}" > "$coturnEnv"
echo "USER=${turnUser}:${turnPassword}" >> "$coturnEnv"

echo "DOMAIN=${domain}" > "$acmeEnv"
echo "EMAIL=${acmeEmail}" >> "$acmeEnv"
echo "DUCKDNS_TOKEN=${duckToken}" >> "$acmeEnv"
echo "DuckDNS_Token=${duckToken}" >> "$acmeEnv"
_generate_coturn_config_file "$subdomainName" "$baseDomain" "$turnUser" "$turnPassword"
