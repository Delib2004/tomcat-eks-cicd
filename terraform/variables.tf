variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "cluster_name" {
  type    = string
  default = "tomcat-eks"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.33"
  description = "Check the EKS console for currently supported versions."
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
