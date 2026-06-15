#!/bin/bash

# ---------------------------------------
# Comments area
# ---------------------------------------

#We need to verify Docker is installed
#We need to verify Docker compose is installed
#We need to verify curl or wget is installed

#We need to grab ask-credentials.bash and compose.yml from the repository
#We need to make ask-credentials.bash executable
#We need to run ask-credentials.bash
#We need to run docker compose up -d

# ---------------------------------------
# Functions definitions
# ---------------------------------------

_pre_requisites_check(){
  local errorMessage=""

  if [[ $(which docker | grep -v "not found") == "" ]]; then
    errorMessage="Docker is not installed on this system. Cannot proceed. Please install it and try again."
  fi

  if [[ $(docker compose --help 2> /dev/null | grep "docker compose") == "" ]]; then
    composeErrorMessage="Docker compose is not installed on this system. Cannot proceed. Please install it and try again"
    if [[ "$errorMessage" == "" ]]; then
      errorMessage="$composeErrorMessage"
    else
      errorMessage="${errorMessage}\n${composeErrorMessage}"
    fi
  fi
  
  local curlInstalled=$(which curl | grep -v "not found")
  local wgetInstalled=$(which wget | grep -v "not found")
  
  if [[ "$curlInstalled" == "" ]] && [[ "$wgetInstalled" == "" ]]; then
    local downloaderErrorMessage="Neither curl nor wget are installed on this system. Cannot proceed. Please install either or both and try again."
    if [[ "$errorMessage" == "" ]]; then
      errorMessage="$downloaderErrorMessage"
    else
      errorMessage="${errorMessage}\n${downloaderErrorMessage}"
    fi
  fi
  
  if [[ "$errorMessage" != "" ]]; then
    echo "$errorMessage"
    return 1
  fi

}

_should_use_curl(){
  local curlInstalled=$(which curl | grep -v "not found")
  local wgetInstalled=$(which wget | grep -v "not found")
  local useCurl="false"
  if [[ "$curlInstalled" != ""  ]]; then
    useCurl="true"
  fi
  echo "$useCurl"
}

_manage_remote_downloads(){
  local useCurl=$(_should_use_curl)
  local filesToDownload=("https://raw.githubusercontent.com/PasqualePerilli/simplex-duckdns-setup/refs/heads/master/ask-credentials.bash" "https://raw.githubusercontent.com/PasqualePerilli/simplex-duckdns-setup/refs/heads/master/compose.yml" )
  local downloadIndex=0
  local numberOfFilesToDownload="${#filesToDownload[@]}"
  for fileToDownload in "${filesToDownload[@]}"; do
    local filename="${fileToDownload##*/}"
	downloadIndex=$(( 1 + $downloadIndex ))
    echo "Downloading file #${downloadIndex}/${numberOfFilesToDownload} with name: $filename"
    if [[ "$useCurl" == "true" ]]; then
	  curl -s -k -H "Cache-Control: no-cache" -H "Pragma: no-cache" -o "$filename" "$fileToDownload" 	 #Use curl
    else
	  wget --header "Cache-Control: no-cache" --header "Pragma: no-cache" -O "$filename" "$fileToDownload" #Use wget instead
    fi
  done
}


_manage_local_execution(){
  #First, we need the ability to execute the ask-credentials.bash script
  chmod +x "ask-credentials.bash"
  #Now we need to run it
  bash "ask-credentials.bash"
  #This should have created the .env folder with the files within it
  if [[ ! -d ".env" ]] || [[ ! -f ".env/duckdns.env" ]] || [[ ! -f ".env/smp.env" ]] || [[ ! -f ".env/xftp.env" ]] || [[ ! -f ".env/coturn.env" ]] || [[ ! -f ".env/acme.env" ]] ; then
    echo "There was a problem defining the credentials. Cannot proceed. Please try again later."
	return 1
  fi
  echo "Now creating the SimpleX stack. Please wait."
  docker compose up -d
  
}

# ---------------------------------------
# This is what the script does
# ---------------------------------------

_pre_requisites_check || return 1
_manage_remote_downloads
_manage_local_execution

