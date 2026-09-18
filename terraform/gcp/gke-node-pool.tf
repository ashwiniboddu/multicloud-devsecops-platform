resource "google_container_node_pool" "primary" {

  name     = "primary-node-pool"

  cluster  = google_container_cluster.main.name
  location = var.zone

  node_count = 2

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {

    machine_type = "e2-standard-2"

    disk_size_gb = 30
    disk_type    = "pd-balanced"

    image_type = "COS_CONTAINERD"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = var.environment
      project     = "multicloud-devsecops"
    }

    tags = [
      "gke-node"
    ]
  }
}