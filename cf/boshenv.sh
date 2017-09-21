#!/bin/bash

#
# Inspired by http://www.starkandwayne.com/blog/target-ops-manager-bosh-director-using-om-and-jq/
#

function boshenv() {
    # set -o xtrace

    function setenv() {
        if (which om | grep "not found"); then
            echo "'om' must be installed before using this script; see https://github.com/pivotal-cf/om#installation"
            return 1
        fi

        if (which bosh | grep "not found"); then
            echo "bosh v2 CLI must be installed before using this script; see https://bosh.io/docs/cli-v2.html#install"
            return 1
        fi

        if (which jq | grep "not found"); then
            echo "'jq' must be installed before using this script; see https://stedolan.github.io/jq/"
            return 1
        fi

        export OM_TARGET="$1"
        export OM_ADMIN="$2"
        export OM_PASSWORD="$3"

        # Unset BOSH_* env vars
        while read var; do unset $var; done < <(env | grep BOSH | cut -d'=' -f1)

        # Get director IP
        BOSH_PRODUCT_GUID=$(om -t $OM_TARGET -k -u $OM_ADMIN curl -s -path /api/v0/deployed/products/ | jq -r -c '.[] | select(.type | contains("p-bosh")) | .guid')
        export BOSH_ENVIRONMENT=$(om -t $OM_TARGET -k -u $OM_ADMIN curl -s -path /api/v0/deployed/products/$BOSH_PRODUCT_GUID/static_ips | jq -r '.[].ips[]')

        # Get Director root cert
        export BOSH_CA_CERT=$(om -t $OM_TARGET -k -u $OM_ADMIN curl -s -path /api/v0/certificate_authorities | jq -r '.certificate_authorities[].cert_pem')

        # Get Director credentials
        export BOSH_USERNAME=$(om -t $OM_TARGET -k -u $OM_ADMIN curl -s -path /api/v0/deployed/director/credentials/director_credentials | jq -r '.credential.value.identity')
        export BOSH_PASSWORD=$(om -t $OM_TARGET -k -u $OM_ADMIN curl -s -path /api/v0/deployed/director/credentials/director_credentials | jq -r '.credential.value.password')

        # Log-in to get UAA token
        echo -e "$BOSH_USERNAME\n$BOSH_PASSWORD\n" | bosh log-in
        bosh env
    }

    if [ "$#" -eq 0 ]; then
        echo "Current environment is $BOSH_ENVIRONMENT"
    elif [ "$#" -eq 3 ]; then
        setenv "$1" "$2" "$3"
    else
        echo "Usage: $0 OM_TARGET OM_ADMIN_USERNAME OM_PASSWORD"
    fi
}
