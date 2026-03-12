output "k8s_service_account_name" {
  value       = module.sa.k8s_service_account_name
  description = "Name of the created Kubernetes Service Account"
}

output "gcp_service_account_email" {
  value       = module.sa.gcp_service_account_email
  description = "Email of the created GCP Service Account"
}

output "workflow_name" {
  value       = var.name
  description = "Name of the created Argo WorkflowTemplate"
}
