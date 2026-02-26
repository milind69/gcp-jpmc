# resource "google_cloud_run_v2_service" "my-fastapi-app" {
#   name                = "${var.app_name}-app"
#   location            = "us-central1"
#   deletion_protection = false
#   #ingress = "INGRESS_TRAFFIC_ALL"
#   ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
#   template {
#     containers {
#       name  = var.app_name
#       image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.my-aft-repo.repository_id}/my-fastapi-app:latest"
#       ports {
#         container_port = 8000
#       }

#       resources {
#         limits = {
#           cpu    = "1"
#           memory = "512Mi"
#         }
#       }
#     }
#     scaling {
#       min_instance_count = 0
#       max_instance_count = 2
#     }
#   }
# }


# resource "google_cloud_run_v2_service_iam_member" "my-fastapi-app-kooltech" {
#   name     = google_cloud_run_v2_service.my-fastapi-app.name
#   location = var.region
#   project  = var.project_id
#   role     = "roles/run.invoker"
#   member   = "user:milind@kooltech.xyz"
# }

# # to use extenal account 
# resource "google_cloud_run_v2_service_iam_member" "my-fastapi-app-external-viewer" {
#   name     = google_cloud_run_v2_service.my-fastapi-app.name
#   location = var.region
#   project  = var.project_id
#   role     = "roles/run.viewer"
#   member   = "user:kulkarni.milind@gmail.com"
# }

# resource "google_cloud_run_v2_service_iam_member" "my-fastapi-app-external-invoker" {
#   name     = google_cloud_run_v2_service.my-fastapi-app.name
#   location = var.region
#   project  = var.project_id
#   role     = "roles/run.invoker"
#   member   = "user:kulkarni.milind@gmail.com"
# }

# resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
#   name                  = "${var.app_name}-neg"
#   project               = var.project_id
#   region                = var.region
#   network_endpoint_type = "SERVERLESS"

#   cloud_run {
#     service = google_cloud_run_v2_service.my-fastapi-app.name
#   }
# }



# resource "google_compute_region_backend_service" "cloud_run_backend_service" {
#   name                            = "${var.app_name}-backend"
#   project                         = var.project_id
#   region                          = var.region
#   protocol                        = "HTTPS"
#   connection_draining_timeout_sec = 10
#   load_balancing_scheme           = "EXTERNAL_MANAGED"
#   timeout_sec                     = 30
#   backend {
#     group           = google_compute_region_network_endpoint_group.cloud_run_neg.id
#     capacity_scaler = 1.0
#   }
# }

# # url map
# resource "google_compute_region_url_map" "cloud_run_url_map" {
#   name            = "${var.app_name}-url-map"
#   project         = var.project_id
#   region          = var.region
#   default_service = google_compute_region_backend_service.cloud_run_backend_service.id
# }




