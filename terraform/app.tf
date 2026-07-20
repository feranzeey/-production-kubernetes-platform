resource "null_resource" "deploy_app" {
  provisioner "local-exec" {
    command = "kubectl apply -f ../kubernetes/app.yaml"
  }
}