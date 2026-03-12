# Module IAM pour la création du SA K8s/GCP
module "sa" {
  source = "git::https://github.com/gouv-nc-data/gcp-k8s-iam.git//?ref=main"

  name               = var.name
  namespace          = var.namespace
  project_id         = var.project_id
  gcp_roles          = var.gcp_roles
  secrets            = var.secrets
  k8s_custom_roles   = var.k8s_custom_roles
  k8s_external_roles = var.k8s_external_roles
}

# Définition du WorkflowTemplate Argo
resource "kubernetes_manifest" "workflow_template" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "WorkflowTemplate"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = merge(var.workflow_spec, {
      serviceAccountName = module.sa.k8s_service_account_name
    })
  }
}
