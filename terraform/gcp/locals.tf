locals {
  project_name = "multicloud-devsecops"

  common_labels = {
    project     = "multicloud-devsecops"
    environment = var.environment
    managed_by  = "terraform"
  }

  vpc_name    = "${local.project_name}-${var.environment}-vpc"
  subnet_name = "${local.project_name}-${var.environment}-subnet"
  gke_name    = "${local.project_name}-${var.environment}-gke"
}