resource "google_compute_health_check" "jenkins" {
  name = "multicloud-devsecops-jenkins-health-check"

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 8080
    request_path = "/login"
  }
}

resource "google_compute_backend_service" "jenkins" {
  name                  = "multicloud-devsecops-jenkins-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  health_checks = [
    google_compute_health_check.jenkins.id
  ]

  backend {
    group = google_compute_instance_group.jenkins.id
  }
}

resource "google_compute_instance_group" "jenkins" {
  name = "multicloud-devsecops-jenkins-ig"
  zone = var.zone

  instances = [
    google_compute_instance.jenkins.self_link
  ]

  named_port {
    name = "http"
    port = 8080
  }
}

resource "google_compute_url_map" "jenkins" {
  name            = "multicloud-devsecops-jenkins-url-map"
  default_service = google_compute_backend_service.jenkins.id
}

resource "google_compute_target_http_proxy" "jenkins" {
  name    = "multicloud-devsecops-jenkins-http-proxy"
  url_map = google_compute_url_map.jenkins.id
}

resource "google_compute_global_address" "jenkins" {
  name = "multicloud-devsecops-jenkins-ip"
}

resource "google_compute_global_forwarding_rule" "jenkins" {
  name                  = "multicloud-devsecops-jenkins-forwarding-rule"
  target                = google_compute_target_http_proxy.jenkins.id
  port_range            = "80"
  ip_address            = google_compute_global_address.jenkins.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}