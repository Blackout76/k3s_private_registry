echo "Enter the namespace:"
read NAMESPACE

echo "Enter sub/domains: (abc.com,def.ghi.net, ...)"
read DOMAINS

# NAMESPACE=""
# DOMAINS=""

echo "#####> Update tls certs on: $NAMESPACE "

MANIFEST="temp.yaml"
cat << EOF >> "$MANIFEST"
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: "tls-$NAMESPACE"
  namespace: "$NAMESPACE"
spec:
  secretName: "tls-$NAMESPACE"
  commonName: "$DOMAIN"
  issuerRef:
    name: "letsencrypt-$NAMESPACE-issuer"
    kind: Issuer
  dnsNames:
  - "$DOMAIN"
EOF
kubectl apply -f temp.yaml
rm temp.yaml

echo "U can check the status of new certificate with: sudo kubectl describe -n $NAMESPACE Certificate tls-$NAMESPACE"
