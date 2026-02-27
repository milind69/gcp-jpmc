

# resource "google_apigee_instance" "apigee_instance" {
#     name = "${var.app_name}-apigee-instance"
#     location = "${var.region}"
#     org_id = google_apigee_organization.apigee_org.id

# }

# resource "google_apigee_environment" "apigee_env" {
#    org_id = google_apigee_organization.apigee_org.id
#    name = "dev"
# }



# resource "google_apigee_instance_attachment" "apigee_attachment" {
#     instance_id = google_apigee_instance.apigee_instance.id 
#     environment = google_apigee_environment.apigee_env.name
# }



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
  member             = "serviceAccount:service-${google_project.myproject.number}@gcp-sa-apigee.iam.gserviceaccount.com"
  #member = "serviceAccount:service-548941500570@gcp-sa-apigee.iam.gserviceaccount.com"
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
