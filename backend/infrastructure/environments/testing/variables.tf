variable "repository_address" {
  type        = "string"
  description = "The address for the Docker repository (ECR)"
}

variable "secret_key_base" {
  type        = "string"
  description = "The phoenix secret key base"
}

variable "postgres_password" {
  type        = "string"
  description = "The database password for the application"
}

variable "guardian_secret_key" {
  type        = "string"
  description = "The guardian secret key"
}

variable "container_version" {
  type        = "string"
  description = "The version of the container to deploy"
}
