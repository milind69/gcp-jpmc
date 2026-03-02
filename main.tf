
resource "google_project_organization_policy" "allow_all_members" {
  project    = var.project_id
  constraint = "iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      all = true
    }
  }
}

resource "google_project_service" "apis" {
  project = var.project_id
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "apigee.googleapis.com",
    "servicenetworking.googleapis.com",
    "vpcaccess.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "networkconnectivity.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "networkmanagement.googleapis.com",
    "networksecurity.googleapis.com"
  ])
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_network" "vpc-consumer" {
  name                    = "vpc-consumer"
  project                 = var.project_id
  auto_create_subnetworks = false
  depends_on              = [google_project_service.apis]
}


resource "google_compute_network" "vpc" {
  name                    = "vpc-producer"
  project                 = var.project_id
  auto_create_subnetworks = false
  depends_on              = [google_project_service.apis]
}

resource "google_compute_subnetwork" "app_subnet" {
  name                     = "${var.app_name}-subnet"
  ip_cidr_range            = var.subnet_cidr
  region                   = "us-central1"
  network                  = google_compute_network.vpc.id
  project                  = var.project_id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "consumer_app_subnet" {
  name                     = "${var.app_name}-consumer-subnet"
  ip_cidr_range            = var.consumer_app_subnet_cidr
  region                   = "us-central1"
  network                  = google_compute_network.vpc-consumer.id
  project                  = var.project_id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "psc_nat" {
  name          = "${var.app_name}-psc-nat-subnet"
  ip_cidr_range = var.psc_nat_subnet_cidr
  region        = "us-central1"
  network       = google_compute_network.vpc.id
  project       = var.project_id
  purpose       = "PRIVATE_SERVICE_CONNECT"
}
# Subnet for private IP
resource "google_compute_subnetwork" "ilb_subnet" {
  name          = "${var.app_name}-ilb-subnet"
  ip_cidr_range = var.ilb_subnet_cidr
  region        = "us-central1"
  network       = google_compute_network.vpc.id
  project       = var.project_id
  purpose       = "PRIVATE"
}
# Subnet for proxy rule
resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "${var.app_name}-proxy-only-subnet"
  ip_cidr_range = var.proxy_only_subnet_cidr
  region        = "us-central1"
  network       = google_compute_network.vpc.id
  project       = var.project_id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_subnetwork" "psc_consumer_subnet" {
  name          = "${var.app_name}-psc-consumer-subnet"
  ip_cidr_range = var.apigee_psc_subnet_cidr
  region        = "us-central1"
  network       = google_compute_network.vpc-consumer.id
  project       = var.project_id
  purpose       = "PRIVATE"
}


