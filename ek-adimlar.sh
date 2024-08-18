
#!/bin/bash
set -e
#######################################################
# Author    : Ahmet Önder Moğol
#######################################################

# Güvenlik ayarları, yük dengeleme ve persistent storage gibi ek yapılandırmalar için aşağıdaki adımları ekleyebilirsiniz. Bu adımlar, daha kapsamlı ve production-ready bir Kubernetes cluster oluşturmanıza yardımcı olacaktır:
# Güvenlik Ayarları:

# RBAC (Role-Based Access Control) politikalarını uygula
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Network Policy'leri uygula
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Pod Security Policies (PSP) etkinleştir
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/policy/privileged-psp.yaml

# Secrets şifreleme etkinleştir
kubectl create secret generic encryption-config --from-file=/path/to/encryption-config.yaml


# Yük Dengeleme:
# MetalLB yük dengeleyici kur (bare-metal cluster'lar için)
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

# Ingress Controller olarak NGINX kur
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Persistent Storage:
# Local Path Provisioner kur (test ortamları için)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml

# NFS Subdir External Provisioner kur (NFS sunucunuz varsa)
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=x.x.x.x \
    --set nfs.path=/exported/path

# Monitoring ve Logging:    
# Prometheus ve Grafana kur
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack

# ELK Stack kur
kubectl apply -f https://download.elastic.co/downloads/eck/2.8.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.8.0/operator.yaml

# Backup ve Disaster Recovery:
# Velero kur
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.6.0 \
    --bucket kubernetesbucket \
    --secret-file ./credentials-velero \
    --use-volume-snapshots=false \
    --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio.velero.svc:9000