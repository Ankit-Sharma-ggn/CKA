#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'
echo END

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

#update resolv.conf so it can resolv AD domain names
echo "DNS=${dns_ip1} ${dns_ip2}" >> /etc/systemd/resolved.conf
echo "Domains=${domain}" >> /etc/systemd/resolved.conf
service systemd-resolved restart
## pagj9U7Z3L6Y2Ml

# disable nameserver inherited via AWS DHCP
if [ ! -f /etc/netplan/50-cloud-init.yaml.bak ]; then
    cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak -f
fi
cat /etc/netplan/50-cloud-init.yaml.bak | sed -e 's/dhcp4: true/dhcp4: true\n            dhcp4-overrides:\n                use-dns: false/' > /etc/netplan/50-cloud-init.yaml
chmod 600 /etc/netplan/50-cloud-init.yaml
netplan apply
service systemd-resolved restart

# install docker-ce
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

#cleaning up 
sudo apt-get autoclean -y

#installing ansible and ansible builder
sudo apt-get update
sudo apt install python3-pip -y
pip3 install ansible
pip3 install ansible-builder==3

#Installing K3s
curl -sfL https://get.k3s.io | sh -s - --docker

#Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

#create kustomization.yaml and awx.yaml
cat <<EOT >> kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  # Add this extra line:
resources:
- github.com/ansible/awx-operator/config/default?ref=2.7.1
- awx.yaml
# Set the image tags to match the git version from above
images:
- name: quay.io/ansible/awx-operator
  newTag: 2.7.1
# Specify a custom namespace in which to install AWX
namespace: awx
EOT

cat <<EOT >> awx.yaml
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
spec:
  service_type: nodeport
  nodeport_port: 30080
  no_log: false
  ipv6_disabled: true
EOT

#deploy the awx operator
./kustomize build . | kubectl apply -f - || true

#Allowing Kustomize to deploy on CRD's
sleep 30

#Retry Kustomise deploy
./kustomize build . | kubectl apply -f -

sleep 300

echo "waiting for 5 minutes, waiting for pods to get up and running"
kubectl delete pod awx-postgres-13-0 -n awx


#create the execution-environment.yaml
cat <<EOT >> execution-environment.yml
version: 3

build_arg_defaults:
  ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '--pre'

dependencies:
  ansible_core:
    package_pip: ansible-core==2.18.6
  ansible_runner:
    package_pip: ansible-runner
  galaxy: requirements.yml
  python: requirements.txt
  system: bindep.txt

images:
  base_image:
    name: quay.io/centos/centos:stream10

additional_build_steps:
  append_final:
    - COPY --from=quay.io/project-receptor/receptor:0.9.7 /usr/bin/receptor /usr/bin/receptor
    - RUN mkdir -p /var/run/receptor
    - RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip --output /tmp/awscliv2.zip
    - RUN cd /tmp && unzip /tmp/awscliv2.zip
    - RUN /tmp/aws/install
EOT

#create requirements.yml
cat <<EOT >> requirements.yml
collections:
  - name: ansible.windows
  - name: community.windows
  - name: citrix.adc
EOT

#create requirements.txt
cat <<EOT >> requirements.txt
urllib3
git+https://github.com/ansible/ansible-builder.git@devel#egg=ansible-builder
pywinrm
pexpect
requests-credssp
requests
EOT

# bindep
cat <<EOT >> bindep.txt
unzip [platform:rpm]
zip [platform:rpm]
expect [platform:rpm]
sshpass [platform:rpm]
git-lfs [platform:rpm]
EOT

#context.sh
mkdir /context
cat <<EOT >> context/run.sh
#! /bin/bash
ansible-runner worker --private-data-dir=/runner
EOT

ansible-builder build --tag quay.io/spendscape/awx-ee:latest --context ./context --container-runtime docker 

#Reboot to apply kernel
apt update && apt upgrade -y
reboot
