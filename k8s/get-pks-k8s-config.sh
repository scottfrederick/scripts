#!/bin/bash -e
# v 0.0.5.1

# get-pks-k8s-config.sh
# gmerlin@vmware.com

function usage()
{
    echo "PKS Kubeconfig Helper Script."
    echo ""
    echo "-h --help"
    echo "--API=[FQDN-OF-YOUR-PKS-API]"
    echo "--CLUSTER=[FQDN-OF-YOUR-K8s-CLUSTER-MASTER-VIP]"
    echo "--USER=[LDAP-USER]"
    echo "--NS=[NAMESPACE]"
    echo "--CERT=[CA-CERT-FILE-PATH]"
    echo ""
    echo "example: ./get-pks-k8s-config.sh --API=pks.mg.lab --CLUSTER=k8s1.mg.lab --USER=cody --NS=pks-dev"
}

urlencode() {
    local l=${#1}
    for (( i = 0 ; i < l ; i++ )); do
        local c=${1:i:1}
        case "$c" in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            ' ') printf + ;;
            *) printf '%%%.2X' "'$c"
        esac
    done
}


if [ "$#" -lt 4 ]; then
        usage
        exit 1
fi

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --API)
            PKS_API=$VALUE
            ;;
        --CLUSTER)
            PKS_CLUSTER=$VALUE
            ;;
        --USER)
            PKS_USER=$VALUE
            ;;
        --NS)
            PKS_NAMESPACE=$VALUE
            ;;
        --CERT)
            PKS_CLUSTER_CERT=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

#Prompt for Password
echo -n "Password:"
read -s PKS_PASSWORD_RAW
echo -n ""

PKS_PASSWORD=$(urlencode $PKS_PASSWORD_RAW)

# Collect Tokens from UAA
CURL_CMD="curl 'https://${PKS_API}:8443/oauth/token' -sk -X POST -H 'Accept: application/json' -d \"client_id=pks_cluster_client&client_secret=\"\"&grant_type=password&username=${PKS_USER}&password=\"${PKS_PASSWORD}\"&response_type=id_token\""

TOKENS=$(eval $CURL_CMD | jq -r '{id_token, refresh_token} | to_entries | map("\(.key)=\(.value | @sh)") | .[]')
eval $TOKENS

if [ $id_token = "unauthorized" ]; then
    echo
    echo "Auth Failed"
    exit 1
fi

#exit 0

# Construct Kubeconfig
if [ -z ${PKS_CLUSTER_CERT} ]; then
    echo | openssl s_client -showcerts -connect ${PKS_CLUSTER}:8443 2>/dev/null | awk '/s:\/CN=ca/,/-----END CERTIFICATE-----/' | openssl x509 -outform PEM > ./${PKS_CLUSTER}-ca.crt
    kubectl config set-cluster ${PKS_CLUSTER} --server=https://${PKS_CLUSTER}:8443 --certificate-authority=./${PKS_CLUSTER}-ca.crt --embed-certs=true
else
    kubectl config set-cluster ${PKS_CLUSTER} --server=https://${PKS_CLUSTER}:8443 --certificate-authority=${PKS_CLUSTER_CERT} --embed-certs=true
fi
kubectl config set-context ${PKS_CLUSTER} --cluster=${PKS_CLUSTER} --user=${PKS_USER} --namespace=${PKS_NAMESPACE}
kubectl config use-context ${PKS_CLUSTER}

kubectl config set-credentials ${PKS_USER} \
  --auth-provider oidc \
  --auth-provider-arg client-id=pks_cluster_client \
  --auth-provider-arg cluster_client_secret="" \
  --auth-provider-arg id-token=${id_token} \
  --auth-provider-arg idp-issuer-url=https://${PKS_API}:8443/oauth/token \
  --auth-provider-arg refresh-token=${refresh_token}
