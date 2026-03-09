resource "helm_release" "argocd" {
  depends_on = [null_resource.k3s_kubeconfig]

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.1.0"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    file("${path.module}/helm/argocd.yaml")
  ]

  set_sensitive = [
    {
      name  = "configs.repositories.infra-gitops.githubAppPrivateKey"
      value = file("${path.module}/../private_key/argocd-infra-gitops.pem")
    },
  ]
}
