#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 K8S_CONTEXT"
  exit 1
fi

K8S_CONTEXT=$1

kubectl config use-context ${K8S_CONTEXT}

kubectl create namespace ingress
helm install stable/nginx-ingress --name nginx --set rbac.create=true --namespace ingress --set controller.config.proxy-buffer-size=16k
kubectl describe svc nginx-nginx-ingress-controller --namespace ingress
