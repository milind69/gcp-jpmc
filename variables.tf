variable "project_id" {
    type = string
}

variable "project" {
    type = string
}

variable "billing_account" {
  type = string
}

variable "org_id" {
   type = string
}

variable "domain_id" {
  type = string
}

variable "app_name"  {
    type = string
    default = "my-fastapi-app"
}

variable "local_image" {
  type  = string
  default = "my-fastapi-app:latest"
}

variable "subnet_cidr" {
  type = string
  default = "10.0.0.0/24"
}

variable "apigee_cidr" {
  type = string
  default = "10.1.0.0/22"
}

variable "psc_nat_subnet_cidr" {
  type = string
  default = "10.2.0.0/28"
}

variable "apigee_instance_cidr" {
  type = string
  default = "10.3.0.0/28"
}

variable "ilb_subnet_cidr" {
  type = string
  default = "10.4.0.0/24"
}

variable "proxy_only_subnet_cidr" {
  type = string
  default = "10.5.0.0/23"
}

variable "region" {
  type = string
  default = "us-central1"
}