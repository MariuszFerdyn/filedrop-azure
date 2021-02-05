#!/bin/bash
sudo apt-get update

# install k3s
curl -sfL https://get.k3s.io | sh -
mkdir ~/.kube && sudo install -T /etc/rancher/k3s/k3s.yaml ~/.kube/config -m 600 -o $USER

# install kubectl and helm
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
echo "Stage 01: Done installing kubectl"

curl -sfL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
echo "Stage 02: Done installing helm"

# get source code
git clone https://github.com/k8-proxy/k8-rebuild.git --recursive && cd k8-rebuild && git submodule foreach git pull origin main
echo "Stage 03: Done clone source code"

# build docker images
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y
echo "Stage 04: Docker Images"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
echo "Stage 05: Docker Images"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install docker-ce docker-ce-cli containerd.io -y
echo "Stage 06: Done Docker Images"

# install local docker registry
sudo docker run -d -p 30500:5000 --restart always --name registry registry:2
echo "Stage 07: Done installing docker registry"
# build images
sudo docker build k8-rebuild-rest-api -f k8-rebuild-rest-api/Source/Service/Dockerfile -t localhost:30500/k8-rebuild-rest-api
echo "Stage 08: Building images"
sudo docker push localhost:30500/k8-rebuild-rest-api
echo "Stage 09: Building images"
sudo docker build k8-rebuild-file-drop/app -f k8-rebuild-file-drop/app/Dockerfile -t localhost:30500/k8-rebuild-file-drop
echo "Stage 10: Building images"
sudo docker push localhost:30500/k8-rebuild-file-drop
echo "Stage 11: Building images"
cat >> kubernetes/values.yaml <<EOF

sow-rest-api:
  image:
    registry: localhost:30500
    repository: k8-rebuild-rest-api
    imagePullPolicy: Never
    tag: latest
sow-rest-ui:
  image:
    registry: localhost:30500
    repository: k8-rebuild-file-drop
    imagePullPolicy: Never
    tag: latest
EOF
echo "Stage 12: Config saved"
# install UI and API helm charts
helm upgrade --install k8-rebuild --set nginx.service.type=ClusterIP --atomic kubernetes/
echo "Stage 13: Finish"
