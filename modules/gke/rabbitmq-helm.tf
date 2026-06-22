provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.default.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)
  }
}

resource "helm_release" "rabbitmq" {
  name       = "rabbbit-mq"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  version    = "14.6.6"  # specify the desired version
  timeout    = "10000"  # Increase timeout to 10 minutes or as needed

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "rabbitmq.username"
    value = "${var.username}"  
  }

  set {
    name  = "rabbitmq.password"
    value = "${var.password}"  
  }

  set {
    name  = "service.type"
    value = "ClusterIP"  # Or "ClusterIP" if you don’t need an external IP
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.size"
    value = "8Gi"
  }

  set {
    name  = "resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "250m"
  }

  set {
    name  = "resources.limits.memory"
    value = "1Gi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }
}
