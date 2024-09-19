resource "kubernetes_service_v1" "coffee_service" {
  metadata {
    name = "coffee"
  }
  spec {
    port {
      port = 80
      target_port = 8080
      protocol = "TCP"
      name = "http"
    }
    selector = {
      app = "coffee"
    }
  }
}

resource "kubernetes_deployment_v1" "coffee_deployment" {
  metadata {
    name = "coffee"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "coffee" 
      }
      
    }
    template {
      metadata {
        labels = {
          app = "coffee"
        }
      }
      spec {
        container {
          name = "coffee"
          image = "nginxdemos/nginx-hello:plain-text"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "node_port" {
  metadata {
    name = "nginx-gateway"
    namespace = "nginx-gateway"
    labels = {
    "app.kubernetes.io/name"= "nginx-gateway"
    "app.kubernetes.io/instance"= "nginx-gateway"
    "app.kubernetes.io/version"= "1.4.0"
    }
  }
  spec {
    type = "NodePort"
    selector = {
        "app.kubernetes.io/name"= "nginx-gateway"
        "app.kubernetes.io/instance"= "nginx-gateway"
    }
    port {
      name = "http"
      port = 80
      protocol = "TCP"
      target_port = 80
      node_port = 31437
    }
    port {
      name = "https"
      port = 443
      protocol = "TCP"
      target_port = 443
      node_port = 31438
    }
  }
}

resource "kubernetes_manifest" "httproute_coffee" {
  depends_on = [ kubernetes_service_v1.node_port ]

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind" = "HTTPRoute"
    "metadata" = {
      "name" = "coffee"
      "namespace" = "default"
    }
    "spec" = {
      "hostnames" = [
        "cafe.example.com",
      ]
      "parentRefs" = [
        {
          "name" = "cafe"
        },
      ]
      "rules" = [
        {
          "backendRefs" = [
            {
              "name" = "coffee"
              "port" = 80
            },
          ]
          "matches" = [
            {
              "path" = {
                "type" = "PathPrefix"
                "value" = "/"
              }
            },
          ]
        },
      ]
    }
  }
}


resource "kubernetes_manifest" "gateway_cafe" {
    depends_on = [ kubernetes_service_v1.node_port ]
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind" = "Gateway"
    "metadata" = {
      "name" = "cafe"
      "namespace" = "default"
    }
    "spec" = {
      "gatewayClassName" = "nginx"
      "listeners" = [
        {
          "name" = "http"
          "port" = 80
          "protocol" = "HTTP"
        },
      ]
    }
  }
}