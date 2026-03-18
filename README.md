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
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sa"></a> [sa](#module\_sa) | git::https://github.com/gouv-nc-data/gcp-k8s-iam.git// | main |

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.staging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.staging_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [kubernetes_manifest.cron_workflow](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.workflow_template](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_staging_bucket"></a> [create\_staging\_bucket](#input\_create\_staging\_bucket) | Créer un bucket GCS pour le staging (DLT) | `bool` | `false` | no |
| <a name="input_cron_schedule"></a> [cron\_schedule](#input\_cron\_schedule) | Cron schedule for the workflow (e.g. '0 1 * * *'). If null, no CronWorkflow is created. | `string` | `null` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Map of environment variables to inject in all container templates | `map(string)` | `{}` | no |
| <a name="input_gcp_roles"></a> [gcp\_roles](#input\_gcp\_roles) | List of GCP IAM roles to assign to the Service Account | `list(string)` | `[]` | no |
| <a name="input_k8s_custom_roles"></a> [k8s\_custom\_roles](#input\_k8s\_custom\_roles) | Custom Kubernetes roles to create and bind | <pre>list(object({<br/>    name = string<br/>    rules = list(object({<br/>      api_groups = list(string)<br/>      resources  = list(string)<br/>      verbs      = list(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_k8s_external_roles"></a> [k8s\_external\_roles](#input\_k8s\_external\_roles) | Existing Kubernetes roles (Role or ClusterRole) to bind | <pre>list(object({<br/>    kind = string<br/>    name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name used for the Service Account and WorkflowTemplate | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The Kubernetes namespace where the resources will be created | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID where the resources will be created | `string` | n/a | yes |
| <a name="input_secret_project_id"></a> [secret\_project\_id](#input\_secret\_project\_id) | ID du projet contenant les secrets GCP | `string` | `"prj-dinum-p-secret-mgnt-aaf4"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secret names to grant access to | `map(string)` | `{}` | no |
| <a name="input_staging_bucket_location"></a> [staging\_bucket\_location](#input\_staging\_bucket\_location) | Localisation du bucket de staging | `string` | `"EU"` | no |
| <a name="input_workflow_spec"></a> [workflow\_spec](#input\_workflow\_spec) | The spec part of the Argo WorkflowTemplate | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_service_account_email"></a> [gcp\_service\_account\_email](#output\_gcp\_service\_account\_email) | Email of the created GCP Service Account |
| <a name="output_k8s_service_account_name"></a> [k8s\_service\_account\_name](#output\_k8s\_service\_account\_name) | Name of the created Kubernetes Service Account |
| <a name="output_workflow_name"></a> [workflow\_name](#output\_workflow\_name) | Name of the created Argo WorkflowTemplate |
<!-- END_TF_DOCS -->
