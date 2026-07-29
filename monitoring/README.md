# Monitoring Stack

This directory contains the monitoring configuration for the Multi-Cloud DevSecOps Platform.

## Components

- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- kube-state-metrics

## Architecture

Kubernetes Cluster
        |
        v
Prometheus
        |
        v
Grafana

Prometheus collects metrics from:

- Kubernetes nodes
- Kubernetes pods
- Kubernetes deployments
- Kubernetes services
- Application workloads

Grafana visualizes the collected metrics.

## Installation

Add the Prometheus Community Helm repository:

    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

Update repositories:

    helm repo update

Create monitoring namespace:

    kubectl apply -f namespace.yaml

Install kube-prometheus-stack:

    helm upgrade --install kube-prometheus-stack \
      prometheus-community/kube-prometheus-stack \
      --namespace monitoring \
      --create-namespace \
      -f prometheus/values.yaml \
      -f grafana/values.yaml

Apply alert rules:

    kubectl apply -f prometheus/alert-rules.yaml \
      -n monitoring

Verify monitoring pods:

    kubectl get pods -n monitoring

Verify services:

    kubectl get svc -n monitoring

## Access Grafana

Get Grafana pods:

    kubectl get pods -n monitoring

Port-forward Grafana:

    kubectl port-forward \
      svc/kube-prometheus-stack-grafana \
      3000:80 \
      -n monitoring

Open:

    http://localhost:3000

Default username:

    admin

The password should be changed before production deployment.

## Access Prometheus

Port-forward:

    kubectl port-forward \
      svc/kube-prometheus-stack-prometheus \
      9090:9090 \
      -n monitoring

Open:

    http://localhost:9090