#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 PKS_ENV_NAME CONTEXT_DNS_NAME"
  exit 1
fi

PKS_ENV=$1
DNS_NAME=$2
PKS_ENV_ZONE=${PKS_ENV}-zone
PKS_ENV_DOMAIN=${PKS_ENV}.cf-app.com

INGRESS_IP=$(kubectl get svc nginx-nginx-ingress-controller \
  --namespace ingress -ojson \
  | jq -r '.status.loadBalancer.ingress | .[0].ip')

gcloud dns record-sets transaction start \
  --zone=${PKS_ENV_ZONE}
gcloud dns record-sets transaction add ${INGRESS_IP} \
  --zone=${PKS_ENV_ZONE} \
  --type=A \
  --ttl 300 \
  --name="spinnaker.${DNS_NAME}.${PKS_ENV_DOMAIN}"
gcloud dns record-sets transaction add ${INGRESS_IP} \
  --zone=${PKS_ENV_ZONE} \
  --type=A \
  --ttl 300 \
  --name="*.spinnaker.${DNS_NAME}.${PKS_ENV_DOMAIN}"
gcloud dns record-sets transaction execute \
  --zone=${PKS_ENV_ZONE}
