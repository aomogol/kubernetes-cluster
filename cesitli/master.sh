#!/bin/bash
set -e
#######################################################
# Author    : Ahmet Önder Moğol
#######################################################

# master nodekurulumu

# tmux
# sudo kubeadm init --control-plane-endpoint=172.27.5.14 --node-name k8s-master --pod-network-cidr=10.244.0.0/16

sudo kubeadm init --node-name kmaster --pod-network-cidr=10.244.0.0/16


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# Flannel yapılacak ise
# kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml


kubectl get nodes
kubectl get pods -A

echo "Please wait a few minutes to get all pods running before joining any worker nodes."

