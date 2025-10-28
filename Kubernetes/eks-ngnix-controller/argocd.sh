kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "LoadBalancer"}}'

kubectl get svc argocd-server -n argocd
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d


================

argocd app create myapp \
  --repo https://github.com/myrepo/k8s-manifests.git \
  --path app-path \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

============================================

# Download the latest version
VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64"

# Make it executable
chmod +x argocd

# Move it to your PATH
sudo mv argocd /usr/local/bin/
