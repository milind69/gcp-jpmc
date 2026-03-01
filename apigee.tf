
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



# Get service account associated with Apigee runtime

# gcloud projects get-iam-policy mpk-project-id \
# --flatten="bindings[].members" \ 
# --filter="bindings.members:gcp-sa-apigee" \ 
# --format="value(bindings.members)" 
# serviceAccount:service-548941500570@gcp-sa-apigee.iam.gserviceaccount.com

#impersoname Apigee runtime SA to impersonate cloud run SA
resource "google_service_account_iam_member" "apigee_impersonate_cloud_run_sa" {
  service_account_id = google_service_account.apigee-cloud-runnersa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  #member             = "serviceAccount:service-${google_project.myproject.number}@gcp-sa-apigee.iam.gserviceaccount.com"
  member = "serviceAccount:service-927625092652@gcp-sa-apigee.iam.gserviceaccount.com"
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

resource "google_apigee_endpoint_attachment" "cloudrun_endpoint" {
  org_id                 = google_apigee_organization.apigee_org.id
  endpoint_attachment_id = "${var.app_name}-endpoint"
  location               = var.region
  service_attachment     = google_compute_service_attachment.ilb-psc-attachement.id
}


output "apigee_endpoint_host" {
  description = "Use this host in Apigee target endpoint"
  value       = google_apigee_endpoint_attachment.cloudrun_endpoint.host
}


resource "google_apigee_target_server" "cloudrun" {
  name   = "cloudrun-backend"
  env_id = google_apigee_environment.apigee_env.id                  # "dev" or "prod"
  host   = google_apigee_endpoint_attachment.cloudrun_endpoint.host # 7.0.x.x
  port   = 443

  s_sl_info {
    enabled                  = true
    ignore_validation_errors = true # needed since host is an IP not FQDN
  }
}

output "apigee_target_server" {
  value = google_apigee_endpoint_attachment.cloudrun_endpoint
}
# resource "google_apigee_api" "apigee_proxy" {
#   org_id = google_apigee_organization.apigee_org.id
#   name = "{${var.app_name}-proxy}"
#   config_bundle = filebase64("${path/module}/proxy_bundle.zip")

# }

# resource "google_apigee_api_deployment" "apigee_deployment" {
#   org_id = google_apigee_organization.apigee_org.id
#   environment = google_apigee_environment.apigee_env.name
#   proxy_id = google_apigee_api.apigee_proxy.name
#   revision = google_apigee_api.apigee_proxy.latest_revision_id
# }
