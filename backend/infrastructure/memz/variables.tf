variable "environment" {
  type        = "string"
  description = "The stage of development this service should be tagged as"
}

variable "cluster_name" {
  type        = "string"
  description = "The cluster to launch this service into"
}

variable "repository_address" {
  type        = "string"
  description = "The address for the Docker repository (ECR)"
}

variable "secret_key_base" {
  type        = "string"
  description = "The phoenix secret key base"
}

variable "guardian_secret_key" {
  type        = "string"
  description = "The guardian secret key"
}

variable "postgres_password" {
  type        = "string"
  description = "The database password for the application"
}

variable "aws_region" {
  type        = "string"
  description = "The AWS region"
}

variable "domain" {
  type        = "string"
  description = "The domain name for the service (environment)"
}

variable "container_version" {
  type        = "string"
  description = "The version of the container to deploy"
}

variable "weave_cidr" {
  type        = "string"
  description = "The Weave subnet to join. This should be unique across applications/environments"
}
