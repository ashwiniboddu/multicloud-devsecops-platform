resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "multicloud-devsecops-allow-iap-ssh"
  network = google_compute_network.main.id

  direction = "INGRESS"

  source_ranges = [
    "35.235.240.0/20"
  ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = [
    "jenkins"
  ]

  description = "Allow SSH through Google Cloud IAP"
}

resource "google_compute_firewall" "allow_internal" {
  name    = "multicloud-devsecops-allow-internal"
  network = google_compute_network.main.id

  direction = "INGRESS"

  source_ranges = [
    "10.10.0.0/20",
    "10.40.0.0/24"
  ]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "multicloud-devsecops-allow-health-checks"
  network = google_compute_network.main.id

  direction = "INGRESS"

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  allow {
    protocol = "tcp"
  }

  target_tags = [
    "jenkins"
  ]
}

resource "google_compute_firewall" "allow_jenkins_lb" {
  name    = "multicloud-devsecops-allow-jenkins-lb"
  network = google_compute_network.main.id

  direction = "INGRESS"

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags = [
    "jenkins"
  ]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  description = "Allow GCP Load Balancer to reach Jenkins"
}