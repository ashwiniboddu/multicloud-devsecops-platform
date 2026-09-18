variable "project_id" {
  description = "GCP Project ID"
  type        = string

  default = "playground-s-11-bfa7194e"
}

variable "region" {
  description = "GCP region"
  type        = string

  default = "us-east1"
}

variable "zone" {
  description = "GCP zone"
  type        = string

  default = "us-east1-d"
}

variable "environment" {
  description = "Environment"
  type        = string

  default = "dev"
}

variable "network_name" {
  description = "VPC network name"
  type        = string

  default = "multicloud-devsecops-vpc"
}

variable "jenkins_subnet_cidr" {
  description = "Jenkins subnet"
  type        = string

  default = "10.40.0.0/24"
}

variable "gke_subnet_cidr" {
  description = "GKE subnet"
  type        = string

  default = "10.10.0.0/20"
}

variable "gke_pods_cidr" {
  description = "GKE pods secondary range"
  type        = string

  default = "10.20.0.0/16"
}

variable "gke_services_cidr" {
  description = "GKE services secondary range"
  type        = string

  default = "10.30.0.0/20"
}

variable "artifact_registry_location" {
  description = "Artifact Registry location"
  type        = string

  default = "us-east1"
}

variable "artifact_registry_repository" {
  description = "Artifact Registry repository"
  type        = string

  default = "multicloud-devsecops"
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string

  default = "multicloud-devsecops-gke"
}