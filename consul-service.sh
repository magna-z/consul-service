#!/usr/bin/env bash

set -e

function usage {
    echo "USAGE: $0"
    echo "  Register service: CONSUL_URL=<consul-url> [CONSUL_TOKEN=<consul-token>] [CURL_MAX_TIME=5] $0 register -e <environment> -n <name> -p <port> -t <tags>"
    echo "  Deregister service: CONSUL_URL=<consul-url> [CONSUL_TOKEN=<consul-token>] [CURL_MAX_TIME=5] $0 deregister -e <environment> -n <name>"
    exit $1
}

function register {
    if [ -z "$ENV" -o -z "$NAME" -o -z "$PORT" -o -z "$TAGS" ]; then
       usage 1
    fi
    ID="${ENV}_${HOSTNAME}_${NAME}"
    DOMAIN=$(grep -i "^search " /etc/resolv.conf | cut -d " " -f2)
    ADDRESS="${HOSTNAME}.${DOMAIN}"
    TAGS="[\"$ENV\",$TAGS]"
    JSON="{\"ID\":\"$ID\",\"Name\":\"$NAME\",\"Address\":\"$ADDRESS\",\"Port\":$PORT,\"Tags\":$TAGS}"
    curl --location --silent --show-error --max-time "${CURL_MAX_TIME:=5}" --header "$CURL_TOKEN_HEADER" --request PUT --data "$JSON" "$CONSUL_URL/v1/agent/service/register"
}

function deregister {
    if [ -z "$ENV" -o -z "$NAME" ]; then
       usage 1
    fi
    ID="${ENV}_${HOSTNAME}_${NAME}"
    curl --location --silent --show-error --max-time "${CURL_MAX_TIME:=5}" --header "$CURL_TOKEN_HEADER" --request PUT "$CONSUL_URL/v1/agent/service/deregister/$ID"
}

if [ -z "$CONSUL_URL" ]; then
    usage 1
fi
CONSUL_URL=${CONSUL_URL%/}

if [ ! -z "$CONSUL_TOKEN" ]; then
    CURL_TOKEN_HEADER="X-Consul-Token: $CONSUL_TOKEN"
fi

if [ -z $1 ] || [ $1 = "-h" ] || [ $1 = "--help" ]; then
    usage 0
fi

if ! [ $1 = "register" -o $1 = "deregister" ]; then
    usage 1
fi

COMMAND="$1"

shift
while getopts "e:n:p:t:" opt; do
  case $opt in
    e) export ENV="$OPTARG" ;;
    n) export NAME="$OPTARG" ;;
    p) export PORT="$OPTARG" ;;
    t) export TAGS="\"$(echo $OPTARG | sed 's/,/\",\"/g')\"" ;;
  esac
done

$COMMAND
