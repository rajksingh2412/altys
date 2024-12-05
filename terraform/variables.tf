# variables.tf

variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
}

variable "db_host" {
  type        = string
  description = "The Cloud SQL MySQL internal hostname"
}

variable "db_user" {
  type        = string
  description = "The MySQL database user"
}

variable "db_password" {
  type        = string
  description = "The MySQL database password"
}

variable "db_name" {
  type        = string
  description = "The MySQL database name"
}
