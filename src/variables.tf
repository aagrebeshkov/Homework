### Cloud Vars

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
  description = "VPC network & subnet name"
}


### SSH Vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVDE863aMMMsd7wnCHM7Htpt0NixNimwyGD3Eelmzqn aleksandrgrebeshkov@MBP-Aleksandr"
  description = "ssh-keygen -t ed25519"
}

### Parameters VM

variable "vm_name_1" {
  type        = string
  default     = "web-01"
  description = "VM Name"
}

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

### MAP

variable "vms_resources" {
  type     = map(map(number))
  default  = {
    vm_web_resources = {
      "vm_web_cores"         = 2
      "vm_web_memory"        = 1
      "vm_web_core_fraction" = 20
    }
    vm_db_resources = {
      "vm_db_cores"         = 2
      "vm_db_memory"        = 2
      "vm_db_core_fraction" = 20
    }
  }
}


#variable "vm_web_name" {
#  type        = string
#  default     = "netology-develop-platform-web"
#  description = "VM Name"
#}

#variable "vm_web_cores" {
#  type        = number
#  default     = 2
#  description = "CPU"
#}

#variable "vm_web_memory" {
#  type        = number
#  default     = 1
#  description = "Memory"
#}

#variable "vm_web_core_fraction" {
#  type        = number
#  default     = 20
#  description = "core_fraction"
#}

