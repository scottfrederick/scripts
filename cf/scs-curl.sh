#
# This scripts expects to have the JSON credentials for an SCS service instance piped into it via the output
# of a service key. For example:
#     $ cf create-service config-server p-config-server -c '<some-json>'
#     $ cf create-service-key config-server config-server-key
#
# then:
#     $ cf service-key config-server config-server-key | scs-curl.sh "/health"
#     $ cf service-key config-server config-server-key | scs-curl.sh "/encrypt/status"
#     $ cf service-key config-server config-server-key | scs-curl.sh "/encrypt" -d "some text to encrypt"

CREDENTIALS="`cat | sed 1,2d`"

if [[ "$CREDENTIALS" == "" ]]; then
    echo "No credentials found in input"
    exit 1
fi

URI=$(echo $CREDENTIALS | jq -r .uri)

# TOKEN_URI=$(echo $CREDENTIALS | jq -r .access_token_uri)
# CLIENT_ID=$(echo $CREDENTIALS | jq -r .client_id)
# CLIENT_SECRET=$(echo $CREDENTIALS | jq -r .client_secret)
#
# TOKEN=$(curl -k -s $TOKEN_URI -u $CLIENT_ID:$CLIENT_SECRET -d grant_type=client_credentials | jq -r .access_token)
#
# curl -k -s -H "Authorization: bearer $TOKEN" $URI"$@"

CONFIG_HOME=~/.cf

AUTH=$(cat $CONFIG_HOME/config.json | jq -r .AccessToken)

echo "AUTH=$AUTH"

curl -k -s -H "Authorization: $AUTH" $URI"$@"
