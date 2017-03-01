CREDENTIALS="`cat | sed 1,2d`"

URI=$(echo $CREDENTIALS | jq -r .uri)
TOKEN_URI=$(echo $CREDENTIALS | jq -r .access_token_uri)
CLIENT_ID=$(echo $CREDENTIALS | jq -r .client_id)
CLIENT_SECRET=$(echo $CREDENTIALS | jq -r .client_secret)

TOKEN=$(curl -k -s $TOKEN_URI -u $CLIENT_ID:$CLIENT_SECRET -d grant_type=client_credentials | jq -r .access_token)

curl -k -H "Authorization: bearer $TOKEN" $URI"$@"
