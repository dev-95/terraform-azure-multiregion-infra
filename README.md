# Azure Multi-Region Infrastructure Deployment with Terraform

## 📌 Project Objective
This project implements a complete Infrastructure as Code (IaC) workflow to deploy a secure, automated Linux environment across multiple Azure regions. It covers dynamic resource management, custom networking, and automated software configuration.

---

## 🚀 Technical Highlights

### 1. Dynamic Resource Management
- **Logic:** Used `for_each` with a map of logical data centers to Azure regions.
- **Outcome:** Provisioned three Resource Groups (DC1, DC2, DC3) dynamically without repeating code blocks, ensuring a DRY (Don't Repeat Yourself) architecture.

### 2. Networking & Security
- **Virtual Network:** Deployed a VNet with a `10.0.0.0/16` address space and a dedicated subnet.
- **Public Connectivity:** Allocated a **Static Public IP** to ensure consistent access for the web server.
- **Security Hardening:** Implemented a Network Security Group (NSG) with rules for:
  - **SSH (Port 22):** For secure administrative access.
  - **HTTP (Port 80):** To allow web traffic.
- **Association:** Following best practices, the NSG is associated at the **Subnet level** rather than the NIC level.

### 3. Automated VM Provisioning
- **OS:** Ubuntu 22.04 LTS (Jammy) on a `Standard_B1s` instance.
- **Authentication:** Enforced **SSH Key-based authentication** (no passwords).
- **Post-Deployment Automation:** Used Terraform **Provisioners** (`file` and `remote-exec`) to:
  - Transfer a custom `install_apache.sh` script.
  - Automatically install, enable, and start the **Apache2** service.

---



## 🛠️ Project Structure
- `main.tf`: Contains the primary resource logic for RGs, Networking, VM, and Provisioners.
- `providers.tf`: Defines the AzureRM provider and versioning.
- `install_apache.sh`: Bash script used by the provisioner to bootstrap the web server.
- `.gitignore`: Configured to protect sensitive data like `.tfstate` and private SSH keys.

---

## 💻 How to Use
1. **Login:** Run `az login` to authenticate your Azure CLI.
2. **Initialize:** Run `terraform init` to download the required providers.
3. **Review:** Run `terraform plan` to see the execution strategy.
4. **Deploy:** Run `terraform apply -auto-approve` to build the environment.
5. **Verify:** Copy the outputted Public IP into your browser to see the live Apache page.

---

## 🏁 Conclusion
This project demonstrates the ability to manage cloud infrastructure at scale. By moving from manual portal configurations to Terraform, I reduced the deployment time and eliminated the risk of human error in security group configurations.
