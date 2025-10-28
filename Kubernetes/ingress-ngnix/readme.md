
https://www.youtube.com/watch?v=gvKi7wZHbLU


✅ Download Nginx Ingress Controller: https://kubernetes.github.io/ingress-...

https://kubernetes.github.io/ingress-nginx/deploy/

https://github.com/Tech-With-Helen/ingress-eks

==========================================================================================================

kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
kubectl rollout restart deployment nginx-deployment -n prod
===================================================================================================
  2  sh https://github.com/pk-1986/DevOpsCloud/blob/main/devops-tool-setup.sh
    3  mkdir workspace
    4  cd workspace/
    5  git clone https://github.com/pk-1986/DevOpsCloud.git
    6  cd DevOpsCloud/
    7  ls -ltr
    8  chmod 775 devops-tool-setup.sh
    9  ./devops-tool-setup.sh
   10  sudo systemctl enable jenkins
   11  sudo systemctl start jenkins
   12  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   13  helm
   14  clear
   15  cd Kubernetes/
   16  ls -ltr
   17  cd eksfg/
   18  ls -ltr
   19  view Dockerfile
   20  vim deploy.sh
   21  vim ecr-auth.sh
   22  cat ecr-auth.sh
   23  ./ecr-auth.sh
   24  chmod 775 ecr-auth.sh
   25  ./ecr-auth.sh
   26  aws configure
   27  ./ecr-auth.sh
   28  sudo chmod 775 /var/run/docker.sock
   29  ./ecr-auth.sh
   30  ls -l /var/run/docker.sock
   31  sudo chmod 777 /var/run/docker.sock
   32  ls -l /var/run/docker.sock
   33  ./ecr-auth.sh
   34  vim ecr-auth.sh
   35  ./ecr-auth.sh
   36  clear
   37  ls -ltr
   38  vim nginx-deployment.yaml
   39  vim nginx-service.yaml
   40  kubectl create ns prod
   41  kubectl create namespace prod
   42  kubectl create namespace -n prod
   43  kubectl create -n namespace prod
   44  kubectl create -h
   45  kubectl create namespace prod
   46  ll
   47  cat deploy.sh
   48  vim deploy.sh
   49  kubectl get no
   50  chmod 775 deploy.sh
   51  ./deploy.sh prod01
   52  vim nginx-service
   53  ll
   54  vim deploy.sh
   55  kubectl get no
   56  kubectl get po
   57  kubectl get po -n prod
   58  kubectl get svc -n prod
   59  vim index.html
   60  kubectl get svc -n prod
   61  kubectl edit svc nginx-service -n prod
     ClusterIP 
   62  kubectl get svc -n prod
   63  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.0/deploy/static/provider/aws/deploy.yaml
   64  kubectl get pods --namespace=ingress-nginx
   65  wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.0/deploy/static/provider/aws/nlb-with-tls-termination/deploy.yaml
   66  vim deploy.yaml
   67  kubectl delete pods --namespace=ingress-nginx
   68  kubectl get pods --namespace=ingress-nginx
   69  kubectl remove -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.0/deploy/static/provider/aws/deploy.yaml
   70  kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.0/deploy/static/provider/aws/deploy.yaml
   71  kubectl get pods --namespace=ingress-nginx
   72  kubectl apply -f deploy.yaml
   73  kubectl get pods --namespace=ingress-nginx
   74  kubectl get nodes
   75  kubectl get po
   76  kubectl get po -n prod
   77  kubectl get svc -n prod
   78  kubectl get svc
   79  ll
   80  vim nginx-ingress.yaml
   81  kubectl get ingress -n prod
   82  cat nginx-service.yaml
   83  kubectl get svc -n prod
   84  ll
   85  vim ngnix-ingress1.yaml
   86  kubectl apply -f ngnix-ingress1.yaml
   87  kubectl get svc -n prod
   88  kubectl get ngnix -n prod
   89  kubectl get ingress -n prod
   90  kubectl get ingress
   91  kubectl get no
   92  kubectl get po
   93  kubectl get po -n prod
   94  kubectl get po -n prod -o wide
   95  kubectl get ingress -n prod
   96  kubectl get ingress
   97  kubectl get svc -n kubeprd
   98  kubectl get svc -n prod
   99  ll
  100  vim ngnix-ingress1.yaml
  101  kubectl delete ingress nginx1
  102  kubectl get svc -n prod
  103  kubectl get ingress
  104  vim ngnix-ingress1.yaml
  105  kubectl apply -f ngnix-ingress1.yaml
  106  kubectl get ingress
  107  kubectl get ingress -n prod
  108  pwd
  109  ls -ltr
  110  pwd
