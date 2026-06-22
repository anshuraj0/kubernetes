resource "google_compute_instance" "bastion" {
  name         = "${var.bastion_name}"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.public_subnet
    access_config {

    }
  }

  metadata = {
    ssh-keys = "terraform:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "allow_ssh_ingress" {
  name    = "bastion-allow-ssh-ingress"
  network = "anshu-network"

  # Priority of the rule (default is 1000)
  priority    = 1000
  direction   = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  # Protocol and port (allow SSH)
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion-host"]

  # Enabling the rule (optional)
  disabled = false
}
