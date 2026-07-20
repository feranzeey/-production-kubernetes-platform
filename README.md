# Production Kubernetes Platform (Local, IaC-Managed)

A self-contained local Kubernetes platform built on **Minikube** and provisioned entirely through **Terraform**. The project automatically creates Kubernetes namespaces, deploys an **NGINX Ingress Controller**, **cert-manager**, and a complete **Prometheus + Grafana monitoring stack**, then deploys and exposes a sample NGINX application through an Ingress resource.

This project demonstrates how to build and manage a Kubernetes platform entirely with **Infrastructure as Code (IaC)** instead of manually running `kubectl` or `helm` commands. It also documents the real-world troubleshooting and debugging process encountered during development.

---

# What This Project Demonstrates

- Infrastructure as Code (IaC) using Terraform
- Kubernetes platform automation
- Namespace management with Terraform
- Helm chart deployment through Terraform
- NGINX Ingress Controller deployment
- cert-manager installation
- Prometheus and Grafana monitoring
- Kubernetes application deployment
- Ingress-based routing
- Real-time cluster monitoring
- Practical troubleshooting and debugging of Kubernetes and Terraform

---

# Architecture

![Architecture](docs/architecture.png)

The platform consists of:

- **Minikube** running with the Docker driver on Windows
- Terraform managing all infrastructure
- Kubernetes namespaces
- NGINX Ingress Controller
- Prometheus & Grafana monitoring stack
- cert-manager
- Sample NGINX application
- Ingress routing from the host machine into the Kubernetes cluster

All namespaces, Helm releases, and application deployments are managed by Terraform.

---

# Technology Stack

- Terraform
- Kubernetes
- Minikube
- Docker Desktop
- Helm
- NGINX Ingress Controller
- cert-manager
- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- node-exporter

---

# Project Structure

```text
production-kubernetes-platform/
│
├── terraform/
│   ├── main.tf
│   ├── namespace.tf
│   ├── helm.tf
│   ├── app.tf
│   └── .terraform.lock.hcl
│
├── kubernetes/
│   ├── namespace.yaml
│   └── app.yaml
│
├── screenshots/
│   ├── terraform-apply.png
│   ├── curl-ingress-response.png
│   ├── grafana-dashboards.png
│   └── grafana-explore-cpu-data.png
│
├── docs/
│   └── architecture.png
│
└── README.md
```

---

# Prerequisites

Install the following tools before starting:

- Docker Desktop
- Minikube
- kubectl
- Terraform (v1.5+)
- Helm

Verify installation:

```bash
docker --version
minikube version
kubectl version --client
terraform version
helm version
```

---

# Start the Kubernetes Cluster

```bash
minikube start
```

Verify the cluster:

```bash
kubectl get nodes
```

Expected output:

```text
NAME       STATUS
minikube   Ready
```

---

# Deploy the Platform

Navigate into the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Review the execution plan:

```bash
terraform plan
```

Deploy the platform:

```bash
terraform apply
```

Type:

```text
yes
```

when prompted.

Terraform creates:

- Kubernetes namespaces
- Sample application
- NGINX Ingress Controller
- kube-prometheus-stack
- cert-manager

---

# Verify Terraform

```bash
terraform state list
```

Example:

```text
helm_release.ingress
helm_release.monitoring
helm_release.cert_manager

kubernetes_namespace.ingress
kubernetes_namespace.monitoring
kubernetes_namespace.cert_manager
kubernetes_namespace.production

null_resource.deploy_app
```

---

# Verify Kubernetes Resources

Namespaces

```bash
kubectl get namespaces
```

Pods

```bash
kubectl get pods -A
```

Services

```bash
kubectl get svc -A
```

Ingress

```bash
kubectl get ingress -A
```

---

# Access the Sample Application

Because Minikube is running with the Docker driver on Windows, the cluster IP is not directly reachable from the host machine.

Start a local tunnel:

```bash
minikube service ingress-nginx-controller -n ingress --url
```

Keep the terminal open.

Open the generated URL in your browser.

Verify the application:

```bash
curl -H "Host: nginx.local" http://127.0.0.1:<generated-port>
```

Expected response:

```html
Welcome to nginx!
```

---

# Access Grafana

Generate the Grafana URL:

```bash
minikube service monitoring-grafana -n monitoring --url
```

Retrieve the admin password:

```bash
kubectl get secret monitoring-grafana \
-n monitoring \
-o jsonpath="{.data.admin-password}" | base64 -d
```

Default username:

```text
admin
```

Grafana includes dashboards for:

- Cluster health
- Nodes
- Pods
- CPU
- Memory
- Networking
- Alertmanager
- Kubernetes workloads

---

# Verify Metrics

Open **Grafana Explore** and run:

```promql
rate(container_cpu_usage_seconds_total{namespace!=""}[5m])
```

The query should return live CPU usage from Kubernetes workloads.

---

# Screenshots

Include screenshots such as:

- Terraform Apply
- Kubernetes Pods
- Ingress Response
- Grafana Dashboard
- Grafana Explore
- Prometheus Targets

---

# Troubleshooting

## 1. Helm Provider Version Conflict

Terraform initially downloaded Helm Provider v3.x, which removed the legacy provider syntax.

Solution:

```hcl
helm = {
  source  = "hashicorp/helm"
  version = "= 2.17.0"
}
```

---

## 2. Duplicate Provider Configuration

Terraform reads every `.tf` file in a directory.

Having multiple default provider blocks caused duplicate provider errors.

Solution:

Consolidate provider definitions into a single file.

---

## 3. Existing Kubernetes Resources

Resources previously created with:

```bash
kubectl apply
```

or

```bash
helm install
```

conflicted with Terraform.

Solution:

Delete existing resources or import them into Terraform state.

---

## 4. ingress-nginx Installation Timeout

The Helm chart defaults to a LoadBalancer Service, which remains pending in Minikube.

Solution:

Configure the controller as a NodePort:

```hcl
set {
  name  = "controller.service.type"
  value = "NodePort"
}
```

---

## 5. Windows + Docker Driver Networking

The Minikube IP is not directly accessible.

Solution:

```bash
minikube service <service-name> --url
```

---

## 6. Grafana Dashboard Showing "No Data"

Some default dashboards expect labels unavailable in a single-node Minikube cluster.

Verification using Grafana Explore confirmed Prometheus was collecting metrics successfully.

---

## 7. Control Plane Metrics

Some control plane metrics remain unavailable because Minikube exposes them only on localhost.

Known affected components:

- kube-controller-manager
- kube-scheduler
- etcd

---

# Key Learning Outcomes

This project demonstrates practical experience with:

- Infrastructure as Code
- Terraform
- Kubernetes
- Helm
- NGINX Ingress
- Prometheus
- Grafana
- Kubernetes networking
- Monitoring and observability
- Debugging Terraform deployments
- Debugging Kubernetes networking
- Managing cloud-native infrastructure

---

# Author

**Oluwaferanmi Dada**

GitHub: https://github.com/feranzeey