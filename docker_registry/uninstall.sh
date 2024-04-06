NAMESPACE="docker-registry"

kubectl delete namespace "$NAMESPACE"
kubectl delete pv "$NAMESPACE-pv"

rm -R "/volumes/$NAMESPACE"
