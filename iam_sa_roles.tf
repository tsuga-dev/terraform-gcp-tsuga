# Grant project-level roles to the builder SA (for cluster/VPC/etc.)
resource "google_project_iam_member" "builder_roles" {
  for_each = toset(var.builder_project_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.builder.email}"

  depends_on = [google_project_service.enabled]
}

data "google_project" "this" {
  project_id = var.project_id
}

# Allow the builder SA to "actAs" the default Compute Engine service account
resource "google_service_account_iam_member" "builder_act_as_default_compute" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.builder.email}"

  depends_on = [google_project_service.enabled]
}

resource "google_project_iam_member" "builder_container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.builder.email}"
}
