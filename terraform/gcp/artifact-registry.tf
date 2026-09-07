resource "google_artifact_registry_repository" "application" {
  location      = var.region
  repository_id = "${local.project_name}-${var.environment}-app"
  description   = "Docker repository for ${local.project_name}"
  format        = "DOCKER"

  project = var.project_id
}