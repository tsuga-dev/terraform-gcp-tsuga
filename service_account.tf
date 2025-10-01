# The builder service account used by Pulumi/Terraform
resource "google_service_account" "builder" {
  account_id   = var.builder_sa_name
  display_name = "Tsuga Builder"
  project      = var.project_id
  depends_on   = [google_project_service.enabled]
}
