output "jenkins_load_balancer_ip" {
  description = "Jenkins Load Balancer IP"
  value       = google_compute_global_address.jenkins.address
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${google_compute_global_address.jenkins.address}"
}

output "artifact_registry_repository" {
  value = google_artifact_registry_repository.docker.name
}

output "artifact_registry_url" {
  value = "${var.artifact_registry_location}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repository}"
}

