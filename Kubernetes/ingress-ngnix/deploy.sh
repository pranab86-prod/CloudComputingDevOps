#!/bin/bash
aws eks --region us-west-2 update-kubeconfig --name $1
kubectl get nodes
kubectl create namespace prod
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
# Get external LoadBalancer IP
kubectl get svc 
