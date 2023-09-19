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

variable "network_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "v4_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vms_ssh_root_key_file" {
  type        = string
  default     = "/Users/aleksandrgrebeshkov/.ssh/yacloud.pub"
  description = "ssh-keygen -t ed25519"
}

variable "subnet_id" {
type    = string
  default = ""
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
