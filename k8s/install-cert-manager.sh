#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 PKS_CONTEXT"
  exit 1
fi

PKS_CONTEXT=$1

kubectl config use-context ${PKS_CONTEXT}

kubectl create namespace cert-manager
kubectl config set-context ${PKS_CONTEXT} --namespace=cert-manager

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install --name cert-manager --namespace cert-manager --version v0.8.1 jetstack/cert-manager

kc apply -f staging-issuer.yml
kc apply -f prod-issuer.yml
