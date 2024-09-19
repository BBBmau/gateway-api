# gateway-api
Provide an example of a working k8s cluster that implements the gateway api. The goal is to make it be usable by anyone that just clones the repo.

### 1. Install Gateway Resources (GatewayClass, Gateway, HTTPRoute, and ReferenceGrant)
`kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml`

## GatewayClass acts as a template for a Gateway resource that tells it how to handle traffic coming into the infrastructure. There's a long list of different GatewayClasses to choose from but for this demo we'll be using the `NGINX Gateway Fabric` GatewayClass
