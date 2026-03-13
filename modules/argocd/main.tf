resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.1.0"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    file(var.helm_values_path)
  ]

  # Dynamic cluster-specific overrides
  set = [
    {
      name  = "global.domain"
      value = "argocd.${var.cluster_domain}"
    },
    {
      name  = "server.ingress.hostname"
      value = "argocd.${var.cluster_domain}"
    },
    {
      name  = "configs.clusterCredentials.in-cluster.name"
      value = var.cluster_name
    },
    {
      name  = "configs.clusterCredentials.in-cluster.labels.cluster-name"
      value = var.cluster_name
    },
    {
      name  = "configs.clusterCredentials.in-cluster.labels.env"
      value = var.cluster_name
    },
  ]

  set_sensitive = [
    {
      name  = "configs.repositories.infra-gitops.githubAppPrivateKey"
      value = file(var.private_key_path)
    },
  ]
}
