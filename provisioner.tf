resource "null_resource" "apply_kubectl" {
  provisioner "local-exec" {
    command = "kubectl apply -f k8s-manifests/"
  }
}