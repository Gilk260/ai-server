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

# Bootstrap root Application -- discovers all ApplicationSets in infra-gitops/bootstrap/
resource "null_resource" "argocd_root_app" {
  depends_on = [helm_release.argocd]

  triggers = {
    argocd_revision = helm_release.argocd.version
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${path.module}/k3s-config.yaml"
    }
    command = <<-EOT
      echo "Waiting 30s for ArgoCD to be ready..."
      sleep 30

      kubectl apply -f - <<'EOF'
      apiVersion: argoproj.io/v1alpha1
      kind: Application
      metadata:
        name: root
        namespace: argocd
      spec:
        project: default
        source:
          repoURL: https://github.com/Gilk260/infra-gitops.git
          targetRevision: main
          path: bootstrap
        destination:
          server: https://kubernetes.default.svc
          namespace: argocd
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
      EOF

      echo "Root Application created"
    EOT
  }
}
