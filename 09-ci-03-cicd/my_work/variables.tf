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

variable "ssh_public_key" {
  type        = string
  default     = "/Users/aleksandrgrebeshkov/.ssh/yacloud.pub"
  description = "ssh-keygen -t ed25519"
}

variable "subnet_id" {
type    = string
  default = ""
}

variable "vm_family" {
  type        = string
  #default     = "ubuntu-2004-lts"
  default     = "centos-7"
  description = "OS Family"
}

variable "vm_platform_id" {
  type        = string
  default     = "standard-v3"
  description = "platform_id"
}



### For_each VM
variable "vm_resources" {
  description = "resources VM"
  type = list(object(
    {
      vm_name       = string
      cpu           = number
      ram           = number
      disk          = number
      core_fraction = number
  }))
  default = [
    {
      vm_name       = "sonar-01"
      cpu           = 2
      ram           = 4
      disk          = 10
      core_fraction = 20
    },
    {
      vm_name       = "nexus-01"
      cpu           = 2
      ram           = 4
      disk          = 10
      core_fraction = 20
    }
  ]
}
