#!/bin/bash
set -e
#######################################################
# Author    : Ahmet Önder Moğol
#######################################################

sudo cp /etc/hosts /etc/hosts.bak
cat <<EOF | sudo tee -a /etc/hosts
# Host bilgileri
# Master ve node bilgileri
192.168.1.206 kmaster1
192.168.1.207 knode1
192.168.1.208 kwinnode1
EOF

# Sistem güncellemeleri
sudo apt update && sudo apt upgrade -y

# Gerekli paketlerin kurulumu
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Docker kurulumu (veya containerd tercih edilebilir)
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Kubernetes repo ekleme
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Kubernetes bileşenlerinin kurulumu
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Kernel modüllerinin yüklenmesi
sudo modprobe overlay
sudo modprobe br_netfilter

# Sistem ayarları
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Swap kapatma
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Kubelet servisini başlatma
sudo systemctl enable kubelet
sudo systemctl start kubelet

echo "Worker node kurulumu tamamlandı. Şimdi 'kubeadm join' komutunu çalıştırarak cluster'a katılabilirsiniz."

# Worker kurulumu

# sudo kubeadm reset pre-flight checks

# sudsho + paste join cmd

# sample command
#  kubeadm join 172.27.5.14:6443 --token ocks85.u2sqfn330l36ypkc \
        #--discovery-token-ca-cert-hash #sha256:939be6a03f1a9014bfbb98507086e453fc83cd109319895871d27f9772653a1d \

# Be careful if there is --control-plane in join command means one more master node