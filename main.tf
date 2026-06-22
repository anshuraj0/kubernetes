provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "tf_state_bucket" {
  name          = "anshu-tf-state"  # Replace with a unique bucket name
  location      = "US"                # Adjust the location as needed
}

module "bastion" {
 source     = "./modules/bastion"
 bastion_name = var.bastion_name
 region     = var.region
 network    = module.gke_cluster.network
 public_subnet = module.gke_cluster.public_subnet
 vpc        = module.gke_cluster.vpc
}


module "gke_cluster" {
  source       = "./modules/gke"
  username     = data.google_secret_manager_secret_version.username.secret_data
  password     = data.google_secret_manager_secret_version.password.secret_data

}