data "google_secret_manager_secret_version" "username" {
  secret = "username"
  version = "latest"
}

data "google_secret_manager_secret_version" "password" {
  secret = "password"
  version = "latest"
}