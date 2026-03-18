locals {
  # Fusion des variables d'environnement calculées
  # On injecte GOOGLE_CLOUD_PROJECT par défaut s'il n'est pas dans var.env_vars
  all_env_vars = merge(
    { GOOGLE_CLOUD_PROJECT = var.project_id },
    var.env_vars
  )

  # Nom du bucket (doit être unique globalement)
  staging_bucket_name = "dlt-staging-${var.name}-${var.project_id}"

  # Génération des variables au format Argo
  automatic_env = concat(
    [for k, v in local.all_env_vars : { name = k, value = v }],
    [for k, v in var.secrets : { name = k, value = "projects/${var.secret_project_id}/secrets/${v}/versions/latest" }],
    var.create_staging_bucket ? [{ name = "BUCKET_URL", value = "gs://${local.staging_bucket_name}" }] : []
  )

  # Reconstruction du workflow_spec avec injection dans les templates de type 'container'
  # On utilise merge(t, ...) au lieu d'un ternaire t ? a : b pour éviter les erreurs de types sur les listes hétérogènes
  patched_workflow_spec = jsondecode(jsonencode(merge(var.workflow_spec, {
    templates = [
      for t in lookup(var.workflow_spec, "templates", []) :
      merge(t, can(t.container) ? {
        container = merge(t.container, {
          env = concat(
            try(t.container.env, []),
            local.automatic_env
          )
        })
      } : {})
    ]
  })))
}

# Module IAM pour la création du SA K8s/GCP
module "sa" {
  source = "git::https://github.com/gouv-nc-data/gcp-k8s-iam.git//?ref=main"

  name              = var.name
  namespace         = var.namespace
  project_id        = var.project_id
  gcp_roles         = var.gcp_roles
  secrets           = var.secrets
  secret_project_id = var.secret_project_id
  k8s_custom_roles  = var.k8s_custom_roles
  k8s_external_roles = concat([
    {
      kind = "ClusterRole"
      name = "argo-task-results"
    }
  ], var.k8s_external_roles)
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
    spec = merge(local.patched_workflow_spec, {
      serviceAccountName = module.sa.k8s_service_account_name
    })
  }
}

# Déclencheur Cron (optionnel)
resource "kubernetes_manifest" "cron_workflow" {
  count = var.cron_schedule != null ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "CronWorkflow"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      schedule = var.cron_schedule
      workflowSpec = {
        workflowTemplateRef = {
          name = kubernetes_manifest.workflow_template.manifest.metadata.name
        }
      }
    }
  }
}

# Ressources pour le staging GCS (optionnel)
resource "google_storage_bucket" "staging" {
  count    = var.create_staging_bucket ? 1 : 0
  project  = var.project_id
  name     = local.staging_bucket_name
  location = var.staging_bucket_location

  force_destroy               = true
  uniform_bucket_level_access = true

  public_access_prevention = "enforced"
}

resource "google_storage_bucket_iam_member" "staging_access" {
  count  = var.create_staging_bucket ? 1 : 0
  bucket = google_storage_bucket.staging[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.sa.gcp_service_account_email}"
}

