
#!/bin/bash
set -e
#######################################################
# Author    : Ahmet Önder Moğol
#######################################################

## Kaynak
# https://github.com/kubernetes/kubernetes
# https://dev.to/rahuldhole/kubernetes-cluster-setup-guide-2024-2d7l
# https://eviatargerzi.medium.com/installing-kubernetes-with-a-windows-node-a256f47ad85a
# https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
# https://kubernetes.io/blog/2023/08/15/pkgs-k8s-io-introduction/
# https://github.com/LondheShubham153/kubestarter/blob/main/minikube_installation.md
# https://github.com/kubernetes-sigs/sig-windows-tools/tree/master


# using 'sudo su' is not a good practice.
sudo apt update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo apt install docker.io -y
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock

# Update the Version if needed
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install kubeadm kubectl kubelet -y
sudo apt-mark hold kubelet kubeadm kubectl



echo ""__  VM related setup__""
sudo apt install containerd
sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
echo "Enabled SystemdCgroup in containerd default config"

sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
echo "IPv4 forwarding has been enabled. Bridging enabled!"

echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
echo "br_netfilter has been added to /etc/modules-load.d/k8s.conf."

echo "__ SWAP OFF"
sudo swapoff -a
echo "Disabled swap"
echo "Edit /etc/fstab and disable swap if swap was eneabled"
sudo nano /etc/fstab


echo "Reboot the server."
echo "__ Docker kontrol__"
docker ps -a


echo "__ Containerd"
systemctl status containerd


