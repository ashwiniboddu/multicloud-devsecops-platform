resource "google_compute_firewall" "allow_internal" {
  name    = "${local.project_name}-${var.environment}-allow-internal"
  network = google_compute_network.vpc.name

  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "10.10.0.0/20",
    "10.20.0.0/16",
    "10.30.0.0/20"
  ]
}