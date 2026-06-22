terraform {
  backend "gcs" {
    bucket  = "anshu-tf-state"
    prefix      = "terraform/state"

  }
}