###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}


### SSH Vars
#variable "vms_ssh_root_key" {
#  type        = string
#  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVDE863aMMMsd7wnCHM7Htpt0NixNimwyGD3Eelmzqn aleksandrgrebeshkov@MBP-Aleksandr"
#  description = "ssh-keygen -t ed25519"
#}

variable "vms_ssh_root_key_file" {
  type        = string
  default     = "/Users/aleksandrgrebeshkov/.ssh/yacloud.pub"
#  default     = file(/Users/aleksandrgrebeshkov/.ssh/yacloud.pub)
  description = "ssh-keygen -t ed25519"
}

### Parameters VM
variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v3"
  description = "platform_id"
}

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "OS Family"
}

variable "vm_web_resources" {
  type                   = map(number)
  default                = {
    vm_web_cores         = 2
    vm_web_memory        = 1
    vm_web_core_fraction = 20
  }
  description            = "resources VM"
}


### For_each VM
variable "vm_resources_main" {
  type                   = map(number)
  default                = {
    #vm_name       = "main"
    cpu           = 4
    ram           = 2
    disk          = 6
    core_fraction = 20
  }
  description            = "resources VM main"
}

variable "vm_resources_replica" {
  type                   = map(number)
  default                = {
    #vm_name       = "replica"
    cpu           = 2
    ram           = 3
    disk          = 10
    core_fraction = 20
  }
  description            = "resources VM replica"
}

### disk_vm
variable "disk_size_vm" {
  type        = number
  default     = 1
  description = "disk vm"
}

variable "disk_block_size_vm" {
  type        = number
  default     = 4096
  description = "disk vm"
}
