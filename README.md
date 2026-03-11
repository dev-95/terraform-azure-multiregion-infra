# Azure Multi-Region Infrastructure Deployment with Terraform

> Fully automated, multi-region Linux infrastructure on Microsoft Azure — provisioned entirely via Infrastructure as Code using Terraform.

---

## 📌 Project Objective

This project implements a complete **Infrastructure as Code (IaC)** workflow to deploy a secure, automated Linux environment across multiple Azure regions. It covers dynamic resource management, custom networking, and automated software configuration — eliminating manual portal work and reducing the risk of human error.

---

## 🏗️ Architecture Overview

```
Terraform (IaC)
    ├── Resource Groups (DC1, DC2, DC3) — dynamic for_each
    ├── Virtual Network (10.0.0.0/16)
    │     └── Subnet + NSG (SSH :22, HTTP :80)
    ├── Static Public IP
    └── Ubuntu 22.04 LTS VM (Standard_B1s)
          └── Apache2 (auto-installed via Provisioner)
```

---

## 🚀 Technical Highlights

### 1. Dynamic Resource Management

- Used Terraform `for_each` with a map of logical data centers to Azure regions
- Provisioned **three Resource Groups (DC1, DC2, DC3)** dynamically — no repeated code blocks
- Follows **DRY (Don't Repeat Yourself)** architecture principles

### 2. Networking & Security

| Component | Detail |
|---|---|
| Virtual Network | `10.0.0.0/16` address space |
| Subnet | Dedicated subnet within the VNet |
| Public IP | Static allocation for consistent access |
| NSG Rules | SSH (Port 22) + HTTP (Port 80) |
| NSG Association | Applied at **Subnet level** (best practice, not NIC level) |

### 3. Automated VM Provisioning

- **OS:** Ubuntu 22.04 LTS (Jammy) on `Standard_B1s`
- **Authentication:** SSH key-based only — no password access
- **Post-Deployment Automation** via Terraform Provisioners:
  - `file` provisioner: transfers custom `install_apache.sh` to the VM
  - `remote-exec` provisioner: installs, enables, and starts the Apache2 web server automatically

---

## 🛠️ Tech Stack

| Layer | Tool |
|---|---|
| Language | HCL (Terraform) |
| Cloud Provider | Microsoft Azure |
| OS | Ubuntu 22.04 LTS |
| Web Server | Apache2 |
| Scripting | Bash |
| Auth | SSH Key-Based |

---

## 📁 Project Structure

```
azure-terraform-apache-deploy/
├── main.tf             # Primary resource logic: RGs, Networking, VM, Provisioners
├── providers.tf        # AzureRM provider definition and versioning
├── install_apache.sh   # Bash bootstrap script for Apache2 installation
└── .gitignore          # Protects .tfstate files and private SSH keys
```

---

## 💻 Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- An active Azure subscription
- An SSH key pair generated locally

### Deployment Steps

```bash
# 1. Authenticate with Azure
az login

# 2. Initialize Terraform and download providers
terraform init

# 3. Preview the execution plan
terraform plan

# 4. Deploy the infrastructure
terraform apply -auto-approve
```

### Verify Deployment

Once `apply` completes, copy the **outputted Public IP** into your browser — you should see the live Apache2 default page confirming a successful deployment.

---

## 🧹 Teardown

To destroy all provisioned resources and avoid unnecessary Azure charges:

```bash
terraform destroy -auto-approve
```

---

## 📚 Key Learnings

- Terraform `for_each` enables scalable, DRY multi-region deployments without code duplication
- NSG association at the subnet level (vs NIC level) is the recommended Azure security practice
- Terraform Provisioners (`file` + `remote-exec`) bridge the gap between infrastructure provisioning and application configuration
- SSH key enforcement removes password-based attack vectors from day one

---

## 👤 Author

**Devesh Chowdary Chalasani**  
Cloud & DevOps Engineer  
[LinkedIn](https://www.linkedin.com/in/) · [GitHub](https://github.com/dev-95)
