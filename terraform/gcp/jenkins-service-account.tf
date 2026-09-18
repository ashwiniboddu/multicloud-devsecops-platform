resource "google_service_account" "jenkins" {
  account_id   = "multicloud-devsecops-jenkins"
  display_name = "Multicloud DevSecOps Jenkins"
  description  = "Service account used by Jenkins for GCP CI/CD operations"
}

# Artifact Registry access
#resource "google_project_iam_member" "jenkins_artifact_registry" {
#  project = var.project_id
#  role    = "roles/artifactregistry.writer"
#  member  = "serviceAccount:${google_service_account.jenkins.email}"
#}

# GKE access
#resource "google_project_iam_member" "jenkins_container_developer" {
#  project = var.project_id
#  role    = "roles/container.developer"
#  member  = "serviceAccount:${google_service_account.jenkins.email}"
#}

# Service account usage
#resource "google_project_iam_member" "jenkins_service_account_user" {
#  project = var.project_id
# role    = "roles/iam.serviceAccountUser"
#  member  = "serviceAccount:${google_service_account.jenkins.email}"
#}