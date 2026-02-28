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

variable "app_name" {
  type    = string
  default = "my-fastapi-app"
}

variable "local_image" {
  type    = string
  default = "my-fastapi-app:latest"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "psc_nat_subnet_cidr" {
  type    = string
  default = "10.0.2.0/28"
}

variable "ilb_subnet_cidr" {
  type    = string
  default = "10.0.4.0/24"
}

variable "proxy_only_subnet_cidr" {
  type    = string
  default = "10.0.5.0/24"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "apigee_instance_cidr" {
  type    = string
  default = "10.0.3.0/28"
}

variable "apigee_cidr" {
  type    = string
  default = "10.0.1.0/22"
}

variable "apigee_psc_subnet" {
  type    = string
  default = "10.0.6.0/24"
}
