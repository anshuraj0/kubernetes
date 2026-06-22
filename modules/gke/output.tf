output "cluster" {
  value = google_container_cluster.default
}

output "vpc" {
  value = google_container_cluster.default.network
}

output "network" {
  value = google_compute_network.default.name
}

output "subnetwork" {
  value = google_compute_subnetwork.default.name
}

output "public_subnet" {
  value = google_compute_subnetwork.public_subnet.name
}