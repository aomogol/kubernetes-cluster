#!/bin/bash
set -e
#######################################################
# Author    : Ahmet Önder Moğol
#######################################################


# on expected new control plane
sudo kubeadm reset pre-flight checks

# sudo kubeadm join <control_plane_endpoint>:<port> --token <token> --discovery-token-ca-cert-hash sha256:<discovery_token_ca_cert_hash> --control-plane --certificate-key <certificate_key>

