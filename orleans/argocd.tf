resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.8.0"
  namespace        = "argocd"
  create_namespace = true

  values = [
    file("${path.module}/helm/argocd.yaml")
  ]

  set_sensitive = [
    {
      name  = "configs.repositories.infra-gitops.githubAppPrivateKey"
      value = file("${path.module}/private_key/argocd-infra-gitops.pem")
    },
  ]
}
