#!/bin/bash

#
# see https://cert-manager.io/docs/installation/
#
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

kubectl apply -f staging-issuer.yml
kubectl apply -f prod-issuer.yml
