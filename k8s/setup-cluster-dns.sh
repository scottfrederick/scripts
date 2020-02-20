#!/bin/bash

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 PKS_ENV_NAME PKS_CONTEXT CLUSTER_MASTER_VM_NAMES"
  exit 1
fi

PKS_ENV=$1
PKS_CONTEXT=$2
CLUSTER_MASTER_VMS=$3

CLUSTER_MASTER_POOL=${PKS_ENV}-${PKS_CONTEXT}
CLUSTER_FRONTEND_ADDRESS=${PKS_ENV}-${PKS_CONTEXT}-cluster-ip
CLUSTER_LOADBALANCER=${PKS_ENV}-${PKS_CONTEXT}-cluster
DNS_ZONE=${PKS_ENV}-zone
DNS_NAME=${PKS_CONTEXT}.${PKS_ENV}.cf-app.com

GCLOUD_REGION=$(lpass show --notes Shared-Spinnaker/pcf/PKS-${PKS_ENV} | jq -r .region)

gcloud compute addresses create ${CLUSTER_FRONTEND_ADDRESS} \
  --region=${GCLOUD_REGION}
CLUSTER_FRONTEND_IP=$(gcloud compute addresses describe ${CLUSTER_FRONTEND_ADDRESS} \
  --region=${GCLOUD_REGION} \
  --format=json \
  | jq -r .address)

gcloud compute target-pools create ${CLUSTER_MASTER_POOL} \
  --region=${GCLOUD_REGION}
gcloud compute target-pools add-instances ${CLUSTER_MASTER_POOL} \
  --region=${GCLOUD_REGION} \
  --instances=${CLUSTER_MASTER_VMS}
gcloud compute forwarding-rules create ${CLUSTER_LOADBALANCER} \
  --region=${GCLOUD_REGION} \
  --address=${CLUSTER_FRONTEND_ADDRESS} \
  --target-pool=${CLUSTER_MASTER_POOL}

gcloud dns record-sets transaction start \
  --zone=${DNS_ZONE}
gcloud dns record-sets transaction add ${CLUSTER_FRONTEND_IP} \
  --name=${DNS_NAME} \
  --type=A \
  --ttl=300 \
  --zone=${DNS_ZONE}
gcloud dns record-sets transaction execute \
  --zone=${DNS_ZONE}
