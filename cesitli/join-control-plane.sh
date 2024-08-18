#!/bin/bash
set -e
#######################################################
# Author    : Ahmet Önder Moğol
#######################################################


# Join as a control plane

# on master/control plane
kubeadm token create --print-join-command

# Get certificate key
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'


# on expected new control plane
sudo kubeadm reset pre-flight checks

sudo kubeadm join <control_plane_endpoint>:<port> --token <token> --discovery-token-ca-cert-hash sha256:<discovery_token_ca_cert_hash> --control-plane --certificate-key <certificate_key>
