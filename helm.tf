resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

 set = [
    {
      name  = "controller.hostNetwork"
      value = "true"
    },
    {
      name  = "controller.kind"
      value = "DaemonSet"
    },
    {
      name  = "controller.service.type"
      value = "ClusterIP"  # Optional: won’t be used if hostNetwork is set
    }
  ]
}
