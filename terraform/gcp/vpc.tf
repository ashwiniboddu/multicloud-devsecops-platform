resource "google_compute_network" "vpc" {
  name                    = local.vpc_name
  auto_create_subnetworks = false

  description = "VPC for ${local.project_name} ${var.environment} environment"

  project = var.project_id
}