# Join as a control plane

# on master/control plane
kubeadm token create --print-join-command

# Get certificate key
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'


# on expected new control plane
sudo kubeadm reset pre-flight checks

sudo kubeadm join <control_plane_endpoint>:<port> --token <token> --discovery-token-ca-cert-hash sha256:<discovery_token_ca_cert_hash> --control-plane --certificate-key <certificate_key>


Useful commands
sudo kubeadm token create --print-join-command # port 6443 need to be open


Troubleshoot
Wait for all the control plane pods to be running before joining new workers in
Have plenty of disk space, the setup size is 4GB on the control plane and 3GB on the worker node
reprint the join command when it expired
API Server failed communication: Must have a static IP to the master node.
References
https://github.com/LondheShubham153/kubestarter/blob/main/kubeadm_installation.md
https://www.learnlinux.tv/how-to-build-an-awesome-kubernetes-cluster-using-proxmox-virtual-environment/
