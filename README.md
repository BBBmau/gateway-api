# gateway-api
Provide an example of a working k8s cluster that implements the gateway api. The goal is to make it be usable by anyone that just clones the repo.

## 1. Setup kind cluster
We need to do some nodePort mapping in order to communicate with the gateway inside the kind cluster (Kubernetes IN Docker)

`kind create cluster --config clusterConfig.yaml --name gateway-testing`

Related Documentation: https://docs.nginx.com/nginx-gateway-fabric/installation/running-on-kind/

## 2. Install Gateway Resources (GatewayClass, Gateway, HTTPRoute, and ReferenceGrant)
This will install the gateway API resources onto your kind cluster that we've setup

`kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml`

## 3. Attaching the application to an HTTPRoute resource
We now have access to Gateway CRDs, however we'll need a simple app where we send traffic to with `HTTPRoute`.

The `coffeeShop` directory has a `deployment.yaml` and `service.yaml` file for setting up a simple app that will be connected to our gateway through a `HTTPRoute` resource.

Configure both service and deployment of coffeeShop:

`kubectl apply -f coffeeShop/deployment.yaml`

`kubectl apply -f coffeeShop/service.yaml`

Configure the `HTTPRoute`, this will allow the gateway resource to send the traffic received to route referenced

`kubectl apply -f gatewayConfigs/httpRoute.yaml`

### GatewayClass acts as a template for a Gateway resource that tells it how to handle traffic coming into the infrastructure. There's a long list of different GatewayClasses to choose from but for this demo we'll be using the `NGINX Gateway Fabric` GatewayClass
 In order to make use of the resources for `NGINX Gateway Fabric` we must deploy the `NGINX Gateway Fabric` CRDs on our cluster.

 `kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.4.0/deploy/crds.yaml`

## 4. Deploy `NGINX Gatway Fabric`
`kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.4.0/deploy/default/deploy.yaml`

We can verify the deployment by running: `kubectl get pods -n nginx-gateway`

The output should be:
```
NAME                             READY   STATUS    RESTARTS   AGE
nginx-gateway-5d4f4c7db7-xk2kq   2/2     Running   0          112s
```

### Accessing the Gateway

Since we are testing within a kind cluster we'll use a `NodePort` service in order to accept NodePort traffic going into the `nginx-gateway` service.

`kubectl apply -f nodePortSvc.yaml`

The `nodePortSvc` will handle port forwarding for you automatically, but you can also open a second terminal and run this command to achieve the same:

`kubectl -n nginx-gateway port-forward <pod-name> 8080:80 8443:443`

`<pod-name>` is obtained when running `kubectl -n nginx-gateway get pods`

```
└─(11:35:46 on main ✹)──> kubectl -n nginx-gateway get pods                                          ──(Thu,Sep19)─┘
NAME                            READY   STATUS    RESTARTS   AGE
nginx-gateway-bccf868b6-vr8vh   2/2     Running   0          2m11s
```

Typically when setting up the Gateway we would obtain the IP address and Port of the gateway itself by running the following:
`kubectl get svc nginx-gateway -n nginx-gateway`

Although this does return information about the gateway resource, because we are running this in kind for testing purposes we instead want access to the container itself where the cluster is being run in: `docker ps`
```
CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS        PORTS                                                                         NAMES
8d1d89935e69   kindest/node:v1.31.0   "/usr/local/bin/entr…"   11 hours ago    Up 11 hours   127.0.0.1:64562->6443/tcp, 0.0.0.0:8080->31437/tcp, 0.0.0.0:8443->31438/tcp   gateway-testing-control-plane
```
What's important to use is the `PORTS` column, this is what we use in place of the gateway IP/ports

`export GW_IP=0.0.0.0`
`export GW_PORT=8080`


## 5. Testing the configuration
`curl --resolve cafe.example.com:$GW_PORT:$GW_IP http://cafe.example.com:$GW_PORT/`

You should get the following:

```
└─(11:23:04 on main ✹)──> curl -k --resolve cafe.example.com:$GW_PORT:$GW_IP http://cafe.example.com:$GW_PORT/
Server address: 10.244.0.7:8080
Server name: coffee-6db967495b-shh5b
Date: 19/Sep/2024:18:23:06 +0000
URI: /
Request ID: 7a88880d7e40ed3a00e134bcf586073e
```