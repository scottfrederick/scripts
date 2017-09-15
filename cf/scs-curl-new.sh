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

set -o xtrace

CREDENTIALS="`cat | sed 1,2d`"

if [[ "$CREDENTIALS" == "" ]]; then
    echo "No credentials found in input"
    exit 1
fi

URI=$(echo $CREDENTIALS | jq -r .uri)

TOKEN=$(cf oauth-token)

curl -k -s -H "Authorization: $TOKEN" $URI"$@"
