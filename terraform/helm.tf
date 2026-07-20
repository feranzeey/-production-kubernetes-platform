resource "helm_release" "ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.15.1"
  namespace  = "ingress"

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
}

resource "helm_release" "monitoring" {
  name       = "monitoring"

  repository = "https://prometheus-community.github.io/helm-charts"

  chart = "kube-prometheus-stack"

  namespace = "monitoring"
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"

  repository = "https://charts.jetstack.io"

  chart = "cert-manager"

  namespace = "cert-manager"

  set {
    name  = "crds.enabled"
    value = "true"
  }
}