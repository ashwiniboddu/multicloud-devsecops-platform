resource "google_container_cluster" "gke" {
  name     = local.gke_name
  location = var.region

  project = var.project_id

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  networking_mode = "VPC_NATIVE"

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  release_channel {
    channel = "REGULAR"
  }

  resource_labels = local.common_labels
}

resource "google_container_node_pool" "primary" {
  name     = "${local.gke_name}-nodes"
  location = var.region
  cluster  = google_container_cluster.gke.name

  project = var.project_id

  node_count = 1

  node_config {
    machine_type = "e2-standard-2"

    disk_type    = "pd-standard"
    disk_size_gb = 30

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = local.common_labels
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}