    #!/bin/bash
    set -e
    #######################################################
    # Author    : Ahmet Önder Moğol
    #######################################################

# Proxmox ağ yapılandırması
sudo apt-get install -y bridge-utils
if [ $? -ne 0 ]; then echo "bridge-utils yüklenemedi"; exit 1; fi

if ! brctl show | grep -q vmbr0; then
    sudo brctl addbr vmbr0
    if [ $? -ne 0 ]; then echo "vmbr0 köprüsü eklenemedi"; exit 1; fi
else
    echo "vmbr0 köprüsü zaten mevcut."
fi

sudo ip addr add 192.168.1.1/24 dev vmbr0
if [ $? -ne 0 ]; then echo "IP adresi eklenemedi"; exit 1; fi

sudo ip link set vmbr0 up
if [ $? -ne 0 ]; then echo "vmbr0 aktif edilemedi"; exit 1; fi

# CPU ve bellek optimizasyonu
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
if [ $? -ne 0 ]; then echo "swappiness ayarı yapılamadı"; exit 1; fi

echo "kernel.numa_balancing=0" | sudo tee -a /etc/sysctl.conf
if [ $? -ne 0 ]; then echo "NUMA dengelemesi ayarı yapılamadı"; exit 1; fi

sudo sysctl -p
if [ $? -ne 0 ]; then echo "sysctl ayarları yüklenemedi"; exit 1; fi