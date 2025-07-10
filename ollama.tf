resource "kubernetes_namespace" "ollama" {
  metadata {
    annotations = {
      name = "ollama"
    }

    labels = {
      mylabel = "ollama"
    }

    name = "ollama"
  }
}

resource "kubernetes_deployment" "ollama" {
  depends_on = [ kubernetes_namespace.ollama, proxmox_virtual_environment_vm.worker ]

  metadata {
    name = "ollama"
    namespace = "ollama"
    labels = {
      app = "ollama"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "ollama"
      }
    }
    template {
      metadata {
        labels = {
          app = "ollama"
        }
      }
      spec {
        container {
          image = "ollama/ollama:latest"
          name = "ollama"

          port {
            container_port = 11434
            name = "http"
            protocol = "TCP"
          }

          lifecycle {
            post_start {
              exec {
                command = ["/bin/sh", "-c", "ollama pull starcoder2:3b"]
              }
            }
          }

          volume_mount {
            mount_path = "/root/.ollama"
            name = "ollama-storage"
          }

          env {
            name = "OLLAMA_KEEP_ALIVE"
            value = "12h"
          }
        }

        volume {
          host_path {
            path = "/opt/ollama"
            type = "DirectoryOrCreate"
          }
          name = "ollama-storage"
        }
      }
    }
  }
}

resource "kubernetes_service" "ollama" {
  depends_on = [ kubernetes_namespace.ollama ]

  metadata {
    name = "ollama"
    namespace = "ollama"
    labels = {
      app = "ollama"
    }
  }

  spec {
    selector = {
      app = "ollama"
    }
    port {
      port = 80
      name = "http"
      target_port = "http"
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "ollama" {
  depends_on = [ kubernetes_service.ollama ]

  metadata {
    name = "ollama"
    namespace = "ollama"
    labels = {
      app = "ollama"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "perso.ollama.ai"

      http {
        path {
          path = "/()(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service.ollama.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
