variable "project_id" {
  description = "The GCP project ID where the resources will be created"
  type        = string
}

variable "name" {
  description = "Name used for the Service Account and WorkflowTemplate"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace where the resources will be created"
  type        = string
}

variable "gcp_roles" {
  description = "List of GCP IAM roles to assign to the Service Account"
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "Map of secret names to grant access to"
  type        = map(string)
  default     = {}
}

variable "k8s_custom_roles" {
  description = "Custom Kubernetes roles to create and bind"
  type = list(object({
    name = string
    rules = list(object({
      api_groups = list(string)
      resources  = list(string)
      verbs      = list(string)
    }))
  }))
  default = []
}

variable "k8s_external_roles" {
  description = "Existing Kubernetes roles (Role or ClusterRole) to bind"
  type = list(object({
    kind = string
    name = string
  }))
  default = []
}

variable "workflow_spec" {
  description = "The spec part of the Argo WorkflowTemplate"
  type        = any
}

variable "cron_schedule" {
  description = "Cron schedule for the workflow (e.g. '0 1 * * *'). If null, no CronWorkflow is created."
  type        = string
  default     = null
}
