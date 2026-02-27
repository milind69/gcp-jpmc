# create private service attachment 

resource "google_compute_service_attachment" "ilb-psc-attachement" {
  name                  = "${var.app_name}-psc-attachment"
  project               = var.project_id
  region                = var.region
  enable_proxy_protocol = false
  nat_subnets           = [google_compute_subnetwork.psc_nat.id]
  target_service        = google_compute_forwarding_rule.https.id
  connection_preference = "ACCEPT_AUTOMATIC"
}


