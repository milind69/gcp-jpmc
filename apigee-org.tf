resource "google_apigee_organization" "apigee_org" {
  project_id         = var.project_id
  analytics_region   = var.region
  authorized_network = google_compute_network.vpc-consumer.id
  billing_type       = "PAYG"
  depends_on         = [google_service_networking_connection.apigee_vpc_connection]
}

# Reserve IP range for VPC Peering with Google services 
resource "google_compute_global_address" "apigee_range" {
  name          = "${var.app_name}-apigee-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 22
  network       = google_compute_network.vpc-consumer.id
  project       = var.project_id
  address       = split("/", var.apigee_cidr)[0]
}

# Service Networking Connection to VPC for Apigee
resource "google_service_networking_connection" "apigee_vpc_connection" {
  network                 = google_compute_network.vpc-consumer.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_range.name]

}

# troubleshoot /28 
resource "google_compute_firewall" "apigee_troubleshooting" {
  name    = "allow-apigee-troubleshooting"
  network = google_compute_network.vpc-consumer.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.0.3.0/28"]
}
