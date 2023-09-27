#!/bin/sh

#
# see https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx
#

set -o errexit

echo "Applying deployment"
echo ""
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for deployment to complete"
echo ""
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

