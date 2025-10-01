###############################################
# Spacelift GCP Integration → impersonate builder
###############################################

# The integration SA must have Token Creator on the target SA to call
# iamcredentials.generateAccessToken.
resource "google_service_account_iam_member" "spacelift_integration_token_creator" {
  service_account_id = google_service_account.builder.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.spacelift_integration_sa_email}"

  depends_on = [google_project_service.enabled]
}

###############################################
# Developers → Token Creator on builder
###############################################
resource "google_service_account_iam_member" "dev_token_creator" {
  for_each           = toset(var.developer_impersonators)
  service_account_id = google_service_account.builder.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.key

  depends_on = [google_project_service.enabled]
}
