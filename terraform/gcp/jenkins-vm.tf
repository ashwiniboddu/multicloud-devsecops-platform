resource "google_compute_instance" "jenkins" {
  name         = "multicloud-devsecops-jenkins"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = [
    "jenkins"
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.jenkins.id
  }

  service_account {
    email = google_service_account.jenkins.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = file("${path.module}/userdata/jenkins.sh")

  depends_on = [
    google_compute_router_nat.main
  ]
}