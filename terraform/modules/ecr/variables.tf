variable "name" {
  type        = string
  description = "Prefix for the repository names, e.g. cnp → cnp/frontend"
}

variable "repositories" {
  type        = list(string)
  description = "Service names to create a repository for, e.g. [\"frontend\", \"cartservice\"]"
}

variable "keep_last_images" {
  type        = number
  default     = 10
  description = "Number of images to keep per repository; older ones are expired by the lifecycle policy"
}
