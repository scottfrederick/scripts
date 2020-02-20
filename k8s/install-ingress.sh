#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 PKS_CONTEXT"
  exit 1
fi

PKS_CONTEXT=$1

kubectl config use-context ${PKS_CONTEXT}

kubectl create namespace ingress
helm install stable/nginx-ingress --name nginx --set rbac.create=true --namespace ingress --set controller.config.proxy-buffer-size=16k
kubectl describe svc nginx-nginx-ingress-controller --namespace ingress
