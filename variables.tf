variable "project_id" {
  description = "Customer GCP project ID where Tsuga will be deployed"
  type        = string

}
variable "region" {
  description = "Default region (e.g. europe-west1)"
  type        = string
}

variable "builder_sa_name" {
  type    = string
  default = "tsuga-builder"
}

# The Spacelift GCP Integration Service Account email
variable "spacelift_integration_sa_email" {
  type        = string
  description = "Spacelift GCP Integration service account email"
}

# Dev impersonators (users/groups) who may generate tokens for the builder SA
variable "developer_impersonators" {
  type        = list(string)
  description = "Human identities with Token Creator on the builder SA"
  default = [
    "group:gcp-organization-admins@tsuga.com",
  ]
}

variable "apis_to_enable" {
  type = list(string)
  default = [
    "artifactregistry.googleapis.com",
    "certificatemanager.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "pubsub.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "sts.googleapis.com",
  ]
}

# Project-level roles for the builder SA
variable "builder_project_roles" {
  type = list(string)
  default = [
    "roles/container.clusterAdmin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/servicenetworking.networksAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/pubsub.admin",
    "roles/certificatemanager.editor",
    "roles/cloudsql.admin",
    "roles/serviceusage.serviceUsageAdmin",
  ]
}
