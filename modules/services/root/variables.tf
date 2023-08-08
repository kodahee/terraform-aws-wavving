variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default = "wavving"
}

variable "region" {
  description = "The region where the resources are created."
  default     = "ap-northeast-2"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "internet_gateway" {
  description = "Internet Gateway"
  default     = "0.0.0.0/0"
}

variable "subnets_prefix" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24", "10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24", "10.0.70.0/24"]
}

