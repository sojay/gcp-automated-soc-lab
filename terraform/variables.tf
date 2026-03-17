variable "project_id" {
  description = "GCP project ID where network resources will be created."
  type        = string
}

variable "region" {
  description = "Primary GCP region for subnet resources."
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "Name for the custom VPC network."
  type        = string
  default     = "soclab-vpc"
}

variable "public_honeypot_subnet_name" {
  description = "Subnet name for public honeypot workloads such as Cowrie."
  type        = string
  default     = "public-honeypot-subnet"
}

variable "public_honeypot_subnet_cidr" {
  description = "CIDR block for the public honeypot subnet."
  type        = string
  default     = "10.10.2.0/24"
}

variable "tools_subnet_name" {
  description = "Subnet name for private tooling workloads such as Grafana and Loki."
  type        = string
  default     = "tools-subnet"
}

variable "tools_subnet_cidr" {
  description = "CIDR block for the tools subnet."
  type        = string
  default     = "10.10.3.0/24"
}

variable "cowrie_allowed_ssh_source_ranges" {
  description = "Source CIDRs allowed to reach Cowrie SSH port 22."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "admin_ssh_allowed_source_ranges" {
  description = "Source CIDRs allowed for admin SSH access on port 2022."
  type        = list(string)
  default     = []
}

variable "cowrie_target_tags" {
  description = "Network tags used to target Cowrie firewall rule on port 22."
  type        = list(string)
  default     = ["cowrie-honeypot"]
}

variable "cowrie_admin_target_tags" {
  description = "Network tags used to target admin SSH firewall rule on port 2022."
  type        = list(string)
  default     = ["cowrie-admin"]
}

variable "logging_vm_target_tags" {
  description = "Network tags used to target logging VM firewall rules."
  type        = list(string)
  default     = ["soc-logging"]
}

variable "iap_ssh_source_ranges" {
  description = "Source CIDRs used by Google IAP TCP forwarding for SSH."
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "create_cowrie_vm" {
  description = "Whether to create a Cowrie VM from the template."
  type        = bool
  default     = false
}

variable "cowrie_vm_name" {
  description = "Name for the Cowrie VM instance."
  type        = string
  default     = "cowrie-1"
}

variable "cowrie_zone" {
  description = "Zone where the Cowrie VM should run. If null, defaults to <region>-a."
  type        = string
  default     = null
  nullable    = true
}

variable "cowrie_machine_type" {
  description = "Machine type for the Cowrie VM."
  type        = string
  default     = "e2-micro"
}

variable "cowrie_boot_disk_image" {
  description = "Boot disk image for the Cowrie VM."
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-12"
}

variable "cowrie_boot_disk_size_gb" {
  description = "Boot disk size in GB for the Cowrie VM."
  type        = number
  default     = 20
}

variable "cowrie_boot_disk_type" {
  description = "Boot disk type for the Cowrie VM."
  type        = string
  default     = "pd-standard"
}

variable "cowrie_enable_public_ip" {
  description = "Whether to assign an external IP to the Cowrie VM."
  type        = bool
  default     = false
}

variable "cowrie_reserved_external_ip_name" {
  description = "Optional reserved regional external IP name to attach when public IP is enabled."
  type        = string
  default     = null
  nullable    = true
}

variable "cowrie_attach_honeypot_tag" {
  description = "Whether to attach the public Cowrie SSH tag to the VM. Keep false until Cowrie is installed."
  type        = bool
  default     = false
}

variable "cowrie_vm_tags" {
  description = "Additional network tags for the Cowrie VM."
  type        = list(string)
  default     = []
}

variable "cowrie_enable_oslogin" {
  description = "Enable OS Login on the Cowrie VM."
  type        = bool
  default     = true
}

variable "cowrie_admin_ssh_public_key" {
  description = "Optional SSH public key for local testing when OS Login is disabled."
  type        = string
  default     = ""
}

variable "cowrie_admin_ssh_username" {
  description = "Linux username to pair with cowrie_admin_ssh_public_key metadata."
  type        = string
  default     = "adminuser"
}

variable "cowrie_admin_ssh_port" {
  description = "Admin SSH port configured on the Cowrie VM."
  type        = number
  default     = 2022
}

variable "cowrie_enable_bootstrap" {
  description = "Whether to install Docker and run the Cowrie container at VM boot."
  type        = bool
  default     = true
}

variable "cowrie_container_image" {
  description = "Container image used for the Cowrie honeypot service."
  type        = string
  default     = "cowrie/cowrie"
}

variable "cowrie_container_host_port" {
  description = "Host port exposed on the VM for Cowrie."
  type        = number
  default     = 22
}

variable "cowrie_service_account_email" {
  description = "Service account email attached to the Cowrie VM."
  type        = string
  default     = "default"
}

variable "create_logging_vm" {
  description = "Whether to create the private logging VM."
  type        = bool
  default     = false
}

variable "logging_vm_name" {
  description = "Name for the logging VM instance."
  type        = string
  default     = "logging-1"
}

variable "logging_zone" {
  description = "Zone where the logging VM should run. If null, defaults to <region>-a."
  type        = string
  default     = null
  nullable    = true
}

variable "logging_machine_type" {
  description = "Machine type for the logging VM."
  type        = string
  default     = "e2-small"
}

variable "logging_boot_disk_image" {
  description = "Boot disk image for the logging VM."
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-12"
}

variable "logging_boot_disk_size_gb" {
  description = "Boot disk size in GB for the logging VM."
  type        = number
  default     = 30
}

variable "logging_boot_disk_type" {
  description = "Boot disk type for the logging VM."
  type        = string
  default     = "pd-standard"
}

variable "logging_enable_oslogin" {
  description = "Enable OS Login on the logging VM."
  type        = bool
  default     = true
}

variable "logging_vm_tags" {
  description = "Additional network tags for the logging VM."
  type        = list(string)
  default     = []
}

variable "logging_service_account_email" {
  description = "Service account email attached to the logging VM."
  type        = string
  default     = "default"
}
