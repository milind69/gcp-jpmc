# resource "google_apigee_organization" "apigee_org" {
#     project_id = google_project.myproject.project_id
#     analytics_region = "${var.region}"
#     authorized_network = google_compute_network.vpc.id
#     billing_type = "EVALUATION"
#     depends_on = [ google_service_networking_connection.apigee_vpc_connection ]
# }
