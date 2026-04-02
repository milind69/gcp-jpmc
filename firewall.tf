# Rule 1 — Apigee peering CIDR → PSC endpoint (vpc-consumer)
resource "google_compute_firewall" "allow_apigee_to_psc" {
  name      = "allow-apigee-to-psc"
  project   = var.project_id
  network   = google_compute_network.vpc-consumer.id
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["10.1.0.0/22", "10.0.3.0/28"]
}

# Rule 2 — PSC NAT → ILB (vpc-producer)
resource "google_compute_firewall" "allow_psc_nat" {
  name      = "allow-psc-nat-to-ilb"
  project   = var.project_id
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["10.0.2.0/28"]
}

# Rule 3 — Health checks → backend (vpc-producer)
resource "google_compute_firewall" "allow_health_check" {
  name      = "allow-health-checks"
  project   = var.project_id
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}
