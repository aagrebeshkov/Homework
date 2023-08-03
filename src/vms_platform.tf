### Parameters VM DB

variable "vm_name_2" {
  type        = string
  default     = "db-02"
  description = "VM Name"
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v3"
  description = "db_platform_id"
}

variable "vm_db_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "OS Family"
}


#variable "vm_db_name" {
#  type        = string
#  default     = "netology-develop-platform-db"
#  description = "VM Name"
#}

#variable "vm_db_cores" {
#  type        = number
#  default     = 2
#  description = "CPU"
#}

#variable "vm_db_memory" {
#  type        = number
#  default     = 2
#  description = "Memory"
#}

#variable "vm_db_core_fraction" {
#  type        = number
#  default     = 20
#  description = "core_fraction"
#}