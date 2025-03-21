# AlmaLinux 9 on Azure with Terraform

This repository contains a **Terraform configuration** for spinning up an **AlmaLinux 9** virtual machine on **Azure**, complete with:

- Auto-generated SSH key pair  
- Static public IP address  
- A minimal resource group, virtual network, and subnet  
- Outputs for the private key, public IP, and an SSH command  

## Prerequisites

1. **Terraform** installed.  
   - [Install instructions](https://developer.hashicorp.com/terraform/downloads)
2. **Azure CLI** installed (optional but recommended).  
   - [Install instructions](https://learn.microsoft.com/cli/azure/install-azure-cli)
3. **Azure credentials**.  
   - Ensure you’re authenticated:  
     ```bash
     az login
     az account set --subscription <your_subscription_id>
     ```
   - Or use another Terraform-compatible authentication method (like a service principal).

## Usage

1. **Clone** this repository:
   ```bash
   git clone https://github.com/YourOrg/almalinux-terraform-azure.git
   cd almalinux-terraform-azure
   ```

2. **Initialize** Terraform:
   ```bash
   terraform init
   ```

3. **Review** the plan:
   ```bash
   terraform plan
   ```
   - Check if everything looks correct.

4. **Apply** to deploy resources:
   ```bash
   terraform apply
   ```
   - Type `yes` when prompted to confirm.

5. **Review the outputs**:
   - **`ssh_private_key`**: Your RSA private key (in plain text). Copy it and save to a file, e.g. `~/.ssh/id_rsa_alma` (with correct permissions: `chmod 600 ~/.ssh/id_rsa_alma`).  
   - **`public_ip`**: The static public IP address.  
   - **`ssh_command`**: A sample command to SSH into the VM.

## Connecting to the VM

1. **Save** the private key (displayed in your terminal) to a local file:
   ```bash
   vi ~/.ssh/id_rsa_alma
   # Paste the private key
   chmod 600 ~/.ssh/id_rsa_alma
   ```
2. **SSH** into the VM:
   ```bash
   ssh -i ~/.ssh/id_rsa_alma azureuser@<public_ip_from_terraform_output>
   ```

## Cleanup

To **delete** all the resources created by this configuration:

```bash
terraform destroy
```

Confirm with `yes` when prompted.

---
