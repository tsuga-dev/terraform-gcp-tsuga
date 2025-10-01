output "builder_service_account_email" {
  description = "Email of the builder service account the CI will impersonate via WIF"
  value       = google_service_account.builder.email
}

output "enabled_apis" {
  description = "APIs enabled in the project"
  value       = [for s in google_project_service.enabled : s.service]
}
