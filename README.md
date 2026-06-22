# Kubernetes Infrastructure (Terraform)

Terraform code for provisioning GCP infrastructure: VPC, GKE Autopilot cluster, bastion host, RabbitMQ (Helm), and MongoDB (Kubernetes manifests).

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  GCP Project (us-central1)                                      │
│                                                                 │
│  ┌─────────────────── anshu-network (VPC) ───────────────────┐  │
│  │                                                           │  │
│  │  private-subnetwork (10.0.0.0/16)                         │  │
│  │  └── GKE Autopilot cluster (gke-cluster)                  │  │
│  │       ├── RabbitMQ (Helm / Bitnami)                       │  │
│  │       └── MongoDB (StatefulSet, mongodb namespace)        │  │
│  │                                                           │  │
│  │  public-subnetwork (10.1.0.0/24)                          │  │
│  │  └── Bastion host (SSH access)                            │  │
│  │                                                           │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  GCS bucket: anshu-tf-state (remote Terraform state)            │
│  Secret Manager: username, password (RabbitMQ credentials)        │
└─────────────────────────────────────────────────────────────────┘
```

## What gets deployed

| Component | Description |
|-----------|-------------|
| **VPC & subnets** | Custom VPC (`anshu-network`) with a private subnet for GKE and a public subnet for the bastion |
| **GKE Autopilot** | Managed Kubernetes cluster (`gke-cluster`) with dual-stack IPv4/IPv6 networking |
| **Bastion host** | `e2-medium` VM in the public subnet for SSH-based cluster access |
| **RabbitMQ** | Bitnami Helm chart with persistent storage (8 Gi), credentials from Secret Manager |
| **MongoDB** | StatefulSet in the `mongodb` namespace with a headless Service and persistent volume |
| **Terraform state** | Remote backend stored in a GCS bucket |

## Repository structure

```
.
├── main.tf                 # Root module: GCS state bucket, bastion & GKE modules
├── backend.tf              # GCS remote state configuration
├── variables.tf            # Input variables
├── terraform.tfvars        # Variable values (project, region, etc.)
├── secrets.tf              # Secret Manager data sources (RabbitMQ credentials)
├── provisioner.tf          # Applies k8s-manifests/ after Terraform apply
├── modules/
│   ├── gke/
│   │   ├── cluster.tf      # VPC, subnets, GKE cluster, Kubernetes provider
│   │   ├── rabbitmq-helm.tf# RabbitMQ Helm release
│   │   ├── variables.tf
│   │   └── output.tf
│   └── bastion/
│       ├── main.tf         # Bastion VM and SSH firewall rule
│       └── variables.tf
└── k8s-manifests/
    ├── namespace.yaml      # mongodb namespace
    ├── StatefulSet.yaml    # MongoDB StatefulSet
    ├── HeadLessService.yaml
    ├── pv.yaml             # PersistentVolume (GCE disk)
    ├── pvc.yaml
    └── mongoclient.yaml    # Debug client pod
```

## Variables

Defined in `variables.tf`, values in `terraform.tfvars`:

| Variable | Description |
|----------|-------------|
| `project_id` | GCP project ID |
| `region` | GCP region for resources |
| `bastion_name` | Name of the bastion VM |
| `cluster_name` | Intended cluster name (see note below) |
| `namespace` | Kubernetes namespace for Helm deployments |

> **Note:** The GKE cluster name is hardcoded as `gke-cluster` in `modules/gke/cluster.tf`. The `cluster_name` variable is not wired through to the module yet.

## Modules

### `modules/gke`

- Creates VPC (`anshu-network`), private and public subnets
- Provisions GKE Autopilot cluster
- Configures Kubernetes and Helm providers
- Deploys RabbitMQ via Bitnami Helm chart (credentials from Secret Manager)

### `modules/bastion`

- Creates a bastion VM in the public subnet
- Opens SSH (port 22) via firewall rule

## Kubernetes manifests

Applied via `provisioner.tf` (`kubectl apply -f k8s-manifests/`):

- **MongoDB** — StatefulSet with PVC backed by a GCE persistent disk (`my-disk`)
- **Headless Service** — Stable DNS for the MongoDB pod
- **mongo-client** — Debug pod for shell access

## State backend

Remote state is configured in `backend.tf`:

- **Bucket:** `anshu-tf-state`
- **Prefix:** `terraform/state`

The same bucket is also created in `main.tf`.
