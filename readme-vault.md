helm repo add hashicorp https://helm.releases.hashicorp.com

helm repo update

kubectl create namespace vault

for testing 
helm install vault hashicorp/vault \
  --namespace vault \
  --set "server.dev.enabled=true"

kubectl get pods -n vault

for prod 
helm install vault hashicorp/vault \
  --namespace vault \
  --set='server.ha.enabled=true' \
  --set='server.ha.raft.enabled=true'

login to vault
kubectl exec -it vault-0 -n vault -- sh
vault status
exit

kubectl exec -it vault-0 -n vault -- sh
vault auth enable kubernetes
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"


vault kv put secret/dockerhub \
  username="nikhireddy" \
  password="YOUR_DOCKERHUB_ACCESS_TOKEN"

cat > dockerhub-policy.hcl <<'EOF'
path "secret/data/dockerhub" {
  capabilities = ["read"]
}
EOF

vault policy write dockerhub-policy dockerhub-policy.hcl

kubectl create namespace myapp

apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp-sa
  namespace: myapp

kubectl apply -f serviceaccount.yaml

vault write auth/kubernetes/role/myapp \
  bound_service_account_names=myapp-sa \
  bound_service_account_namespaces=myapp \
  policies=dockerhub-policy \
  ttl=1h

helm install vault-secrets-operator \
  hashicorp/vault-secrets-operator \
  --namespace vault-secrets-operator \
  --create-namespace

kubectl get pods -n vault-secrets-operator

apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultConnection
metadata:
  name: vault-connection
  namespace: myapp
spec:
  address: http://vault.vault.svc.cluster.local:8200

kubectl apply -f vault-connection.yaml

apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: myapp-auth
  namespace: myapp

spec:
  method: kubernetes

  mount: kubernetes

  kubernetes:
    role: myapp
    serviceAccount: myapp-sa

  vaultConnectionRef: vault-connection

kubectl apply -f vault-auth.yaml

apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: dockerhub-secret
  namespace: myapp

spec:
  type: kv-v2

  mount: secret

  path: dockerhub

  destination:
    name: dockerhub-secret
    create: true

  vaultAuthRef: myapp-auth

  refreshAfter: 1h

kubectl apply -f vault-static-secret.yaml

vault kv put secret/dockerhub \
  .dockerconfigjson='{"auths":{"https://index.docker.io/v1/":{"username":"nikhireddy","password":"YOUR_ACCESS_TOKEN"}}}'

