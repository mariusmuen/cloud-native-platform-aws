variable "name" {
  type        = string
  description = "Prefix for all resource names, e.g. cnp-dev"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version of the cluster, e.g. 1.34"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the cluster and the worker nodes"
}
