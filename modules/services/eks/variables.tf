variable "vpc_id" {
  description = "vpc id"
  default     = "vpc-07942fa0ef2840a0e"
}

#############
## TAG
#############
variable "env" {
  type        = list(string)
  default     = ["prod", "dev"]
  description = "인프라 환경 정의 prod | dev"
}

variable "prefix" {
  type        = string
  description = "This prefix will be included in the name of most resources."
  default     = "wavving"
}

#####################
## eks-node
#####################

variable "key_pair_name" {
  type        = string
  description = "Key pair 이름 정의"
  default     = "TEST-RSA"
}

variable "subnet_ids" {
  type        = list(string)
  description = "EKS 클러스터 생성에 필요한 서브넷 아이디 목록"
  default     = ["subnet-0efaf3fa37aa333fa", "subnet-0d44ce8366893d89a", "subnet-03f3c342de15a108b", "subnet-00005d24605ff5e25"]
}

variable "eks_scaling_desired" {
  type        = number
  description = "scaling config. initially desired size"
  default     = 2
}

variable "eks_scaling_max" {
  type        = number
  description = "scaling config. max size" ##// max size needs to bigger than 0 (>= 1)
  default     = 4
}

variable "eks_scaling_min" {
  type        = number
  description = "scaling config. min size"
  default     = 2
}

variable "eks_node_ami_id" {
  type        = string
  description = "EKS 노드용 ami id"
  default     = "ami-0ea4d4b8dc1e46212"
}

variable "node_instance_types" {
  type        = string
  description = "EKS 노드 인스턴스 타입 정의"
  default     = "m5.large"
}