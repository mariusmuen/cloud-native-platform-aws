variable "project" {
  type        = string
  default     = "cnp"
  description = "name of the project"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev or prod)"
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "region of the project"
}
