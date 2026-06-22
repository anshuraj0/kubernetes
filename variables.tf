variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
}

variable "bastion_name" {
  description = "Bastion host name"
  type        = string
}

variable "cluster_name" {
  description = "GKE Cluster name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Helm deployments"
  type        = string
}
