packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 2.0.0"
    }
  }
}

# Use locals to grab environment variables directly
variable "arm_client_id" {
  default   = "${env("ARM_CLIENT_ID")}"
  sensitive = true
}
variable "arm_client_secret" {
  default   = "${env("ARM_CLIENT_SECRET")}"
  sensitive = true
}
variable "arm_tenant_id" {
  default   = "${env("ARM_TENANT_ID")}"
  sensitive = true

}
variable "arm_subscription_id" {
  default   = "${env("ARM_SUBSCRIPTION_ID")}"
  sensitive = true
}

locals {
  timestamp_safe = formatdate("YYYYMMDDhhmmss", timestamp())
}

source "azure-arm" "windows-avd" {
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
  tenant_id       = var.arm_tenant_id
  subscription_id = var.arm_subscription_id

  os_type   = "Windows"
  vm_size  = "Standard_B2s"
  location = "eastus"

  image_publisher = "MicrosoftWindowsDesktop"
  image_offer     = "windows-11"
  image_sku       = "win11-24h2-pro"

  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_username = "packer"
  winrm_timeout  = "30m"

  managed_image_name                = "avd-image-${local.timestamp_safe}"
  managed_image_resource_group_name = "avd-demo-rg"
}

build {
  sources = ["source.azure-arm.windows-avd"]

  # Enable TLS 1.2 + Chocolatey
  provisioner "powershell" {
    inline = [
      "Set-ExecutionPolicy Bypass -Scope Process -Force",
      "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12",
      "iex ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    ]
  }

  # OPTIONAL: Install basic tools before Ansible
  provisioner "powershell" {
    inline = [
      "choco install -y git 7zip"
    ]
  }

  # 🚀 Run Ansible REMOTELY
  provisioner "ansible" {
    playbook_file = "ansible.yml"
    user          = "packer"
    use_proxy     = false

    extra_arguments = [
      "--extra-vars",
      "ansible_connection=winrm",
      "--extra-vars",
      "ansible_winrm_transport=ntlm",
      "--extra-vars",
      "ansible_winrm_server_cert_validation=ignore"
    ]
  }


  # Sysprep (required for AVD)
  provisioner "powershell" {
    inline = [
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit",
      "while (Get-Process Sysprep -ErrorAction SilentlyContinue) { Start-Sleep 10 }"
    ]
  }
}
