# Helm-hadoop

## Usage

### macOS

#### Prerequisites
```shell
brew install qemu socket_vmnet helm
```

#### Setup
```shell
# Start minikube
minikube start --driver qemu --network socket_vmnet --cpus "$(($(nproc) / 2))" --memory "$(nproc)g"

# Build the image and load it to minikube
docker/build_image.sh

helm install --name-template=hadoop .
```

#### Access Services
```shell
# Set route up
sudo route -n delete 10.244.0.0/16
sudo route -n add 10.244.0.0/16 "$(minikube ip)"

# Don't kill this process
minikube tunnel
```

#### Test
```shell
ping nn-0.namenode.default.svc.cluster.local

curl -L http://nn-0.namenode.default.svc.cluster.local:50070/
```
