    #!/bin/bash
    set -e
    #######################################################
    # Author    : Ahmet Önder Moğol
    #######################################################

## Kaynak
# Bu kaynak iyi
# https://github.com/LondheShubham153/kubestarter/blob/main/kubeadm_installation.md

# https://github.com/kubernetes/kubernetes
# https://dev.to/rahuldhole/kubernetes-cluster-setup-guide-2024-2d7l
# https://eviatargerzi.medium.com/installing-kubernetes-with-a-windows-node-a256f47ad85a
# https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
# https://kubernetes.io/blog/2023/08/15/pkgs-k8s-io-introduction/
# https://github.com/LondheShubham153/kubestarter/blob/main/minikube_installation.md
# https://github.com/kubernetes-sigs/sig-windows-tools/tree/master
# https://www.learnlinux.tv/how-to-build-an-awesome-kubernetes-cluster-using-proxmox-virtual-environment/
# https://cri-o.io/
# https://jqlang.github.io/jq/
#
#

#  hosts  
sudo cp /etc/hosts /etc/hosts.bak
cat <<EOF | sudo tee -a /etc/hosts
# Host bilgileri
# Master ve node bilgileri
192.168.1.149 kmaster1
192.168.1.150 knode1
192.168.1.151 kwinnode1
EOF

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Kernel modüllerini kontrol etmek için
lsmod | grep br_netfilter 
lsmod | grep overlay 

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
sudo systemctl daemon-reload    

# using 'sudo su' is not a good practice.
sudo apt update
sudo apt-get install -y software-properties-common curl apt-transport-https ca-certificates gpg
sudo apt install -y docker.io
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock
sudo systemctl enable docker
sudo systemctl start docker

# Update the Version if needed
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update 
sudo apt install -y kubeadm kubectl kubelet
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet


# Containerd kurulumu ve yapılandırması (Docker ile çakışabilir, dikkatli olun)
# sudo apt install -y containerd
# sudo mkdir -p /etc/containerd
# containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
# sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
# sudo systemctl restart containerd


# echo ""__  VM related setup__""
# sudo apt install containerd
# sudo mkdir /etc/containerd
# containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
# sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
# echo "Enabled SystemdCgroup in containerd default config"

# IPv4 forwarding
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# br_netfilter
echo "br_netfilter"
echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
echo "br_netfilter has been added to /etc/modules-load.d/k8s.conf."

# SWAP OFF
echo "__ SWAP OFF"
sudo cp /etc/fstab /etc/fstab.bak  # fstab'ın yedeğini al
sudo swapoff -a
#swap satırını tamamen sil
#sudo sed -i '/swap/d' /etc/fstab
#swap satırını yorum satırına al
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Kubelet'i etkinleştirme ve başlatma
sudo systemctl enable kubelet
sudo systemctl start kubelet



echo "Kurulum tamamlandı. Lütfen sistemi yeniden başlatın."