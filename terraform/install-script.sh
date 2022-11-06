#!/usr/bin/env bash
set -e
if
sudo dnf update -y
sudo dnf install epel-release -y
sudo dnf install -y git podman netavark zip unzip python3
sudo python3 -m pip install --upgrade pip
sudo pip3 install podman-compose azure-cli
mkdir -p /etc/containers
cat << 'EOF' | sudo tee /etc/containers/containers.conf
[network]
# Explicitly force "netavark" as to not use the outdated CNI networking, which it would not apply otherwise as long as old stuff is there.
# This may be removed once all containers were upgraded?
# see https://discussion.fedoraproject.org/t/how-to-get-podman-dns-plugin-container-name-resolution-to-work-in-fedora-coreos-36-podman-plugins-podman-dnsname/39493/5?u=rugk
# official doc:
# Network backend determines what network driver will be used to set up and tear down container networks.
# Valid values are "cni" and "netavark".
# The default value is empty which means that it will automatically choose CNI or netavark. If there are
# already containers/images or CNI networks preset it will choose CNI.
#
# Before changing this value all containers must be stopped otherwise it is likely that
# iptables rules and network interfaces might leak on the host. A reboot will fix this.
#
network_backend = "netavark"
EOF
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install vault
then
exit 0
else
exit 1
fi