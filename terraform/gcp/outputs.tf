output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}

output "gke_cluster_name" {
  value = google_container_cluster.gke.name
}

output "artifact_registry_repository" {
  value = google_artifact_registry_repository.application.name
}

output "artifact_registry_location" {
  value = google_artifact_registry_repository.application.location
}