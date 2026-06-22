data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}


# Provide time for Service cleanup
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.default]

  destroy_duration = "180s"
}

resource "google_compute_network" "default" {
  name = "anshu-network"

  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "default" {
  name = "private-subnetwork"

  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "INTERNAL" 
  private_ip_google_access = true #  private subnets

  network = google_compute_network.default.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.1.0/24"
  }
}

resource "google_compute_subnetwork" "public_subnet" {
  name = "public-subnetwork"

  ip_cidr_range = "10.1.0.0/24"
  region        = "us-central1"

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL" 

  network = google_compute_network.default.id
  private_ip_google_access = false # public subnets

  secondary_ip_range {
    range_name    = "public-services-range"
    ip_cidr_range = "192.168.4.0/24"
  }

  secondary_ip_range {
    range_name    = "public-pod-ranges"
    ip_cidr_range = "192.168.5.0/24"
  }
}

resource "google_container_cluster" "default" {
  name = "gke-cluster"

  location                 = "us-central1"
  enable_autopilot         = true
  enable_l4_ilb_subsetting = true

  network    = google_compute_network.default.id
  subnetwork = google_compute_subnetwork.default.id

  ip_allocation_policy {
    stack_type                    = "IPV4_IPV6"
    services_secondary_range_name = google_compute_subnetwork.default.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.default.secondary_ip_range[1].range_name
  }
  # private_cluster_config {
  #   enable_private_nodes = true
  #   enable_private_endpoint = true

  # }

  # master_authorized_networks_config {

  #   // Add your authorized networks here
  #   // Example: Allow access from a specific CIDR block
  #   cidr_blocks {
  #     cidr_block = "203.0.113.0/24"
  #     display_name = "Authorized Network"
  #   }
  # }

  deletion_protection = false
}

