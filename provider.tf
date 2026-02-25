terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">=7.18.0"
    }
  }
}

# provider "google" {
#   region  = "us-central1"
#   zone    = "us-central1-c"
# }

provider "google" {
  region  = "us-central1"
  zone    = "us-central1-c"
  project = "${var.project_id}"

}

provider "tls" {
  proxy {
    from_env = true
  }
}
# https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build