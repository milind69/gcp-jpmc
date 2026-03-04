
resource "google_apigee_instance" "apigee_instance" {
  name     = "${var.app_name}-apigee-instance"
  location = var.region
  org_id   = google_apigee_organization.apigee_org.id
  ip_range = var.apigee_instance_cidr
}





resource "google_apigee_environment" "apigee_env" {
  org_id = google_apigee_organization.apigee_org.id
  name   = "dev"
}


resource "google_apigee_instance_attachment" "apigee_attachment" {
  instance_id = google_apigee_instance.apigee_instance.id
  environment = google_apigee_environment.apigee_env.name
}

resource "google_apigee_envgroup" "apigee_envgroup" {
  name      = "${var.app_name}-apigee-envgroup"
  org_id    = google_apigee_organization.apigee_org.id
  hostnames = ["api.kooltech.xyz"]
}

resource "google_apigee_envgroup_attachment" "apigee_envgroup_attachment" {
  envgroup_id = google_apigee_envgroup.apigee_envgroup.id
  environment = google_apigee_environment.apigee_env.name
  depends_on  = [google_apigee_instance_attachment.apigee_attachment, google_apigee_envgroup.apigee_envgroup]

}
# Get service account associated with Apigee runtime

# gcloud projects get-iam-policy mpk-project-id \
# --flatten="bindings[].members" \ 
# --filter="bindings.members:gcp-sa-apigee" \ 
# --format="value(bindings.members)" 
# serviceAccount:service-548941500570@gcp-sa-apigee.iam.gserviceaccount.com
#member             = "serviceAccount:service-${google_project.myproject.number}@gcp-sa-apigee.iam.gserviceaccount.com"

#impersoname Apigee runtime SA to impersonate cloud run SA
resource "google_service_account_iam_member" "apigee_impersonate_cloud_run_sa" {
  service_account_id = google_service_account.apigee-cloud-runnersa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-927625092652@gcp-sa-apigee.iam.gserviceaccount.com"
}

resource "google_compute_address" "psc_consumer_ip" {
  name         = "${var.app_name}-psc-consumer-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.psc_consumer_subnet.id
}

# PSC consumer forwarding rule
resource "google_compute_forwarding_rule" "psc_consumer" {
  name                  = "${var.app_name}-psc-consumer"
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = "" # empty = PSC consumer
  ip_address            = google_compute_address.psc_consumer_ip.id
  target                = google_compute_service_attachment.ilb-psc-attachement.id
  network               = google_compute_network.vpc-consumer.id
}


resource "google_apigee_endpoint_attachment" "apigee-psc-attachement" {
  org_id                 = google_apigee_organization.apigee_org.id
  endpoint_attachment_id = "${var.app_name}-psc-endpoint"
  location               = var.region
  service_attachment     = google_compute_service_attachment.ilb-psc-attachement.id
  depends_on             = [google_apigee_instance.apigee_instance]
}

# troubleshoot /28 
resource "google_compute_firewall" "apigee_troubleshooting" {
  name    = "allow-apigee-troubleshooting"
  network = google_compute_network.vpc-consumer.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.consumer_app_subnet_cidr}"]
  target_tags   = ["ssh-enabled"]
}
