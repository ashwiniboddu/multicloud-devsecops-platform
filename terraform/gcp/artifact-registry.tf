resource "google_artifact_registry_repository" "docker" {
  location      = var.artifact_registry_location
  repository_id = var.artifact_registry_repository

  description = "Multicloud DevSecOps Docker Repository"
  format      = "DOCKER"

  depends_on = [
    google_project_service.artifact_registry
  ]
}