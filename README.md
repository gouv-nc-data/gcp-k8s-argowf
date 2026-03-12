# GCP Argo Workflow Terraform Module

Ce module permet de déclarer un **Argo WorkflowTemplate** sur un cluster GKE tout en gérant l'authentification **Workload Identity** (GCP Service Account) de manière isolée par projet métier.

Il appelle en interne le module [gcp-k8s-iam](https://github.com/gouv-nc-data/gcp-k8s-iam) pour la gestion des permissions.

## Utilisation

```hcl
module "sydonia_pipeline" {
  source     = "git::https://github.com/gouv-nc-data/gcp-k8s-argowf.git//?ref=v1.0.0"
  name       = "sydonia-db-to-bq"
  project_id = "prj-drd-p-bq-0b3e"
  namespace  = "drd-jobs"

  gcp_roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
  ]

  secrets = {
    DB_URL_SECRET = "sydonia-url-dlt-secret"
  }

  workflow_spec = {
    entrypoint = "pipeline"
    templates = [
      {
        name = "pipeline"
        steps = [
          [{ name = "step1", template = "container-step" }]
        ]
      },
      {
        name = "container-step"
        container = {
          image   = "alpine"
          command = ["echo", "hello"]
        }
      }
    ]
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
