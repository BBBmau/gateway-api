# gateway-api
Provide an example of a working k8s cluster that implements the gateway api. The goal is to make it be usable by anyone that just clones the repo.

### 1. Setup kind cluster
We need to do some nodePort mapping in order to communicate with the gateway inside the kind cluster (Kubernetes IN Docker)
`kind create cluster --config clusterConfig.yaml --name gateway-testing`

Because we are using NodePorting we'll also require a service of type `NodePort` in order to accept NodePort traffic going into the `nginx-gateway` service. (This will be setup later on)
`kubectl apply -f nodePortSvc.yaml`

Related Documentation: https://docs.nginx.com/nginx-gateway-fabric/installation/running-on-kind/

### 2. Install Gateway Resources (GatewayClass, Gateway, HTTPRoute, and ReferenceGrant)
`kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml`

## GatewayClass acts as a template for a Gateway resource that tells it how to handle traffic coming into the infrastructure. There's a long list of different GatewayClasses to choose from but for this demo we'll be using the `NGINX Gateway Fabric` GatewayClass
 In order to make use of the resources for `NGINX Gateway Fabric` we must deply the `NGINX Gateway Fabric` CRDs on our cluster.
 `kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.4.0/deploy/crds.yaml`

