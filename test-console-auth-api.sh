#!/bin/bash
set -e

INSTANCE_ID=$1

echo "Getting Keystone token"

TOKENS_RESP=`curl -s -k -X 'POST' $OS_AUTH_URL/tokens -d '{"auth":{"passwordCredentials":{"username": "'$OS_USERNAME'", "password":"'$OS_PASSWORD'"}, "tenantName":"'$OS_TENANT_NAME'"}}' -H 'Content-type: application/json'`
TOKEN=`echo $TOKENS_RESP | python -c "import json; import sys; d=json.load(sys.stdin); print d['access']['token']['id']"`
NOVA_URL=`echo $TOKENS_RESP | python -c "import json; import sys; d=json.load(sys.stdin); print d['access']['serviceCatalog'][0]['endpoints'][0]['adminURL']"`

echo "Getting RDP console"

CONSOLE_RESP=`curl -s -H "X-Auth-Token: $TOKEN" $NOVA_URL/servers/$INSTANCE_ID/action -X "POST" -H 'Content-type: application/json' -d '{"os-getRDPConsole":{"type":"rdp-html5"}}'`
#CONSOLE_RESP=`curl -s -H "X-Auth-Token: $TOKEN" $NOVA_URL/servers/$INSTANCE_ID/action -X "POST" -H 'Content-type: application/json' -d '{"os-getVNCConsole":{"type":"novnc"}}'`

echo $CONSOLE_RESP

CONSOLE_URL=`echo $CONSOLE_RESP | python -c "import json; import sys; d=json.load(sys.stdin); print d['console']['url']"`
echo $CONSOLE_URL

CONSOLE_TOKEN=${CONSOLE_URL#*=}

echo $CONSOLE_TOKEN

echo "Getting console connect info"

GET_CONSOLE_CONN_RESP=`curl -s -H "X-Auth-Token: $TOKEN" $NOVA_URL/console-auth-tokens/$CONSOLE_TOKEN/action -X "POST" -H 'Content-type: application/json' -d '{"os-getConsoleConnectInfo": null}'`

HOST=`echo $GET_CONSOLE_CONN_RESP | python -c "import json; import sys; d=json.load(sys.stdin); print d['console']['host']"`
PORT=`echo $GET_CONSOLE_CONN_RESP | python -c "import json; import sys; d=json.load(sys.stdin); print d['console']['port']"`
INTERNAL_ACCESS_PATH=`echo $GET_CONSOLE_CONN_RESP | python -c "import json; import sys; d=json.load(sys.stdin); print d['console']['internal_access_path']"`

echo "Host: $HOST"
echo "Port: $PORT"
echo "Internal_access_path: $INTERNAL_ACCESS_PATH"
