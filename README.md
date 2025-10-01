# Tsuga GCP Project Customer Onboarding

This Terraform config prepares **your GCP project** so Tsuga can deploy and manage resources **without long-lived keys**.

It uses **Service Account → Service Account impersonation** via the **IAM Credentials API**. Tsuga’s CI (Spacelift **GCP Integration Service Account**) and approved developer identities are granted **Token Creator** on a *builder* service account.

---

## What these Terraform files do

1. **Enables required Google Cloud APIs** in your project.
2. **Creates a dedicated builder Service Account**
   `tsuga-builder@<YOUR_PROJECT>.iam.gserviceaccount.com`.
3. **Grants project-level IAM roles** to the builder SA so it can create the needed resources (GKE, VPC, etc.).
4. **Allows Tsuga CI to impersonate the builder SA**
   by granting **`roles/iam.serviceAccountTokenCreator`** to the **Spacelift GCP Integration Service Account** you provide.
5. **Allows approved developers to impersonate the builder SA**
   by granting **`roles/iam.serviceAccountTokenCreator`** to the identities listed in `developer_impersonators`.

> **Security model:** Only the identities you specify (CI SA and developer principals) can mint short-lived tokens to act as the builder SA. All actions occur in your project under that SA’s permissions.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) **v1.6.0+**
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
- A user with sufficient permissions in the **target project** (e.g. **Owner** or **Editor** + **Project IAM Admin**) to run Terraform.
- Application Default Credentials (ADC) initialized:

  ```sh
  gcloud auth application-default login
  ```

| Variable                         | Required                     |                                                              Example | Description                                                                               |
| -------------------------------- | ---------------------------- | -------------------------------------------------------------------: | ----------------------------------------------------------------------------------------- |
| `project_id`                     | ✅                            |                                                  `customer-prod-123` | Your GCP **project ID** to onboard.                                                       |
| `region`                         | ✅                            |                                                       `europe-west1` | Region used by the providers (and some services).                                         |
| `spacelift_integration_sa_email` | ✅                            |                       `gcp-abc123@spacelift.iam.gserviceaccount.com` | The **Spacelift GCP Integration Service Account** that should impersonate the builder SA. Given to you by Tsuga. |
| `builder_sa_name`                | ❌ (default: `tsuga-builder`) |                                                      `tsuga-builder` | Builder SA account ID (email will be `<name>@<project>.iam.gserviceaccount.com`).         |
| `developer_impersonators`        | ❌                            | `["group:gcp-organization-admins@tsuga.com"]` | Additional **users/groups/SAs** allowed to impersonate the builder SA. Given to you by Tsuga.                    |
| `apis_to_enable`                 | ❌                            |                                                         see defaults | List of services to enable in your project.                                               |
| `builder_project_roles`          | ❌                            |                                                         see defaults | Roles granted to the builder SA at the project level.                                     |

## How to run

```sh
# 0) Authenticate with permissions on the target project
gcloud auth application-default login

# 1) Initialize Terraform
terraform init

# 2) Set the inputs
export GOOGLE_PROJECT_ID="your-gcp-project-id"
export GCP_REGION="europe-west1"
export SPACELIFT_SA_EMAIL="gcp-xxxxx@spacelift.iam.gserviceaccount.com"

# (Optional) Override developer impersonators if Tsuga shared additional ones
# export DEV_IMPERSONATORS='["group:gcp-organization-admins@tsuga.com","group:new_group@tsuga.com"]'

# 3) Apply
terraform apply \
  -var="project_id=${GOOGLE_PROJECT_ID}" \
  -var="region=${GCP_REGION}" \
  -var="spacelift_integration_sa_email=${SPACELIFT_SA_EMAIL}"
  # If overriding:
  # -var='developer_impersonators='"${DEV_IMPERSONATORS}"
```

### Outputs on success

```sh
builder_service_account_email = "tsuga-builder@your-gcp-project-id.iam.gserviceaccount.com"
enabled_apis = [...]
```

### Verify the bindings

Check that Token Creator is granted to the above-mentioned:

```sh
gcloud iam service-accounts get-iam-policy \
  "tsuga-builder@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${GOOGLE_PROJECT_ID}"
# Should include:
#  - roles/iam.serviceAccountTokenCreator
#    - serviceAccount:gcp-xxxxx@spacelift.iam.gserviceaccount.com
#    - group:gcp-organization-admins@tsuga.com (or your overrides)
```
