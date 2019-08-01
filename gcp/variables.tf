variable "project_id" {
  type        = string
  description = "Unique id for the project"
  default     = "kubelearn"
}
variable "region" {
  type        = string
  description = "Region for the project"
  default     = "us-west1"
}

variable "zone" {
  type        = string
  description = "Zone for the project"
  default     = "us-west1-c"
}
