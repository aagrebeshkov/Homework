variable "default_zone" {
  type        = string
  default     = null
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "network_name" {
  type        = string
  default     = null
  description = "VPC network&subnet name"
}

variable "v4_cidr_blocks" {
  type        = list(string)
  #default     = ["10.0.1.0/24"]
  default     = null
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
