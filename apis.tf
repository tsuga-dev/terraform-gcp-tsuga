# Enable required APIs; Terraform waits for activation
resource "google_project_service" "enabled" {
  for_each           = toset(var.apis_to_enable)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}
