
resource "google_project_organization_policy" "allow_all_members" {
  project    = "${var.project_id}"
  constraint = "iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      all = true
    }
  }
}

resource "google_project_service" "apis" {
  project = "${var.project_id}"
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
    "cloudresourcemanager.googleapis.com"
  ])
  service            = each.value
  disable_on_destroy = false
}




resource "google_compute_network" "vpc" {
  name = "vpc-producer"
  project = "${var.project_id}"
  auto_create_subnetworks = false 
  depends_on = [ google_project_service.apis ]
}

resource "google_compute_subnetwork" "app_subnet" {
  name = "${var.app_name}-subnet"
  ip_cidr_range = "${var.subnet_cidr}"
  region = "us-central1"
  network = google_compute_network.vpc.id
  project = "${var.project_id}"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "psc_nat" {
  name = "${var.app_name}-psc-nat-subnet"
  ip_cidr_range = "${var.psc_nat_subnet_cidr}"
  region = "us-central1"
  network = google_compute_network.vpc.id
  project = "${var.project_id}"
  purpose = "PRIVATE_SERVICE_CONNECT"
}

resource "google_compute_subnetwork" "ilb_subnet" {
  name = "${var.app_name}-ilb-subnet"
  ip_cidr_range = "${var.ilb_subnet_cidr}"
  region = "us-central1"
  network = google_compute_network.vpc.id
  project = "${var.project_id}"
}
